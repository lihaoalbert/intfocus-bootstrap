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
# Table name: account_shareholders
#    t.integer  "account_id"
#    t.integer  "shareholder_id"
#    t.datetime "deleted_at"
#    t.datetime "created_at",     :null => false
#    t.datetime "updated_at",     :null => false
#


class AccountShareholder < ActiveRecord::Base
  belongs_to :account
  belongs_to :shareholder
  validates_presence_of :account_id, :shareholder_id

  has_paper_trail
end
