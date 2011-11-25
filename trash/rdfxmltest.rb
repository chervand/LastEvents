require 'rubygems'
require 'rdf/n3'
require 'rdf-xml'


RDF::N3::Reader.open("../data/rdf/sample_event.n3") do |reader|
  reader.each_statement do |statement|
    #puts statement.inspect
  end
end

rdf = RDF::Graph.load("../data/rdf/sample_event.n3")
#graph = RDF::Graph.load("http://rdf.rubyforge.org/doap.nt")

RDF::N3::Writer.open("../data/rdf/test.n3") do |writer|
   writer << rdf
end