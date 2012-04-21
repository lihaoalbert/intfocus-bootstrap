class CreateGleanermanInfos < ActiveRecord::Migration
  def change
    create_table :gleanerman_infos do |t|
      t.string :title
      t.string :linke
      t.text :message
      t.date :gm_date
      t.string :gm_source
      t.string :m_source

      t.timestamps
    end
  end
end
