#!/bin/bash
. ${FLOW_VENV}/bin/activate
cd $(dirname $1)
export PYTHONPATH=$PYTHONPATH:$(dirname $(dirname $FAKE_ERT_SCRIPT))
python \
    $FAKE_ERT_SCRIPT \
    --outputdir outdirert \
    --ert-file $(realpath $(basename $1)) \
    --flowpath $(which flow_venv.sh) \
    --cpus-per-sample "${FAKE_ERT_NUM_PROCS:-2}"
