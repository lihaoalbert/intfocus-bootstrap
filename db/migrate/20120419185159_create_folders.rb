class CreateFolders < ActiveRecord::Migration
  def change
    create_table :folders do |t|
      t.integer     :parent_id
      t.string      :uuid, :limit => 36
      t.references  :user
      t.integer     :assigned_to
      t.string      :name, :limit => 64, :null => false, :default => ""
      t.string      :displayname
      t.integer     :foldertype
      t.integer     :is_single_document_class
      t.integer     :document_class_id
      t.integer     :allow_categorize
      t.integer     :allow_discussing
      t.integer     :auto_categorize
      t.integer     :auto_keywords
      t.integer     :auto_description
      t.integer     :sort_order
      t.integer     :folder_state
      t.string      :access, :limit => 8, :default => "Public" 
      t.datetime    :deleted_at

      t.timestamps
    end
  end
end
