module API
  module V1
    class AdTasksAPI < Grape::API
      
      helpers API::SharedParams
      
      resource :ad_tasks, desc: "广告收益相关接口" do
        desc "获取广告列表"
        params do
          optional :loc, type: String, desc: "位置坐标，经纬度，值格式为：经度,纬度，例如：104.333122,30.893321"
          optional :sr,  type: String, desc: "指定图片的大小，值为：large, thumb, small中的一个，如果不传该参数默认为large"
          use :pagination
        end
        get :list do
          @tasks = AdTask.opened.no_expired.sorted.recent
          if params[:loc]
            lng,lat = params[:loc].split(',')
            @tasks = @tasks.list_with_location(lng, lat)
          end
          
          @tasks = @tasks.paginate page: params[:page], per_page: page_size
          
          sr = params[:sr] || "large"
          if not %w(large thumb small).include?(sr)
            sr = "large"
          end
          
          render_json(@tasks, API::V1::Entities::AdTask, image_size: sr)
        end # end get list
        desc "根据位置来获取附近的商家广告列表"
        params do
          requires :loc,   type: String,  desc: "位置坐标，经纬度，值格式为：经度,纬度，例如：104.333122,30.893321"
          optional :total, type: Integer, desc: "数量，如果不传该值，默认为30"
          optional :sr,  type: String, desc: "指定图片的大小，值为：large, thumb, small中的一个，如果不传该参数默认为large"
          use :pagination
        end
        get :nearby do
          lng,lat = params[:loc].split(',')
          size = ( params[:total] || 30 ).to_i
          sr = params[:sr] || "large"
          if not %w(large thumb small).include?(sr)
            sr = "large"
          end
          
          @tasks = AdTask.opened.no_expired.nearby(lng,lat,size).sorted.recent
          
          if params[:page]
            @tasks = @tasks.paginate page: params[:page], per_page: page_size
          end
          render_json(@tasks, API::V1::Entities::AdTask, image_size: sr)
        end # end get nearby
        
        desc "点击浏览商家广告"
        params do
          requires :token, type: String, desc: "用户Token"
          requires :ad_id, type: Integer, desc: "返回的广告任务id"
          optional :loc,     type: String, desc: "用到当前位置，经纬度坐标，格式为：经度,纬度，例如：104.312321,30.393930"
          use :device_info
        end
        post :view do
          user = authenticate!
          
          @ad_task = AdTask.find_by(id: params[:ad_id])
          return render_error(4004, '没有该广告') if @ad_task.blank?
          
          count = AdTaskViewLog.where(user_id: user.id, ad_task_id: @ad_task.id).count
          if count == 0
            # 说明是第一次浏览广告，给用户积分
            # 写收益明细
            EarnLog.create!(user_id: user.id,
                            earnable: @ad_task,
                            title: '浏览商家广告',
                            subtitle: "浏览商家广告，获得#{@ad_task.price}益豆",
                            earn: @ad_task.price)
          end
          
          if params[:loc]
            loc = "POINT(#{params[:loc].gsub(',', ' ')})"
          else
            loc = nil
          end
          
          # 记录浏览历史
          AdTaskViewLog.create!(user_id: user.id, 
                                ad_task_id: @ad_task.id,
                                location: loc,
                                udid: params[:udid],
                                model: params[:m],
                                platform: params[:pl],
                                os_version: params[:osv],
                                app_version: params[:bv],
                                screen_size: params[:sr],
                                country_language: params[:cl],
                                ip_addr: client_ip,
                                network_type: params[:nt],
                                is_broken: params[:bb])
                                
          render_json_no_data
          
        end # end post view
      end # end resource
      
    end
  end
end