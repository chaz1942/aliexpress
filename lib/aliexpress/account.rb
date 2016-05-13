# -*- encoding : utf-8 -*-
module Aliexpress
  # 平台通用的信息
  class Account < Base
    
    # 查询会员账户等级 
    # 地址： http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.queryAccountLevel&v=1
    # 
    def self.queryAccountLevel(login_id = '')
      params = {
        loginId: login_id
      }
      
      api_endpoint 'api.queryAccountLevel', params
    end
  end
end