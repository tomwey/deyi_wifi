class CreateMerchants < ActiveRecord::Migration
  def change
    create_table :merchants do |t|
      t.integer :merch_id
      t.string :name,    null: false
      t.string :address, null: false
      t.st_point :location, geographic: true
      t.string :mobile

      t.timestamps null: false
    end
    add_index :merchants, :merch_id, unique: true
    add_index :merchants, :location, using: :gist
  end
end
