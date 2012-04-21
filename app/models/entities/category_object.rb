#  create_table "category_objects", :force => true do |t|
#    t.integer  "category_id"
#    t.integer  "solrindex_id"
#    t.integer  "asset_id"
#    t.string   "asset_type"
#    t.datetime "deleted_at"
#    t.datetime "created_at",   :null => false
#    t.datetime "updated_at",   :null => false
#  end
#
class CategoryObject < ActiveRecord::Base
  belongs_to :category
  has_many :solr_indices
  validates_presence_of :category_id, :solr_index_id
end
