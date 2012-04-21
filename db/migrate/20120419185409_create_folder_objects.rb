class CreateFolderObjects < ActiveRecord::Migration
  def change
    create_table :folder_objects do |t|
      t.references :folder
      t.references :solr_index
      t.integer    :asset_id
      t.string     :asset_type
      t.datetime   :deleted_at

      t.timestamps
    end
  end
end
