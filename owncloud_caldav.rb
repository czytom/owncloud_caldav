require 'net/https'
require 'uuid'
require 'rexml/document'
require 'rexml/xpath'
require 'time'
require 'date'
require 'active_support'
require 'icalendar'

#['client.rb', 'request.rb', 'net.rb', 'query.rb', 'filter.rb', 'event.rb', 'todo.rb', 'format.rb'].each do |f|
['client.rb', 'request.rb', 'net.rb', 'query.rb', 'filter.rb',   'format.rb'].each do |f|
    require File.join( File.dirname(__FILE__), 'owncloud_caldav', f )
end
