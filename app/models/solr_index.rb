
#  create_table "solr_indices", :force => true do |t|
#    t.string   "uuid",       :limit => 36
#    t.integer  "user_id"
#    t.integer  "asset_id"
#    t.string   "asset_type"
#    t.string   "title"
#    t.text     "summary"
#    t.text     "body"
#    t.string   "access",     :limit => 8,  :default => "Public"
#    t.integer  "clicks"
#    t.integer  "comments"
#    t.datetime "created_at",                                     :null => false
#    t.datetime "updated_at",                                     :null => false
#  end
#

class SolrIndex < ActiveRecord::Base
  belongs_to  :user
  has_one     :folder_object, :dependent => :destroy
  has_one     :folder, :through => :folder_object
  has_many    :category_objects, :dependent => :destroy
  has_many    :categories, :through => :category_objects #, :source => :category_id
  has_many    :emails, :as => :mediator
  has_many    :tags, :class_name => "Tagging", :finder_sql => Proc.new {
    %Q{
      SELECT DISTINCT t.tag_id
      FROM taggings t, solr_indices s
      WHERE s.asset_type = t.taggable_type
         AND t.taggable_id= #{asset_id} 
         AND s.asset_id = t.taggable_id
    }
  }
  has_many    :comments, :finder_sql => Proc.new {
    %Q{
      SELECT DISTINCT t.id, t.comment
      FROM comments t, solr_indices s
      WHERE s.asset_type = t.commentable_type
         AND t.commentable_id= #{asset_id} 
         AND s.asset_id = t.commentable_id
    }
  }
  
  
  
  #acts_as_commentable
  #acts_as_taggable_on :tags
  exportable

  #添加索引
  searchable do
   integer :id, :asset_id, :user_id
   text :title, :summary, :body
    string :title_sort do
      title.downcase.gsub(/^(an?|the)\b/, '')
    end
    string :asset_type
    #integer :folder do
    #  folder.id
    #end
    #integer :categories, :multiple => true do
    #  categorys.map(&:category.id)
    #end
    integer :tags, :multiple => true do
      tags.map(&:tag_id)
    end
    text :comments do
      comments.map(&:comment)
    end

    time :created_at
    time :updated_at
 
    #integer :comments, :multiple => true do
    #  comments.map(&:comment)
    #end
  end

end
