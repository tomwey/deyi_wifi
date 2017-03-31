class WifiDog::WifiController < ApplicationController
  def login
    if params[:gw_id].blank? or params[:gw_address].blank? or params[:gw_port].blank? or params[:mac].blank?
      render status: :forbidden
      return
    end
    
    session[:gw_id]      = params[:gw_id]
    session[:gw_address] = params[:gw_address]
    session[:gw_port]    = params[:gw_port]
    session[:mac]        = params[:mac]
    
    @ap = AccessPoint.where(gw_id: params[:gw_id].downcase).first
  end
  
  def auth
    auth = 0
    
    if CommonConfig.banned_macs.blank?
      mac_banned = false
    elsif CommonConfig.banned_macs.split(',').include?(params[:mac])
      mac_banned = true
    else
      mac_banned = false
    end
    
    @ap = AccessPoint.find_by(gw_id: params[:gw_id].downcase)
    
    # 由网关传递过来
    token = params[:token]
    
    if !wifi_status = WifiStatus.find_by(token: token)
      puts "无效的上网Token: #{token}"
    else
      user = wifi_status.user
      if user.blank?
        puts "无效的用户上网状态信息"
      else
        case params[:stage]
        when 'login' # 初次认证登录
          if !user.has_enough_wifi_length?
            puts "没有足够的网时使用外网"
            code = -1
            msg = "没有足够的上网时长，请充值"
          elsif mac_banned
            puts "Banned MAC tried logging in at " + Time.now.to_s + " with MAC: " + params[:mac]
            code = -2
            msg = "您的设备禁止连接得益WIFI网络"
          else
            auth = 1
            # 记录上网日志
            WifiLog.create!(user_id: user.id, access_point_id: @ap.try(:id), mac: params[:mac], used_at: Time.zone.now)
            
            user.connect_wifi!
            
            code = 0
            msg = '得益WIFI网络连接成功，现在可以上网了'
          end
          
          # 发送通知给客户端，告知是否连接成功
          PushService.push_to('', ["#{user.uid}"], {
            code: code,
            message: msg
          })
          
        when 'counters' # 已经认证登录过
          connection = user.current_connection
          
          if connection.blank?
            puts "counters: 用户的当前外网连接为空"
          else
            # incoming = params[:incoming].to_i
            # outgoing = params[:outgoing].to_i
            
            # if incoming == 0 and outgoing == 0
            #   # 表示用户已经切换wifi了或者已经没有连接到WiFi了导致关掉了我们自己的wifi
            #   puts 'counter: 用户已经切换了wifi或系统关闭了wifi'
            #   connection.close!
            # else
            if !connection.closed?
              puts "counter: 当前用户没有关闭wifi"
              if !mac_banned and user.has_enough_wifi_length?
                auth = 1
                # 更新当前连接的上网状态信息
                # if connection.used_at.blank?
                #   connection.used_at = Time.zone.now
                # end
        
                connection.ip = params[:ip]
                
                if connection.incoming_bytes.to_i < params[:incoming].to_i
                  connection.incoming_bytes = params[:incoming]
                end
                if connection.outgoing_bytes.to_i < params[:outgoing].to_i
                  connection.outgoing_bytes = params[:outgoing]
                end
                connection.save!
        
              else
                puts "counter: 用户的MAC被禁用或者用户没有足够上网时间，关闭连接"
                connection.close!
              end # end mac check and wifi length check
            end # end connection close
            # end # end user traffic check
          end # end connection blank check
        
        when 'logout'
          puts "Logging out: #{params[:token]}"
          connection = user.current_connection
          connection.close!
        else
          puts "Invalid stage: #{params[:stage]}"
        end # end case
        
        # 给客户端发通知，告知用户已经离线了
        if auth == 0 and ( params[:stage] == 'counters' or params[:stage] == 'logout' )
          # 发送推送消息
          PushService.push_to('得益WIFI网络已经关闭了，请重新连接上网', ["#{user.uid}"])
        end
        
      end # end has user
      
    end # end has wifi status
    # 通知网关是否连上外网
    render text: "Auth: #{auth}"
  end
  
  def ping
    @ap = AccessPoint.find_by(gw_id: params[:gw_id])
    unless @ap.blank?
      @ap.update_attributes({
        sys_uptime: params[:sys_uptime],
        sys_load: params[:sys_load],
        sys_memfree: params[:sys_memfree],
        wifidog_uptime: params[:wifidog_uptime],
        client_count: params[:client_count],
        update_time: Time.now
      })
    end
    render text: "Pong"
  end
  
  def portal
    
    auth_result = params[:auth_result]
    client_mac  = params[:mac]
    
    if auth_result == 'failed'
      puts '连接外网失败'
      # PushService.push_to('', [], { code: -1, message: '连接失败，或者网络已经关闭' })
    else
      puts '连接外网成功'
      # PushService.push_to('', [], { code: 0, message: '连接成功，可以使用得益WIFI上网了' })
    end
    
    render status: :ok
    return
  end
  
  private
    
  def auth_1_0
    auth = 0
    
    # mac_banned = SiteConfig.banned_macs and SiteConfig.banned_macs.split(',').include?(params[:mac])
    if SiteConfig.banned_macs.blank?
      mac_banned = false
    elsif SiteConfig.banned_macs.split(',').include?(params[:mac])
      mac_banned = true
    else
      mac_banned = false
    end
    
    if !connection = Connection.find_by(token: params[:token])
      puts "Invalid token: #{params[:token]}"
    else
      case params[:stage]
      when 'login'
        if connection.expired? or connection.used?
          puts "Tried to login with used or expired token: #{params[:token]}"
        elsif mac_banned
          puts "Banned MAC tried logging in at " + Time.now.to_s + " with MAC: " + params[:mac]
        else
          connection.use!
          auth = 1
        end
      when 'counters'
        if !connection.expired?
          if !mac_banned
            auth = 1
            connection.update_attributes({
              mac: params[:mac],
              ip: params[:ip],
              incoming_bytes: params[:incoming],
              outgoing_bytes: params[:outgoing]
            })
          else
            connection.expire!
          end
        end
      when 'logout'
        puts "Logging out: #{params[:token]}"
        connection.expire!
      else
        puts "Invalid stage: #{params[:stage]}"
      end
    end
    
    render text: "Auth: #{auth}"
  end
  
end