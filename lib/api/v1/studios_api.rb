module API
  module V1
    class StudiosAPI < Grape::API
      
      helpers API::SharedParams
      
      resource :studio, desc: '工作室相关接口' do
        desc "工作室登录"
        params do
          requires :sid, type: String, desc: '工作室账号'
          # use :device_info
        end
        post :login do
          studio = Studio.find_by(studio_id: params[:sid])
          
          if studio.blank?
            return render_error(4004, '该工作室不存在')
          end
          
          @ip = client_ip
          
          has_record = StudioLoginHistory.today_for(studio, @ip).count > 0
          if has_record
            return render_error(1001, '同一IP，同一账号，一天只能登录一次')
          end
          
          # 登陆，并写日志
          StudioLoginHistory.create!(studio: studio, login_ip: @ip)
          
          render_json(studio, API::V1::Entities::Studio)
        end # end post
        
        desc "获取工作室的基本信息"
        params do
          requires :sid, type: String, desc: '工作室账号'
        end
        get :profile do
          studio = Studio.find_by(studio_id: params[:sid])
          
          if studio.blank?
            return render_error(4004, '该工作室不存在')
          end
          
          render_json(studio, API::V1::Entities::Studio)
        end # end get
        
      end # end resource
      
    end
  end
end