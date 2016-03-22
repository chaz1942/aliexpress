module Aliexpress
  class Web < Sinatra::Base
    set :public_dir, File.dirname(__FILE__) + '/public'
    set :views, File.dirname(__FILE__) + '/views'

    # 授权页面
    get '/' do
      puts "params = #{params}"

      get_access_token_by_code params[:code]

      slim :index
    end
  end
end