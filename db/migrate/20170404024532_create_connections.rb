class CreateConnections < ActiveRecord::Migration
  def change
    create_table :connections do |t|
      t.integer :access_point_id, null: false
      t.integer :client_id,       null: false
      t.string :token
      t.string :ip
      t.integer :incoming, default: 0
      t.integer :outgoing, default: 0
      t.datetime :closed_at
      t.datetime :expired_at

      t.timestamps null: false
    end
    add_index :connections, :access_point_id
    add_index :connections, :client_id
    add_index :connections, :token, unique: true
  end
end
