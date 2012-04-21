class CreateCategoryObjects < ActiveRecord::Migration
  def change
    create_table :category_objects do |t|
      t.references :category
      t.references :solr_index
      t.integer    :asset_id
      t.string     :asset_type
      t.datetime   :deleted_at

      t.timestamps
    end
  end
end
