module OwncloudCalDAV
  class Client
    include Icalendar
    attr_accessor :host, :port, :url, :user, :password, :ssl

    def format=( fmt )
      @format = fmt
    end

    def format
      @format ||= Format::Debug.new
    end

    def initialize( data )
      unless data[:proxy_uri].nil?
        proxy_uri   = URI(data[:proxy_uri])
        @proxy_host = proxy_uri.host
        @proxy_port = proxy_uri.port.to_i
      end
      uri = URI(data[:uri])
      @host     = uri.host
      @port     = uri.port.to_i
      @url      = uri.path
      @user     = data[:user]
      @password = data[:password]
      @ssl      = uri.scheme == 'https'
    end

    def __create_http
      if @proxy_uri.nil?
        http = Net::HTTP.new(@host, @port)
      else
        http = Net::HTTP.new(@host, @port, @proxy_host, @proxy_port)
      end
      if @ssl
        http.use_ssl = @ssl
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      http
    end

    def find_events data
      result = ""
      events = []
      res = nil
      __create_http.start do |http|
        req = Net::HTTP::Report.new(@url, initheader = {'Content-Type'=>'application/xml', 'depth' => '1'} )
        req.basic_auth @user, @password
        req.body = OwncloudCalDAV::Request::ReportVEVENT.new(DateTime.parse(data[:start]).strftime("%Y%m%dT%H%M%S"), DateTime.parse(data[:end]).strftime("%Y%m%dT%H%M%S")).to_xml
        res = http.request(req)
      end
        errorhandling res
        result = ""
        xml = REXML::Document.new(res.body)
        REXML::XPath.each( xml, '//d:response/') do |c| 
          event = Icalendar.parse(c.elements['//cal:calendar-data'].text).first.events.first
          uid = c.elements['d:href'].text.split('/').last.split('.').first
          event.uid = uid
          events << event
        end
      return events
    end

    def find_event uuid
      res = nil
      __create_http.start {|http|
        req = Net::HTTP::Get.new("#{@url}/#{uuid}.ics")
        req.basic_auth @user, @password
        res = http.request( req )
      }  
      errorhandling res
      r = Icalendar.parse(res.body)
      unless r.empty?
        r.first.events.first 
      else
        return false
      end

      
    end

    def delete_event uuid
      res = nil
      __create_http.start {|http|
        req = Net::HTTP::Delete.new("#{@url}/#{uuid}.ics")
        req.basic_auth @user, @password
        res = http.request( req )
      }
      errorhandling res
      if res.code.to_i == 200
        return true
      else
        return false
      end
    end

    def create_event event
      c = Calendar.new
      uuid = UUID.new.generate
      raise DuplicateError if entry_with_uuid_exists?(uuid)
      c.event do |e|
        e.uid = uuid
        e.dtstart = DateTime.parse(event[:start])
        e.dtend = DateTime.parse(event[:end])
        e.categories = event[:categories]# Array
        e.duration = event[:duration]
        e.summary = event[:title]
        e.description = event[:description]
        e.status = event[:status]
      end
      cstring = c.to_ical
      res = nil
      http = Net::HTTP.new(@host, @port)
      __create_http.start { |http|
        req = Net::HTTP::Put.new("#{@url}/#{uuid}.ics")
        req['Content-Type'] = 'text/calendar'
        req.basic_auth @user, @password
        req.body = cstring
        res = http.request( req )
      }
      errorhandling res
      find_event uuid
    end

    def update_event event
      #TODO... fix me
      if delete_event event[:uid]
        create_event event
      else
        return false
      end
    end

    def add_alarm tevent, altCal="Calendar"
    
    end

    def find_todo uuid
      res = nil
      __create_http.start {|http|
        req = Net::HTTP::Get.new("#{@url}/#{uuid}.ics")
        req.basic_auth @user, @password
        res = http.request( req )
      }  
      errorhandling res
      r = Icalendar.parse(res.body)
      r.first.todos.first
    end

    def create_todo todo
      c = Calendar.new
      uuid = UUID.new.generate
      raise DuplicateError if entry_with_uuid_exists?(uuid)
      c.todo do
        uid           uuid 
        start         DateTime.parse(todo[:start])
        duration      todo[:duration]
        summary       todo[:title]
        description   todo[:description]
        klass         todo[:accessibility] #PUBLIC, PRIVATE, CONFIDENTIAL
        location      todo[:location]
        percent       todo[:percent]
        priority      todo[:priority]
        url           todo[:url]
        geo           todo[:geo_location]
        status        todo[:status]
      end
      c.todo.uid = uuid
      cstring = c.to_ical
      res = nil
      http = Net::HTTP.new(@host, @port)
      __create_http.start { |http|
        req = Net::HTTP::Put.new("#{@url}/#{uuid}.ics")
        req['Content-Type'] = 'text/calendar'
        req.basic_auth @user, @password
        req.body = cstring
        res = http.request( req )
      }
      errorhandling res
      find_todo uuid
    end

    def create_todo
      res = nil
      raise DuplicateError if entry_with_uuid_exists?(uuid)

      __create_http.start {|http|
        req = Net::HTTP::Report.new(@url, initheader = {'Content-Type'=>'application/xml'} )
        req.basic_auth @user, @password
        req.body = OwncloudCalDAV::Request::ReportVTODO.new.to_xml
        res = http.request( req )
      }
      errorhandling res 
      format.parse_todo( res.body )
    end

    private
    def entry_with_uuid_exists? uuid
      res = nil
      __create_http.start {|http|
        req = Net::HTTP::Get.new("#{@url}/#{uuid}.ics")
        req.basic_auth @user, @password
        res = http.request( req )
      }      
      if res.code.to_i == 404
        return false
      else
        return true
      end
    end

    def  errorhandling response   
      raise AuthenticationError if response.code.to_i == 401
      raise NotExistError if response.code.to_i == 410 
      raise APIError if response.code.to_i >= 500
    end
  end

  class OwncloudCalDAVError < StandardError
  end
  class AuthenticationError < OwncloudCalDAVError; end
  class DuplicateError      < OwncloudCalDAVError; end
  class APIError            < OwncloudCalDAVError; end
  class NotExistError       < OwncloudCalDAVError; end
end
