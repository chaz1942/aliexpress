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
    def self.upload_temp_image(file = '')
      unless image_file? file
        raise ImageTypeException, 'Image File is invalid!'
      end

      file_data = File.new(file, 'rb')

      params = {srcFileName: File.basename(file)}

      body = {
          fileData: file_data,
          multipart: true
      }.merge! params

      self.uploadTempImage4SDK(params, body)
    rescue => e
      logger.info e
    end

    # 上传文件到图片银行
    #
    # @param [String] file - 图片文件
    def self.upload_image(file)
      unless image_file? file
        raise ImageTypeException, 'Image File is invalid!'
      end

      file_name = File.basename(file, group_id = 'picture')
      file_data = File.new(file, 'rb')

      params = {
          fileName: file_name,
          groupId: group_id
      }

      body = {
          imageBytes: file_data,
          multipart: true
      }.merge!(params)

      self.uploadImage4SDK(params, body)
    rescue => e
      logger.info e
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
      params.merge!(currentPage: 1, pageSize: 6, locationType: LocationType::ALL_GROUP)
      api_endpoint 'api.listImagePagination', params
    end
    
    private

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

    # 判断 文件是否是图片
    #
    # @param [String] file - 图片文件
    def self.image_file?(file)
      if File.exist?(file)
        type = MIME::Types.type_for(file).first

        type.media_type == 'image'
      end
    end
  end
end