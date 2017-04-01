ActiveAdmin.register Merchant do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :name, :address, :mobile
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

form html: { multipart: true } do |f|
  f.semantic_errors
  f.inputs do
    f.input :name
    f.input :address
    f.input :mobile
  end
  actions
end


end
