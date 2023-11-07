#!/bin/bash
. ${FLOW_VENV}/bin/activate
cd $(dirname $1)
python $FAKE_ERT_SCRIPT --outputdir outdirert --ert-file $(basename $1) --flowpath $(which flow_venv.sh)