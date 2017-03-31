module API
  module V1
    class ApartmentsAPI < Grape::API
      
      helpers API::SharedParams
      
      resource :rent, desc: '租房接口' do
        desc "获取租房信息"
        params do 
          optional :loc, type: String, desc: "位置坐标，经纬度，值格式为：经度,纬度，例如：104.333122,30.893321"
          optional :sr,  type: String, desc: "指定图片的大小，值为：large, thumb, small中的一个，如果不传该参数默认为large"
          use :pagination
        end
        get :list do
          @apartments = Apartment.sorted.recent
          if params[:loc]
            lng,lat = loc.split(',')
            @apartments = @apartments.list_with_location(lng, lat)
          end
          if params[:page]
            @apartments = @apartments.paginate page: params[:page], per_page: page_size
          end
          
          sr = params[:sr] || "large"
          if not %w(large thumb small).include?(sr)
            sr = "large"
          end
          
          total = params[:page] ? @apartments.total_entries : @apartments.size
          render_json(@apartments, API::V1::Entities::Apartment, { image_size: sr }, total)
        end # end list
        
        desc "获取附近一定数量的租房信息"
        params do 
          requires :loc,   type: String,  desc: "位置坐标，经纬度，值格式为：经度,纬度，例如：104.333122,30.893321"
          optional :total, type: Integer, desc: "数量，如果不传该值，默认为30"
          optional :sr,  type: String, desc: "指定图片的大小，值为：large, thumb, small中的一个，如果不传该参数默认为large"
          use :pagination
        end
        get :nearby do
          lng,lat = params[:loc].split(',')
          size = ( params[:total] || 30 ).to_i
          sr = params[:sr] || "large"
          if not %w(large thumb small).include?(sr)
            sr = "large"
          end
          @apartments = Apartment.nearby(lng,lat,size)
          if params[:page]
            @apartments = @apartments.paginate page: params[:page], per_page: page_size
          end
          
          total = params[:page] ? @apartments.total_entries : @apartments.size
          
          render_json(@apartments, API::V1::Entities::Apartment, { image_size: sr }, total)
        end # end get nearby
        
      end # end resource
      
    end
  end
end