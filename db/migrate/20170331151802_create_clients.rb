class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :mac, null: false
      t.integer :client_id
      t.integer :wifi_length, default: 0
      t.boolean :is_auth, default: false
      t.string  :private_token
      t.timestamps null: false
    end
    add_index :clients, :mac, unique: true
    add_index :clients, :client_id, unique: true
    add_index :clients, :private_token, unique: true
  end
end
