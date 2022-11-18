#!/bin/bash

#NOTE: This is NOT to be run from within ERT, this is simply a convenience
#      script for running flow with insitu visualization outside of ert

# First we start dask
dask-scheduler --scheduler-file ${DASK_FILE} &

# Then the Bokeh server
bokeh serve main.py --args -s ${DASK_FILE} &

# Then we can start flow
flow "$@"
