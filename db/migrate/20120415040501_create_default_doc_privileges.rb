class CreateDefaultDocPrivileges < ActiveRecord::Migration
  def change
    create_table :default_doc_privileges do |t|
      t.integer :resource_id
      t.text :data

      t.timestamps
    end
  end
end
