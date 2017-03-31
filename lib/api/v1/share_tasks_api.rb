module API
  module V1
    class ShareTasksAPI < Grape::API
      
      helpers API::SharedParams
      
      resource :share_tasks, desc: '分享任务相关接口' do
        desc "获取任务列表"
        params do 
          requires :token, type: String, desc: '用户Token'
          use :pagination
        end
        get :list do
          
          user = authenticate!
          
          @tasks = ShareTask.where('(quantity - visit_count) > 0').opened.sorted.recent
          if params[:page]
            @tasks = @tasks.paginate page: params[:page], per_page: page_size
          end
          
          render_json(@tasks, API::V1::Entities::ShareTask, { uid: user.nb_code })
        end # end get list
      end # end resource
      
    end
  end
end