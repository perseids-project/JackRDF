# JackRDF
Use JackRDF to...

* easily install a Fuseki triple-store
* convert JSON-LD files to Fuseki served RDF...
	* with support for custom URNs

JackRDF works with [JackSON](https://github.com/caesarfeta/JackSON) to create a hybrid Fuseki/file-system database useful for application development and small-scale hosting.

RDF conversion is mostly done with [ruby-rdf/json-ld](https://github.com/ruby-rdf/json-ld/). 

This [W3C draft describes JSON-LD and RDF's relationship](http://json-ld.org/spec/latest/json-ld-rdf/).

## Install the JackRDF gem
	rake build
	gem build JackRDF.gemspec
	gem install JackRDF-1.0.1.gem

## Install Fuseki
	rake server:install

## Config
Open **Rakefile** and change the following config items if necessary.

	FUSEKI_TRIPLES = "/var/www/JackRDF/triples"
	FUSEKI_HOST = "http://localhost"
	FUSEKI_PORT = "4321"
	FUSEKI_DATASTORE = "ds"
	FUSEKI_ENDPOINT = "#{FUSEKI_HOST}:#{FUSEKI_PORT}/#{FUSEKI_DATASTORE}"

## Start
	rake server:start

## Securing
You typically want to allow everyone to query your Fuseki instance; 
however, you probably don't want everyone updating it.

The easiest way I know to secure Fuseki's update features is to use an Apache proxy combined with iptables.

This goes in your Apache config ( usually that is **/etc/apache2/httpd.conf** )

	LoadModule proxy_http_module /usr/lib/apache2/modules/mod_proxy_http.so
	ProxyRequests Off
	<Proxy *>
	  Order deny,allow
	  Allow from all
	</Proxy>
	
	<Location /fuseki>
		ProxyPass http://localhost:4321
		ProxyPassReverse http://localhost:4321
	</Location>
	
	<LocationMatch /fuseki/[^/]+/update>
		Order deny,allow
		Deny from all
		Allow from 127.0.0.0
	</LocationMatch>

Then set iptables to drop all packets sent to **:4321** from anywhere but localhost.

	sudo iptables -A INPUT -p tcp -s localhost --dport 4321 -j ACCEPT
	sudo iptables -A INPUT -p tcp --dport 4321 -j DROP

To undo this...

	sudo iptables -D INPUT -p tcp -s localhost --dport 4321 -j ACCEPT
	sudo iptables -D INPUT -p tcp --dport 4321 -j DROP

If you're using OSX you don't have **iptables**.  
You can use **pfctl**.
Haven't used it myself but [here's a tutorial.](http://blog.scottlowe.org/2013/05/15/using-pf-on-os-x-mountain-lion/)

If all goes well... 

* Access to **http://localhost:4321** should be forbidden.
* **http://localhost/fuseki/ds/query** should be accessible to the world.
* **http://localhost/fuseki/ds/update** should be forbidden everywhere but from localhost.
	* This is needed for JackRDF to work.

## API
[See API.md](https://github.com/caesarfeta/JackRDF/blob/master/docs/API.md)

## CITE URNs and relative IRIs
If you want to use relative IRIs which means CITE URNs like this...

	<urn:cite:perseus:author.1.1>

Make sure this line is in lib/JackRDF.rb

    @urn_verb = "http://data.perseus.org/collections/urn:"

JSON-LD that looks like this...

	{
		"@context": {
			"urn": "http://data.perseus.org/collections/urn:",
			"rdf": "http://perseus.org/rdf/",
			"redirect_to": { "@id": "rdf:redirectTo" }
		},
		"@id": "urn:cite:perseus:author.1.1",
		"redirect_to": [
			{ "@id": "urn:cite:perseus:author.1.2" },
			{ "@id": "urn:cite:perseus:author.2.4" }
		]
	}

...posted to **http://localhost:4567/test/urn/1** will produce triples like this...

	<urn:cite:perseus:author.1.1> | <http://github.com/caesarfeta/JackSON/blob/master/docs/SCHEMA.md#src> | "http://localhost:4567/test/urn/1"
	<urn:cite:perseus:author.1.1> | <http://perseus.org/rdf/redirectTo>                                   | <urn:cite:perseus:author.1.2>     
	<urn:cite:perseus:author.1.1> | <http://perseus.org/rdf/redirectTo>                                   | <urn:cite:perseus:author.2.4>     

...instead of the default...

	<http://localhost:4567/test/urn/1> | <http://perseus.org/rdf/redirectTo> | <http://data.perseus.org/collections/urn:cite:perseus:author.1.2>
	<http://localhost:4567/test/urn/1> | <http://perseus.org/rdf/redirectTo> | <http://data.perseus.org/collections/urn:cite:perseus:author.2.4>
