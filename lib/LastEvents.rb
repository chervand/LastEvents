require 'optparse'
require 'rubygems'
require 'rdf'
require 'nokogiri'

require_relative 'LastEvents/files'
require_relative 'LastEvents/lastfm'
require_relative 'LastEvents/xml'
require_relative 'LastEvents/graph'
require_relative 'LastEvents/queries'

# MI-RUB & MI-SWE Project at FIT CTU in Prague (http://fit.cvut.cz)
#
# ==Author
#
# Andrey Chervinka (mailto:chervand@fit.cvut.cz)
#
# ==Description
#
# The application requests http://last.fm API for todays events
# in defined location and converts XML response to RDF-N3
# ontology (for more information view mi-swe_chervand.pdf).
# XML and RDF files are stored at data/xml/ and data/rdf folders.
#
# ==Runing
#
# To run the application, you need to install
# Ruby interpreter (http://ruby-lang.org/),
# Ruby libraries: Nokogiri (http://nokogiri.org/)
# and RDF.rb (http://rdf.rubyforge.org/).
#
# ===Parameters
#
# * +-l+ - location name
# * +-t+ - writes out titles of events (execute query to rdf file)
#
# ====Command line run example:
#
#  LastEvents/bin$ ruby LastEvents -l "New York" -t
# or
#  LastEvents/bin$ ruby LastEvents -l Prague
module LastEvents
  # Interprets comand line user interface
  # and options parser
  class Runner
    # Runs +parse+ method
    def initialize(argv)
      @location = nil
      @titles = false
      parse(argv)
    end

    # Parses comand line parameters
    # * +--help+ or +-h+
    # * +--location+ or +-l+
    # * +--titles+ or +-t+
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

    # Interprets runner of the application
    # and writes out system messages
    def run
      if @location.nil?
        puts "Nil location"
      else
        files = LastEvents::Files.new
        # Time.new for local time, Time.new.getgm for GMT time
        time = Time.new
        file_name = "#{@location}-#{time.year}-#{time.month}-#{time.day}"
        if files.xml_exists file_name
          # puts "XML file already exists, reading from file"
          xml = Nokogiri::XML(File.read "../data/xml/#{file_name}.xml")
        else
          puts "Requesting Last.FM for events in #{@location}"
          xml = LastEvents::XML.new.get_events(@location, time.day)
        end
        if xml.nil?
          puts "Nil response"
        else
          if files.xml_exists(file_name)
            # puts "XML file already exists"
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