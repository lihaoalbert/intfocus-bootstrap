class CreateGleanermen < ActiveRecord::Migration
  def change
    create_table :gleanermen do |t|
      t.integer :source_id
      t.string :gm_name
      t.string :keyword
      t.text :filters
      t.integer :state

      t.timestamps
    end
  end
end
