module API
  module V1
    class BusinessAuthInfoAPI < Grape::API
      
      resource :pa_info, desc: '个人认证信息上传' do
        desc '个人认证上传'
        params do
          requires :token,   type: String,   desc: '用户Token'
          requires :name,    type: String,   desc: '姓名'
          optional :mobile,  type: String,   desc: '联系电话'
          requires :sex,     type: Integer,  desc: '性别，值为1或者2，1表示男，2表示女'
          requires :id_card, type: String, desc: '身份证号'
          requires :image,         type: Rack::Multipart::UploadedFile, desc: "身份证正面，图片二进制文件, 格式为：jpg,jpeg,gif,png"
          requires :inverse_image, type: Rack::Multipart::UploadedFile, desc: "身份证背面，图片二进制文件, 格式为：jpg,jpeg,gif,png"
        end
        post :upload do
          user = authenticate!
          
          @info = PaInfo.new(name: params[:name],
                             mobile: params[:mobile],
                             sex: params[:sex],
                             card_no: params[:id_card],
                             card_image: params[:image],
                             card_inverse_image: params[:inverse_image],
                             user_id: user.id)
           if @info.save
             render_json_no_data
           else
             render_error(-1, @info.errors.full_messages.join(','))
           end
        end # end post upload
      end # end pa_info res
      
      resource :ca_info, desc: '企业认证信息上传' do
        desc '企业认证上传'
        params do
          requires :token,        type: String,   desc: '用户Token'
          requires :comp_name,    type: String, desc: '公司名称'
          requires :comp_address, type: String, desc: '公司注册地址'
          optional :name,     type: String, desc: '联系人'
          optional :mobile,   type: String, desc: '电话'
          optional :email,    type: String, desc: '邮箱'
          requires :bl_no,    type: String, desc: '营业执照号'
          requires :bl_image, type: Rack::Multipart::UploadedFile, desc: '营业执照正本图片'
        end
        post :upload do
          user = authenticate!
          
          @info = CaInfo.new(comp_name: params[:comp_name],
                             comp_address: params[:comp_address],
                             name: params[:name],
                             mobile: params[:mobile],
                             email: params[:email],
                             business_license_no: params[:bl_no],
                             business_license_image: params[:bl_image],
                             user_id: user.id)
           if @info.save
             render_json_no_data
           else
             render_error(-1, @info.errors.full_messages.join(','))
           end
        end # end post upload
      end # end ca_info
      
    end
  end
end