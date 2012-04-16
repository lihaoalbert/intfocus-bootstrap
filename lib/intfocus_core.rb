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

module IntfocusCore
  class << self
    # Return either Application or Engine,
    # depending on how Intfocus Project has been loaded
    def application
      defined?(IntfocusCore::Engine) ? Engine : Application
    end

    def root
      application.root
    end
  end
end

# Load Intfocus Project as a Rails Engine, unless running as a Rails Application
unless defined?(IntfocusCore::Application)
  require 'intfocus_core/engine'
end

# Our settings.yml structure requires the Syck YAML parser
require 'intfocus_core/syck_yaml'

# Require gem dependencies, monkey patches, and vendored plugins (in lib)
require "intfocus_core/gem_dependencies"
require "intfocus_core/gem_ext"
require "intfocus_core/plugin_dependencies"

require "intfocus_core/version"
require "intfocus_core/core_ext"
require "intfocus_core/exceptions"
require "intfocus_core/errors"
require "intfocus_core/i18n"
require "intfocus_core/permissions"
require "intfocus_core/exportable"
require "intfocus_core/renderers"
require "intfocus_core/fields"
require "intfocus_core/sortable"
require "intfocus_core/tabs"
require "intfocus_core/callback"
require "intfocus_core/dropbox" if defined?(::Rake)
require "intfocus_core/plugin"
