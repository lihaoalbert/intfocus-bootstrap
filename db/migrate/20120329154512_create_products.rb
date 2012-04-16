class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string      :uuid, :limit => 36
      t.references  :user
      t.references  :account
      t.integer     :assigned_to
      t.string      :name, :null => false, :limit => 64
      t.string      :access, :limit => 8, :default => "Public" # %w(Private Public Shared)
      t.string      :product_type, :limit => 30
      t.date        :startup_date
      t.date        :close_date
      t.datetime    :deleted_at
      t.string      :audit_flag, :limit => 25
      t.string      :background_info
      
      t.timestamps
    end

    add_index :products, [ :user_id, :name, :deleted_at ], :unique => true
  end

  def self.down
    drop_table :products
  end
end
