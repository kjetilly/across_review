#!/bin/bash

# HQ does not seem to work well with venv for now?

VIRTUALENV_PATH=$1
CMD_ARGS="${@:2}"

. ${VIRTUALENV_PATH}/bin/activate
$CMD_ARGS