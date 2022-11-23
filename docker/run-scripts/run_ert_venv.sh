#!/bin/bash

. ${FLOW_VENV}/bin/activate
# First we start dask
location=$(pwd)
dask-scheduler --scheduler-file ${DASK_FILE} &> dask_log.txt &
sleep 5s
# i=0
for i in `seq 0 $NUMBER_OF_CPUS`
do

    dask-worker --scheduler-file ${DASK_FILE} &> dask_worker_${i}.txt &
done

# Then the Bokeh server
cd /damaris-scripts/
bokeh serve main.py --args -s ${DASK_FILE} &> $location/bokeh_log.txt &
cd -

deactivate

hq server start &
sleep 5s
hq worker start --cpus ${NUMBER_OF_CPUS} &

sleep 10s

. ${ERT_VENV}/bin/activate
# Then we can start ERT

ert "$@"
