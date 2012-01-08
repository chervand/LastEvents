require 'net/http'

module LastEvents
  # Provides tools for work with last.fm API
  #
  # More info at http://www.last.fm/api/
  class LastFM
    def initialize() #:nodoc:
      @uri = URI.parse("http://ws.audioscrobbler.com/2.0/")
      @api_key = "cb8a3c9887ceb9237956aa4fe1d19b7a"
    end

    # Sends request to the geoGetEvents method
    # and returns XML data.
    # More info at http://www.last.fm/api/show?service=270
    # ==== Parameters
    # * +location+ - location name as "Prague"
    # * +limit+ - events per page
    # * +page+ - page number
    #  LastEvents::LastFM.new.geoGetEvents("Prague", 15, 1)
    def geoGetEvents(location, limit = 10, page = 1)
      params = {
        :method => "geo.getevents",
        :location => location,
        :api_key => @api_key,
        :limit => limit,
        :page => page
      }
      #--
      # TODO Handle connection errors
      #++
      @uri.query = URI.encode_www_form(params)
      response = Net::HTTP.get_response(@uri)
      return response.body if response.is_a?(Net::HTTPSuccess)
    end
  end
end