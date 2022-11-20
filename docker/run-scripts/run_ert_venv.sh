#!/bin/bash

. ${FLOW_VENV}/bin/activate
# First we start dask
location=$(pwd)
dask-scheduler --scheduler-file ${DASK_FILE} &> dask_log.txt &

# Then the Bokeh server
cd /damaris-scripts/
bokeh serve main.py --args -s ${DASK_FILE} &> $location/bokeh_log.txt &
cd -

deactivate

hq server --server-dir=/tmp/hq start &
sleep 5s

. ${ERT_VENV}/bin/activate
# Then we can start flow
export PYTHONPATH=$PYTHONPATH:/opt/src/damaris_python
ert "$@"
