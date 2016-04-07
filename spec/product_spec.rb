require 'aliexpress'

describe Aliexpress::Product do

  describe '测试速卖通商品相关接口' do

    # 获取商品的 SKU 属性
    def get_product_skus(skus)
      product_skus = []

      product_skus << Aliexpress::ProductSKU.default(skus).to_h

      product_skus.to_json
    end

    # 获取商品属性
    def get_product_properties(properties)
      product_properties = []

      properties.each do |property|
        product_properties << Aliexpress::ProductProperty.default(property)
      end

      product_properties.to_json
    end

    # 获取图片的 URL - 图片链接
    def get_image_urls
      image_key = Aliexpress::Cache.generate_key('image_urls_key')
      image_urls = Aliexpress::Cache.fetch image_key do
        Aliexpress::Image.listImagePagination
      end

      image_urls.images.map(&:url)[0..5].join(';')
    end

    # 获取运费模板的 ID
    def get_freight_template_id
      freight_key = Aliexpress::Cache.generate_key('freight_key')

      freights = Aliexpress::Cache.fetch freight_key do
        Aliexpress::Freight.listFreightTemplate
      end

      freights.aeopFreightTemplateDTOList.sample.templateId
    end

    # 获取服务模板
    def get_promise_template_id
      promise_key = Aliexpress::Cache.generate_key 'promise_key'

      promise = Aliexpress::Cache.fetch promise_key do
        Aliexpress::Product.queryPromiseTemplateById
      end

      promise.templateList.sample.id
    end

    it '刊登商品测试' do
      category_id = 200004358

      # 优惠券日期
      coupon_date = {
          couponStartDate: Date.new,
          couponEndDate: Date.new
      }

      # 所有的 SKU 信息
      all_sku = Aliexpress::Cache.fetch "test_sku_#{category_id}" do
        Aliexpress::Category.getChildAttributesResultByPostCateIdAndPath cateId: category_id
      end

      # 所有 sku 属性 为 false 的，都是 类目属性
      product_property = all_sku.attributes.reject { |item| item.sku }

      # 获取类目属性，并按顺序排序
      product_skus = all_sku.attributes.reject { |item| item.sku == false }.sort_by(&:spec)

      # 检查敏感词过滤， http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.findAeProductProhibitedWords&v=1
      Aliexpress::Product.findAeProductProhibitedWords


      options = {
          subject: 'Big_Test',
          keyword: 'testkeyword',
          categoryId: category_id, # 其他特殊类中的其他测试
          aeopAeProductSKUs: get_product_skus(product_skus), # 用来设置SKU属性
          aeopAeProductPropertys: get_product_properties(product_property), # 设置公共产品属性
          deliveryTime: 7,
          detail: 'bigtest123',
          freightTemplateId: get_freight_template_id, # 运费模板
          wsValidNum: 30,
          productPrice: 1.00,
          imageURLs: get_image_urls,
          # 可选字段 - optional fields
          productPrice: 123.00,
          promiseTemplateId: get_promise_template_id,
          productUnit: Aliexpress::Product::Unit::PIECE,
          packageType: false,
          lotNum: 1,
          currencyCode: 'USD',
          isPackSell: false,
          sizechartId: 121,
          reduceStrategy: Aliexpress::ReduceStrategy::ORDER
          # bulkOrder: '',
          # bulkDiscount: ''
      }

      Aliexpress::Product.postAeProduct options
    end
  end
end