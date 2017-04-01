class CreateAccessPoints < ActiveRecord::Migration
  def change
    create_table :access_points do |t|
      t.string :ssid, null: false
      t.integer :ap_id # 系统生成的ID
      t.integer :merchant_id, null: false
      t.string :gw_id  # 网关的ID
      t.string :gw_mac,     null: false # 网关的Mac地址
      t.string :gw_address, null: false # 网关的ip
      t.integer :gw_port,   null: false # 网关的端口
      t.integer :sys_uptime
      t.integer :sys_load
      t.integer :sys_memfree
      t.integer :wifidog_uptime
      t.integer :cpu_usage
      t.datetime :update_time
      t.integer :client_count, default: 0      # 连接设备数量
      t.integer :connections_count, default: 0 # 网络连接数
      t.boolean :online, default: true         # 设备当前是否在线

      t.timestamps null: false
    end
    add_index :access_points, :ap_id,  unique: true
    add_index :access_points, :gw_mac, unique: true
    add_index :access_points, :merchant_id
  end
end
