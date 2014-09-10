require 'rubygems'
require 'json/ld'
require 'sparql/client'

class JackSON_RDF
  
  def initialize( endp )
    @endp = endp
    @sparql = SPARQL::Client.new( File.join( @endp, 'update' ) )
  end
  
  def post( url, file )
    hash = JSON.parse( File.read( file ) )
    
    # Is this a certain way of esuring JSON is JSON-LD?
    if hash.has_key('@context') == false
      throw "#{file} is not JSON-LD"
    end
    
    # Convert to RDF graph
    jsonld = JSON::LD::API.expand( hash )
    graph = RDF::Graph.new << JSON::LD::API.toRdf( jsonld )
    @sparql.insert_data( graph )
  end
  
  def put
  end
  
  def delete
  end
  
end