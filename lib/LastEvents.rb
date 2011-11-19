require 'optparse'
require_relative 'LastEvents/files'
require_relative 'LastEvents/lastfm_api'

module LastEvents
  class Runner

    def initialize(argv)
      @location = "Prague"
      parse(argv)
    end
                     
    def parse(argv)
      OptionParser.new do |opts|
        opts.banner = "Usage:  LastEvents [options]"   
        opts.on("-l ", "--location ", String, "Location name (ex.'-l prague')") do |l|
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
      if @location.nil?
        puts "Nil location"
      else
        puts "Requesting Last.FM for events in #{@location}"
        xml =  LastEvents::LastFMAPI.new().geoGetEvents(@location)
        if xml.nil?
          puts "Nil response"    
        else
          time = Time.new
          file_name = "#{@location}-#{time.year}-#{time.month}-#{time.day}"
          LastEvents::Files.new().save_xml_data(xml, file_name)
        end
      end
    end
       
  end
end