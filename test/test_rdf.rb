require 'minitest/autorun'
require 'benchmark'
require 'rest_client'
require_relative '../lib/JackRDF'
require 'rest_client'
require 'sparql_model'


# Want to run a single test?
# You probably do when developing.

# ruby test/test_rdf.rb --name test_AAA_post

class TestRdf < Minitest::Test
  
  
  # Make sure post method uses URL if no @id value is present
  
  def test_AAA_post
    Help.empty
    rdf = Help.handle
    rdf.post( 'http://localhost:4567/test/urn/1', 'sample/post.json' )
    check = Help.get
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
    Help.empty
    rdf = Help.handle
    rdf.post( 'http://localhost:4567/test/urn/1', 'sample/post.json' )
    rdf.delete( 'http://localhost:4567/test/urn/1', 'sample/post.json' )
    check = Help.get
    assert_equal( check.length, 0 )
  end
  
  
  # Make sure double posts are blocked
  
  def test_AAC_double_post_block
    Help.empty
    rdf = Help.handle
    rdf.post( 'http://localhost:4567/test/urn/1', 'sample/post.json' )
    begin
      rdf.post( 'http://localhost:4567/test/urn/1', 'sample/post.json' )
    rescue
      assert( true )
      return
    end
    assert( false )
  end
  
  
  # Make sure CITE URNs are used as subject nodes 
  # when id_mode conditions are met
  
  def test_AAD_cite_urn_subject
    Help.empty
    rdf = Help.handle
    rdf.post( 'http://localhost:4567/test/urn/1', 'sample/id.json' )
    url = Help.get
    file = rdf.file_to_hash( 'sample/id.json' )
    url.each do |tri|
      if tri["s"]["value"] != file['@id']
        assert( false )
        return
      end
    end
    assert( true )
  end
  
  
  # Make sure all sources are recorded 
  # when using CITE URNs as subject nodes
  
  def test_AAE_cite_urn_multi
    Help.empty
    rdf = Help.handle
    (1..3).each do |n|
      rdf.post( "http://localhost:4567/test/urn/#{n}", "sample/cite/urn_0#{n}.json" )
    end
    check = Help.get
    count = 0
    check.each do |tri|
      if tri["p"]["value"] == Help.src
        count += 1
      end
    end
    assert_equal( count, 3 )
  end
  
  
  # Make sure sources are being deleted properly
  # when using CITE URNs with multiple JSON sources
  
  def test_AAF_cite_urn_multi_delete
    Help.empty
    rdf = Help.handle
    (1..3).each do |n|
      rdf.post( "http://localhost:4567/test/urn/#{n}", "sample/cite/urn_0#{n}.json" )
    end
    (1..2).each do |n|
      rdf.delete( "http://localhost:4567/test/urn/#{n}", "sample/cite/urn_0#{n}.json" )
    end
    check = Help.get
    disc = 0
    src = 0
    check.each do |item|
      if item["p"]["value"].include?( "discoverer" )
        disc += 1
      end
      if item["p"]["value"].include?( "src" )
        src += 1
      end
    end
    if src == 1 && disc == 1
      assert( true )
      return
    end
    assert( false )
  end
  
  
  # JSON-LD with specified id attribute
  # does not default to filename
  
  def test_AAG_no_urn_id
    Help.empty
    rdf = Help.handle
    rdf.post( "http://localhost:4567/test/urn/1", "sample/no_urn_id.json" )
    check = Help.get
    assert_equal( check[0]["s"]["value"], "http://github.com/caesarfeta/JackRDF" )
  end
  
  
  # Make sure put method is up to snuff
  
  def test_AAH_put
    Help.empty
    rdf = Help.handle
    rdf.post( "http://localhost:4567/test/urn/1", "sample/cite/urn_02.json" )
    rdf.put( "http://localhost:4567/test/urn/1", "sample/cite/urn_03.json" )
    assert( true )
  end
  
end

class Help
  def self.src
    "http://github.com/caesarfeta/JackRDF/blob/master/docs/SCHEMA.md#src"
  end
  
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