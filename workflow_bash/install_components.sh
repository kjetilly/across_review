#!/bin/bash
set -e
if [ $# -eq 0 ]
then
    echo "No arguments supplied"
    echo "Usage:"
    echo "    bash $0 <path to install directory>"
    exit 1
fi

export CC=$(which gcc-11)
export CXX=$(which g++-11)

target_dir=$(realpath $1)
mkdir -p $target_dir
# see https://stackoverflow.com/a/246128
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
docker_dir=$(dirname $SCRIPT_DIR)/docker
ERT_VENV=${target_dir}/ert_venv
FLOW_VENV=${target_dir}/flow_venv
BUILD_FOLDER=${target_dir}/src

mkdir -p ${BUILD_FOLDER}
BUILD_TYPE=Release

python3.10 -m venv $ERT_VENV
python3.10 -m venv $FLOW_VENV

. $ERT_VENV/bin/activate 
cd ${BUILD_FOLDER}
pip install --upgrade pip wheel setuptools
#pip install cmake==3.16.8
pip install conan==1.61.0
#conan profile detect
pip install git+https://github.com/kjetilly/ert.git@hq
deactivate

. $FLOW_VENV/bin/activate
pip3 install -r ${docker_dir}/damaris-scripts/requirements.txt


mkdir -p ${target_dir}/damaris-extra
cd ${BUILD_FOLDER}
git clone https://gitlab.inria.fr/Damaris/damaris.git
cd damaris
mkdir -p build
cd build
cmake .. \
      -DENABLE_HDF5=ON \
      -DBUILD_SHARED_LIBS=ON \
    -DENABLE_PYTHON=ON \
    -DENABLE_PYTHONMOD=ON \
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -DGENERATE_MODEL=ON \
    -DCMAKE_INSTALL_PREFIX=${BUILD_FOLDER}/damaris-install \
    -DPython_FIND_VIRTUALENV=ONLY \
    -DPYTHON_MODULE_INSTALL_PATH=${BUILD_FOLDER}/damaris_python && \
make install

# Get fake_ert
cd ${BUILD_FOLDER}
git clone https://github.com/kjetilly/opm-runner.git

cp -r ${docker_dir}/opm-sources-master ${BUILD_FOLDER}/opm-sources
cd ${BUILD_FOLDER}
cd opm-sources
bash build_zoltan.sh
bash build_dune.sh
bash build_opm_component.sh opm-common
bash build_opm_component.sh opm-grid
bash build_opm_component.sh opm-models
bash build_opm_component.sh opm-simulators

cd ${BUILD_FOLDER}
mkdir -p opm-josh
cd opm-josh
bash ../opm-sources/build_zoltan.sh
bash ../opm-sources/build_dune.sh
bash ../opm-sources/build_opm_josh.sh
deactivate

cd ${BUILD_FOLDER}
wget https://github.com/It4innovations/hyperqueue/releases/download/v0.16.0/hq-v0.16.0-linux-x64.tar.gz
mkdir -p ${target_dir}/bin
cd ${target_dir}/bin
tar xvf ${BUILD_FOLDER}/hq-v0.16.0-linux-x64.tar.gz && \
rm -rf ${BUILD_FOLDER}/hq-v0.16.0-linux-x64.tar.gz && \
chmod a+rwx hq

cp ${docker_dir}/run-scripts/* ${target_dir}/bin/
mv ${target_dir}/bin/flow_venv_native.sh ${target_dir}/bin/flow_venv.sh
chmod a+x ${target_dir}/bin/*.sh
chmod a+x ${target_dir}/bin/fix_xml.py
chmod a+x ${target_dir}/bin/get_ensemble_number.py


cp -r ${docker_dir}/damaris-scripts ${target_dir}/damaris-scripts
mv ${target_dir}/damaris-scripts/damaris_native.xml ${target_dir}/damaris-scripts/damaris.xml
chmod -R a+rX ${target_dir}/damaris-scripts


echo "export DASK_FILE=${target_dir}/dask.json" > ${target_dir}/environments.sh
echo "export FLOW_VENV=$FLOW_VENV" >> ${target_dir}/environments.sh
echo "export ERT_VENV=$ERT_VENV" >> ${target_dir}/environments.sh
