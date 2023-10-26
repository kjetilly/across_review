#!/bin/bash
. ${FLOW_VENV}/bin/activate
echo "running flow with $@"
export PYTHONPATH=$PYTHONPATH:${DAMARIS_PYTHON_DIR}

fix_xml.py $FLOW_DAMARIS_CONFIG_XML_FILE
export FLOW_DAMARIS_XML_FILE=$(realpath damaris_local.xml)

# And now we can run flow 
mpirun -np 2 flow --threads-per-process=1 --enable-damaris-output=true "$@"