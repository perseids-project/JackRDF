# How to JackRDF

Remember to load or require...

	load 'JackRDF.rb'

Create a new object.

	rdf = JackRDF.new( 'http://localhost:4321/ds' )

Create graph from a JSON-LD file.

	rdf.post( 'http://localhost/sample/manu', '/var/www/JackRDF/sample/manu.json' )

Delete graph associated with a subject URL

	rdf.delete( 'http://localhost/sample/manu' )

Update graph from

	rdf.put( 'http://localhost/sample/manu', '/var/www/JackRDF/sample/manu.json' )
