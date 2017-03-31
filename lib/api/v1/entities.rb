module API
  module V1
    module Entities
      class Base < Grape::Entity
        format_with(:null) { |v| v.blank? ? "" : v }
        format_with(:chinese_date) { |v| v.blank? ? "" : v.strftime('%Y-%m-%d') }
        format_with(:chinese_datetime) { |v| v.blank? ? "" : v.strftime('%Y-%m-%d %H:%M:%S') }
        format_with(:money_format) { |v| v.blank? ? 0 : ('%.2f' % v).to_f }
        expose :id
        # expose :created_at, format_with: :chinese_datetime
      end # end Base
      
      # 版本信息
      class AppVersion < Base
        expose :version
        expose :app_download_url do |model, opts|
          if model.file
            model.file.url
          else
            ''
          end
        end
        expose :must_upgrade
        expose :link do |model, opts|
          model.version_summary_url
        end
      end
      
      # 收货地址
      class Shipment < Base
        expose :name
        expose :hack_mobile, as: :mobile
        expose :address
        expose :is_current do |model, opts|
          model.id == model.user.try(:current_shipment_id)
        end
      end
      
      # 用户基本信息
      class UserProfile < Base
        expose :uid, format_with: :null
        expose :mobile, format_with: :null
        expose :nickname do |model, opts|
          model.nickname || model.hack_mobile
        end
        expose :avatar do |model, opts|
          model.avatar.blank? ? "" : model.avatar_url(:large)
        end
        expose :nb_code, as: :invite_code
        expose :bean
        expose :balance
        expose :current_shipment, as: :shipment, using: API::V1::Entities::Shipment, if: proc { |u| u.current_shipment_id.present? }
        # expose :wifi_length
        expose :qrcode_url
      end
      
      # 用户详情
      class User < UserProfile
        expose :private_token, as: :token, format_with: :null
      end
      
      class Studio < Base
        expose :studio_id, as: :id
        expose :name
        expose :contact_name
        expose :balance
        expose :earnings, as: :earn
      end
      
      # 供应商
      class Merchant < Base
        expose :name
        expose :mobile
        expose :address, format_with: :null
        expose :note, format_with: :null
      end
      
      # 商品
      class Product < Base
        expose :title, :body, :price, :sku, :is_virtual_goods, :orders_count, :visit_count
        expose :stocks_count, as: :stock
        expose :image do |model, opts|
          if model.image.blank?
            ""
          else
            model.image.url(:thumb)
          end
        end
        expose :merchant_name do |model, opts|
          model.merchant.try(:name) || ""
        end
        expose :detail_url
        
      end
      
      # 订单
      class Order < Base
        expose :order_no
        expose :product_title, as: :title
        expose :product_small_image, as: :image
        expose :quantity
        expose :product_price, as: :price
        expose :total_fee
        expose :state_info, as: :state
        expose :created_at, as: :time, format_with: :chinese_datetime
      end
      
      # 收益明细
      class EarnLog < Base
        expose :title
        expose :earn
        expose :unit
        expose :created_at, as: :time, format_with: :chinese_datetime
      end
      
      
      class AppTask < Base
        expose :task_id, as: :id
        expose :icon do |model, opts|
          model.app.icon ? model.app.icon.url(:big) : ''
        end
        expose :app_id do |model, opts|
          model.app.app_id
        end
        expose :app_name do |model, opts|
          model.app.name
        end
        expose :bundle_id do |model, opts|
          model.app.bundle_id
        end
        expose :appstore_url do |model, opts|
          model.app.appstore_url
        end
        expose :url_scheme do |model, opts|
          model.app.url_scheme || ''
        end
        expose :name, :keywords, :task_steps
        expose :price do |model, opts|
          opts[:st] == 0 ? model.price : model.st_price
        end
        expose :special_price
        expose :put_in_count do |model, opts|
          opts[:st] == 0 ? model.put_in_count : model.st_put_in_count
        end
        expose :grab_count do |model, opts|
          opts[:st] == 0 ? model.grab_count : model.st_grab_count
        end
        expose :in_progress do |model, opts|
          if opts[:ip]
            model.in_progress?(opts[:ip])
          else
            false
          end
        end
      end
      
      class AppTaskDetail < AppTask
        expose :task_log_id do |model, opts|
          opts[:opts][:log_id]
        end
      end
      
      # 收益摘要
      class EarnSummary < Base
        expose :task_type do |m, opts|
          ::EarnLog::TASK_TYPES.index(m.earnable_type) + 1
        end
        expose :task_name do |m,opts|
          ::EarnLog.task_name(m.earnable_type)
        end
        expose :total
      end
      
      # 积分墙渠道
      class Channel < Base
        expose :name, :title
        expose :subtitle, format_with: :null
        expose :icon do |model, opts|
          if model.icon
            model.icon.url(:large)
          else
            ''
          end
        end
      end
      
      # 关注任务
      class FollowTask < Base
        expose :icon do |model, opts|
          if model.icon
            model.icon.url(:large)
          else
            ''
          end
        end
        expose :gzh_name, :gzh_id
        expose :gzh_intro do |model, opts|
          model.gzh_intro || '7天内不能取消关注'
        end
        expose :earn, as: :income
        expose :link do |model, opts|
          uid = opts[:opts][:uid]
          model.task_detail_url_for(uid)
        end
      end
      
      # 分享任务
      class ShareTask < Base
        expose :icon do |model, opts|
          if model.icon
            model.icon.url(:large)
          else
            ''
          end
        end
        expose :title
        expose :earn, as: :income
        expose :first_open_earn, as: :first_open_income
        expose :link
        expose :left_count do |model, opts|
          [model.quantity - model.visit_count, 0].max
        end
        expose :my_total_income do |model, opts|
          uid = opts[:opts][:uid]
          model.my_total_income_for(uid)
        end
        expose :share_icon do |model, opts|
          if model.icon
            model.icon.url(:large)
          else
            ''
          end
        end
        expose :share_link do |model, opts|
          model.format_share_link_for(opts[:opts][:uid])
        end
        expose :share_content do |model, opts|
          model.format_share_content_for(opts[:opts][:uid])
        end
      end
      
      # 租房
      class Apartment < Base
        expose :images do |model, opts|
          img_size = opts[:opts][:image_size].to_sym
          model.images.map { |img| img.url(img_size) }
        end
        expose :name, :area, :rental, :rent_type
        expose :model do |model, opts|
          model.model_info
        end
        expose :title
        expose :body, format_with: :null
        expose :facilities
        expose :deco_info, format_with: :null
        expose :contact_info, if: proc { |a| not a.hide_mobile } do
          expose :u_name,   format_with: :null
          expose :u_mobile, format_with: :null
        end
        expose :room_info, if: proc { |apartment| apartment.rent_type == '单间' } do
          expose :room_type
          expose :sex_limit
        end
        expose :location_str, as: :location
        expose :distance do |model, opts|
          model.try(:distance) || 0
        end
        expose :published_at
        expose :user, using: API::V1::Entities::UserProfile, if: proc { |a| a.user_id.present? }
      end
      
      # 商家广告
      class AdTask < Base
        expose :title
        expose :subtitle, format_with: :null
        expose :cover_image do |model,opts|
          img_size = opts[:opts][:image_size].to_sym
          if model.cover_image.blank?
            ''
          else
            model.cover_image.url(img_size)
          end
        end
        expose :price, :share_price
        expose :location_str, as: :location
        expose :distance do |model, opts|
          model.try(:distance) || 0
        end
        expose :view_count, :sort
        expose :expired_on, format_with: :chinese_date
        expose :ad_type
        expose :ad_contents, if: proc { |a| a.ad_type != 2 } do |model, opts|
          model.ad_contents.map { |file| file.url }
        end
        expose :ad_link, if: proc { |a| a.ad_type == 2 and a.ad_link.present? }
      end
      
      # 消息
      class Message < Base
        expose :title do |model, opts|
          model.title || '系统公告'
        end#, format_with: :null
        expose :content, as: :body
        expose :created_at, format_with: :chinese_datetime
      end
      
      class PayHistory < Base
        expose :pay_name, format_with: :null
        expose :created_at, format_with: :chinese_datetime
        expose :pay_money do |model, opts|
          if model.pay_type == 0
            "+ ¥ #{model.money}"
          elsif model.pay_type == 1
            "- ¥ #{model.money}"
          else
            if model.pay_name == '打赏别人'
              "- ¥ #{model.money}"
            else
              "+ ¥ #{model.money}" # 收到打赏
            end
          end
        end
      end
      
      class Author < Base
        expose :nickname do |model, opts|
          model.nickname || model.mobile
        end
        expose :avatar do |model, opts|
          model.avatar.blank? ? "" : model.avatar_url(:large)
        end
      end
      
      # 提现
      class Withdraw < Base
        expose :bean, :fee
        expose :total_beans do |model, opts|
          model.bean + model.fee
        end
        expose :pay_type do |model, opts|
          if model.account_type == 1
            "微信提现"
          elsif model.account_type == 2
            "支付宝提现"
          else
            ""
          end
        end
        expose :state_info, as: :state
        expose :created_at, as: :time, format_with: :chinese_datetime
        expose :user, using: API::V1::Entities::Author
      end
      
      # Banner
      class Banner < Base
        expose :image do |model, opts|
          model.image.blank? ? "" : model.image.url(:large)
        end
        expose :link, format_with: :null
      end
      
      # 上网的状态
      class WifiStatus < Base
        expose :wifi_length, :login_count
        expose :last_login_at, format_with: :chinese_datetime
        expose :wifi_online
        expose :wifi_mac, as: :mac
        expose :ap_list do |model, opts|
          if opts.blank? or opts[:opts].blank? or opts[:opts][:ap_list].blank?
            []
          else
            opts[:opts][:ap_list]
          end
        end
      end
      
      class WifiChargePlan < Base
        expose :cid, :hour, :cost
      end
    
    end
  end
end
