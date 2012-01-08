require 'net/http'

module LastEvents
  class LastFM
    
    def initialize()
      @uri = URI.parse("http://ws.audioscrobbler.com/2.0/")
      @api_key = "cb8a3c9887ceb9237956aa4fe1d19b7a"
    end
    
    def geoGetEvents(location, limit = 10, page = 1)
      params = { 
        :method => "geo.getevents", 
        :location => location, 
        :api_key => @api_key,
        :limit => limit,
        :page => page
      }              
      @uri.query = URI.encode_www_form(params)     
      response = Net::HTTP.get_response(@uri)
      return response.body if response.is_a?(Net::HTTPSuccess) #TODO Handle connection errors
    end
    
  end
end