module Aliexpress
  module CurrencyCode
    USD = 'USD'

    RUB = 'RUB'
  end

  # 减库存的策略
  module ReduceStrategy
    # 下单减库存
    ORDER = 'place_order_withhold'

    # 支付减库存
    PAYMENT = 'payment_success_deduct'
    
    ALL = [ORDER, PAYMENT]
  end
end
