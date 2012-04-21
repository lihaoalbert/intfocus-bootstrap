#  create_table "categories", :force => true do |t|
#    t.integer  "parent_id"
#    t.string   "uuid",        :limit => 36
#    t.integer  "user_id"
#    t.integer  "assigned_to"
#    t.string   "name",        :limit => 64, :default => "",       :null => false
#    t.string   "access",      :limit => 8,  :default => "Public"
#    t.datetime "deleted_at"
#    t.datetime "created_at",                                      :null => false
#    t.datetime "updated_at",                                      :null => false
#  end

class Category < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :assignee, :class_name => "User", :foreign_key => :assigned_to
  has_many    :category_objects, :dependent => :destroy
  has_many    :solrindexs, :through => :category_objects, :uniq => true
  has_many    :emails, :as => :mediator
  
  scope :state, lambda { |filters|
    where('name IN (?)' + (filters.delete('other') ? ' OR name IS NULL' : ''), filters)
  }
  scope :created_by, lambda { |user| where(:user_id => user.id) }
  scope :assigned_to, lambda { |user| where(:assigned_to => user.id) }

  
end
