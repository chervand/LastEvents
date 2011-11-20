require 'optparse'
require_relative 'LastEvents/files'
require_relative 'LastEvents/lastfm'
require_relative 'LastEvents/xml'
require_relative 'LastEvents/rdf'

module LastEvents
  class Runner

    def initialize(argv)
      @location = "Prague"
      parse(argv)
    end
                     
    def parse(argv)
      OptionParser.new do |opts|
        opts.banner = "Usage:  LastEvents [options]"   
        opts.on("-l ", "--location ", String, "Location name (ex.'-l Prague')") do |l|
          @location = l
        end 
        opts.on("-h", "--help", "Show this message") do
          puts opts
          exit
        end
        begin
          argv = ["-h"] if argv.empty?
          opts.parse!(argv)
        rescue OptionParser::ParseError => e
          STDERR.puts e.message, "\n", opts
          exit(-1)
        end
      end
    end
    
        
    def run
      #TODO Check if such file aready exists
      #TODO Handle connection error
      
      if @location.nil?
        puts "Nil location"
      else
        puts "Requesting Last.FM for events in #{@location}"
        #TODO Find in a book how to use class instances
        xml = LastEvents::XML.new.get_events(@location, Time.new.day)
        #xml = LastEvents::LastFM.new().geoGetEvents(@location)
        if xml.nil?
          puts "Nil response"    
        else
          time = Time.new #localtime, Time.new.getgm for GMT time
          file_name = "#{@location}-#{time.year}-#{time.month}-#{time.day}"
          LastEvents::Files.new.save_xml_data(xml, file_name)
          
          LastEvents::RDF.new.serialize(xml)
          
        end
      end
    end
       
  end
end