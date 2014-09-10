#!/bin/bash

# Install fuseki
curl -O http://archive.apache.org/dist/jena/binaries/jena-fuseki-1.0.2-distribution.tar.gz
tar xvzf jena-fuseki-1.0.2-distribution.tar.gz
ln -s jena-fuseki-1.0.2 fuseki
chmod +x fuseki/fuseki-server fuseki/s-**

# Install required gems
gem install json-ld
gem install sparql-client