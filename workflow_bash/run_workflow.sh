#!/bin/bash

if [[ -z "${FLOW_VENV}" ]]
then
    echo "FLOW_VENV not set"
    exit 1
elif [ ! -f "${FLOW_VENV}/bin/activate" ]
then
    echo "FLOW_VENV/bin/activate does not exist"
    exit 1
fi

if [[ -z "${ERT_VENV}" ]]
then
    echo "ERT_VENV not set"
    exit 1
elif [ ! -f "${ERT_VENV}/bin/activate" ]
then
    echo "ERT_VENV/bin/activate does not exist"
    exit 1
fi

if [[ -z "${DASK_FILE}" ]]
then
    echo "DASK_FILE not set"
    exit 1
fi


if [[ -z "${MACHINE_LEARNING_SCRIPT}" ]]
then
    echo "MACHINE_LEARNING_SCRIPT not set"
    exit 1
elif [ ! -f "${MACHINE_LEARNING_SCRIPT}" ]
then
    echo "MACHINE_LEARNING_SCRIPT=${MACHINE_LEARNING_SCRIPT} does not exist"
    exit 1
fi


# 0) Start the HQ server on the login node
echo "Starting the HQ server"
hq server start &> hq_server_log.txt &
sleep 30s # Make sure it is really started before we go on

# 1) Start the dask scheduler on login node
echo "Starting dask scheduler"
. ${FLOW_VENV}/bin/activate
dask-scheduler --scheduler-file ${DASK_FILE} &> dask_scheduler_log.txt &
deactivate
sleep 30s # Make sure it is really started before we go on


# 2) Submit some HQ workers to the slurm queue.
# TODO: Replace with slurm
echo "Starting HQ workers"
hq worker start --cpus 3 &> hq_worker_log.txt &
sleep 30s # Make sure it is really started before we go on


# 3) Queue the start of some dask workers through HQ ("some" is loosely defined, but say 2 for a very simple example)
echo "Queuing some dask workers"
hq submit ${PYTHON_RUNNER} ${FLOW_VENV} dask-worker --scheduler-file ${DASK_FILE}
sleep 30s # Make sure it is started before we go on


# 4) Queue the start of a machine learning Python script through HQ (this script essentially just runs an infinite loop training as long as it can)
echo "Queuing ML script"
hq submit ${PYTHON_RUNNER} ${FLOW_VENV} python ${MACHINE_LEARNING_SCRIPT} -s ${DASK_FILE}
sleep 30s # Make sure it is started before we go on


# 5) Run ert on the login node. ERT will then queue jobs through HQ.
echo "Starting ERT"
. ${ERT_VENV}/bin/activate
cd $(dirname $1)

ert ensemble_experiment $(basename $1)