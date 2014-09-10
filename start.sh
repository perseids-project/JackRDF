#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
function fuseki() {
	cd $DIR
	cd fuseki
	mkdir -p $JACKSON_RDF
	./fuseki-server --update --loc=$JACKSON_RDF --port=$JACKSON_PORT /$JACKSON_DATA &
	echo $! > $DIR/fuseki.pid
}
source $DIR/fuseki.config
fuseki
