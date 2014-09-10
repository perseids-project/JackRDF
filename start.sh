#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
function fuseki() {
	cd $DIR
	cd fuseki
	mkdir -p $JACKRDF_TRIPLES
	./fuseki-server --update --loc=$JACKRDF_TRIPLES --port=$JACKRDF_PORT /$JACKRDF_DS &
	echo $! > $DIR/fuseki.pid
}
source $DIR/fuseki.config
fuseki
