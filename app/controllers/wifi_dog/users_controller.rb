class WifiDog::UsersController < ApplicationController
  def login
    if params[:gw_id] and params[:gw_address] and params[:gw_port]
      session[:gw_id] = params[:gw_id]
      session[:gw_address] = params[:gw_address]
      session[:gw_port] = params[:gw_port]
    end
  end
  
  def sign_in
    return unless request.post?
    redirect_to :wifi_dog_portal_path and return if !params[:gw_id]
    
    user = User.find_by(mobile: params[:mobile])
    if user.blank?
      flash[:notice] = '用户未注册'
      redirect_to :back and return
    end
    
    if !user.authenticate(params[:password])
      flash[:notice] = '密码不正确'
      redirect_to :back and return
    end
    
    user.expire_all_connections
      
    session[:user] = user
    
    node = AccessNode.where(mac: params[:gw_id]).first_or_create
    node.time_limit = user.wifi_length
    node.save!
    
    session[:access_node] = node
    
    min = (CommonConfig.free_wifi_length || 2).to_i
    login_connection = Connection.create!(
      remote_addr: request.remote_addr,
      token: SecureRandom.uuid,
      access_node: node,
      user: user,
      expired_at: Time.now + min.minutes
    )
    
    redirect_to 'http://' + params[:gw_address].to_s + ':' + params[:gw_port].to_s + '/wifidog/auth?token=' + login_connection.token
  end
    
  def register
    
    # 手机号检测
    
    # 是否注册过账号检查
    
    # 验证码检查
    
    # 注册
    
    if session[:gw_id] and session[:gw_address] and session[:gw_port]
      # Fake user login, works quite well
      params[:gw_id] = session[:gw_id]
      params[:gw_address] = session[:gw_address]
      params[:gw_port] = session[:gw_port]
      session[:gw_id] = session[:gw_address] = session[:gw_port] = nil
      sign_in
    else
      # Redirect o user login, we don't have the info to auto-login in the session
      render :login
    end
  end
  
  def signup
    
  end
  
end