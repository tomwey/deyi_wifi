ActiveAdmin.register Admin do
  
  # menu priority: 100, label: '管理员'
  menu parent: 'user'
  
  permit_params :email, :password, :password_confirmation, :role
  
  config.filters = false

  actions :all, except: [:show]
  
  index do
    selectable_column
    column 'ID', :id
    column :email, sortable: false
    column '角色', sortable: false do |admin|
      admin.role_name
    end
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  form do |f|
    f.inputs "管理员信息" do
      if f.object.new_record?
        f.input :email
      end
      f.input :password
      f.input :password_confirmation
      f.input :role, as: :radio, collection: Admin.roles.map { |role| [I18n.t("common.#{role}"), role] }
    end
    f.actions
  end

end
