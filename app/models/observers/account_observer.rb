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

class AccountObserver < ActiveRecord::Observer
  observe :account

  @@accounts = {}

  def after_create(item)
    create_solr_index(item)
  end

  def before_update(item)
    @@accounts[item.id] = Account.find(item.id).freeze
  end

  def after_update(item)
    SolrIndex.update(item.id,{
      :user_id => account.user_id,
      :asset_id => account.id,
      :asset_type => account.class.name.capitalize,
      :title => account.name,
      :summary => account.phone,
      :body => account.email.to_s + ',' + account.background_info.to_s
    })
  end

  private

  def log_activity(item, event)
    item.send(item.class.versions_association_name).create(:event => event, :whodunnit => PaperTrail.whodunnit)
  end

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

  def create_solr_index(account)
    SolrIndex.create(
      :user_id => account.user_id,
      :asset_id => account.id,
      :asset_type => account.class.name.capitalize,
      :title => account.name,
      :summary => account.phone,
      :body => account.email.to_s + ',' + account.background_info.to_s
    )
  end
  
end
