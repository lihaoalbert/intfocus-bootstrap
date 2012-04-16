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
# Table name: treecodes
#    t.string   "node_class",  :limit => 20,                    :null => false
#    t.string   "node",        :limit => 15,                    :null => false
#    t.string   "parent_node", :limit => 15
#    t.string   "node_cn",     :limit => 100
#    t.string   "node_en",     :limit => 100
#    t.boolean  "use_flag",                   :default => true
#    t.string   "value1",      :limit => 25
#    t.string   "value2",      :limit => 25
#    t.string   "sort_order",  :limit => 10
#    t.string   "color",       :limit => 20
#    t.datetime "created_at",                                   :null => false
#    t.datetime "updated_at",                                   :null => false
#

class Treecode < ActiveRecord::Base
end
