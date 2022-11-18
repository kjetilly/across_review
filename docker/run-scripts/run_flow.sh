#!/bin/bash

#NOTE: This is NOT to be run from within ERT, this is simply a convenience
#      script for running flow with insitu visualization outside of ert

# First we start dask
location=$(pwd)
dask-scheduler --scheduler-file ${DASK_FILE} &> dask_log.txt &

# Then the Bokeh server
cd /damaris-scripts/
bokeh serve main.py --args -s ${DASK_FILE} &> $location/bokeh_log.txt &
cd -
sleep 5s
# Then we can start flow
export PYTHONPATH=$PYTHONPATH:/opt/src/damaris_python
mpirun -np 2 flow "$@"