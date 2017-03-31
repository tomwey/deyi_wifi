module API
  module V1
    class FeedbacksAPI < Grape::API
      
      resource :feedbacks, desc: '意见反馈接口' do
        desc "意见反馈"
        params do
          requires :content, type: String, desc: "反馈内容，必须"
          optional :author,  type: String, desc: "用户联系方式"
        end
        post do
          @feedback = Feedback.new(author: params[:author], content: params[:content])
          if @feedback.save
            render_json_no_data
          else
            render_error(5001, @feedback.errors.full_messages.join(','))
          end
        end
      end # end resource
      
    end
  end
end