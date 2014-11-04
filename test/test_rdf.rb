require 'minitest/autorun'
require 'benchmark'
require 'rest_client'
require 'JackRDF'
require 'rest_client'
require 'sparql_model'

class TestRdf < Minitest::Test
  def test_AAA_post
    rdf = JackRDF.new( Fuseki.ds )
    rdf.post( 'http://localhost:4567/test/urn/1', 'sample/urn.json' )
    puts Fuseki.get
    Fuseki.empty
    assert( true )
  end
  
  #def test_AAB_delete
  #  rdf = JackRDF.new( 'http://localhost:4321/ds' )
  #  rdf.post( 'http://localhost:4567/test/urn/1', 'sample/urn.json' )
  #  rdf.delete( 'http://localhost:4567/test/urn/1', 'sample/urn.json' )
  #  assert( true )
  #end
  
end

class Fuseki
  def self.ds
    "http://localhost:4321/ds"
  end
  
  def self.get
    json = JSON.parse( RestClient.get( "#{self.ds}/query?query=select+%3Fs+%3Fp+%3Fo%0D%0Awhere+%7B+%3Fs+%3Fp+%3Fo+%7D&output=json" ) )
    json["results"]["bindings"]
  end
  
  def self.empty
    quick = SparqlQuick.new( self.ds )
    quick.empty( :all )
  end
end