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

require "intfocus_core/gem_ext/rails/text_helper"
require "intfocus_core/gem_ext/active_record/schema_dumper"
require "intfocus_core/gem_ext/active_support/buffered_logger"
require "intfocus_core/gem_ext/active_model/serializers/xml/serializer/attribute"
require "intfocus_core/gem_ext/action_controller/base"
require "intfocus_core/gem_ext/authlogic/session/cookies"
require "intfocus_core/gem_ext/simple_form/action_view_extensions/form_helper"
require "intfocus_core/gem_ext/rake/task" if defined?(Rake)
