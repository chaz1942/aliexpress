# -*- encoding : utf-8 -*-
module Aliexpress
  class Authorization < Base

    #
    # 获取速卖通的授权登陆的地址
    # 地址: http://gw.api.alibaba.com/dev/doc/intl/sys_auth.htm?ns=aliexpress.open
    #
    # @return String 返回发起授权的请求
    def self.get_auth_url(params = '')
      options = {
          client_id: app_key,
          site: 'aliexpress',
          redirect_uri: redirect_uri,
          state: params
      }

      signature = get_signature options.map { |k,v|  "#{k}#{v}" }.sort.join

      puts "signature =  #{signature}"

      "#{auth_url}?#{options.map { |k, v| "#{k}=#{v}" }.join('&')}&_aop_signature=#{signature}"
    end

    # 获取访问令牌的 token
    #
    # 获取令牌 token 的 URL 是: "https://gw.api.alibaba.com/openapi/http/1/system.oauth2/getToken/YOUR_APPKEY?grant_type=authorization_code&need_refresh_token=true&client_id= YOUR_APPKEY&client_secret= YOUR_APPSECRET&redirect_uri=YOUR_REDIRECT_URI&code=CODE"
    #
    # @note code 有效期为 2分钟，且是一次性
    #
    # 返回结果是：
    # {
    #     "refresh_token_timeout": "",
    #     "aliId": "1609765110",
    #     "resource_owner": "",
    #     "expires_in": "36000",
    #     "refresh_token": "",
    #     "access_token": ""
    # }
    def self.get_access_token_by_params(params)
      options = {
          grant_type: 'authorization_code',
          client_id: app_key,
          client_secret: app_secret,
          redirect_uri: redirect_uri,
          need_refresh_token: true,
          code: params[:code]
      }

      tmp_url =  "#{token_url}/#{app_key}?#{options.map { |k, v| "#{k}=#{v}" }.join('&')}"

      puts "token_url = #{tmp_url}"

      # RestClient 发送 post 请求，报 RestClient::BadRequest: 400 Bad Request
      response = JSON.parse RestClient.post(tmp_url, {})

      puts "response = #{response}"

      token_key = get_access_token_key params[:state]

      set_refresh_token(response, params[:state])

      set_access_token response, token_key
    rescue => e
      if e.is_a? RestClient::ExceptionWithResponse
        puts "Response Code: #{e.message}"
        puts "Response Boby: #{e.http_body}"
      else
        logger.info e
      end
    end
  end
end
