	load 'JackRDF.rb'
	rdf = JackRDF.new( 'http://localhost:4321/ds' )
	
	rdf.post( 'http://localhost:4567/test/urn/1', '/var/www/JackRDF/sample/urn.json' )
	rdf.delete( 'http://localhost:4567/test/urn/1', '/var/www/JackRDF/sample/urn.json' )
	rake data:destroy
	
	rdf.post( 'http://localhost:4567/test/urn/1', '/var/www/JackRDF/sample/urn.json' )
	rdf.post( 'http://localhost:4567/test/urn/2', '/var/www/JackRDF/sample/urn_too.json' )
	rdf.delete( 'http://localhost:4567/test/urn/2', '/var/www/JackRDF/sample/urn_too.json' )
	Make sure contents of urn_too still there.
	rake data:destroy
	
	rdf.post( 'http://localhost:4567/test/urn/1', '/var/www/JackRDF/sample/urn.json' )
	rdf.post( 'http://localhost:4567/test/urn/2', '/var/www/JackRDF/sample/urn_too.json' )
	rdf.delete( 'http://localhost:4567/test/urn/3', '/var/www/JackRDF/sample/urn_too.json' )
	Make sure this throws an error.
	rake data:destroy
	
	rdf.post( 'http://localhost:4567/test/urn/1', '/var/www/JackRDF/sample/urn.json' )
	rdf.post( 'http://localhost:4567/test/urn/2', '/var/www/JackRDF/sample/urn_too.json' )
	rdf.delete( 'http://localhost:4567/test/urn/1', '/var/www/JackRDF/sample/urn_too.json' )
	Make sure this throws an error.
	rake data:destroy

