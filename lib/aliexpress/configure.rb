# -*- encoding : utf-8 -*-
require 'redis'
module Aliexpress
  # 存放 gem 配置信息
  module Configure

    # 请求 URL 组成部分
    #
    # http://gw.api.alibaba.com/openapi/param2/1/aliexpress.open/api.findAeProductById/100000?&_aop_timestamp=1375703483649&access_token=HMKSwKPeSHB7Zk7712OfC2Gn1-kkfVsaM-P&_aop_signature=DE1D9BDE00646F5C1704930003C9FC011AADDE25
    #
    mattr_accessor :api_url
    self.api_url = 'http://gw.api.alibaba.com/openapi'

    mattr_accessor :app_key
    self.app_key = '44872398'

    mattr_accessor :app_secret
    self.app_secret = '1FyHgep5Mkh'

    # 获取授权的地址
    mattr_accessor :auth_url
    self.auth_url = 'http://authhz.alibaba.com/auth/authorize.htm'

    # 授权获取 url
    mattr_accessor :token_url
    self.token_url = 'https://gw.api.alibaba.com/openapi/param2/1/system.oauth2/getToken'

    # 回调地址
    mattr_accessor :redirect_uri
    self.redirect_uri = 'http://xiajian.ngrok.natapp.cn/aliexpress/auth'

    # 项目主地址 - 授权回调之后跳转的地址
    mattr_accessor :project_url
    self.project_url = '/'

    # redis 链接配置
    mattr_accessor :redis
    self.redis = Redis.new password: 'Fy958e5mmyb7Ta4H'

    mattr_accessor :access_token

    mattr_accessor :refresh_token

    # 日志记录
    mattr_accessor :logger
    self.logger = Logger.new(STDOUT)
  end
end
