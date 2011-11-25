require 'rdf/n3'

require_relative 'xml'

module LastEvents
  class LE_RDF
    def initialize
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

    def create_vocabulary
      @LFM    = RDF::Vocabulary.new("http://www.last.fm/event/")
      @EVENT  = RDF::Vocabulary.new("http://purl.org/NET/c4dm/event.owl#")
      @MO     = RDF::Vocabulary.new("http://purl.org/ontology/mo/")
      @TL     = RDF::Vocabulary.new("http://purl.org/NET/c4dm/timeline.owl#")
      @GN     = RDF::Vocabulary.new('http://www.geonames.org/ontology#')
      @GEO    = RDF::Vocabulary.new('http://www.w3.org/2003/01/geo/wgs84_pos#')
    end

    def test_event
      event = Hash.new
      event = {
        :id => '2054894',
        :title => 'Share the Welt Tour',
        :description => '',
        :artists => ['Five Finger Death Punch','All That Remains','Hatebreed','Rains'],
        :headliner => 'Five Finger Death Punch',
        :startDate => 'Wed, 23 Nov 2011 17:34:01',
        :place => {
          :name => 'Best Buy Theater',
          :website => 'http://bestbuytheater.com/',
          :geo => {:lat => '40.754428', :long => '-73.979681'},
          #:city=>'New York, NY',
          #:country=>'United States',
          #:street=>'1515 Broadway',
          #:postalcode=>'10036',
        },
        :tags => ['metalcore','metal']
      }
      event
    end

    def to_statements(event)
      @statements = Array.new

      #event
      @statements << {
        :subject   => @LFM[event[:id]],
        :predicate => RDF['type'],
        :object    => @EVENT['Event']
      }

      #event.title
      @statements << {
        :subject    => @LFM[event[:id]],
        :predicate  => RDF::DC['title'],
        :object     => event[:title],
      }
      
      #event.description
      @statements << {
        :subject    => @LFM[event[:id]],
        :predicate  => RDF::DC['description'],
        :object     => event[:description],
      }

      #event.agent     
      event[:artists].each do |artist|
        agent = RDF::Node.new #bnode
        @statements << {
          :subject   => @LFM[event[:id]],
          :predicate => @EVENT['agent'],
          :object    => agent
        }
        @statements << {
          :subject   => agent,
          :predicate => RDF['type'],
          :object    => @MO['MusicArtist'], #subclass of foaf:agent #TODO Change to Performer class???
        }
        @statements << {
          :subject   => agent,
          :predicate => RDF::FOAF['name'],
          :object    => artist,
        }
      end

      #event.factor
      headliner = RDF::Node.new
      @statements << {
        :subject   => @LFM[event[:id]],
        :predicate => @EVENT['factor'],
        :object    => headliner,
      }
      @statements << {
        :subject   => headliner,
        :predicate => @MO['headliner'],
        :object    => event[:headliner],
      }
      
      #event.product
      event[:tags].each do |tag|
        product= RDF::Node.new
        @statements << {
          :subject   => @LFM[event[:id]],
          :predicate => @EVENT['product'],
          :object    => product,
        }
        @statements << {
          :subject   => product,
          :predicate => @MO['genre'],
          :object    => tag,
        }
      end      

      #event.timeline
      timeline = RDF::Node.new
      @statements << {
        :subject   => @LFM[event[:id]],
        :predicate => @EVENT['time'], #same as OWL Time
        :object    => timeline
      }
      @statements << {
        :subject   => timeline,
        :predicate => RDF['type'],
        :object    => @TL['Instant']
      }
      @statements << {
        :subject   => timeline,
        :predicate => @TL['at'],
        :object    => event[:startDate] #TODO convert date type to OWL
      }
      
      #event.place
      place = RDF::Node.new
      @statements << {
        :subject    => @LFM[event[:id]],
        :predicate  => @EVENT['place'],
        :object     => place
      }
      @statements << {
        :subject    => place,
        :predicate  => RDF['resource'],
        :object     => event[:place][:website]  #TODO check if exist
      }
      @statements << {
        :subject    => place,
        :predicate  => @GN['name'],
        :object     => event[:place][:name]
      }
      @statements << {
        :subject    => place,
        :predicate  => @GEO['lat'],
        :object     => event[:place][:geo][:lat]
      }
      @statements << {
        :subject    => place,
        :predicate  => @GEO['long'],
        :object     => event[:place][:geo][:long]
      }      
    end

    def write_graph_to_n3(graph)
      #TODO check if everything is ok
      RDF::N3::Writer.open("../../data/rdf/graph.n3", :prefixes => @prefixes) do |writer|
        writer << graph
        n3 = writer
      end
    end

    def build_graph(statements)
      graph = RDF::Graph.new
      statements.each do |st|
        graph.insert(RDF::Statement.new(st))
      end
      graph
    end

    def serialize
      #TODO handle errors
      self.create_vocabulary
      events = to_statements(self.test_event)
      graph = self.build_graph(events)
      self.write_graph_to_n3(graph)
    end

    if __FILE__ == $0
    LastEvents::LE_RDF.new.serialize
    end

  end
end