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

module HomeHelper
  def sort_by_assets
    Version::ASSETS.map do |asset|
      %Q[{ name: "#{t(asset.singularize)}", on_select: function() { #{redraw(:asset, [ asset, t(asset.singularize).downcase ], url_for(:action => :redraw))} } }]
    end
  end

  #----------------------------------------------------------------------------
  def sort_by_events
    Version::EVENTS.map do |event|
      %Q[{ name: "#{t(event + '_past_participle')}", on_select: function() { #{redraw(:event, [ event, t(event + '_past_participle').downcase ], url_for(:action => :redraw))} } }]
    end
  end

  #----------------------------------------------------------------------------
  def sort_by_duration
    Version::DURATION.map do |duration|
      %Q[{ name: "#{t(duration)}", on_select: function() { #{redraw(:duration, [ duration, t(duration).downcase ], url_for(:action => :redraw))} } }]
    end
  end

  #----------------------------------------------------------------------------
  def sort_by_users
    users = [[ "all_users", t(:option_all_users) ]] + @all_users.map do |user|
      escaped = escape_javascript(user.full_name)
      [ escaped, escaped ]
    end

    users.map do |key, value|
      %Q[{ name: "#{value}", on_select: function() { #{redraw(:user, [ key, (value == t(:option_all_users) ? value.downcase : value) ], url_for(:action => :redraw))} } }]
    end
  end

  # Activity title for RSS/ATOM feeds.
  #----------------------------------------------------------------------------
  def activity_title(activity)
    user    = activity.user.full_name
    action  = t('action_' + activity.event)
    type    = t('subject_' + activity.item_type.downcase)
    subject = if item = activity.item
      if item.respond_to?(:full_name)
        item.full_name
      elsif item.respond_to?(:name)
        item.name
      end
    end
    t(:activity_text, :user => user, :action => action, :type => type, :subject => subject,
      :default => "#{user} #{action} #{type} #{subject}")
  end
end

