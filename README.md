# JackRDF
JackSON extension for 'on-the-fly' conversion of JSON-LD to Fuseki served RDF.

# Install
Run...

	./install.sh

...to install Fuseki and the required gems

# Config
Open fuseki.config and change the configuration if you so choose.

	JACKRDF_TRIPLES="/var/www/JackRDF/triples"
	JACKRDF_HOST="http://localhost"
	JACKRDF_PORT="4321"
	JACKRDF_DS="ds"
	JACKRDF_ENDPOINT=$JACKSON_HOST:$JACKSON_PORT/$JACKSON_DS

# Start
Run...

	./start.sh

# API
[See API.md](API.md)