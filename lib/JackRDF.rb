require 'rubygems'
require 'json/ld'
require 'sparql_model'

class JackRDF
  
  # endp { String } Queryable Sparql endpoint
  def initialize( endp )
    @endp = endp
    @sparql = SparqlQuick.new( @endp )
  end
  
  # urn { String } Subject URN
  # file { String } Path to file
  def post( urn, file )
    # Does this already exist?
    if @sparql.count([ urn.tagify,:p,:o ]) > 0
      throw "#{urn} graph already exists. Use .put()"
    end
    
    hash = to_hash( File.read( file ) )
    if hash.has_key?('@context') == false
      throw "#{file} is not JSON-LD"
    end
    
    # The urn to the JSON file becomes 
    # the JSON-LD id which becomes the
    # RDF subject
    hash['@id'] = urn
    
    # Convert to JSON-LD then to RDF
    jsonld = to_jsonld( hash )
    rdf = to_rdf( jsonld )
        
    # Insert the RDF data
    @sparql._update.insert_data( rdf )
  end
  
  # urn { String } Subject URN
  # file { String } Path to file
  def put( urn, file )
    delete( urn )
    post( urn, file )
  end
  
  # urn { String } Subject URN
  def delete( urn )
    @sparql.delete([ urn.tagify,:p,:o ])
  end
  
  private
  
  # json { JSON }
  # @return { Hash }
  def to_hash( json )
    JSON.parse( json )
  end
  
  # hash { Hash }
  # @return { JSON-LD }
  def to_jsonld( hash )
    JSON::LD::API.expand( hash )
  end
  
  # jsonld { JSON-LD }
  # @return { RDF::Graph }
  def to_rdf( jsonld )
    RDF::Graph.new << JSON::LD::API.toRdf( jsonld )
  end
  
end