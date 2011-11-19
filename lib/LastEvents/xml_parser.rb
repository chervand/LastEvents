#require 'xmlsimple' #xml-simple.rubyforge.org
require 'nokogiri'

module LastEvents
  class XMLParser
    def parse
      path = "../../data/xml/London-2011-11-17.xml"
      file = File.read(path)
      Nokogiri::XML(file)
    end
    
    if __FILE__ == $0
      
      xml = LastEvents::XMLParser.new().parse
      xml.xpath('//events//event').each do |x|
        puts x
      end

    end
    
  end
end