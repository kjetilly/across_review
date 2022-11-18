#!/bin/bash

# First we start dask
dask-scheduler --scheduler-file ${DASK_FILE} &

# Then the Bokeh server
bokeh serve main.py --args -s ${DASK_FILE} &

# Then we can start ERT
ert "$@"
