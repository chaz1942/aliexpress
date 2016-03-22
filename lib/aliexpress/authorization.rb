# -*- encoding : utf-8 -*-
module Aliexpress
  class Authorization < Base

    #
    # 获取授权的地址
    # 参考: Sidekiq 的实现，其 web 授权。
    def self.get_auth
      "#{auth_url}?client_id=#{Aliexpress.app_key}&site=aliexpress&redirect_uri="
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
    def self.get_access_token_by_code(code = '')
      options = {
          grant_type: 'authorization_code',
          client_id: app_key,
          client_secret: app_secret,
          redirect_uri: redirect_uri,
          need_refresh_token: true,
          code: code
      }

      token_url =  "#{token_url}/#{app_key}?#{options.map { |k, v| "#{k}=#{v}" }.join('&')}"

      # RestClient 发送 post 请求，报 RestClient::BadRequest: 400 Bad Request
      response = JSON.parse Nestful.post(token_url)

      puts "response = #{response}"

      set_access_token response

      set_refresh_token response
    end
  end
end
