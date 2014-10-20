# JackRDF
[JackSON](https://github.com/caesarfeta/JackSON) extension for 'on-the-fly' conversion of JSON-LD to Fuseki served RDF.

The conversion is done with [ruby-rdf/json-ld](https://github.com/ruby-rdf/json-ld/) a "fully conforming JSON-LD API processor". 

Read the [W3C draft](http://json-ld.org/spec/latest/json-ld-rdf/) for creating "JSON-LD API extensions for transforming to RDF".

[Building Linked-Data Apps with JackSON](https://github.com/caesarfeta/JackSON/blob/master/APP.md)

## Install the JackRDF gem
	rake build

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
You typically want to allow outsiders to query your Fuseki instance.
You may not want them to update it however.

The easiest way I know to secure Fuseki's update features is to use an Apache proxy combined with iptables.

This goes in your Apache config; usually that is **/etc/apache2/httpd.conf**

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

Then use iptables to drop all packets sent to :4321 from anywhere but localhost.

	sudo iptables -A INPUT -p tcp -s localhost --dport 4321 -j ACCEPT
	sudo iptables -A INPUT -p tcp --dport 4321 -j DROP

To undo this...

	sudo iptables -D INPUT -p tcp -s localhost --dport 4321 -j ACCEPT
	sudo iptables -D INPUT -p tcp --dport 4321 -j DROP

If you're using OSX you don't have **iptables**.  You can use **pfctl**.
Haven't used it myself but [here's a tutorial.](http://blog.scottlowe.org/2013/05/15/using-pf-on-os-x-mountain-lion/)

If all goes well... 

* Access to http://localhost:4321 should be forbidden.
* http://localhost/fuseki/ds/query should be accessible to the world.
* http://localhost/fuseki/ds/update should be forbidden everywhere but from the localhost.
	* This is needed for the JackRDF gem and JackSON to do their thing.

Remember to update your application configs to point to the new URL.

## Development

* [See all of your triples](http://localhost:4321/ds/query?query=select+%3Fs+%3Fp+%3Fo%0D%0Awhere+%7B+%3Fs+%3Fp+%3Fo+%7D&output=text&stylesheet=)

## API
[See API.md](API.md)

## JSON-LD details
Writing RDF compatible JSON-LD requires understanding both formats.
That requires some homework.

Currently JSON-LD does not support arrays of arrays ( aka list of lists ).
See the [json-ld-rdf spec](http://json-ld.org/spec/latest/json-ld-rdf/) section 3.1.1 Methods:toRDF.