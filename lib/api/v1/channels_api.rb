module API
  module V1
    class ChannelsAPI < Grape::API
      
      resource :channels, desc: '积分墙接口' do
        desc "获取积分墙渠道列表"
        params do 
          # requires :token, type: String, desc: "用户Token"
          requires :os_type, type: Integer, desc: "设备系统类型，1为iOS, 2为Android"
        end
        get :list do
          @channels = Channel.list_for_os(params[:os_type]).opened.sorted.recent
          
          render_json(@channels, API::V1::Entities::Channel)
        end # end get list
      end # end resource
      
    end
  end
end