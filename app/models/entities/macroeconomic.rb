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
# Table name: macroeconomics
#    t.integer  "user_id"
#    t.string   "country",     :limit => 30, :default => "china",  :null => false
#    t.string   "year",        :limit => 4
#    t.integer  "assigned_to"
#    t.string   "access",      :limit => 8,  :default => "Public"
#    t.string   "audit_flag",  :limit => 25
#    t.datetime "created_at",  :null => false
#    t.datetime "updated_at",  :null => false
#

class Macroeconomic < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :assignee, :class_name => "User"  #, :foreign_key => :assigned_to
  has_many    :emails, :as => :mediator

  scope :state, lambda { |filters|
    where('country IN (?)' + (filters.delete('other') ? ' OR country IS NULL' : ''), filters)
  }
  scope :created_by, lambda { |user| where('user_id = ?' , user.id) }

  uses_user_permissions
  acts_as_commentable
  acts_as_taggable_on :tags
  has_paper_trail
  has_fields
  exportable
  sortable :by => [ "country ASC", "year DESC", "created_at DESC", "updated_at DESC" ], :default => "created_at DESC"

#  validates_presence_of :name, :message => :missing_macroeconomic_name
#  validates_uniqueness_of :name, :scope => [ :user_id, :deleted_at ]
#  validate :start_and_end_dates
#  validate :users_for_shared_access

  # Default values provided through class methods.
  #----------------------------------------------------------------------------
  def self.per_page ; 20     ; end
  def self.outline  ; "long" ; end

  # Attach given attachment to the macroeconomic if it hasn't been attached already.
  #----------------------------------------------------------------------------
  def attach!(attachment)
    unless self.send("#{attachment.class.name.downcase}_ids").include?(attachment.id)
      if attachment.is_a?(Task)
        self.send(attachment.class.name.tableize) << attachment
      else # Leads, Opportunities
        attachment.update_attribute(:macroeconomic, self)
        attachment.send("increment_#{attachment.class.name.tableize}_count")
        [ attachment ]
      end
    end
  end

  # Discard given attachment from the macroeconomic.
  #----------------------------------------------------------------------------
  def discard!(attachment)
    if attachment.is_a?(Task)
      attachment.update_attribute(:asset, nil)
    else # Leads, Opportunities
      attachment.send("decrement_#{attachment.class.name.tableize}_count")
      attachment.update_attribute(:macroeconomic, nil)
    end
  end

# 导入测试
#  attr_accessor  :field_group_list
#
#  def field_group_name_string
#    self.field_groups ? self.field_groups.map{|group| group.label}.join(", ") : ""
#  end
#
#  def field_group_name_string=(val)
#    if val
#      @field_group_list = val.split(",").map {|label| field_group = FieldGroup.find_by_label(label.strip); field_group && field_group.id.to_s}.compact.uniq
#    end
#  end
#
#  before_save do
#    if field_group_list.present?
#      return self.field_groups = field_group_list.map { |id| field_group = FieldGroup.find_by_id(id.strip) }.compact.uniq
#    else
#      self.field_groups = []
#    end
#  end
#  def self.get_field_array
#    # every element consist of "name", "label", "name" is column name, "label" is display name
#    field_array = [["country","country"], ["year","year"], ["field_group_name_string","types"]]
#    FieldGroup.all.each do |group|
#      if group.fields && group.fields.present?
#        group.fields.each do |field|
#          field_array << [field.name, field.label]
#        end
#      end
#    end
#    field_array
#  end



  private

  # Make sure at least one user has been selected if the macroeconomic is being shared.
  #----------------------------------------------------------------------------
  def users_for_shared_access
    errors.add(:access, :share_macroeconomic) if self[:access] == "Shared" && !self.permissions.any?
  end

end

