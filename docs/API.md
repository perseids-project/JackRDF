# JackRDF

Remember to require...

	require 'JackRDF'

Create a new object by passing a SPARQL endpoint url.

	rdf = JackRDF.new( 'http://localhost:4321/ds' )

Create RDF graph from a JSON-LD file.

	rdf.post( 'http://localhost/sample/test', '/var/www/JackRDF/sample/post.json' )

Update RDF graph.

	rdf.put( 'http://localhost/sample/test', '/var/www/JackRDF/sample/put.json' )

Delete triples defined in JSON-LD from RDF graph.

	rdf.delete( 'http://localhost/sample/test', '/var/www/JackRDF/sample/put.json' )