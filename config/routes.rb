Rails.application.routes.draw do
  # mount RedactorRails::Engine => '/redactor_rails'
  
  # 网页文档
  resources :pages, path: :p, only: [:show]
    
  # WIFI认证系统
  namespace :wifi, path: '' do
    # 客户端首次连接wifi，浏览器请求将被重定向到login并携带参数
    # login?gw_address=路由器ip&gw_port=路由器wifidog的端口&gw_id=用户id&mac=用户的mac地址&url=被重定向前用户浏览的地址
    get '/login'  => 'wifi#login',  as: :wifi_login
    get '/auth'   => 'wifi#auth',   as: :wifi_auth
    get '/ping'   => 'wifi#ping',   as: :wifi_ping
    get '/portal' => 'wifi#portal', as: :wifi_portal
    get '/gw_message' => 'wifi#gw_message', as: :wifi_gw_message
    
    # connect?access_token=xxxxxxx
    get '/connect' => 'wifi#connect', as: :wifi_connect
  end
  # namespace :wifi_dog, path: '' do
  #   # get '/login'  => 'users#login',  as: :login
  #   # post '/sign_in' => 'users#sign_in', as: :sign_in
  #   # post '/register' => 'users#register', as: :register
  #   # get '/signup' => 'users#signup', as: :signup
  #   get '/login'  => 'wifi#login',   as: :login
  #   get '/download_auth' => 'wifi#download_auth', as: :download_auth
  #   get '/auth'   => 'wifi#auth',    as: :auth
  #   get '/ping'   => 'wifi#ping',    as: :ping
  #   get '/portal' => 'wifi#portal',  as: :portal
  # end
  
  # 后台系统登录
  devise_for :admins, ActiveAdmin::Devise.config
  
  # 后台系统路由
  ActiveAdmin.routes(self)
  
  # 队列后台管理
  # require 'sidekiq/web'
  # authenticate :admin do
  #   mount Sidekiq::Web => 'sidekiq'
  # end
  
  # API 文档
  # mount GrapeSwaggerRails::Engine => '/apidoc'
  # 
  # # API 路由
  # mount API::Dispatch => '/api'
end
