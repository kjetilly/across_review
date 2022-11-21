#!/bin/bash
. ${FLOW_VENV}/bin/activate
echo "running flow with $@"
export PYTHONPATH=$PYTHONPATH:/opt/src/damaris_python
mpirun -np 2 flow --enable-damaris-output=true "$@"