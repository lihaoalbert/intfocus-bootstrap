class CreateFldPrivileges < ActiveRecord::Migration
  def change
    create_table :fld_privileges do |t|
      t.integer :resource_id
      t.text :data

      t.timestamps
    end
  end
end
