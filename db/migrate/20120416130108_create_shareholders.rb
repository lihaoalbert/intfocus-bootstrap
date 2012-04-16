class CreateShareholders < ActiveRecord::Migration
  def change
    create_table :shareholders do |t|
      t.string      :uuid,   :limit => 36
      t.references  :user
      t.integer     :assigned_to
      t.string      :name, :null => false, :limit => 64
      t.string      :access, :limit => 8, :default => "Public" # %w(Private Public Shared)
      t.float       :share, :null => false
      t.string      :group, :limit => 25
      t.string      :audit_flag, :limit => 25
      t.string      :background_info
      
      t.timestamps
    end

  end
end
