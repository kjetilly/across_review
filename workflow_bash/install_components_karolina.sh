#!/bin/bash
set -e
if [ $# -eq 0 ]
then
    echo "No arguments supplied"
    echo "Usage:"
    echo "    bash $0 <path to install directory>"
    exit 1
fi

export CC=$(which gcc)
export CXX=$(which g++)

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

python -m venv $ERT_VENV
python -m venv $FLOW_VENV

. $ERT_VENV/bin/activate 
pip install --upgrade pip
cd ${BUILD_FOLDER}
pip install --upgrade pip wheel setuptools
#pip install cmake==3.16.8
pip install conan==1.61.0
#conan profile detect
pip install git+https://github.com/kjetilly/ert.git@hq
deactivate

. $FLOW_VENV/bin/activate
pip install --upgrade pip
pip3 install -r ${docker_dir}/damaris-scripts/requirements.txt

# we need build2 for xsd which we in turn need for damaris
cd $BUILD_FOLDER/
mkdir build2
cd build2
curl -sSfO https://download.build2.org/0.16.0/build2-install-0.16.0.sh
sh build2-install-0.16.0.sh --yes ${target_dir}/build2

# We need XSD for damaris
cd ${BUILD_FOLDER}
mkdir xsd
cd xsd

bpkg create -d xsd-gcc-10 cc     \
  config.cxx=g++                  \
  config.cc.coptions=-O3          \
  config.bin.rpath=${target_dir}/xsd-install \
  config.install.root=${target_dir}/xsd-install 

cd xsd-gcc-N
bpkg build --yes --sys-yes xsd@https://pkg.cppget.org/1/beta
bpkg install --yes --sys-yes xsd

cd ${BUILD_FOLDER}
mkdir -p ${target_dir}/damaris-extra

git clone https://gitlab.inria.fr/Damaris/damaris.git
cd damaris
mkdir -p build
cd build
cmake .. \
    -DENABLE_HDF5=ON \
    -DENABLE_PYTHON=ON \
    -DENABLE_PYTHONMOD=ON \
    -DCMAKE_PREFIX_PATH=${target_dir}/xsd-install \
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -DGENERATE_MODEL=ON \
    -DCMAKE_INSTALL_PREFIX=${BUILD_FOLDER}/damaris-install \
    -DPYTHON_MODULE_INSTALL_PATH=${BUILD_FOLDER}/damaris_python && \
make install


cp -r ${docker_dir}/opm-sources-master ${BUILD_FOLDER}/opm-sources
cd ${BUILD_FOLDER}
cd opm-sources
bash build_zoltan.sh
bash build_dune.sh
bash build_opm_component.sh opm-common
bash build_opm_component.sh opm-grid
bash build_opm_component.sh opm-models
bash build_opm_component.sh opm-simulators
deactivate

cd ${BUILD_FOLDER}
wget https://github.com/It4innovations/hyperqueue/releases/download/v0.13.0/hq-v0.13.0-linux-x64.tar.gz
mkdir -p ${target_dir}/bin
cd ${target_dir}/bin
tar xvf ${BUILD_FOLDER}/hq-v0.13.0-linux-x64.tar.gz && \
rm -rf ${BUILD_FOLDER}/hq-v0.13.0-linux-x64.tar.gz && \
chmod a+rwx hq

cp ${docker_dir}/run-scripts/* ${target_dir}/bin/
chmod a+x ${target_dir}/bin/*.sh

cp -r ${docker_dir}/damaris-scripts ${target_dir}/damaris-scripts
chmod -R a+rX ${target_dir}/damaris-scripts


echo "DASK_FILE=${target_dir}/dask.json" > ${target_dir}/environments.sh
echo "FLOW_VENV=$FLOW_VENV" >> ${target_dir}/environments.sh
echo "ERT_VENV=$ERT_VENV" >> ${target_dir}/environments.sh