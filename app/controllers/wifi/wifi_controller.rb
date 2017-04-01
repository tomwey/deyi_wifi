class Wifi::WifiController < ApplicationController
  # login/?gw_id=00F3D20903C0&gw_address=192.168.8.1&gw_port=80&gw_mac=00:f3:d2:09:03:c0&   ssid=5oiR55qE5peg57q/U1NJROWQjeensA==&mac=28:cf:da:f1:8c:d6&co=jk&router_type=JIKE-X86&
  # url=aHR0cDovLzE5Mi4xNjguMC4xL3dhbl9kaGNwLmFzcA==
  def login
    if params[:gw_id].blank? or params[:gw_address].blank? or params[:gw_port].blank? or params[:mac].blank?
      render status: :forbidden
      return
    end
    
    # 创建一个用户
    @client = Client.where(mac: params[:mac]).first_or_create
    
    # 生成一张二维码的图片地址，并将用户的private_token传入
    # 
    
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
    
    auth = 1
    conn = Connection.find_by(token: params[:token])
    
    case params[:stage]
    when 'login'
    when 'counter'
    else
      auth = 0
    end
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
    
  end
  
  # 认证失败
  def gw_message
    
  end
  
  # 下发连接token，然后接入wifi热点
  # connect?token=kdkskskskalskdad&ad_token=dksassddeieowoqqeeee
  def connect
    
    # http://网关地址:网关端口/wifidog/auth?token=
  end
end