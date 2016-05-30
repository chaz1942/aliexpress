# Aliexpress

Aliexpress 期初就就是想要实现对 速卖通的 API 进行封装， 尝试用使用开源的手法来开发。

## Installation

Add this line to your application's Gemfile:


```ruby
gem 'aliexpress'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aliexpress

## Usage

在 config/initializers/aliexpress.rb 文件中，设置: 


```
Aliexpress.app_key = 'Your app key'
Aliexpress.app_secret = 'Your app secret' 

Aliexpress.redis = Redis::Namespace.new(RedisSetting.name_space.to_sym, redis: Redis.new )
Aliexpress.redirect_uri = AliexpressSetting.redirect_uri
```

在路由中，添加如下的行: 

```
require 'aliexpress/web'
mount Aliexpress::Web => '/aliexpress/auth'
```

API 的使用，api 的命名 与 速卖通中的文档类似，文件和类的结构如下: 

```
lib
├── aliexpress
│   ├── authorization.rb - 授权相关
│   ├── base.rb - 基本类
│   ├── category.rb - 类目
│   ├── common.rb - 公共
│   ├── configure.rb - 配置信息
│   ├── data.rb - 数据
│   ├── evaluation.rb - 评价接口
│   ├── freight.rb - 运费
│   ├── logistics.rb - 物流信息
│   ├── marketing.rb - 营销
│   ├── message.rb - 站内信
│   ├── order.rb - 较易
│   ├── product.rb - 产品
│   ├── image.rb - 图片相关的接口, 图片银行 和 上传图片的功能
│   └── version.rb
└── aliexpress.rb
```

方法的实现: 

```
# 商品列表查询接口
# 地址：http://gw.api.alibaba.com/dev/doc/intl/api.htm?ns=aliexpress.open&n=api.findProductInfoListQuery&v=1
#
def findProductInfoListQuery(params = {})
    api_endpoint 'api.findProductInfoListQuery', params
end
```

使用: 

```
params[:page] ||= 20
params[:per] ||= 1

params.merge!({
    productStatusType: StatusType::ON_SELL,
    pageSize: params[:page],
    currentPage: params[:per]
})

Aliexpress::Product.findProductInfoListQuery params
```

## 多用户 和 单用户的区别

存储都是使用 redis，关键在于 key 。

单用户: 

```
Aliexpress.access_token = 'xxxx' # 10 小时过期
Aliexpress.refresh_token = 'xxx' # 半年过期一次
```

多用户: 每次访问时，需要传入用户特定的 `access_token`，使用如下:

```
params[:page] ||= 20
params[:per] ||= 1

params.merge!({
    productStatusType: StatusType::ON_SELL,
    pageSize: params[:page],
    currentPage: params[:per],
    access_token: self.access_token(account_refresh_token_key, account_access_token_key)
})

Aliexpress::Product.findProductInfoListQuery params
```

## Contributing

欢迎 Pull Request, qq 号: 1540469793。 

Bug reports and pull requests are welcome on GitHub at https://github.com/xiajian/aliexpress. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).