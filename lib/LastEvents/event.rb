require 'nokogiri'
require 'rdf/n3'
module LastEvents
  class Event
    def initialize(event)
      #puts event.to_s.encoding.name
      #puts event.to_s
      @xml_event = Nokogiri::XML(event.to_s, nil, 'UTF-8')
      #puts @xml_event.encoding
    end
    
    def create_vocabulary
      @LFM    = RDF::Vocabulary.new("http://www.last.fm/event/")
      @EVENT  = RDF::Vocabulary.new("http://purl.org/NET/c4dm/event.owl#")
      @MO     = RDF::Vocabulary.new("http://purl.org/ontology/mo/")
      @TL     = RDF::Vocabulary.new("http://purl.org/NET/c4dm/timeline.owl#")
      @GN     = RDF::Vocabulary.new('http://www.geonames.org/ontology#')
      @GEO    = RDF::Vocabulary.new('http://www.w3.org/2003/01/geo/wgs84_pos#')
    end
    
    def parse #unicode problem is somewhere here
      artists = Array.new
      @xml_event.xpath('//artists/artist/text()').each do |artist|
        artists << artist.to_s
      end
      tags = Array.new
      @xml_event.xpath('//tags/tag/text()').each do |tag|
        tags << tag.to_s
      end
      @parsed_event = {
        :id => @xml_event.xpath('/event/id/text()').to_s,
        :title => @xml_event.xpath('//title/text()').to_s,
        :description => @xml_event.xpath('//description/text()').to_s,
        :artists => artists,
        :headliner => @xml_event.xpath('//headliner/text()').to_s,
        :startDate => @xml_event.xpath('//startDate/text()').to_s,
        :place => {
          :name => @xml_event.xpath('//venue/name/text()').to_s,
          :website => @xml_event.xpath('//venue/website/text()').to_s,
          :geo => {
            :lat => @xml_event.xpath('//venue/location/point/lat/text()').to_s, 
            :long => @xml_event.xpath('//venue/location/point/long/text()').to_s},
          #:city=>'',
          #:country=>'',
          #:street=>'',
          #:postalcode=>'',
        },
        :tags => tags
      }
      return @parsed_event
    end
    
    def to_statements
      self.parse
      self.create_vocabulary
      if @parsed_event.nil? 
        puts 'nil event'
      end

      @statements = Array.new

      #event
      @statements << {
        :subject   => @LFM[@parsed_event[:id]],
        :predicate => RDF['type'],
        :object    => @EVENT['Event']
      }

      #event.title
      @statements << {
        :subject    => @LFM[@parsed_event[:id]],
        :predicate  => RDF::DC['title'],
        :object     => @parsed_event[:title],
      }
      
      #event.description
      #@statements << {
      #  :subject    => @LFM[@parsed_event[:id]],
      #  :predicate  => RDF::DC['description'],
      #  :object     => @parsed_event[:description],
      #}

      #event.agent     
      @parsed_event[:artists].each do |artist|
        agent = RDF::Node.new #bnode
        @statements << {
          :subject   => @LFM[@parsed_event[:id]],
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

      @statements << {
        :subject   => @LFM[@parsed_event[:id]],
        :predicate => @MO['headliner'],
        :object    => @parsed_event[:headliner],
      }

      #event.factor
      #headliner = RDF::Node.new
      #@statements << {
      #  :subject   => @LFM[@parsed_event[:id]],
      #  :predicate => @EVENT['factor'],
      #  :object    => headliner,
      #}
      #@statements << {
      #  :subject   => headliner,
      #  :predicate => RDF['type'],
      #  :object    => @MO['headliner'],
      #}
      #@statements << {
      #  :subject   => headliner,
      #  :predicate => RDF::FOAF['name'],
      #  :object    => @parsed_event[:headliner],
      #}
      
      #event.product
      @parsed_event[:tags].each do |tag|
        product= RDF::Node.new
        @statements << {
          :subject   => @LFM[@parsed_event[:id]],
          :predicate => @EVENT['factor'],
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
      date = @parsed_event[:startDate].to_s
      ar = date.split
      parsed_date = Date.parse("#{ar[3]}-#{ar[2]}-#{ar[1]}").to_s + "T#{ar[4]}" #to_f
      xsd_date = RDF::Literal.new(parsed_date, :datatype => RDF::XSD.dateTime)
      @statements << {
        :subject   => @LFM[@parsed_event[:id]],
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
        :object    => xsd_date
      }
      
      #event.place
      place = RDF::Node.new
      @statements << {
        :subject    => @LFM[@parsed_event[:id]],
        :predicate  => @EVENT['place'],
        :object     => place
      }
      @statements << {
        :subject    => place,
        :predicate  => RDF['resource'],
        :object     => @parsed_event[:place][:website]  #TODO check if exist
      }
      @statements << {
        :subject    => place,
        :predicate  => @GN['name'],
        :object     => @parsed_event[:place][:name]
      }
      @statements << {
        :subject    => place,
        :predicate  => @GEO['lat'],
        :object     => @parsed_event[:place][:geo][:lat]
      }
      @statements << {
        :subject    => place,
        :predicate  => @GEO['long'],
        :object     => @parsed_event[:place][:geo][:long]
      }
      return @statements    
    end
    
    if __FILE__ == $0
      file = File.read("../../data/xml/Prague-2011-11-25.xml")
      xml = Nokogiri.XML(file, nil, 'utf-8')
      xml.xpath('//event').each do |xml_event|
        #print xml_event #encoding ok
        event = LastEvents::Event.new(xml_event)
        st = event.to_statements
        st.each do |s|
           puts s[:object]
        end
      end
    end
    
  end
end