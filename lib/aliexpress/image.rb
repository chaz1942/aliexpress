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
    def self.uploadImageData(file)
      # TODO - 需要判断文件的类型
      file_name = File.basename(file)

      params = {
          srcFileName: file_name,
          fileData: File.read(file)
      }

      self.uploadTempImage4SDK(params)
    end

    # 上传图片到临时目录(推荐使用)
    # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.uploadTempImage4SDK&v=1
    #
    def self.uploadTempImage4SDK(params = {}, body = {})
      api_endpoint 'api.uploadTempImage4SDK', params, body
    end

    # 上传图片到临时目录
    # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.uploadTempImage&v=1
    #
    def self.uploadTempImage(params = {})
      api_endpoint 'api.uploadTempImage', params
    end

    # 上传图片到图片银行(推荐使用)
    # 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.uploadImage4SDK&v=1
    #
    def self.uploadImage4SDK(params = {})
      api_endpoint 'api.uploadImage4SDK', params
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
  end
end
