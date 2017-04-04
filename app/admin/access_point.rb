ActiveAdmin.register AccessPoint do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#

menu parent: 'deyi'

permit_params :ssid, :gw_mac, :gw_id, :gw_address, :gw_port, :merchant_id

# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

form do |f|
  f.inputs do
    f.input :merchant_id, as: :select, collection: Merchant.all.map { |m| [m.name, m.merch_id] }, prompt: '-- 选择热点场所 --'
    f.input :ssid
    f.input :gw_mac
    # f.input :gw_address
    # f.input :gw_port
  end
  actions
end


end
