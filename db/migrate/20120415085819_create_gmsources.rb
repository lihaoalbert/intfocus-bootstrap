class CreateGmsources < ActiveRecord::Migration
  def change
    create_table :gmsources do |t|
      t.string :url
      t.string :name
      t.integer :gmsource_state

      t.timestamps
    end
  end
end
