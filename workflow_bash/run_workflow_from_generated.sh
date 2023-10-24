#!/bin/bash
set -e
if [ $# -ne 2 ]
then
    echo "Not enough arguments supplied"
    echo "Usage:"
    echo "    bash $0 <path to install directory> <path to generated case>"
    exit 1
fi

installdir=$1
datadir=$2

if [ ! -f ${installdir}/environment.sh ]
then
    echo "${installdir}/environment.sh does not exist"
    exit 1
fi

if [ ! -f ${datadir}/machine_learning_across.py ]
then
    echo "${datadir}/machine_learning_across.py does not exist"
    exit 1
fi


source ${installdir}/environment.sh

export MACHINE_LEARNING_SCRIPT=${datadir}/machine_learning_across.py

# see https://stackoverflow.com/a/246128
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

bash ${SCRIPT_DIR}/run_workflow.sh ${datadir}/spe1_local.ert


