#!/bin/bash
. ${FLOW_VENV}/bin/activate
echo "Generating SPE11C case from $@"
pyopmspe11 -i $@ -m deck -o SPE11C -r ${ACROSS_SPE11C_RESOLUTION:"240,60,5"}
INPUTCASE=$(realpath SPE11C/deck/SPE11C.DATA)
echo "running flow with $INPUTCASE"
export PYTHONPATH=$PYTHONPATH:${DAMARIS_PYTHON_DIR}

fix_xml.py $FLOW_DAMARIS_CONFIG_XML_FILE
export FLOW_DAMARIS_XML_FILE=$(realpath damaris_local.xml)
#unset FLOW_DAMARIS_XML_FILE
ensemble_number=$(get_ensemble_number.py)

# And now we can run flow 
echo mpirun -np "${FAKE_ERT_NUM_PROCS:-2}" flow \
    --threads-per-process=1 \
    --enable-damaris-output=true \
    --enable-ecl-output=false \
    --damaris-python-script=$ACROSS_PUBLISH_DATA_SCRIPT \
    --damaris-dedicated-cores=1 \
    --damaris-sim-name=flow-$ensemble_number \
    --damaris-dask-file=$DASK_FILE \
    --damaris-save-to-hdf=false \
    --damaris-shared-memeory-size-bytes=$((512*1024*1024)) \
    "$INPUTCASE"
mpirun -np "${FAKE_ERT_NUM_PROCS:-2}" flow \
    --threads-per-process=1 \
    --enable-damaris-output=true \
    --enable-ecl-output=false \
    --damaris-python-script=$ACROSS_PUBLISH_DATA_SCRIPT \
    --damaris-dedicated-cores=1 \
    --damaris-sim-name=flow-$ensemble_number \
    --damaris-dask-file=$DASK_FILE \
    --damaris-save-to-hdf=false \
    --damaris-shared-memeory-size-bytes=$((512*1024*1024)) \
    "$INPUTCASE"
