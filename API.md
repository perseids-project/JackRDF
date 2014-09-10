# How to JackRDF

Remember to load or require...

	load 'JackRDF.rb'

Create a new object.

	rdf = JackRDF.new( 'http://localhost:4321/ds' )

Create RDF from a JSON-LD file.

	rdf.post( 'http://localhost/sample/manu.json', '/var/www/JackRDF/sample/manu.json' )
