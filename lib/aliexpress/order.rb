# -*- encoding : utf-8 -*-
module Aliexpress
  OrderList = Struct.new(:totalItem, :orderList) do

  end

  OrderItem = Struct.new(:bizType, :buyerLoginId) do

  end

  class Order < Base

    module Status
      IN_ISSUE = 'IN_ISSUE'   # 含纠纷中的订单
      IN_FROZEN = 'IN_ISSUE'  # 冻结中的订单
      IN_CANCEL = 'IN_CANCEL' # 买家申请取消
      RISK_CONTROL = 'RISK_CONTROL'       # 订单处于风控24小时中，从买家在线支付完成后开始，持续24小时
      FUND_PROCESSING = 'FUND_PROCESSING' # 买卖家达成一致，资金处理中
      PLACE_ORDER_SUCCESS = 'PLACE_ORDER_SUCCESS'       # 等待买家付款
      WAIT_SELLER_SEND_GOODS = 'WAIT_SELLER_SEND_GOODS' # 等待您发货
      SELLER_PART_SEND_GOODS = 'SELLER_PART_SEND_GOODS' # 部分发货
      WAIT_BUYER_ACCEPT_GOODS = 'WAIT_BUYER_ACCEPT_GOODS'     # 等待买家收货
      WAIT_SELLER_EXAMINE_MONEY = 'WAIT_SELLER_EXAMINE_MONEY' # 等待您确认金额
    end

    class << self

      # 获取订单列表
      def get_orders(params = {})
        params[:page] ||= 1
        params[:per] ||= 20
        params[:status] ||= Status::PLACE_ORDER_SUCCESS
        params[:start] ||= Time.now - 3.years
        params[:end] ||= Time.now

        options = {
            page: params[:page],
            pageSize: params[:per],
            orderStatus: params[:status],
            createDateStart: Time.now - 1.years,
            createDateEnd: Time.now,
            access_token: params[:access_token]
        }

        findOrderListQuery options
      end

      # 一键延长买家收货时间
      # 地址: http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.extendsBuyerAcceptGoodsTime&v=1
      #
      # @note 订单状态需处于“买家确认收货”及“非纠纷、非冻结”状态下可支持该操作。
      def extendsBuyerAcceptGoodsTime(params = {})
        api_endpoint 'api.extendsBuyerAcceptGoodsTime', params
      end

      # 订单交易信息查询
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.findOrderTradeInfo&v=1
      #
      # @param [Hash] params - 应用参数 { orderId: 30025745255804 }
      def findOrderTradeInfo(params = {})
        api_endpoint 'api.findOrderTradeInfo', params
      end

      # 根据订单 ID 获取订单的交易
      #
      def getOrderTradeInfoById(id = 0)
        findOrderTradeInfo orderId: id
      end

      # 订单收货信息查询
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.findOrderReceiptInfo&v=1
      #
      # @param [Hash] params -
      def findOrderReceiptInfo(params = {})
        api_endpoint 'api.findOrderReceiptInfo', params
      end

      # 订单基础信息查询
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.findOrderBaseInfo&v=1
      #
      def findOrderBaseInfo(params = {})
        api_endpoint 'api.findOrderBaseInfo', params
      end

      # 订单列表简化查询
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.findOrderListSimpleQuery&v=1
      #
      def findOrderListSimpleQuery(params = {})
        api_endpoint 'api.findOrderListSimpleQuery', params
      end

      # 未放款订单请款
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.requestPaymentRelease&v=1
      #
      def requestPaymentRelease(params = {})
        api_endpoint 'api.requestPaymentRelease', params
      end

      # 卖家在订单做请款时上传证明附件
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.updateDeliveriedConfirmationFile&v=1
      #
      def updateDeliveriedConfirmationFile(params = {})
        api_endpoint 'api.updateDeliveriedConfirmationFile', params
      end

      # 查询订单放款信息
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.findLoanListQuery&v=1
      #
      # @note: 目前只查询进入放款中的订单信息状态，未进入放款中订单暂未做内容兼容。
      def findLoanListQuery(params = {})
        params.merge!({page: 1, pageSize: 50})
        api_endpoint 'api.findLoanListQuery', params
      end

      # 订单详情查询
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.findOrderById&v=1
      #
      #
      def findOrderById(params = {})
        api_endpoint 'api.findOrderById', params
      end

      # 交易订单列表查询
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.findOrderListQuery&v=1
      #
      # @note: 订单状态会多一个全新的值RISK_CONTROL 该值的含义是订单处于风控24小时中，从买家在线支付完成后开始，持续24小时。
      def findOrderListQuery(params = {})
        api_endpoint 'api.findOrderListQuery', params
      end
    end
  end
end
