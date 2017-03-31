class Wifi::WifiController < ApplicationController
  # login/?gw_id=00F3D20903C0&gw_address=192.168.8.1&gw_port=80&gw_mac=00:f3:d2:09:03:c0&   ssid=5oiR55qE5peg57q/U1NJROWQjeensA==&mac=28:cf:da:f1:8c:d6&co=jk&router_type=JIKE-X86&
  # url=aHR0cDovLzE5Mi4xNjguMC4xL3dhbl9kaGNwLmFzcA==
  def login
    if params[:gw_id].blank? or params[:gw_address].blank? or params[:gw_port].blank? or params[:mac].blank?
      render status: :forbidden
      return
    end
    
    session[:gw_id]      = params[:gw_id]
    session[:gw_address] = params[:gw_address]
    session[:gw_port]    = params[:gw_port]
    session[:mac]        = params[:mac]
  end
  
  def auth
    
  end
  
  def ping
    
  end
  
  def portal
    
  end
  
  # 下发连接token，然后接入wifi热点
  def connect
    
  end
end