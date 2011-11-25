require 'rubygems'
require 'rdf'
require 'rdf/n3'

require_relative 'files'

module LastEvents
  class Queries
    attr_reader :graph
    def initialize(file_name)
      @graph = load_graph_from_n3(file_name)
    end
    
    #TODO Move to Graph class
    def load_graph_from_n3(file_name)     
      file_path = LastEvents::Files.new.get_rdf_data_path(file_name) + ".n3"
      if File.exists?(file_path)
        graph = RDF::Graph.new
        RDF::N3::Reader.open(file_path) do |reader|
          reader.each_statement do |statement|
            graph.insert statement
          end
        end
      else
        #TODO raise 'no file' error
      end
      return nil unless graph.graph? && !graph.empty?
      graph
    end

    def get_titles
      query = RDF::Query.new do
        pattern [:subject, RDF::DC.title, :object]
      end
      titles = Array.new
      query.execute(@graph).each do |solution|
        titles << solution[:object].to_s
      end
      titles.sort!
      return nil unless !titles.empty?
      titles
    end
    
  end
end