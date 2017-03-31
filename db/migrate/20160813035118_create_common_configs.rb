class CreateCommonConfigs < ActiveRecord::Migration
  def change
    create_table :common_configs do |t|
      t.string :key
      t.string :value
      t.string :description

      t.timestamps null: false
    end
    add_index :common_configs, :key, unique: true
  end
end
