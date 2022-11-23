#!/bin/bash
. ${FLOW_VENV}/bin/activate
echo "running flow with $@"
export PYTHONPATH=$PYTHONPATH:/opt/src/damaris_python

python /run-scripts/fix_xml.py $FLOW_DAMARIS_CONFIG_XML_FILE
export FLOW_DAMARIS_CONFIG_XML_FILE=$(realpath damaris_local.xml)

# And now we can run flow 
mpirun --oversubscribe -np 2 flow --threads-per-process=1 --enable-damaris-output=true "$@"