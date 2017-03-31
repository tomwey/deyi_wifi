module API
  module V1
    class AppVersionsAPI < Grape::API
      
      resource :version, desc: '版本更新接口' do
        desc '检测版本'
        params do
          requires :os,  type: String, desc: '系统, ios或者android'
          requires :bv,  type: String, desc: 'app当前版本号'
          requires :m,   type: Integer, desc: 'app的使用环境，0表示开发模式，1表示产品模式'
        end
        get :check do
          @app = AppVersion.opened.where('lower(os) = ? and mode = ? and version > ?', params[:os].downcase, params[:m], params[:bv]).order('version desc').first
          if @app.blank?
            render_error(4004, '没有新版本')
          else
            render_json(@app, API::V1::Entities::AppVersion)
          end
        end # end get check
        
        desc '升级下载统计'
        params do
        end
        post :download do
        end # end post download
      end # end resource
      
    end
  end
end