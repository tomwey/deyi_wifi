module API
  module V1
    class Root < Grape::API
      version 'v1'
      
      helpers API::CommHelpers
      helpers API::SharedParams
      
      # 接口访问权限认证
      before do        
        is_pro = Rails.env.production?
        # 如果访问的是API文档，那么不做判断
        is_api_doc_path = request.path.include? "swagger_doc"
        # encode_str = Base64.urlsafe_encode64(SiteConfig.api_key + params[:i].to_s)
        encode_str = Digest::MD5.hexdigest(SiteConfig.api_key + params[:i].to_s)
        if is_pro && !is_api_doc_path && ( encode_str != params[:ak] or (Time.now.to_i - params[:i].to_i) > SiteConfig.access_key_expire_in.to_i )
          error!({"code" => 403, "message" => "没有访问权限"}, 403)
        end
      end
      
      # mount API::V1::Welcome
      mount API::V1::FeedbacksAPI
      mount API::V1::AuthCodesAPI
      mount API::V1::UsersAPI
      mount API::V1::BannersAPI
      mount API::V1::PayAPI
      mount API::V1::ApartmentsAPI
      # mount API::V1::BusinessAuthInfoAPI
      mount API::V1::CheckinsAPI
      mount API::V1::EarningsAPI
      mount API::V1::ProductsAPI
      # mount API::V1::ShipmentsAPI
      # mount API::V1::OrdersAPI
      mount API::V1::AdTasksAPI
      mount API::V1::MessagesAPI
      # mount API::V1::FollowTasksAPI
      # mount API::V1::ShareTasksAPI
      mount API::V1::ChannelsAPI
      mount API::V1::AppVersionsAPI
      mount API::V1::WithdrawsAPI
      mount API::V1::StudiosAPI
      mount API::V1::AppTasksAPI
      # mount API::V1::WifiAPI
      
      # 
      # 配合trix文本编辑器
      # mount API::V1::AttachmentsAPI
      
      # 开发文档配置
      add_swagger_documentation(
          :api_version => "api/v1",
          hide_documentation_path: true,
          # mount_path: "/api/v1/api_doc",
          hide_format: true
      )
      
    end
  end
end