# JackRDF
[JackSON](https://github.com/caesarfeta/JackSON) extension for 'on-the-fly' conversion of JSON-LD to Fuseki served RDF.

# Install
Run...

	rake install

...to install Fuseki and the required gems

# Config
Open Rakefile and change the following config items if you must.

	FUSEKI_TRIPLES = "/var/www/JackRDF/triples"
	FUSEKI_HOST = "http://localhost"
	FUSEKI_PORT = "4321"
	FUSEKI_DATASTORE = "ds"
	FUSEKI_ENDPOINT = $FUSEKI_HOST:$FUSEKI_PORT/$FUSEKI_DATASTORE

# Start
Run...

	rake start

... to start up the Fuseki test server

# API
[See API.md](API.md)