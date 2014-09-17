# JackRDF
[JackSON](https://github.com/caesarfeta/JackSON) extension for 'on-the-fly' conversion of JSON-LD to Fuseki served RDF.

The conversion is done with [ruby-rdf/json-ld](https://github.com/ruby-rdf/json-ld/) a "fully conforming JSON-LD API processor". 

Read the [W3C draft](http://json-ld.org/spec/latest/json-ld-rdf/) for creating "JSON-LD API extensions for transforming to RDF".

## Install
Run...

	rake server:install

...to install Fuseki and the required gems

## Config
Open **Rakefile** and change the following config items if necessary.

	FUSEKI_TRIPLES = "/var/www/JackRDF/triples"
	FUSEKI_HOST = "http://localhost"
	FUSEKI_PORT = "4321"
	FUSEKI_DATASTORE = "ds"
	FUSEKI_ENDPOINT = "#{FUSEKI_HOST}:#{FUSEKI_PORT}/#{FUSEKI_DATASTORE}"

## Start
Run...

	rake server:start

... to start up the Fuseki test server

## Development

* [All triples](http://localhost:4321/ds/query?query=select+%3Fs+%3Fp+%3Fo%0D%0Awhere+%7B+%3Fs+%3Fp+%3Fo+%7D&output=text&stylesheet=)

## API
[See API.md](API.md)

## JSON-LD details
Currently JSON-LD does not support arrays of arrays ( aka list of lists ).
See the [json-ld-rdf spec](http://json-ld.org/spec/latest/json-ld-rdf/) section 3.1.1 Methods:toRDF.