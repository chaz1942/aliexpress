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
    def self.api_endpoint(api_name, params = {}, body = {}, headers = {})
      options = {
          headers: headers,
          params: params,
          body: body
      }

      _api_endpoint(api_name: api_name, options: options)
    end

    protected

    def self.get_refresh_token_key(name = '')
      name.blank? ? REFRESH_TOKEN_KEY : Digest::MD5.hexdigest("refresh_token_#{CGI.escape(name)}")
    end

    def self.get_access_token_key(refresh_key = '')
      refresh_key.blank? ? ACCESS_TOKEN_KEY : Digest::MD5.hexdigest("access_token_#{refresh_key}")
    end

    # 通过 redis 获取 token，并设置过期时间
    #
    # @param [String] refresh_token_key
    # @param [String] access_token_key
    #
    # @return 返回获取 access_token
    def self.access_token(refresh_token_key = get_refresh_token_key, access_token_key = get_access_token_key)
      token = redis.get access_token_key

      return token if token.present?

      refresh_access_token(access_token_key, refresh_token_key)
    end

    # 通过 redis 获取 refresh_token, 并设置过期时间
    #
    # @return 返回 refresh_token
    def self.refresh_token
      get_refresh_token
    end

    # 通过 redis 获取 refresh_token, 并设置过期时间
    #
    # @return 返回 refresh_token
    def self.get_refresh_token(redis_key = get_refresh_token_key)
      logger.info "refresh_token_key: #{redis_key}"

      token = redis.get redis_key

      if token.present?
        token
      else
        raise ValidRefreshTokenException, 'Refresh token cannot be empty !'
      end
    rescue => e
      logger.info e

      nil
    end

    #
    # 获取 access_token
    #
    def self.get_access_token(token = get_refresh_token)
      token_url = 'https://gw.api.alibaba.com/openapi/param2/1/system.oauth2/getToken'

      options = {
          grant_type: 'refresh_token',
          client_id: app_key,
          client_secret: app_secret,
          refresh_token: token
      }

      token_url = "#{token_url}/#{app_key}?#{options.map { |k, v| "#{k}=#{v}" }.join('&')}"

      logger.info token_url

      JSON.parse RestClient.post(token_url, {})
    end

    #
    # 设置访问 token
    #
    # @param response [Hash] - 获取
    def self.set_access_token(response, redis_key = get_access_token_key)
      token = response['access_token']

      redis.multi do
        redis.set redis_key, token
        redis.expire redis_key, response['expires_in']
      end

      token
    end

    #
    # 设置 refresh code
    #
    # @param response [Hash] - 接口返回的值
    def self.set_refresh_token(response, redis_key = get_refresh_token_key)
      token = response['refresh_token']

      redis.multi do
        redis.set redis_key, token
        redis.expireat redis_key, Time.parse(response['refresh_token_timeout'])
      end

      token
    end

    #
    # 重新获取 access_token
    #
    def self.refresh_access_token(access_token_key, refresh_token_key)
      refresh_token = get_refresh_token refresh_token_key

      if refresh_token.present?
        response = get_access_token refresh_token

        set_access_token(response, access_token_key)
      end
    end

    #
    # 在 refresh_token 未过期前重新请求 refresh_token
    #
    def self.refresh_refresh_token
      refresh_token_url = 'https://gw.api.alibaba.com/openapi/param2/1/system.oauth2/postponeToken'

      options = {
          client_id: app_key,
          client_secret: app_secret,
          refresh_token: refresh_token,
          access_token: access_token
      }

      token_url = "#{refresh_token_url}/#{app_key}?#{options.map { |k, v| "#{k}=#{v}" }.join('&')}"

      # RestClient 发送 post 请求，报 RestClient::BadRequest: 400 Bad Request
      response = JSON.parse RestClient.post(token_url, {})

      logger.info response

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
    # digest 方法存在两个版本:  hexdigest 版本
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
    # @note urlPath 的规则: 将除了 +_aop_signature+ 以外的其他所有参数都加入 signature 的生成
    #       大多数的接口是不需要 +_aop_timestamp+ (以毫秒表示)
    #       特定的请求，需要设定请求提供
    #
    # @return [Hash] 请求返回的相应
    def self._api_endpoint(api_version: 1, api_namespace: 'aliexpress.open', api_name: '', protocol: 'param2', options: {})
      url_path = "#{protocol}/#{api_version}/#{api_namespace}/#{api_name}/#{app_key}"

      params = options[:params] || {}

      unless params[:access_token].present?
        params.merge!({access_token: access_token
                       # _aop_timestamp: Time.now.to_i * 1000
                      })
      end

      signature_factor = url_path.clone

      signature_factor << params.map { |k, v| "#{k}#{v}" }.sort.join

      # logger.info "signature_factor = #{signature_factor}"

      signature = get_signature signature_factor

      # logger.info "signature = #{signature}"

      params.merge! _aop_signature: signature

      # tmp_url = "#{api_url}/#{url_path}?#{Helpers.to_url_param params}"
      tmp_url = "#{api_url}/#{url_path}"

      logger.info "Request URL：#{tmp_url}"

      logger.info "Request Body: #{options[:body].merge!(params)}"

      response = Profile.prof { RestClient.post tmp_url, options[:body], options[:headers] }

      logger.info "Response Result: #{response}"

      # TODO: 根据获取的返回值，抛出异常，刷新 Refresh Token - 过期的时间是半年
      ::Hashie::Mash.new JSON.parse(response)
    rescue => e
      if e.is_a? RestClient::ExceptionWithResponse
        logger.info "Response Code: #{e.message}"
        logger.info "Response Boby: #{e.http_body}"
      else
        logger.info e
      end
    end
  end
end