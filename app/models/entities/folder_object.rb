#  create_table "folder_objects", :force => true do |t|
#    t.integer  "folder_id"
#    t.integer  "solr_index_id"
#    t.integer  "asset_id"
#    t.string   "asset_type"
#    t.datetime "deleted_at"
#    t.datetime "created_at",   :null => false
#    t.datetime "updated_at",   :null => false
#  end

class FolderObject < ActiveRecord::Base
  belongs_to :folder
  has_many :solr_indices
  validates_presence_of :folder_id, :solr_index_id
end
