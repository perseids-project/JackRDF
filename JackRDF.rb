require 'rubygems'
require 'json/ld'
require 'sparql_model'

class JackRDF
  
  # endp { String } Queryable Sparql endpoint
  def initialize( endp )
    @endp = endp
    @sparql = SparqlQuick.new( @endp )
  end
  
  # url { String }
  # file { String }
  def post( url, file )
    # Does this already exist?
    if @sparql.count([ url.tagify,:p,:o ]) > 0
      throw "#{url} graph already exists. Use .put()"
    end
    
    hash = to_hash( File.read( file ) )
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
        
    # Insert the RDF data
    @sparql._update.insert_data( rdf )
  end
  
  # url { String }
  # file { String }
  def put( url, file )
    delete( url )
    post( url, file )
  end
  
  # url { String }
  def delete( url )
    @sparql.delete([ url.tagify,:p,:o ])
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