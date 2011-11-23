require 'rdf/n3'

require_relative 'xml'

module LastEvents
  class LE_RDF
    attr_reader :statements
    def initialize
      #TODO check if all ontologies are needed
      @prefixes = {
        :rdfs => 'http://www.w3.org/2000/01/rdf-schema#',       
        :xsd => 'http://www.w3.org/2001/XMLSchema#',
        :time => 'http://www.w3.org/2006/time#',
        :geo => 'http://www.w3.org/2003/01/geo/wgs84_pos#',
        :foaf => 'http://xmlns.com/foaf/0.1/',
        :event => 'http://purl.org/NET/c4dm/event.owl#',
        :mit => 'http://purl.org/ontology/mo/mit#',
        :tl => 'http://purl.org/NET/c4dm/timeline.owl#',
        :dc => 'http://purl.org/dc/terms/'
      }
      @statements = Array.new
      @statements << ["http://www.last.fm/event/2041307+Captain+Ahab+at+Final+Club+on+21+November+2011",'http://purl.org/NET/c4dm/event.owl#','as']
    end

    def write_graph_to_n3(graph)
      #TODO check if everything is ok
      RDF::N3::Writer.open("../../data/rdf/graph.n3", :prefixes => @prefixes) do |writer|
        writer << graph
        n3 = writer
      end
    end

    def build_graph
      graph = RDF::Graph.new
      
      statement = RDF::Statement.new({
        :subject   => RDF::URI.new("http://www.last.fm/event/2041307+Captain+Ahab+at+Final+Club+on+21+November+2011"),
        :predicate => RDF::URI.new("http://purl.org/NET/c4dm/event.owl#Factor"),
        :object    => RDF::URI.new("http://purl.org/ontology/mo/mit#Santur"),
      })


      graph.insert(statement)
      
      statement = RDF::Statement.new({
        :subject   => RDF::URI.new("http://www.last.fm/event/2041307+Captain+Ahab+at+Final+Club+on+21+November+2011"),
        :predicate => RDF.type,
        :object    => RDF::URI.new("http://purl.org/NET/c4dm/event.owl#Event"),
      })
      

      graph.insert(statement)
    end

    if __FILE__ == $0
    le = LastEvents::LE_RDF.new
    graph = le.build_graph
    le.write_graph_to_n3(graph)
    p le.statements

    #Loads Nokogiri::XML
    #rdf = LastEvents::RDFf.new.serialize(LastEvents::XML.new.xml_load_from_file("Prague-2011-11-20.xml"))
    #print rdf

    #RDF::N3::Reader.open("../../data/rdf/graph.n3") do |reader|
    #  reader.each_statement do |statement|
    #    puts statement.inspect
    #end
    end

  end
end