require 'rubygems'
require 'json/ld'
require 'sparql/client'

class JackSON_RDF
  
  def initialize( endp )
    @endp = endp
    @update = SPARQL::Client.new( File.join( @endp, 'update' ) )
    @query = SPARQL::Client.new( File.join( @endp, 'query' ) )
  end
  
  def post( url, file )
    hash = to_hash( File.read( file ) )
    
    # Is this a certain way of esuring JSON is JSON-LD?
    if hash.has_key?('@context') == false
      throw "#{file} is not JSON-LD"
    end
    
    # The url to the JSON file becomes 
    # the JSON-LD id which becomes the
    # RDF subject
    hash['@id'] = url
    
    # Convert to JSON-LD then to RDF
    jsonld = to_jsonld( hash )
    rdf = to_rdf( jsonld )
    
    # Does this already exist?
    
    # Insert the RDF data
    @update.insert_data( rdf )
  end
  
  def put
  end
  
  def delete( url )
    RDF::URI( url )
  end
  
  private
  
  def to_hash( json )
    JSON.parse( json )
  end
  
  def to_jsonld( hash )
    JSON::LD::API.expand( hash )
  end
  
  def to_rdf( jsonld )
    RDF::Graph.new << JSON::LD::API.toRdf( jsonld )
  end
  
end