# JackSON_RDF
JackSON extension for 'on-the-fly' conversion of JSON-LD to Fuseki served RDF.

# Install
Run...

	./install.sh

...to install Fuseki and the required gems

# Config
Open fuseki.config and change the configuration if you so choose.

	JACKSON_RDF="/var/www/JackSON_RDF/triples"
	JACKSON_HOST="http://localhost"
	JACKSON_PORT="4321"
	JACKSON_DS="ds"
	JACKSON_ENDPOINT=$JACKSON_HOST:$JACKSON_PORT/$JACKSON_DS

# Start
Run...

	./start.sh

# API
[See API.md](API.md)