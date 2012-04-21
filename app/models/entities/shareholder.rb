# Intfocus Project Init
# Copyright (C) 2011-2012 by Intfocus Corp.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

# == Schema Information
#
# Table name: shareholders
#    t.string   "uuid",            :limit => 36
#    t.integer  "user_id"
#    t.integer  "assigned_to"
#    t.string   "name",            :limit => 64,                       :null => false
#    t.string   "access",          :limit => 8,  :default => "Public"
#    t.float    "share",                                               :null => false
#    t.string   "group",           :limit => 25
#    t.string   "audit_flag",      :limit => 25
#    t.string   "background_info"
#    t.datetime "created_at",                                          :null => false
#    t.datetime "updated_at",                                          :null => false
#

class Shareholder < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :assignee, :class_name => "User", :foreign_key => :assigned_to
  has_many    :account_shareholders, :dependent => :destroy
  has_many    :accounts, :through => :account_shareholders, :uniq => true, :order => "accounts.id DESC"
  has_many    :emails, :as => :mediator

  scope :state, lambda { |filters|
    where('group IN (?)' + (filters.delete('other') ? ' OR group IS NULL' : ''), filters)
  }
  scope :created_by, lambda { |user| { :conditions => [ "user_id = ?", user.id ] } }
  scope :assigned_to, lambda { |user| { :conditions => ["assigned_to = ?", user.id ] } }

  scope :text_search, lambda { |query|
    query = query.gsub(/[^@\w\s\-\.'\p{L}]/u, '').strip
    # We can't always be sure that names are entered in the right order, so we must
    # split the query into all possible first/last name permutations.
    name_query = if query.include?(" ")
      query.name_permutations.map{ |first, last|
        "(upper(first_name) LIKE upper('%#{first}%') AND upper(last_name) LIKE upper('%#{last}%'))"
      }.join(" OR ")
    else
      "upper(name) LIKE upper('%#{query}%') OR upper(background_info) LIKE upper('%#{query}%')"
    end
    where("#{name_query} OR upper(email) LIKE upper(:m) OR upper(alt_email) LIKE upper(:m) OR phone LIKE :m OR mobile LIKE :m", :m => "%#{query}%")
  }

  uses_user_permissions
  acts_as_commentable
  acts_as_taggable_on :tags
  has_paper_trail
  has_fields
  exportable
  sortable :by => [ "first_name ASC",  "last_name ASC", "created_at DESC", "updated_at DESC" ], :default => "created_at DESC"

  validates_presence_of :first_name, :message => :missing_first_name
  validates_presence_of :last_name, :message => :missing_last_name if Setting.require_last_names
  validate :users_for_shared_access
  before_save :nullify_blank_group
  
    # Class methods.
  #----------------------------------------------------------------------------
  def self.create_or_select_for(model, params, users)
    if params[:id].present?
      shareholder = Shareholder.find(params[:id])
    else
      shareholder = Shareholder.new(params)
      if shareholder.access != "Lead" || model.nil?
        shareholder.save_with_permissions(users)
      else
        shareholder.save_with_model_permissions(model)
      end
    end
    account
  end
  
  private
  # Make sure at least one user has been selected if the account is being shared.
  #----------------------------------------------------------------------------
  def users_for_shared_access
    errors.add(:access, :share_shareholder) if self[:access] == "Shared" && !self.permissions.any?
  end

  def nullify_blank_group
    self.group = nil if self.group.blank?
  end

end
