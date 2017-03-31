module API
  module V1
    class FollowTasksAPI < Grape::API
      
      helpers API::SharedParams
      
      resource :follow_tasks, desc: '关注任务相关接口' do
        desc "获取任务列表"
        params do 
          requires :token, type: String, desc: '用户Token'
          use :pagination
        end
        get :list do
          
          user = authenticate!
          
          @ft_ids = FollowTaskLog.where(uid: user.nb_code).pluck(:follow_task_id)
          
          @tasks = FollowTask.where.not(id: @ft_ids).opened.sorted.recent
          if params[:page]
            @tasks = @tasks.paginate page: params[:page], per_page: page_size
          end
          
          render_json(@tasks, API::V1::Entities::FollowTask, { uid: user.nb_code })
        end # end get list
      end # end resource
      
    end
  end
end