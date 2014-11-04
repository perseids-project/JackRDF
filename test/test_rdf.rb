require 'minitest/autorun'
require 'benchmark'
require 'rest_client'
require 'JackRDF'
require 'rest_client'
require 'sparql_model'

class TestRdf < Minitest::Test
  
  # Make sure post method uses URL if no @id value is present
  def test_AAA_post
    Fuseki.empty
    rdf = Fuseki.handle
    rdf.post( 'http://localhost:4567/test/urn/1', 'sample/post.json' )
    check = Fuseki.get
    check.each do |tri|
      if tri["s"]["value"] != 'http://localhost:4567/test/urn/1'
        assert( false )
        return
      end
    end
    assert( true )
  end
  
  # Make sure triples are deleted entirely
  def test_AAB_delete
    Fuseki.empty
    rdf = Fuseki.handle
    rdf.post( 'http://localhost:4567/test/urn/1', 'sample/post.json' )
    rdf.delete( 'http://localhost:4567/test/urn/1', 'sample/post.json' )
    check = Fuseki.get
    assert( check.length, 0 )
  end
  
  # Make sure double posts are blocked
  def test_AAC_double_post_block
    Fuseki.empty
    rdf = Fuseki.handle
    rdf.post( 'http://localhost:4567/test/urn/1', 'sample/post.json' )
    begin
      rdf.post( 'http://localhost:4567/test/urn/1', 'sample/post.json' )
    rescue
      assert( true )
      return
    end
    assert( false )
  end
  
  # Make sure CITE URNs are used as subject nodes when id_mode conditions are met
  def test_AAD_cite_urn_subject
    Fuseki.empty
    rdf = Fuseki.handle
    rdf.post( 'http://localhost:4567/test/urn/1', 'sample/id.json' )
    url = Fuseki.get
    file = rdf.file_to_hash( 'sample/id.json' )
    url.each do |tri|
      if tri["s"]["value"] != file['@id']
        assert( false )
        return
      end
    end
    assert( true )
  end
  
end

class Fuseki
  def self.handle
    JackRDF.new( self.ds )
  end
  
  def self.ds
    "http://localhost:4321/ds"
  end
  
  def self.select
    "select+%3Fs+%3Fp+%3Fo%0D%0Awhere+%7B+%3Fs+%3Fp+%3Fo+%7D"
  end
  
  def self.url
    "#{self.ds}/query?query=#{self.select}&output=json"
  end
  
  def self.get
    json = JSON.parse( RestClient.get( self.url ) )
    json["results"]["bindings"]
  end
  
  def self.empty
    quick = SparqlQuick.new( self.ds )
    quick.empty( :all )
  end
end