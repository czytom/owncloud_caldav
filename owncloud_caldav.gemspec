# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require File.expand_path('../lib/owncloud_caldav/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "owncloud_caldav"
  s.version     = OwncloudCalDAV::VERSION
  s.summary     = "Ruby Owncloud CalDAV client"
  s.description = "yet another great Ruby client for CalDAV calendar and tasks."

  s.required_ruby_version     = '>= 1.9.2'

  s.license     = 'MIT'

  s.homepage    = %q{https://github.com/agilastic/agcaldav}
  s.authors     = [%q{Krzysztof Tomczyk}]
  s.email       = [%q{czytom@gmail.com}]
  s.add_runtime_dependency 'icalendar'
  s.add_runtime_dependency 'uuid'
  s.add_runtime_dependency 'builder'
  s.add_runtime_dependency 'net-http-digest_auth'
  s.add_development_dependency "rspec"  
  s.add_development_dependency "fakeweb"
  s.description = <<-DESC
  owncloud_caldav is Ruby client for CalDAV calendar.  It is based on the agcaldav gem.
DESC
  s.post_install_message = <<-POSTINSTALL
  Changelog: https://github.com/czytom/owncloud_caldav/blob/master/CHANGELOG.rdoc
  Examples:  https://github.com/czytom/owncloud_caldav
POSTINSTALL


  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
end
