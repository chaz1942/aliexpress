require 'open-uri'

module Aliexpress
  class Image < Base
    module LocationType
      ALL_GROUP = 'ALL_GROUP'

      SUB_GROUP = 'SUB_GROUP'

      UNGROUP = 'UNGROUP'
    end

    # 上传图片
    #
    # @param [String] 图品文件的地址
    def self.upload_temp_image(file = '', access_token)
      unless image_file? file
        raise ImageTypeException, 'Image File is invalid!'
      end

      file_data = File.new(file, 'rb')

      params = {srcFileName: File.basename(file), access_token: access_token }

      body = {
          fileData: file_data,
          multipart: true
      }.merge! params

      self.uploadTempImage4SDK(params, body)
    rescue => e
      logger.info e
    end

    # 从 url 中上传文件
    #
    # 上传图片到 阿里的 cdn, 从而方便刊登商品
    #
    # @note 实际上，速卖通可能不支持 png 等格式的图片
    def self.upload_image_from_url(url, access_token)
      puts 'Note: 不支持 png 格式的图片'
      upload_temp_image download(url), access_token
    end

    # 下载文件 - 依赖本地的 tmp 目录
    #
    # 参考: http://stackoverflow.com/questions/2263540/how-do-i-download-a-binary-file-over-http
    def self.download(url, file = '')
      if file.blank?
        file = "/tmp/#{url.scan(/.*\/([^\/]*)/).flatten.try(:first)}"
      end

      if File.exist? file
        `rm -rf #{file}`
      end

      File.open(file, 'wb') do |saved_file|
        open(url, 'rb') do |read_file|
          saved_file.write(read_file.read)
        end
      end

      file
    end

    # 上传文件到图片银行
    #
    # @param [String] file - 图片文件
    def self.upload_image(file, access_token = '')
      unless image_file? file
        raise ImageTypeException, 'Image File is invalid!'
      end

      file_name = File.basename(file, group_id = 'picture')
      file_data = File.new(file, 'rb')

      params = {
          groupId: group_id,
          fileName: file_name,
          access_token: access_token
      }

      body = {
          imageBytes: file_data,
          multipart: true
      }.merge!(params)

      self.uploadImage4SDK(params, body)
    rescue => e
      logger.info e
    end

    # 查询图片列表
    #
    # @param [Fixnum] per - 当前页数
    # @param [Fixnum] page - 页面的列表数
    def self.list_image(access_token = '', per = 1, page = 6, type = LocationType::ALL_GROUP)
      params = {
          currentPage: per,
          pageSize: page,
          locationType: type,
          access_token: access_token
      }

      response = self.listImagePagination(params)

      response.images.map(&:url)
    end

    # 上传图片到临时目录
    # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.uploadTempImage&v=1
    #
    def self.uploadTempImage(params = {})
      api_endpoint 'api.uploadTempImage', params
    end

    # 根据path查询图片信息
    # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.queryPhotoBankImageByPaths&v=1
    #
    def self.queryPhotoBankImageByPaths(params = {})
      api_endpoint 'api.queryPhotoBankImageByPaths', params
    end

    # 获取图片银行信息
    # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.getPhotoBankInfo&v=1
    #
    def self.getPhotoBankInfo(params = {})
      api_endpoint 'api.getPhotoBankInfo', params
    end

    # 删除未被引用图片
    # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.delUnUsePhoto&v=1
    #
    def self.delUnUsePhoto(params = {})
      api_endpoint 'api.delUnUsePhoto', params
    end

    # 上传图片到图片银行
    # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.uploadImage&v=1
    #
    def self.uploadImage(params = {})
      api_endpoint 'api.uploadImage', params
    end

    # 查询图片银行分组信息
    # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.listGroup&v=1
    #
    def self.listGroup(params = {})
      api_endpoint 'api.listGroup', params
    end

    # 图片银行列表分页查询
    # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.listImagePagination&v=1
    #
    def self.listImagePagination(params = {})
      api_endpoint 'api.listImagePagination', params
    end

    # 上传图片到临时目录(推荐使用)
    # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.uploadTempImage4SDK&v=1
    #
    def self.uploadTempImage4SDK(params = {}, body = {})
      headers = {
          'Content-Type' => 'multipart/form-data'
      }

      api_endpoint 'api.uploadTempImage4SDK', params, body, headers
    end

    # 上传图片到图片银行(推荐使用)
    # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.uploadImage4SDK&v=1
    #
    def self.uploadImage4SDK(params = {}, body = {})
      api_endpoint 'api.uploadImage4SDK', params, body
    end

    private

    # 判断 文件是否是图片
    #
    # @note: 好搓的判断方法，根据文件的扩展名
    # @param [String] file - 图片文件
    def self.image_file?(file)
      if File.exist?(file)
        type = MIME::Types.type_for(file).first

        type.media_type == 'image'
      end
    end
  end
end