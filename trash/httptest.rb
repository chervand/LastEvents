require 'net/http'


#http://ws.audioscrobbler.com/2.0/?method=geo.getevents&location=madrid&api_key=b25b959554ed76058ac220b7b2e0a026
uri = URI.parse('http://ws.audioscrobbler.com/2.0/')

params = { 
  :method => 'geo.getevents', 
  :location => 'prague', 
  :api_key => 'cb8a3c9887ceb9237956aa4fe1d19b7a',
  :limit => 10,
  :page => 1
}
         
uri.query = URI.encode_www_form(params)

resp = Net::HTTP.get_response(uri)

print resp.body if resp.is_a?(Net::HTTPSuccess)
