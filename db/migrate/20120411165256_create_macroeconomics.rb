class CreateMacroeconomics < ActiveRecord::Migration
  def change
    create_table :macroeconomics do |t|
      t.references  :user
      t.string      :country, :null => false, :default => "china", :limit => 30
      t.string      :year, :limit => 4
      t.integer     :assigned_to
      t.string      :access, :limit => 8, :default => "Public" # %w(Private Public Shared)
      t.string      :audit_flag, :limit => 25
      t.timestamps
    end
  end
end
