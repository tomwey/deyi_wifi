module API
  module V1
    class CheckinsAPI < Grape::API
      
      helpers API::SharedParams
      
      resource :checkins, desc: '签到接口' do
        desc "创建签到"
        params do
          requires :token,   type: String, desc: "用户认证Token"
          optional :loc,     type: String, desc: "用到当前位置，经纬度坐标，格式为：经度,纬度，例如：104.312321,30.393930"
          use :device_info
        end
        post do
          user = authenticate!
          
          has_record = Checkin.today_for_user(user).count > 0
          return render_error(10001, '今天已经签到过了') if has_record
          
          if params[:loc]
            loc = "POINT(#{params[:loc].gsub(',', ' ')})"
          else
            loc = nil
          end
          
          earn = ( CommonConfig.checkin_earn || 0 ).to_i
          
          Checkin.transaction do
            checkin = Checkin.create!(user_id: user.id, 
                                      location: loc, 
                                      earn: earn,
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
            
            # 写收益明细
            EarnLog.create!(user_id: user.id,
                            earnable: checkin,
                            title: '签到',
                            subtitle: "成功签到，获得#{earn}益豆",
                            earn: earn)
          end
          
          render_json_no_data
        end
      end # end resource
      
    end
  end
end