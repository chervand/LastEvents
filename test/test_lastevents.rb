require_relative '../lib/LastEvents'
require_relative '../lib/LastEvents/files'
require_relative '../lib/LastEvents/lastfm'
require_relative '../lib/LastEvents/xml'
require_relative '../lib/LastEvents/event'
require_relative '../lib/LastEvents/graph'
require_relative '../lib/LastEvents/queries'

require 'test/unit'
require 'nokogiri'
require 'rdf/n3'

module LastEvents
  # Implements unit tests
  class TestLastEvents < Test::Unit::TestCase
    
    # Tests RDF.rb & Nokogiri for work
    def test_gems
      assert(Nokogiri::XML("<root><aliens><alien><name>Alf</name></alien></aliens></root>"))
      assert(RDF::Graph.new)
    end
    
    def test_classes
      #assert(LastEvents::Runner.new)
      assert(LastEvents::Files.new)
      assert(LastEvents::LastFM.new)
      assert(LastEvents::XML.new)
      assert(LastEvents::Event.new("<event></event>"))
      assert(LastEvents::Graph.new("<event></event>"))
      assert(LastEvents::Queries.new("New York-2012-1-16"))
    end
    
    def test_files
      files = LastEvents::Files.new
      assert(files.get_project_path)
      assert(files.get_rdf_data_path("New York-2012-1-16"))
      assert(files.rdf_exists("New York-2012-1-16"))
      assert(files.xml_exists("New York-2012-1-16"))
    end
    
    def test_lastfm
      assert(LastEvents::LastFM.new.geoGetEvents("Prague"))
    end
    
    def test_queries
      titles = []
      titles << "A Tribute to  Stevie Wonder"
      titles << "Deep Space : Jan 16 : Francois K : Juan Aktins : Cielo"
      titles << "Experiments in Opera"
      titles << "Herman Dune"
      titles << "Phantom Family Halo"
      titles << "Santigold"
      titles << "So is the Tongue Record Release/ Precious Metal Mondays"
      titles << "The Good Natured"
      assert_equal(titles, LastEvents::Queries.new("New York-2012-1-16").get_titles)
    end
    
  end
end