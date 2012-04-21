class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.integer     :parent_id
      t.string      :uuid, :limit => 36
      t.references  :user
      t.integer     :assigned_to
      t.string      :name, :limit => 64, :null => false, :default => ""
      t.string      :access, :limit => 8, :default => "Public" 
      t.datetime    :deleted_at

      t.timestamps
    end
  end
end
