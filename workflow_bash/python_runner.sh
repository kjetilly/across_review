#!/bin/bash

# HQ does not seem to work well with venv for now?

VIRTUALENV_PATH=$1
CMD_ARGS="${@:2}"

. ${VIRTUALENV_PATH}/bin/activate
export PYTHONPATH=$PYTHONPATH:${DAMARIS_PYTHON_DIR}

$CMD_ARGS