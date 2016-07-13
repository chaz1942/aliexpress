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

Aliexpress.redis = Redis::Namespace.new('namespace', redis: Redis.new )
Aliexpress.logger = Rails.logger   # 默认使用的是 Logger 的实例变量
Aliexpress.redirect_uri = 'http://your-domain/aliexpress/auth' # gem 包提供的
Aliexpress.project_url = '/'    
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
params.merge!({
    productStatusType: StatusType::ON_SELL,
    pageSize: 20,
    currentPage: 1
})

Aliexpress::Product.findProductInfoListQuery params
```

## 授权流程

参考: 速卖通官方授权的流程(<http://gw.api.alibaba.com/dev/doc/intl/sys_auth.htm?ns=aliexpress.open>)。 具体的步骤： 

1. 获取授权的 URL 地址: Aliexpress::Authorization.get_auth_url(account.unique_id)， 并在 页面或直接在浏览器中打开

  备注: 生成的 URL 链接: "http://authhz.alibaba.com/auth/authorize.htm?client_id=#{Aliexpress.app_key}&site=aliexpress&redirect_uri=http://xiajian.vip.natapp.cn/aliexpress/auth&state=account_9&_aop_signature=26E277DD75FA169BE830CCBFEC858C5FD5879F4D"


2. 在速卖通的授权页面，输入用户名密码，点击授权，等待会跳到回调地址(Aliexpress.redirect_uri) - gem 包提供的处理逻辑

3. 处理逻辑结束后，会跳到项目的地址(Aliexpress.project_url)，之后，获取`access_token`的大体逻辑如下: 

```
def account_access_token_key
 set_token_key 'access_token', account_refresh_token_key
end

def account_refresh_token_key
 set_token_key 'refresh_token', self.unique_id
end

def set_token_key(type = '', value)
 token_key = "#{type}_key"
 return self.content[token_key] if self.content[token_key].present?
 
 self.content[token_key] = Aliexpress::Base.public_send "get_#{token_key}".to_sym, value

 self.save

 self.content[token_key]
end

# get_ali_account_token '309af7f538d786747aa644f8a2e4dc51', '2a96b17127a5cd29f2309df75a3524f6'
def get_ali_access_token
 Aliexpress::Base.access_token(account_refresh_token_key, account_access_token_key)
end
```



## 多用户 和 单用户的区别

存储都是使用 redis，关键在于 key， 通过授权 state 参数，设置 key 的变化，从而存储多个 refresh_token 以及 access_token。

单用户: 

```
Aliexpress.access_token = 'xxxx' # 10 小时过期
Aliexpress.refresh_token = 'xxx' # 半年过期一次
```

多用户: 每次访问时，需要传入用户特定的 `access_token`，使用如下:

```
params.merge!({
    productStatusType: StatusType::ON_SELL,
    pageSize: 20,
    currentPage: 1
    access_token: self.access_token(account_refresh_token_key, account_access_token_key)
})

Aliexpress::Product.findProductInfoListQuery params
```

## Contributing

欢迎 Pull Request, qq 号: 1540469793。 

Bug reports and pull requests are welcome on GitHub at https://github.com/xiajian/aliexpress. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).