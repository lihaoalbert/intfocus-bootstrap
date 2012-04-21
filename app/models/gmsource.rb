class Gmsource < ActiveRecord::Base
  has_one(:gmsource, :class_name => "Gleanerman", :foreign_key => "id")
end
