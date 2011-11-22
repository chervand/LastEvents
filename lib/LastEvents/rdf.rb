require 'rubygems'
require 'rdf/n3'
require_relative 'xml'
require 'rdf'

module LastEvents
  class RDFf
    def serialize(xml)
      @xml = xml
      RDF::N3::Reader.open("../../data/xml/Prague-2011-11-20.xml") do |reader|
        reader.each_statement do |statement|
          puts statement.inspect
        end
      end
      
    end
    
    if __FILE__ == $0
      #Loads Nokogiri::XML
      #rdf = LastEvents::RDFf.new.serialize(LastEvents::XML.new.xml_load_from_file("Prague-2011-11-20.xml"))
      #print rdf
      
graph = RDF::Graph.new("http://rubygems.org/")     
      
statement = RDF::Statement.new({
  :subject   => RDF::URI.new("Mark"),
  :predicate => RDF::DC.creator,
  :object    => RDF::URI.new("http://ar.to/#self"),
})



graph.insert(statement)



RDF::N3::Writer.open("../../data/rdf/graph.n3") do |writer|
   writer.prefix :dc, RDF::URI('http://purl.org/dc/terms/')
   writer << graph
end

RDF::N3::Reader.open("../../data/rdf/sample_event.n3") do |reader|
   reader.each_statement do |statement|
     puts statement.inspect
   end
end
    end
  end
end