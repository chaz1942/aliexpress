# -*- encoding : utf-8 -*-
module Aliexpress

  ### 数据常量的定义

  # 备注：使用严格类型定义
  # SKU 对象
  # aeopSKUProperty: SKU 属性对象列表
  # aeopSKUProperty - SKU属性集， skuPrice - SKU 的价格， ipmSkuStock - 可售库存 必填
  # skuStock - 判断是否有货
  ProductSKU = Struct.new(:aeopSKUProperty, :skuPrice, :skuCode, :skuStock, :ipmSkuStock, :id, :currencyCode) do
    def self.default(skus = [])
      sku_properties = []

      skus.each do |sku|
        sku_properties << SKUProperty.default(sku)
      end

      new(sku_properties, '200.07', '', true, 1, '', CurrencyCode::USD)
    end
  end

  # SKU 属性对象
  # 属性介绍
  # propertyValueDefinitionName - 自定义名称
  # skuImage - 自定义图片
  SKUProperty = Struct.new(:skuPropertyId, :propertyValueId, :propertyValueDefinitionName, :skuImage) do
    def self.default(sku = {})
      if sku.present?
        value_id = sku[:values][rand(sku[:values].length)].id
        case sku.attributeShowTypeValue
          when 'input'
            {skuPropertyId: sku.id, propertyValueId: ''}
          when 'list_box'
            {skuPropertyId: sku.id, propertyValueId: value_id}
          when 'check_box'
            {skuPropertyId: sku.id, propertyValueId: value_id}
          when 'other'
            {skuPropertyId: sku.id, propertyValueId: 4, attrValue: ''}
        end
      else
        new(14, 771, 'back', 'http://xiajian.github.io/assets/images/face.jpg')
      end
    end
  end

  # 商品类目属性对象, 看起来没什么用
  # 根据 类目属性的类型不同，所取的值会有所不同
  ProductProperty = Struct.new(:attrNameId, :attrName, :attrValueId, :attrValue) do
    def self.default(property = {})
      if property.present?
        case property.attributeShowTypeValue
          when 'input'
            {attrNameId: property.id, attrValue: ''}
          when 'list_box' || 'check_box'
            value_id = property[:values][rand(property[:values].length)].id
            {attrNameId: property.id, attrValueId: value_id}
          when 'other'
            {attrNameId: property.id, attrValueId: 4, attrValue: ''}
        end
      else
        new(200000043, 'size', 581, '2 - 5 kg')
      end
    end
  end

  # 产品展示对象
  ProductDisplayDTO = Struct.new(:subject, :groupId, :wsOfflineDate, :productId, :imageURLs, :src, :wsDisplay,
                                 :gmtCreate, :productMinPrice, :productMaxPrice, :ownerMemberId, :ownerMemberSeq) do
    def self.default

    end
  end

  # 商品的基本信息 - 参数
  ProductDisplaySampleDTO = Struct.new(:subject, :groupId, :wsOfflineDate, :productId, :imageURLs, :src, :gmtCreate, :gmtModified) do

  end

  # 产品子分组
  ChildProductGroup = Struct.new(:groupId, :groupName) do
    def self.default
      new(500052004, 'twrewerw')
    end
  end

  # 产品分组信息
  ProductGroup = Struct.new(:groupID, :groupName, :childGroup) do
    def self.default
      new(262007001, 'testjiweji', [])
    end
  end

  class Product < Base

    # 产品计量单位
    module Unit
      BAG = 100000000 # 袋
      BARREL = 100000001 # 桶
      BUSHEL = 100000002 # 蒲式耳
      CARTON = 100078580 # 箱
      CENTIMETER = 100078581 # 厘米
      CUBIC_METER = 100000003 # 立方米
      DOZEN = 100000004 # 打
      FEET = 100078584 # 英尺
      GALLON = 100000005 # 加仑
      GRAM = 100000006 # 克
      INCH = 100078587 # 英寸
      KILOGRAM = 100000007 # 千克
      KILOLITER = 100078589 # 千升
      KILOMETER = 100000008 # 千米
      LITER = 100078559 # 升
      LONG_TON = 100000009 # 英吨
      METER = 100000010 # 米
      METRIC_TON = 100000011 # 公吨
      MILLIGRAM = 100078560 # 毫克
      MILLILITER = 100078596 # 毫升
      MILLIMETER = 100078597 # 毫米
      OUNCE = 100000012 # 盎司
      PACK = 100000014 # 包
      PAIR = 100000013 # 双
      PIECE = 100000015 # 件/个
      POUND = 100000016 # 磅
      QUART = 100078603 # 夸脱
      SET = 100000017 # 套
      SHORT_TON = 100000018 # 美吨
      SQUARE_FEET = 100078606 # 平方英尺
      SQUARE_INCH = 100078607 # 平方英寸
      SQUARE_METER = 100000019 # 平方米
      SQUARE_YARD = 100078609 # 平方码
      TON = 100000020 # 吨
      YARD = 100078558 # 码
    end

    # 产品业务状态
    module StatusType
      # 上架
      ON_SELL = 'onSelling'

      # 下架
      OFFLINE = 'offline'

      # 审核中
      AUDIT = 'auditing'

      # 审核不通过
      EDIT = 'editingRequired'
    end

    class << self
      # 获取商品列表
      def get_products(params = {})
        params[:page] ||= 20
        params[:per] ||= 1

        params.merge!({
            productStatusType: StatusType::ON_SELL,
            pageSize: params[:page],
            currentPage: params[:per]
        })

        findProductInfoListQuery params
      end

      # 获取单个商品的信息
      def get_product(id = '', access_token = '')
        findAeProductById productId: id, access_token: access_token
      end

      def get_promise_template(id = -1, access_token = '')
        queryPromiseTemplateById id, access_token
      end

      def online_product(ids, access_token)
        if ids.is_a?(Array)
          product_ids = ids.join(';')
        elsif ids.is_a?(String)
          product_ids = ids
        end

        options = {
            productIds: product_ids,
            access_token: access_token
        }

        onlineAeProduct options
      end

      def offline_product(ids, access_token)
        if ids.is_a?(Array)
          product_ids = ids.join(';')
        elsif ids.is_a?(String)
          product_ids = ids
        end

        options = {
            productIds: product_ids,
            access_token: access_token
        }

        offlineAeProduct options
      end



      # 卖家可以通过这个接口发布一个多语言商品。一次只能发布一种多语言商品
      # 地址: http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=alibaba.product.postMultilanguageAeProduct&v=1
      #
      def postMultilanguageAeProduct(params = {})
        api_endpoint 'alibaba.product.postMultilanguageAeProduct', params
      end

      # 查询商品状态，
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.findAeProductStatusById&v=1
      #
      # @note: 商品供三种状态。审核通过:approved;审核中:auditing; 审核不通过:refuse
      def findAeProductStatusById(params = {})
        api_endpoint 'api.findAeProductStatusById', params
      end

      # 调用发布商品接口api.postaeproduct前，针对商品标题等信息做违禁词相关信息查询接口
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.findAeProductProhibitedWords&v=1
      #
      # @param categoryId, title, keywords, productProperties, detail等字符型参数
      #
      def findAeProductProhibitedWords(params = {})
        api_endpoint 'api.findAeProductProhibitedWords', params
      end

      # 编辑SKU的可售库存
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.editMutilpleSkuStocks&v=1
      #
      #
      def editMutilpleSkuStocks(params = {})
        api_endpoint 'api.editMutilpleSkuStocks', params
      end

      # 编辑商品单个 SKU 库存
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.editSingleSkuStock&v=1
      #
      def editSingleSkuStock(params = {})
        api_endpoint 'api.editSingleSkuStock', params
      end

      # 编辑商品的单个SKU价格信息
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.editSingleSkuPrice&v=1
      #
      def editSingleSkuPrice(params = {})
        api_endpoint 'api.editSingleSkuPrice', params
      end

      # 原发编辑商品多语言标题或详描描述（英文版本除外）
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.editMultilanguageProduct&v=1
      #
      #
      def editMultilanguageProduct(params = {})
        api_endpoint 'api.editMultilanguageProduct', params
      end

      # 可查询获取该卖家目前实际可用橱窗数量
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.getRemainingWindows&v=1
      #
      #
      def getRemainingWindows(params = {})
        api_endpoint 'api.getRemainingWindows', params
      end

      # 创建产品分组
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.createProductGroup&v=1
      #
      def createProductGroup(params = {})
        api_endpoint 'api.createProductGroup', params
      end

      # 查询当前用户在指定类目下可用的尺码模版信息。
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.getSizeChartInfoByCategoryId&v=1
      #
      def getSizeChartInfoByCategoryId(id = 0, access_token)
        api_endpoint 'api.getSizeChartInfoByCategoryId', {categoryId: id, access_token: access_token}
      end

      # 修改商品所引用的尺码模板
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.setSizeChart&v=1
      #
      def setSizeChart(params = {})
        api_endpoint 'api.setSizeChart', params
      end

      # 获取某个卖家橱窗商品目前使用情况详情
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.getWindowProducts&v=1
      #
      def getWindowProducts(params = {})
        api_endpoint 'api.getWindowProducts', params
      end

      # 编辑商品的类目属性，用给定的类目属性覆盖原有的类目属性
      # 地址： http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.editProductCategoryAttributes&v=1
      #
      def editProductCategoryAttributes(params = {})
        api_endpoint 'api.editProductCategoryAttributes', params
      end

      # 设置单个产品的产品分组信息，最多设置三个分组
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.setGroups&v=1
      #
      def setGroups(params = {})
        api_endpoint 'api.setGroups', params
      end

      # 查询指定商品ID所在产品分组
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.queryProductGroupIdByProductId&v=1
      #
      def queryProductGroupIdByProductId(params = {})
        api_endpoint 'api.queryProductGroupIdByProductId', params
      end

      # 获取当前会员的产品分组
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.getProductGroupList&v=1
      #
      def getProductGroupList(params = {})
        api_endpoint 'api.getProductGroupList', params
      end

      # 编辑产品类目、属性、sku
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.editProductCidAttIdSku&v=1
      #
      def editProductCidAttIdSku(params = {})
        api_endpoint 'api.editProductCidAttIdSku', params
      end

      # 编辑商品的单个字段
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.editSimpleProductFiled&v=1
      #
      def editSimpleProductFiled(params = {})
        api_endpoint 'api.editSimpleProductFiled', params
      end

      # 获取属性需要优化的商品列表
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.getAtributeMissingProductList&v=1
      #
      def getAtributeMissingProductList(params = {})
        api_endpoint 'api.getAtributeMissingProductList', params
      end

      # 通过淘宝产品的url进行单品认领
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.claimTaobaoProducts4API&v=1
      #
      def claimTaobaoProducts4API(params = {})
        api_endpoint 'api.claimTaobaoProducts4API', params
      end

      # 商品橱窗设置
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.setShopwindowProduct&v=1
      #
      def setShopwindowProduct(params = {})
        api_endpoint 'api.setShopwindowProduct', params
      end

      # 服务模板查询
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.queryPromiseTemplateById&v=1
      #
      # @note id 为 0 获取全部的服务模板
      def queryPromiseTemplateById(id = -1, access_token)
        params = {
            templateId: id,
            access_token: access_token
        }

        api_endpoint 'api.queryPromiseTemplateById', params
      end

      # 获取淘宝原始产品信息
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.listTbProductByIds&v=1
      #
      def listTbProductByIds(params = {})
        api_endpoint 'api.listTbProductByIds', params
      end

      # 查询信息模板列表
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.findAeProductDetailModuleListByQurey&v=1
      #
      def findAeProductDetailModuleListByQurey(params = {})
        api_endpoint 'api.findAeProductDetailModuleListByQurey', params
      end

      # 查询单个信息模板详情
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.findAeProductModuleById&v=1
      #
      def findAeProductModuleById(params = {})
        api_endpoint 'api.findAeProductModuleById', params
      end

      # 商品上架
      # 地址： http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.onlineAeProduct&v=1
      #
      def onlineAeProduct(params = {})
        api_endpoint 'api.onlineAeProduct', params
      end

      # 商品下架
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.offlineAeProduct&v=1
      #
      def offlineAeProduct(params = {})
        api_endpoint 'api.offlineAeProduct', params
      end

      # 修改编辑商品信息
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.editAeProduct&v=1
      #
      def editAeProduct(params = {})
        api_endpoint 'api.editAeProduct', params
      end

      # 获取单个产品信息
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.findAeProductById&v=1
      #
      def findAeProductById(params = {})
        api_endpoint 'api.findAeProductById', params
      end

      # 商品列表查询接口
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.findProductInfoListQuery&v=1
      #
      def findProductInfoListQuery(params = {})
        api_endpoint 'api.findProductInfoListQuery', params
      end

      # 发布产品信息
      # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.postAeProduct&v=1
      # @note: 有机会实现代码中的相关的验证
      #
      # @param [Hash] 应用参数
      def postAeProduct(params = {}, body = {})
        api_endpoint 'api.postAeProduct', params, body
      end
    end
  end
end