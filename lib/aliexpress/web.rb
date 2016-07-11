module Aliexpress
  class Web < Sinatra::Base
    set :public_dir, File.dirname(__FILE__) + '/public'
    set :views, File.dirname(__FILE__) + '/views'

    # 授权页面
    get '/' do
      Aliexpress.logger.info "params = #{params}"

      @project_url = Aliexpress.project_url

      if params[:code].blank? && params[:state].blank?
        redirect @project_url
        return
      end

      Aliexpress::Authorization.get_access_token_by_params params

      slim :index
    end
  end
end