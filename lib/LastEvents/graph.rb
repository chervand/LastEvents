require 'nokogiri'
require 'rdf/n3'

require_relative 'event'
require_relative 'files'

module LastEvents
  # RDF.rb graph serialization
  class Graph
    # Writes prefixes
    def initialize(xml)
      @xml_events = xml
      @prefixes = {
        :rdf    => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
        :rdfs   => 'http://www.w3.org/2000/01/rdf-schema#',
        :xsd    => 'http://www.w3.org/2001/XMLSchema#',
        :time   => 'http://www.w3.org/2006/time#',
        :gn     => 'http://www.geonames.org/ontology#',
        :geo    => 'http://www.w3.org/2003/01/geo/wgs84_pos#',
        :foaf   => 'http://xmlns.com/foaf/0.1/',
        :event  => 'http://purl.org/NET/c4dm/event.owl#', #Music Event Ontology
        :mo     => 'http://purl.org/ontology/mo/', #Music Ontology
        :mit    => 'http://purl.org/ontology/mo/mit#', #Music Instrument
        :tl     => 'http://purl.org/NET/c4dm/timeline.owl#', #Timeline
        :dc     => 'http://purl.org/dc/terms/'
      }
    end

    # Parses xml data to Array of Event class instances
    def parse_events(xml) #:nodoc:
      if xml.is_a? String
        events = Nokogiri::XML(xml)
      else
      events = xml
      end
      parsed_events = Array.new
      events.xpath("//events/event").each do |event|
        parsed_events << LastEvents::Event.new(event)
      end
      parsed_events
    end

    # Serializes xml data to RDF.rb graph
    # and writes it to RDF-N3 file
    def serialize_n3(file_name)
      file_path = LastEvents::Files.new.get_rdf_data_path(file_name) + ".n3"
      @graph = RDF::Graph.new
      @xml_events.xpath('//events/event').each do |xml_event|
      # FIXME if not to_s, ruby falls
        event = LastEvents::Event.new(xml_event.to_s)
        statements = event.to_statements
        statements.each do |stmnt|
          @graph.insert RDF::Statement.new(stmnt)
        end
      end
      RDF::N3::Writer.open(file_path, :prefixes => @prefixes) do |writer|
        writer << @graph
      end
    end
  end
end