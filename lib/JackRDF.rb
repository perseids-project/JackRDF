require 'rubygems'
require 'json/ld'
require 'sparql_model'

class JackRDF
  
  # endp { String } Queryable Sparql endpoint
  def initialize( endp )
    @endp = endp
    @sparql = SparqlQuick.new( @endp )
    @urn_verb = "http://github.com/caesarfeta/JackSON/docs/SCHEMA.md#urn"
    @src_verb = "http://github.com/caesarfeta/JackSON/docs/SCHEMA.md#src"
  end
  
  # url { String } URL to JSON
  # file { String } Path to file
  def post( url, file )
    urn = url
    
    # Does this already exist?
    if @sparql.count([ url.tagify,:p,:o ]) > 0
      throw "#{urn} graph already exists. Use .put()"
    end
    
    # Turn JSON into a hash for checking
    hash = to_hash( File.read( file ) )
    if hash.has_key?('@context') == false
      throw "#{file} is not JSON-LD"
    end
    context = hash['@context']
    
    # Add src
    context['src'] = @src_verb
    hash['src'] = url
    
    # The urn to the JSON file becomes 
    # the JSON-LD id which becomes the
    # RDF subject
    hash['@id'] = urn
    
    # Convert to JSON-LD then to RDF
    jsonld = to_jsonld( hash )
    rdf = to_rdf( jsonld )
    
    # CITE URN support
    if hash.has_key?('urn') == true 
      if context.has_key?('urn') && context['urn'] == @urn_verb
        urn_rdf = RDF::Graph.new
        rdf.each do |tri|
          tri.subject = RDF::Resource.new( hash['urn'] )
          urn_rdf << tri
        end
        rdf = urn_rdf
      end 
    end
    
    # Insert the RDF data
    @sparql._update.insert_data( rdf )
  end
  
  # url { String } URL to JSON file
  # file { String } Path to file
  def put( url, file )
    delete( urn )
    post( urn, file )
  end
  
  # url { String } URL to JSON file
  def delete( url, file )
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