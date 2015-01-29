require 'rubygems'
require 'json/ld'
require_relative 'sparql_quick'

class JackRDF
  
  
  # Initialize JackRDF 
  # Endpoint and ontology prefix hash are the arguments
  
  def initialize( endp, onto=nil )
    @endp = endp
    @sparql = SparqlQuick.new( @endp )
    if onto != nil 
      @urn = onto['uri_prefix']
      @src = onto['src_verb']
    else
      @urn = "http://data.perseus.org/collections/urn:"
      @src = "http://purl.org/dc/terms/source"
    end
  end
  
  
  # Return the src verb.
  # Used by the JackSON server.
  
  def src_verb
    @src
  end
  
  
  ## Preparations...
  
  def prep( url, file )
    
    # Make sure URL has a valid protocol
    
    protocol_chk( url )
    
    # Does the file actually exist?
    
    file_chk( file )
    
    # Turn JSON into a hash for checking
    
    hash = jsonld_chk( file )
    context = hash['@context']
    
    # Add src.. check for src
    
    context['src'] = @src
    hash['src'] = url
    
    # RDF subject is url to JSON-LD by default
    
    if hash.has_key?('@id') == false
      hash['@id'] = url
    end
    
    # Convert to RDF
    
    [ hash, hash_to_rdf( hash ) ]
  end
  
  
  # url { String } URL to JSON-LD
  # file { String } Local path to JSON-LD
  
  def post( url, file )
    
    # Convert to RDF
    
    hash, rdf = prep( url, file )
    
    # See if the @id and src pair already exist
    
    if @sparql.count([ hash['@id'].tagify, @src.tagify, url ]) > 0
      raise JackRDF_Critical, "Triples sourced from #{url} already exist in #{hash['urn']} graph. Use .put()"
    end
    
    # CITE URN support
    
    rdf = urn_rdf( hash, rdf )
    
    # Insert the RDF data
    
    begin
      @sparql._update.insert_data( rdf )
    rescue
      raise JackRDF_Critical, "There was an error updating fuseki"
    end
    
    # Return the RDF data
    
    return rdf
  end
  
  
  # url { String } URL to JSON file
  # file { String } Path to file
  
  def put( url, file )
    delete( url, file )
    post( url, file )
  end
  
  
  # url { String } URL to JSON file
  # file { String } Path to file
  
  def delete( url, file )
    
    # Convert to RDF
    
    hash, rdf = prep( url, file )
    
    # Make sure subject URN and source JSON match
    
    if @sparql.count([ hash['@id'].tagify, @src.tagify, url ]) != 1
      raise JackRDF_Critical, "#{hash['@id']} is not src'd by #{url}"
    end
    
    # CITE URN support
    
    rdf = urn_rdf( hash, rdf )
    
    # Delete the relevant triples
        
    rdf.each do |tri|
      @sparql._update.delete_data( @sparql.graph( tri ) )
    end
    
    begin
      @sparql.delete([ hash['@id'].tagify, @src.tagify, url ])
    rescue
      raise JackRDF_Critical, "There was an error deleting triples"
    end
    
    # All is well...
    
    return true
  end
  
  
  # We don't want to expand node ids with a 'urn' prefix
  
  def urn_rdf( hash, rdf )
    graph = RDF::Graph.new
    rdf.each do |tri|
      tri.subject = RDF::Resource.new( hash['@id'] )
      tri.object = urn_obj( tri.object )
      graph << tri
    end
    graph
  end
  
  
  # We don't want to expand object node ids with a 'urn' prefix
  
  def urn_obj( obj )
    str = obj.to_s
    if str.include?( @urn )
      return RDF::Resource.new( str.sub( @urn, 'urn:' ) )
    end
    obj
  end
  
  
  # Turn a hash into RDF
  
  def hash_to_rdf( hash )
    to_rdf( to_jsonld( hash ) )
  end
  
  
  # Turn JSON-LD file into a hash
  
  def file_to_hash( file )
    to_hash( File.read( file ) )
  end
  
  
  # Turn JSON-LD into a hash
  
  def to_hash( json )
    JSON.parse( json )
  end
  
  
  # Turn hash into JSON-LD
  
  def to_jsonld( hash )
    JSON::LD::API.expand( hash )
  end
  
  
  # Turn JSON-LD into RDF
  
  def to_rdf( jsonld )
    rdf = RDF::Graph.new << JSON::LD::API.toRdf( jsonld )
    if rdf.count == 0
      raise JackRDF_Error, "No triples could be created from JSON-LD"
    end
    rdf
  end
  
  
  # Make sure a path is a real file
  
  def file_chk( path )
    if File.exist?( path ) == false
      raise JackRDF_Critical, "#{path} is not a valid file"
    end
  end
  
  
  # Make sure file is JSON-LD
  
  def jsonld_chk( file )
    hash = file_to_hash( file )
    if hash.has_key?('@context') == false
      raise JackRDF_Error, "#{file} is not JSON-LD"
    end
    return hash
  end
  
  
  # Print RDF graph triples
  
  def tri_print( rdf )
    rdf.each do | triple |
      puts triple.inspect
    end
  end
  
  
  # Does the URL have a protocol?
  
  def protocol_chk( url )
    if URI( url ).scheme == nil
      raise JackRDF_Critical, "#{url} is missing protocol"
    end
  end
  
end

class JackRDF_Error < StandardError
end

class JackRDF_Critical < StandardError
end