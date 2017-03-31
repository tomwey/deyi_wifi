module API
  module V1
    class WifiAPI < Grape::API
      
      resource :wifi, desc: 'WIFI相关的接口' do
        desc '获取用户的得益wifi信息'
        params do
          requires :token, type: String, desc: '用户Token'
        end
        get :status do
          user = authenticate!
          
          wifi_status = WifiStatus.where(user_id: user.id).first
          
          @ap_list = AccessPoint.pluck(:wmac)
          
          render_json(wifi_status, API::V1::Entities::WifiStatus, { ap_list: @ap_list })
        end # end get info
        
        desc '连接wifi'
        params do
          requires :token,  type: String, desc: '用户Token'
          requires :gw_mac, type: String, desc: '热点的MAC地址' 
        end
        post :open do
          user = authenticate!
          
          # 如果没有找到热点，直接返回错误提示
          @ap = AccessPoint.where(wmac: params[:gw_mac]).first
          if @ap.blank?
            return render_error(20001, "不是得益WIFI官方热点")
          end
          
          # 检测当前账号是否正在上网
          if user.has_connected_wifi?
            return render_error(20002, "当前账号正在上网，你不能多人同时使用")
          end
          
          # 检测是否有足够的网时
          unless user.has_enough_wifi_length?
            return render_error(20003, "没有足够的上网往时，至少需要#{user.min_allowed_wifi_length}分钟，请充值")
          end
          
          # 返回给客户端热点的网关注册地址
          token = user.wifi_status.try(:token)
          if token.blank?
            return render_error(20004, "用户的上网认证Token不存在或生成失败")
          end
          
          # 返回网关注册地址
          { code: 0, link: "http://#{@ap.gw_address}:#{@ap.gw_port}/wifidog/auth?token=#{token}" }
          
        end # end post open
        
        desc '关闭wifi'
        params do
          requires :token,  type: String, desc: '用户Token'
          requires :gw_mac, type: String, desc: '热点的MAC地址' 
        end
        post :close do
          
          user = authenticate!
          
          # 如果没有找到热点，直接返回错误提示
          @ap = AccessPoint.where(wmac: params[:gw_mac]).first
          if @ap.blank?
            return render_error(20001, "不是得益WIFI官方热点")
          end
          
          connection = user.current_connection_for(@ap)
          
          # connection = user.current_connection
          if connection.blank?
            return render_error(20005, "当前用户没有连接wifi")
          end
          
          connection.close!
          
          # # 如果没有找到热点，直接返回错误提示
          # @ap = AccessPoint.where(gw_mac: params[:gw_mac]).first
          # if @ap.blank?
          #   return render_error(20003, "没有找到热点")
          # end
          # 
          # # 返回给客户端热点的网关注册地址
          # token = user.wifi_status.try(:token)
          # if token.blank?
          #   return render_error(20004, "用户的上网认证Token不存在或生成失败")
          # end
          
          # 返回网关注册地址
          # { code: 0, link: "http://#{@ap.gw_address}:#{@ap.gw_port}/wifidog/auth?token=#{token}" }
          
          render_json_no_data
          
        end # end post close
        
        desc "返回充值套餐列表"
        params do
          requires :token, type: String, desc: '用户认证Token'
        end
        get :charge_list do
          user = authenticate!
          
          @plans = WifiChargePlan.order('hour asc')
          render_json(@plans, API::V1::Entities::WifiChargePlan)
        end # end get charge_list
        
        desc "wifi充值"
        params do
          requires :token, type: String, desc: "用户认证Token"
          requires :cid,   type: String, desc: "套餐ID，对应套餐列表中返回的cid的值"
        end
        post :charge do
          user = authenticate!
          
          @plan = WifiChargePlan.find_by(cid: params[:cid])
          if @plan.blank?
            render_error(4004, "没有找到该套餐")
          end
          
          if @plan.cost > user.balance
            render_error(20006, "余额不足，不能充值")
          end
          
          if user.charge_wifi_length!(@plan.hour * 60)
            user.change_balance!(- @plan.cost)
            render_json_no_data
          else
            render_error(20007, '充值失败！')
          end
          
        end # end post charge
        
      end # end resource
      
    end
  end
end