#!/bin/bash

# Install fuseki
curl -O http://mirror.symnds.com/software/Apache//jena/binaries/jena-fuseki-1.1.0-distribution.tar.gz
tar xvzf jena-fuseki-1.1.0-distribution.tar.gz
ln -s jena-fuseki-1.1.0 fuseki
chmod +x fuseki/fuseki-server fuseki/s-**

# Install required gems
gem install json-ld
gem install sparql-client