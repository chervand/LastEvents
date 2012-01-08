require 'optparse'
require 'rubygems'
require 'rdf'
require 'nokogiri'

require_relative 'LastEvents/files'
require_relative 'LastEvents/lastfm'
require_relative 'LastEvents/xml'
require_relative 'LastEvents/graph'
require_relative 'LastEvents/queries'

module LastEvents
  class Runner
    def initialize(argv)
      @location = nil
      @titles = false
      parse(argv)
    end

    def parse(argv)
      OptionParser.new do |opts|
        opts.banner = "Usage:  LastEvents [options]"
        opts.on("-l ", "--location ", String, "Location name (ex.'-l Prague')") do |l|
          @location = l
        end
        opts.on("-t", "--titles", "Print titles") do
          @titles = true
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
        files = LastEvents::Files.new
        time = Time.new #local time, Time.new.getgm for GMT time
        file_name = "#{@location}-#{time.year}-#{time.month}-#{time.day}"
        
        if files.xml_exists file_name
          #puts "XML file already exists, reading from file"
          xml = Nokogiri::XML(File.read "../data/xml/#{file_name}.xml")        
        else
          puts "Requesting Last.FM for events in #{@location}"
          xml = LastEvents::XML.new.get_events(@location, time.day)          
        end
        
        if xml.nil?
          puts "Nil response"
          
        else                   
          if files.xml_exists(file_name)
            #puts "XML file already exists"
          else           
            puts "Saving XML data"
            if files.save_xml_data(xml, file_name)
              puts "XML data saved to #{file_name}.xml"
            else
              puts "XML write error"
            end
          end
          
          if files.rdf_exists file_name
            #puts "RDF file already exists"
            puts "Files already exists, reading from file"
          else
            puts "Serializing RDF/N3 data"
            if LastEvents::Graph.new(xml).serialize_n3(file_name)
              puts "RDF/N3 data saved to #{file_name}.n3"
            else
              puts "RDF write error"
            end
            
          end
          
          if @titles
            query = LastEvents::Queries.new(file_name)
            if query.graph
              puts "\nTITLES"
              titles = query.get_titles
              titles.each do |t|
                puts "#{t}"
              end
            end           
          end
          
        end
      end
    end

  end
end