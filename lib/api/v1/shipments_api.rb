module API
  module V1
    class ShipmentsAPI < Grape::API
      
      helpers API::SharedParams
      resource :shipments, desc: '收货地址相关接口' do
        desc "获取用户的当前收货地址"
        params do
          requires :token, type: String, desc: "用户Token"
        end
        get :current do
          user = authenticate!
          
          @shipment = user.current_shipment
          if @shipment.blank?
            render_error(4004, '还未设置收货地址')
          else
            render_json(@shipment, API::V1::Entities::Shipment)
          end
        end # end get current
        
        desc "获取用户所有地址列表"
        params do
          requires :token, type: String, desc: "用户Token"
          use :pagination
        end
        get :list do
          user = authenticate!
          
          @shipments = Shipment.where(user_id: user.id).order('id desc')
          if params[:page]
            @shipments = @shipments.paginate page: params[:page], per_page: page_size
          end
          
          render_json(@shipments, API::V1::Entities::Shipment)
        end # end get list
        
        desc "新增收货地址"
        params do
          requires :token,   type: String, desc: "用户Token"
          requires :name,    type: String, desc: "姓名"
          requires :mobile,  type: String, desc: "手机"
          requires :address, type: String, desc: "收货地址"
        end
        post :create do
          user = authenticate!
          
          shipment = Shipment.new(name: params[:name], 
                                      mobile: params[:mobile], 
                                      address: params[:address],
                                      user_id: user.id)
                                      
          if shipment.save
            render_json(shipment, API::V1::Entities::Shipment)
          else
            render_error(6001, shipment.errors.full_messages.join(','))
          end
          
        end # end post create
        
        desc "编辑收货地址"
        params do
          requires :token,   type: String, desc: "用户Token"
          requires :shipment_id, type: Integer, desc: "返回的收货地址ID"
          optional :name,    type: String, desc: "姓名"
          optional :mobile,  type: String, desc: "手机"
          optional :address, type: String, desc: "收货地址"
        end
        post :update do
          user = authenticate!
          
          @shipment = Shipment.where(user_id: user.id, id: params[:shipment_id]).first
          
          @shipment.name = params[:name] if params[:name].present?
          @shipment.mobile = params[:mobile] if params[:mobile].present?
          @shipment.address = params[:address] if params[:address].present?
          
          if @shipment.save
            render_json(@shipment, API::V1::Entities::Shipment)
          else
            render_error(6001, @shipment.errors.full_messages.join(','))
          end
          
        end # end post update
        
        desc "删除收货地址"
        params do
          requires :token,   type: String, desc: "用户Token"
          requires :shipment_ids, type: String, desc: "用逗号分隔的一些收货地址ID，例如：3,2,4,5"
        end
        post :delete do
          user = authenticate!
          
          ids = params[:shipment_ids].split(',')
          
          Shipment.transaction do
            Shipment.where(user_id: user.id, id: ids).delete_all
            if user.current_shipment_id && ids.include?(user.current_shipment_id.to_s)
              user.current_shipment_id = nil
              user.save!
            end
          end
          render_json_no_data
        end # end post delete
        
        desc "设置默认收货地址"
        params do
          requires :token,       type: String,  desc: "用户Token"
          requires :shipment_id, type: Integer, desc: "收货地址ID"
        end
        post :set_current do
          user = authenticate!
          
          shipment = Shipment.find_by(id: params[:shipment_id])
          return render_error(4004, '没有找到该收货地址') if shipment.blank?
          
          user.current_shipment_id = shipment.id
          user.save!
          
          render_json_no_data
        end # end post set_current
        
      end # end resource
      
    end
  end
end