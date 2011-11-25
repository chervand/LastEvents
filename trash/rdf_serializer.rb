require 'rdf'
require 'rubygems'
#require 'rdf/ntriples'
require 'rdf/raptor'
#require 'rapper'
#require 'rdf/raptor' #rdf.rubyforge.org/raptor/
#gem install rapper

module LastEvents
  class RDFSerializer
    def serialize
      #RDF::NTriples::Reader.open("../../data/rdf/foaf.nt") do |reader|
      #  reader.each_statement do |statement|
      #    puts statement.inspect
      #  end
      #end
      puts RDF::Raptor.available?
      puts RDF::Raptor::ENGINE
      #RDF::Reader.open("../../data/rdf/foaf.rdf") do |reader|
      #  reader.each_statement do |statement|
      #    puts statement.inspect
      #  end
      #end

    end
    
    if __FILE__ == $0
      #puts RDF::Raptor.available?
      LastEvents::RDFSerializer.new().serialize
    end
    
  end
end