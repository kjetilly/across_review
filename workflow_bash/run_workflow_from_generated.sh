#!/bin/bash
set -e
if [ $# -ne 2 ]
then
    echo "Not enough arguments supplied"
    echo "Usage:"
    echo "    bash $0 <path to install directory> <path to generated case>"
    exit 1
fi

installdir=$(realpath $1)
datadir=$2

if [ ! -f ${installdir}/environments.sh ]
then
    echo "${installdir}/environments.sh does not exist"
    exit 1
fi

if [ ! -f ${datadir}/machine_learning_across.py ]
then
    echo "${datadir}/machine_learning_across.py does not exist"
    exit 1
fi


source ${installdir}/environments.sh
export PATH=$PATH:${installdir}/bin:${installdir}/src/opm-sources/opm-install/bin
export DAMARIS_PYTHON_DIR=${installdir}/src/damaris_python

export MACHINE_LEARNING_SCRIPT=${datadir}/machine_learning_across.py
export FLOW_DAMARIS_CONFIG_XML_FILE=${installdir}/damaris-scripts/damaris.xml
export ACROSS_PUBLISH_DATA_SCRIPT=${installdir}/damaris-scripts/publish_data.py
export ACROSS_DATA_DIR=$(pwd)/data
mkdir -p ${ACROSS_DATA_DIR}

# see https://stackoverflow.com/a/246128
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
export PYTHON_RUNNER="bash ${SCRIPT_DIR}/python_runner.sh"

bash ${SCRIPT_DIR}/run_workflow.sh ${datadir}/spe1.ert


