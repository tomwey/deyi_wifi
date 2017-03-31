module API
  module V1
    class PayAPI < Grape::API
      
      helpers API::SharedParams
      
      resource :payouts, desc: "提现接口" do
        desc '申请提现'
        params do
          requires :token, type: String,     desc: "用户Token"
          requires :money, type: BigDecimal, desc: '提现金额，单位为元'
          requires :card_no, type: String,   desc: "提现账号"
          requires :card_name, type: String, desc: "账号姓名"
        end
        post do
          user = authenticate!
          
          pay_limit = 100.0
          if user.balance < pay_limit # 最少要有100的余额才能提现
            return render_error(7001, "余额至少为#{pay_limit}元才能提现")
          end
          
          if params[:money].to_f > user.balance
            return render_error(7001, "余额不足，最多只能提现#{user.balance}元")
          end
          
          # 创建一条提现申请
          Payout.create!(card_name: params[:card_name], card_no: params[:card_no], money: params[:money], user_id: user.id)
          
          render_json_no_data
        end # end post payout
      end # end resource
      
      resource :pay_histories, desc: '交易明细' do
        desc '获取交易明细'
        params do
          requires :token, type: String,  desc: "用户Token"
          use :pagination
        end
        get do
          user = authenticate!
          
          @histories = PayHistory.where(user_id: user.id).order('id desc')
          if params[:page]
            @histories = @histories.paginate page: params[:page], per_page: page_size
          end
          
          render_json(@histories, API::V1::Entities::PayHistory)
        end # end get
      end # end resource
      
    end
  end
end