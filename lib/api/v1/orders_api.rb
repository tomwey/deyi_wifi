module API
  module V1
    class OrdersAPI < Grape::API
      
      helpers API::SharedParams
      
      resource :orders, desc: "订单接口" do
        desc "下单"
        params do
          requires :token,    type: String,  desc: "用户Token"
          requires :sku,      type: Integer, desc: "产品编号sku"
          optional :quantity, type: Integer, desc: "产品数量，如果不传该参数，值默认为1"
          optional :note,     type: String,  desc: "订单备注"
        end
        post :create do
          user = authenticate!
          
          product = Product.find_by(sku: params[:sku])
          return render_error(4004, '未找到产品') if product.blank?
          
          # 检查库存
          quantity = (params[:quantity] || 1).to_i
          return render_error(-1, '库存不足') if product.stock < quantity
          
          # 检查余额是否足够
          total_fee = product.price * quantity
          return render_error(-1, '余额不足') if user.balance < total_fee
          
          # 检查是否设置了收货地址
          if !product.is_virtual_goods
            if user.current_shipment_id.blank?
              return render_error(-1, '收货地址不能为空')
            end
          end
          
          order = Order.new(product_id: product.id, 
                            user_id: user.id, 
                            total_fee: total_fee,
                            quantity: quantity,
                            note: params[:note])
          if !product.is_virtual_goods
            order.shipment_id = user.current_shipment_id
          end 
          
          if order.save
            # 更新用户的余额
            user.change_balance!(- order.total_fee)
            render_json(order, API::V1::Entities::Order)
          else
            render_error(-1, order.errors.full_messages.join(','))
          end
        end # end post create
        
        desc '获取订单列表'
        params do
          requires :token, type: String, desc: "用户Token"
          optional :state, type: String, desc: '订单状态，如果不传该参数，会获取全部订单；该参数可能的值为：pending(待处理)，paid(待配送)，shipping(配送中)，canceled(已取消)，completed(已完成)'
          use :pagination
        end
        get :list do
          user = authenticate!
          
          @orders = Order.where(user_id: user.id).order('id desc')
          if params[:state]
            @orders = @orders.with_state(params[:state].to_sym)
          end
          
          if params[:page]
            @orders = @orders.paginate page: params[:page], per_page: page_size
          end
          
          render_json(@orders, API::V1::Entities::Order)
        end # end get list
        
      end # end resource
      
    end
  end
end