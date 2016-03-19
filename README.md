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

TODO: Write usage instructions here

文件的目录结构： 

```
├── bin
│   ├── console
│   └── setup
├── lib
│   ├── aliexpress
│   │   ├── anouncement.rb
│   │   ├── authorization.rb
│   │   ├── base.rb
│   │   ├── category.rb
│   │   ├── configure.rb
│   │   ├── freight.rb
│   │   ├── logistics.rb
│   │   ├── message.rb
│   │   ├── order.rb
│   │   ├── product.rb
│   │   ├── token
│   │   │   ├── object_store.rb
│   │   │   ├── redis_store.rb
│   │   │   └── store.rb
│   │   └── version.rb
│   └── aliexpress.rb
```


## Development

签出代码库之后， 运行 `bin/setup`安装依赖， 运行 `bin/console` 进入交互式探索环境。 

运行 `bundle exec rake install`， 将 gem 包安装到本地。 生成新的版本的步骤：

*  更新 `version.rb` 中的版本号
*  运行 `bundle exec rake release`， 创建 git tag, 提交请求和 tag，将生成新的 gem 推送到 [rubygems.org](https://rubygems.org)

速卖通的 API 地址: <http://gw.api.alibaba.com/dev/doc/intl/sys_description.htm?spm=5261.6744729.972263401.3.B9M4i7&ns=aliexpress.open>

备注：

方法的命名，取自 API 文档中的 apiName，将其中的 `api.` 前缀去掉。 


## Contributing

实现上， 获取 access_token 的方式，参考了 https://github.com/lanrion/weixin_authorize。 

Bug reports and pull requests are welcome on GitHub at https://github.com/xiajian/aliexpress. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

