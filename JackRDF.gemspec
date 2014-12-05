lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'sparql_model/version'

Gem::Specification.new do |s|
  s.name        = 'JackRDF'
  s.version     = '1.0.1'
  s.date        = '2014-09-10'
  s.summary     = "Convert JSON-LD to Fuseki served RDF"
  s.description = "JackSON extension for 'on-the-fly' conversion of JSON-LD to Fuseki served RDF."
  s.authors     = [ "Adam Tavares" ]
  s.email       = 'adamtavares@gmail.com'

  s.homepage    = 'http://github.com/caesarfeta/jackrdf'
  s.license       = 'MIT'

  s.files         = `git ls-files -z`.split("\x0")
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_dependency "json-ld"
  s.add_dependency "sparql-client"
end
