class Wifi::WifiController < ApplicationController
  # login/?gw_id=00F3D20903C0&gw_address=192.168.8.1&gw_port=80&gw_mac=00:f3:d2:09:03:c0&   ssid=5oiR55qE5peg57q/U1NJROWQjeensA==&mac=28:cf:da:f1:8c:d6&co=jk&router_type=JIKE-X86&url=aHR0cDovLzE5Mi4xNjguMC4xL3dhbl9kaGNwLmFzcA==
  def login
    if params[:gw_address].blank? or params[:gw_mac].blank? or params[:gw_port].blank? or params[:mac].blank?
      render status: :forbidden
      return
    end
    
    @ap = AccessPoint.find_by(gw_mac: params[:gw_mac])
    
    if @ap.blank?
      render status: :forbidden
      return
    end
    
    @ap.gw_id = params[:gw_id] if params[:gw_id]
    
    if @ap.gw_address.blank? or @ap.gw_port.blank?
      @ap.gw_address = params[:gw_address]
      @ap.gw_port    = params[:gw_port]
      @ap.save!
    end
    
    # 创建一个用户，此时这个客户端处于待认证状态
    @client = Client.where(mac: params[:mac]).first_or_create
    
    # 根据ap对应的门店ID获取该门店的登录地址，
    # 1、地址由平台统一模板，例如：GET http://deyi-ad.deyiwifi.com/wifi-auth/portal?gw_mac=xxxxxx&mac=xxxxxxxxxx
    # 跳转到登录认证页面，这个页面可以由我们系统认证平台统一认证模板，也可以由合作wifi提供商提供
    
    # session[:gw_id]      = params[:gw_id]
    # session[:gw_address] = params[:gw_address]
    # session[:gw_port]    = params[:gw_port]
    # session[:mac]        = params[:mac]
    
  end
  
  # /auth?stage=&ip=&mac=&token=&incoming=&outgoing=
  def auth
    if params[:token].blank?
      render text: 'Auth: 0'
      return
    end
    
    auth = 0
    conn = Connection.find_by(token: params[:token])
    
    if conn.blank?
      puts "无效的上网Token: #{params[:token]}"
    else
      if conn.client.mac != params[:mac]
        puts "非法上网操作Token:#{conn.token}, MAC:#{params[:mac]}"
      else
        case params[:stage]
        when 'login'
          puts "login"
          if conn.expired?
          else
            puts "login: 认证成功"
            auth = 1
          end
        when 'counter'
          puts "counter"
          if !conn.closed?
            if !conn.expired?
              auth = 1
              
              puts "counter: 可以上网"
              
              # 更新上网数据
              conn.ip = params[:ip]
              if conn.incoming.to_i < params[:incoming].to_i
                conn.incoming = params[:incoming]
              end
              if conn.outgoing.to_i < params[:outgoing].to_i
                conn.outgoing = params[:outgoing]
              end
              conn.save!
            else
              puts "counter: 没有足够的网时，不能上网"
              conn.close!
            end
          end
        else
          puts "Invalid stage: #{params[:stage]}"
        end
      end
    end
    
    render text: "Auth: #{auth}"
  end
  
  # /ping/?gw_id=00F3D20903C0&sys_uptime=10465&wifidog_uptime=32&check_time=600&wmac=00:f3:d2:09:03:c0&wip=192.168.0.12&pid=&sv=Build2016060611&wan_ip=192.168.0.12&sys_memfree=762340&client_count=1&sys_load=0.05&gw_address=192.168.8.1&router_type=JIKE-X86&gw_mac=00:f3:d2:09:03:c0
  def ping
    @ap = AccessPoint.find_by(gw_mac: params[:gw_mac])
    if @ap.present?
      @ap.sys_uptime     = params[:sys_uptime]
      @ap.wifidog_uptime = params[:wifidog_uptime]
      @ap.sys_load       = params[:sys_load].to_f * 1000
      @ap.sys_memfree    = params[:sys_memfree]
      @ap.client_count   = params[:client_count]
      @ap.update_time    = params[:check_time]
      @ap.save
    end
    render text: 'Pong'
  end
  
  # 认证成功
  def portal
    render text: '可以上网了'
  end
  
  # 认证失败
  def gw_message
    render text: 'gw_message: 不能上网'
  end
  
  def control86
    puts '----------------'
    puts params
    puts '----------------'
    render text: 'ok'
  end
  
  # 下发连接token，然后接入wifi热点
  # connect?token=kdkskskskalskdad&ad_token=dksassddeieowoqqeeee
  def connect
    @ap = AccessPoint.find_by(gw_mac: params[:bssid])
    
    @client = Client.find_by(mac: params[:mac])
    
    if @ap.blank? or @client.blank?
      render status: :forbidden
      return
    end
    
    # 从ap获取本次上网的网时长度，单位为分钟
    wifi_length = 1 # 真实环境下面是从广告系统里面去获得一个该广告主对应的上网时长
    
    # 关闭当前用户的所有连接
    @client.close_all_connections!
    
    # 创建一个新的连接
    @conn = Connection.create!(access_point_id: @ap.id, client_id: @client.id, expired_at: Time.zone.now + 1.minutes)
    
    # 向路由器网关注册上网
    redirect_to "http://#{@ap.gw_address}:#{@ap.gw_port}/wifidog/auth?token=#{@conn.token}"
  end
end