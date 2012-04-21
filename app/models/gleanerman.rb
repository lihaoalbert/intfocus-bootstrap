class Gleanerman < ActiveRecord::Base
  belongs_to(:gleanerman, :class_name => "Gmsource", :foreign_key => "source_id")
end
