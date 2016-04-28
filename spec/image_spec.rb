require 'aliexpress'

describe Aliexpress::Image do
  describe '测试速卖通图片相关接口' do
    it '上传图片到临时目录' do
      file = '/Users/xiajian/Downloads/test.jpg'

      Aliexpress::Image.upload_temp_image(file)
    end

    it '上传图片到图片银行' do
      response = Aliexpress::Image.upload_image '/Users/xiajian/Downloads/product_images/6.jpg'
    end

    it '查询图片银行分组信息' do
      response = Aliexpress::Image.listGroup

      expect(response.photoBankImageGroupList.class).to eq(Array)
    end
  end
end      
