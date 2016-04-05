describe Aliexpress::Product do

  describe '测试 publish 商品' do

    def get_product_skus
      product_skus = []

      sku_properties = []

      sku_property = Aliexpress::SKUProperty.default

      sku_properties << sku_property

      product_sku = Aliexpress::ProductSKU.default

      product_sku.aeopSKUProperty = sku_properties

      product_skus << product_sku

      product_skus.to_json
    end

    def get_product_properties
      properties = []

      property = Aliexpress::ProductProperty.default

      properties << property

      properties.to_json
    end

    it 'return success in publish product' do

      # 优惠券日期
      coupon_date = {
          couponStartDate: Date.new,
          couponEndDate: Date.new
      }

      skus = Aliexpress::Category.getAttributesResultByCateId 200002024

      options = {
          subject: '这是一个测试',
          categoryId: 200002024,                   # 洗浴用品
          aeopAeProductSKUs: get_product_skus,     # sku属性
          aeopAeProductPropertys: get_product_properties,   # 产品属性
          deliveryTime: 20,
          detail: '<p>这是一个大的测试</p>',
          freightTemplateId: '',                     # 运费模板
          # 可选字段 - optional fields
          productPrice: 123.00,
          productUnit: '',
          packageType: false,
          lotNum: 1,
          currencyCode: 'USD',
          isPackSell: false,
          sizeChartId: 121,
          reduceStrategy: '',
          wsValidNum: '',
          bulkOrder: '',
          bulkDiscount: ''
      }


    end
  end

end