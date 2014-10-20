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
  
  # load 'JackRDF.rb'
  # rdf = JackRDF.new( 'http://localhost:4321/ds' )
  # rdf.post( 'http://localhost:4567/test/urn/5', '/var/www/JackRDF/sample/urn.json' )
  
  # url { String } URL to JSON-LD
  # file { String } Local path to JSON-LD
  def post( url, file )
    
    # Does this already exist?
    if @sparql.count([ url.tagify,:p,:o ]) > 0
      throw "#{url} graph already exists. Use .put()"
    end
    
    # Turn JSON into a hash for checking
    hash = to_hash( File.read( file ) )
    if hash.has_key?('@context') == false
      throw "#{file} is not JSON-LD"
    end
    context = hash['@context']
    
    # CITE URN put() check
    if cite_mode( hash, context ) == true
      if @sparql.count([ hash['urn'].tagify,@src_verb.tagify,url ]) > 0
        throw "Triples sourced from #{url} already exist in #{hash['urn']} graph. Use .put()"
      end
    end
    
    # Add src
    context['src'] = @src_verb
    hash['src'] = url
    
    # RDF subject is url to JSON-LD by default
    hash['@id'] = url
    
    # Convert to JSON-LD then to RDF
    jsonld = to_jsonld( hash )
    rdf = to_rdf( jsonld )
    
    # CITE URN support
    if cite_mode( hash, context ) == true
      urn_rdf = RDF::Graph.new
      rdf.each do |tri|
        tri.subject = RDF::Resource.new( hash['urn'] )
        urn_rdf << tri
      end
      rdf = urn_rdf
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
  
  # Check for CITE URN mode markers
  # hash { Hash }
  # context { Hash }
  def cite_mode( hash, context )
    if hash.has_key?('urn') == true 
      if context.has_key?('urn') && context['urn'] == @urn_verb
        return true
      end
    end
    false
  end
  
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