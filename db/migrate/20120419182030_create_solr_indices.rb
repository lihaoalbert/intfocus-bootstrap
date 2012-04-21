class CreateSolrIndices < ActiveRecord::Migration
  def change
    create_table :solr_indices do |t|
      t.string      :uuid,   :limit => 36
      t.references  :user
      t.integer     :asset_id
      t.string      :asset_type
      t.string      :title
      t.text        :summary
      t.text        :body
      t.string      :access, :limit => 8, :default => "Public" # %w(Private Public Shared)
      t.integer     :clicks
      t.integer     :comment_cnt

      t.timestamps
    end
  end
end
