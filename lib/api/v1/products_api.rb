module API
  module V1
    class ProductsAPI < Grape::API
      
      helpers API::SharedParams
      
      resource :items, desc: '益豆商城产品相关接口' do
        desc "获取所有的商品，支持分页"
        params do
          use :pagination
        end
        get :list do
          @products = Product.visible.saled.sorted.hot.recent
          if params[:page]
            @products = @products.paginate page: params[:page], per_page: page_size
          end
          render_json(@products, API::V1::Entities::Product)
        end # end get list
      end # end resource
      
    end
  end
end