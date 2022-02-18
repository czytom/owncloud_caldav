# owncloud_caldav Ruby CalDAV library

** owncloud_caldav is a CalDAV library based on agilastic/agcaldav **

##Usage Events

First, you've to install the gem

    gem install owncloud_caldav

and require it

    require "owncloud_caldav"

Next you have to obtain the URI, username and password to a CalDAV-Server.


Now you can e.g. create a new connection:
    	
	cal = OwncloudCalDAV::Client.new(:uri => "http://localhost:5232/user/calendar", :user => "user" , :password => "")

Alternatively, the proxy parameters can be specified:

	cal = OwncloudCalDAV::Client.new(:uri => "http://localhost:5232/user/calendar",:user => "user" , :password => "password", :proxy_uri => "http://my-proxy.com:8080")


####Create an Event

    result = cal.create_event(:start => "2012-12-29 10:00", :end => "2012-12-30 12:00", :title => "12345", :description => "12345 12345")


####Find Events within time interval

    result = cal.find_events(:start => "2012-10-01 08:00", :end => "2013-01-01")

 
##Licence

MIT



##Contributors


1. Fork it.
2. Create a branch (`git checkout -b my_feature_branch`)
3. Commit your changes (`git commit -am "bugfixed abc..."`)
4. Push to the branch (`git push origin my_feature_branch`)
5. Open a [Pull Request][1]
6. Enjoy a refreshing Club Mate and wait

[1]: https://github.com/czytom/owncloud_caldav/pulls/

