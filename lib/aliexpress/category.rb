# -*- encoding : utf-8 -*-
require 'csv'
module Aliexpress
  class Category < Base
    # TODO: 数据结构之类的如何存储, 使用 Struct 结构体存储

    # 获取下级目录的类目信息
    # 地址： http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.getChildrenPostCategoryById&v=1
    #
    # @param [Fixnum] id  类目属性 ID
    #
    # @note 与获取单个类目信息内容相同
    #
    def self.getChildrenPostCategoryById(id = 0)
      api_endpoint 'api.getChildrenPostCategoryById', {cateId: id}
    end

    # 获取单个类目信息
    # 地址： http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.getPostCategoryById&v=1
    #
    # @param [Fixnum] id  类目属性 ID
    #
    def self.getPostCategoryById(id = 0)
      api_endpoint 'api.getPostCategoryById', {cateId: id}
    end

    # 获取叶子类目下的 普通类目属性
    # @note #doc#
    def self.getAttributesResultByCateId(id = 3)
      api_endpoint 'api.getAttributesResultByCateId', {cateId: id}
    end

    # 通过关键词获取发布类目
    # 地址： http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.recommendCategoryByKeyword&v=1
    #
    # @param [Hash] params 应用级参数 - { keyword: 'mp4' }
    #
    def self.recommendCategoryByKeyword(params = {})
      params[:keyword] ||= 'mp3'
      api_endpoint 'api.recommendCategoryByKeyword', params
    end

    # 根据发布类目id、父属性路径（可选）获取子属性信息
    # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=getChildAttributesResultByPostCateIdAndPath&v=1
    #
    # @param [Hash] params 应用级参数 - { cateId: 0, parentAttrValueList: [[2,200013977]] }
    #
    def self.getChildAttributesResultByPostCateIdAndPath(params = {})
      api_endpoint 'getChildAttributesResultByPostCateIdAndPath', params
    end

    # 判断发布类目尺码模板是否必须
    # 地址： http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=sizeModelIsRequiredForPostCat&v=1
    #
    # @param [Hash] parmas  应用级参数 - { postCatId: 0 }
    #
    def self.sizeModelIsRequiredForPostCat(params = {})
      api_endpoint 'sizeModelIsRequiredForPostCat', params
    end

    # 查询指定类目适合的尺码模板
    # 地址： http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.sizeModelsRequiredForPostCat&v=1
    #
    # @param [Hash] parmas  应用级参数 - { postCatId: 0 }
    #
    def self.sizeModelsRequiredForPostCat(params = {})
      api_endpoint 'api.sizeModelsRequiredForPostCat', params
    end

  end

  # 生成并保存 目录的 csv 文件
  # 如果想要 层级获取，必然需要递归调用
  def self.generate_csv(id = 0)
    category_file = "tmp/aliexpress_category_#{Time.now.strftime('%Y%m%d%H%M')}.csv"

    headers = %w( id 父等级 名称-中文 名称-英文)
    categories = Aliexpress::Category.getChildrenPostCategoryById(id)

    CSV.open category_file, 'wb' do |csv|
      csv << headers

      categories['aeopPostCategoryList'].each do |category|
        csv << [category['id'], id, category['names']['zh'], category['names']['en']]
      end

    end
  end

  #
  # 导出所有的分类信息
  #
  def self.export_all_category
    # 缓存分类
    cache_category

    # 导出分类
    dump_category
  end

  # 尝试递归失败, 递归学不好。 递归传文件做为参数，可能有些问题。
  # 换个方式，利用 缓存（Cache） 处理。
  def test_for_output_csv
    category_file = "tmp/aliexpress_category_#{Time.now.strftime('%Y%m%d%h%m')}.csv"
    headers = %w( id 等级 名称-中文 名称-英文 parent_id)
    categories = Aliexpress::Category.getChildrenPostCategoryById(0)

    csv = CSV.open category_file, 'wb'

    csv << headers

    # 这段递归的代码写的有些问题
    def generate_csv(categories, csv, id = 0)
      categories['aeopPostCategoryList'].each do |category|
        csv << [category['id'], category['level'], category['names']['zh'], category['names']['en'], id]

        unless category['isleaf']
          generate_csv Aliexpress::Category.getChildrenPostCategoryById(category['id']), csv, category['id']
        end
      end
    end

    generate_csv categories, csv, 0
  end

  private

  #
  # 通过接口，将获取的分类的数据保存到 redis 中
  #
  def self.cache_category(id = 0)
    tmp_category = Aliexpress::Category.getChildrenPostCategoryById(id)
    Aliexpress.redis.hset 'categories', id, Marshal.dump(tmp_category)

    tmp_category.aeopPostCategoryList.each do |category|

      unless category.isleaf
        cache_category(category.id)
      end
    end
  end

  #
  # 将存放到 redis 中的数据存到 csv 文件中
  #
  def self.dump_category
    category_file = "tmp/aliexpress_category_#{Time.now.strftime('%Y%m%d%h%m')}.csv"
    headers = %w(id 等级 名称-中文 名称-英文 parent_id isleaf)

    CSV.open category_file, 'wb' do |csv|
      csv << headers
      Aliexpress.redis.hgetall('categories').each do |k, v|

        Marshal.load(v).aeopPostCategoryList.each do |category|
          puts category
          csv << [category['id'], category['level'], category['names']['zh'], category['names']['en'], k, category['isleaf']]
        end
      end
    end
  end

  #
  # 将叶子节点三级分类的数据的数组获到
  #
  def get_leaf_category
    category_ids = []
    Aliexpress.redis.hgetall('categories').each do |k, v|

      Marshal.load(v).aeopPostCategoryList.each do |category|
        category_ids << category.id if category.isleaf
      end
    end

    category_ids
  end

  #
  #
  #
  def get_leaf_category_sku
    sku_file = "tmp/leaf_category_sku_#{Time.now.strftime('%Y%m%d%h%m')}.csv"

    headers = %w( 分类ID sku_id 中文名 英文名 子属性id 子属性中文名 子属性英文名 是否为必须)
    CSV.open sku_file, 'wb' do |csv|
      csv << headers

      get_leaf_category.each do |k|
        tmp_skus = Marshal.load(Aliexpress.redis.hget('product_skus', k))

        next if tmp_skus.attributes.blank?

        tmp_skus.attributes.each do |sku|
          puts "sku = #{sku}"
          puts "insert array = #{ [k, sku.id, sku.names.zh, sku.names.en, '', '', '', sku.required] }"
          # Note: 注意不能使用 sku.values
          if sku[:values].present?
            sku[:values].each do |item|
              csv << [k, sku.id, sku.names.zh, sku.names.en, item.id, item.names.zh, item.names.en, sku.required]
            end
          else
            csv << [k, sku.id, sku.names.zh, sku.names.en, '', '', '', sku.required]
          end
        end

      end
    end
  end

  #
  # 获取 商品三级分类 下的 sku 属性
  #
  def self.cache_product_sku
    category_file = 'tmp/aliexpress_category_20160321Mar03.csv'

    category_ids = []

    CSV.foreach category_file do |row|
      category_ids << row[0]
    end

    category_ids[1..-1].each do |id|
      next if Aliexpress.redis.hexists 'product_skus', id

      tmp_sku = Aliexpress::Category.getAttributesResultByCateId(id)

      Aliexpress.redis.hset 'product_skus', id, Marshal.dump(tmp_sku)
    end
  end

  #
  # 将 三级分类属性 导出到 csv 格式的文件中
  #
  def self.dump_product_sku
    sku_file = "tmp/product_sku_#{Time.now.strftime('%Y%m%d%h%m')}.csv"

    headers = %w( 分类ID sku_id 中文名 英文名 子属性id 子属性中文名 子属性英文名 是否为必须)

    CSV.open sku_file, 'wb' do |csv|
      csv << headers

      Aliexpress.redis.hgetall('product_skus').each do |k, v|
        tmp_skus = Marshal.load(v)
        next if tmp_skus.attributes.blank?

        tmp_skus.attributes.each do |sku|
          puts "sku = #{sku}"
          puts "insert array = #{ [k, sku.id, sku.names.zh, sku.names.en, '', '', '', sku.required] }"
          # Note: 注意不能使用 sku.values
          if sku[:values].present?
            sku[:values].each do |item|
              csv << [k, sku.id, sku.names.zh, sku.names.en, item.id, item.names.zh, item.names.en, sku.required]
            end
          else
            csv << [k, sku.id, sku.names.zh, sku.names.en, '', '', '', sku.required]
          end
        end
      end
    end
  end
end
