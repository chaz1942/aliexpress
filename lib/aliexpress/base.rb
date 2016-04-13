# -*- encoding : utf-8 -*-
require 'openssl' # 生成特定的验证码
require 'redis'
require 'json'
module Aliexpress
  class Base

    # TODO: 多用户的关键， 在 redis key 的命名上做文章
    # 获取 code 的过程中，可以传递一个参数，速卖通会原样返回这个参数值。此时，把这个值
    # 与用户名生成一个 redis key
    ACCESS_TOKEN_KEY = 'aliexpress_access_token_key'.freeze
    REFRESH_TOKEN_KEY = 'aliexpress_refresh_token_key'.freeze

    # 将 +配置信息+ 放在单独的模块中。
    extend Aliexpress::Configure

    # API 封装调用接口封装
    #
    # @param [string] api_name - 速卖通 API 的名字
    # @param [Hash] params - api 的应用级参数
    # @param [Hash] body - api 请求body
    #
    def self.api_endpoint(api_name, params = {}, body = {})
      _api_endpoint(api_name: api_name, params: params, body: body)
    end

    protected

    # 通过 redis 获取 token，并设置过期时间
    #
    # @return 返回获取 access_token
    def self.access_token
      token = redis.get ACCESS_TOKEN_KEY

      return token if token.present?

      refresh_access_token
    end

    # 通过 redis 获取 refresh_token, 并设置过期时间
    #
    # @return 返回 refresh_token
    def self.refresh_token
      token = redis.get REFRESH_TOKEN_KEY

      if token.present?
        token
      else
        raise ValidRefreshTokenException, 'Refresh token cannot be empty !'
      end
    rescue => e
      puts e
      puts 'should redirect to Authorization.get_auth_url'
    end

    #
    # 设置访问 token
    #
    # @param response [Hash] - 获取
    def self.set_access_token(response)
      token = response['access_token']

      redis.multi do
        redis.set ACCESS_TOKEN_KEY, token
        redis.expire ACCESS_TOKEN_KEY, response['expires_in']
      end

      token
    end

    #
    # 设置 refresh code
    #
    # @param response [Hash] - 接口返回的值
    def self.set_refresh_token(response)
      token = response['refresh_token']

      redis.multi do
        redis.set REFRESH_TOKEN_KEY, token
        redis.expireat REFRESH_TOKEN_KEY, Time.parse(response['refresh_token_timeout'])
      end

      token
    end

    #
    # 重新获取 access_token
    #
    def self.refresh_access_token
      token_url = 'https://gw.api.alibaba.com/openapi/param2/1/system.oauth2/getToken'

      options = {
          grant_type: 'refresh_token',
          client_id: app_key,
          client_secret: app_secret,
          refresh_token: refresh_token
      }

      token_url = "#{token_url}/#{app_key}?#{options.map { |k, v| "#{k}=#{v}" }.join('&')}"

      puts token_url

      response = JSON.parse Nestful.post(token_url)

      puts response

      set_access_token(response)
    end


    #
    # 在 refresh_token 未过期前重新请求 refresh_token
    #
    def self.get_refresh_token
      refresh_token_url = 'https://gw.api.alibaba.com/openapi/param2/1/system.oauth2/postponeToken'

      options = {
          client_id: app_key,
          client_secret: app_secret,
          refresh_token: refresh_token,
          access_token: access_token
      }

      token_url = "#{refresh_token_url}/#{app_key}?#{options.map { |k, v| "#{k}=#{v}" }.join('&')}"

      # RestClient 发送 post 请求，报 RestClient::BadRequest: 400 Bad Request
      response = JSON.parse Nestful.post token_url, {}

      puts response

      set_access_token response

      set_refresh_token response
    end

    #
    # 获取签名
    #
    # 签名验证使用 Digest::HMAC 进行生成
    #
    # 判断检测地址：http://gw.api.alibaba.com/dev/tools/request_signature.html
    #
    # 例子： OpenSSL::HMAC.hexdigest OpenSSL::Digest.new('sha1'), '1FyHgep5Mkh', 'param2/1/aliexpress.open/api.getChildrenPostCategoryById/44872398cateId0'
    #
    # @note Digest::HMAC.hexdigest ruby2.1.5 还支持，2.3.0 就不支持了。
    def self.get_signature(signature_factor)
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), app_secret, signature_factor).upcase
      # Digest::HMAC.hexdigest(signature_factor, secret_key, Digest::SHA1).upcase
    end

    #
    # 发送请求 API 的链接
    #
    # @example http://gw.api.alibaba.com/dev/tools/api_test_intl.html
    #
    # @param api_version - API 版本
    # @param api_namespace - API 命名空间
    #
    #
    # @note urlPath 的规则: 将除了 _aop_signature 以外的其他所有参数都加入 signature 的生成
    #       大多数的接口是不需要 _aop_timestamp(以毫秒表示)
    #       特定的请求，需要设定请求提供
    #
    # @return [Hash] 请求返回的相应
    def self._api_endpoint(api_version: 1, api_namespace: 'aliexpress.open', api_name: 'dev.test', params: {}, protocol: 'param2', body: {})
      url_path = "#{protocol}/#{api_version}/#{api_namespace}/#{api_name}/#{app_key}"

      params.merge!({access_token: access_token
                     # _aop_timestamp: Time.now.to_i * 1000
                    })

      signature_factor = url_path.clone

      signature_factor << params.map { |k, v| "#{k}#{v}" }.sort.join

      # puts "signature_factor = #{signature_factor}"

      signature = get_signature signature_factor

      # puts "signature = #{signature}"

      params.merge! _aop_signature: signature

      tmp_url = "#{api_url}/#{url_path}?#{Nestful::Helpers.to_url_param params}"

      puts "Request URL：#{tmp_url}"

      request = Nestful::Request.new tmp_url, method: :post, format: :json

      if body.present?
        request.body = Nestful::Helpers.to_url_param body

        puts "Request Body: #{request.body}"
      end

      start_time = Time.now

      response = request.execute

      cost_time = Time.now - start_time

      puts "Time Cost: #{cost_time} s"

      puts "Response Result: #{response}"

      # TODO: 根据获取的返回值，抛出异常，刷新访问 token
      ::Hashie::Mash.new JSON.parse(response.body)
    end
  end
end