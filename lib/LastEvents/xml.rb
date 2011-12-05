require 'nokogiri'
require_relative 'lastfm'

module LastEvents
  class XML
    
    def xml_load_from_file(file_name)
      xml = false
      path = "../../data/xml/#{file_name}"
      if File.exist? path
        xml = Nokogiri::XML(File.read(path))
      else
        xml = false
      end
      xml
    end
    
    def xml_build(event_nodes, location, total)
      #TODO check if well formated
      builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.events( "xmlns:geo" => "http://www.w3.org/2003/01/geo/wgs84_pos#", 
                    "location" => location,
                    "total" => total) {
          xml.__send__ :insert, event_nodes
        }
      end
      builder.to_xml
    end
    
    def get_events(location, date)
      i = 1
      @total = 0
      @totalPages = 0
      @location_attr = ""
      @events = ""
      @cur_date = date.to_i
      @date = date.to_i
      
      while @cur_date.to_i < @date.to_i + 1 && api = LastEvents::LastFM.new.geoGetEvents(location, 10, i)
        page = Nokogiri::XML(api)
        @totalPages =  page.xpath("//events/@totalPages").to_s
        if i == @totalPages.to_i #FIXME it's stupid
          break
        else
          page.xpath("//events/event").each do |event|
            da = event.xpath("startDate/text()").to_s.split
            @cur_date = da[1].to_i
            #FIXME fix date format (not only day)!!!!
            if @cur_date != @date
              event.remove
            end
          end
        end       
        @location_attr = page.xpath("//events/@location")
        @total = @total + page.xpath("//events/event").count       
        @events = @events + page.xpath("//events/event").to_s
        i = i + 1
      end #end of loop
      @nodes = Nokogiri::XML::DocumentFragment.parse(@events)
      if @total == 0
        @xml = nil
      else
        @doc = self.xml_build(@nodes, @location_attr, @total)
        @xml = Nokogiri::XML(@doc)
      end
      @xml
    end
    
  end
end