#!/bin/bash
set -e
location=$(pwd)
git clone https://gitlab.inria.fr/Damaris/damaris.git -b dask_pub_sub
cd damaris
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release \
    -DENABLE_HDF5=ON \
    -DENABLE_PYTHON=ON \
    -DENABLE_PYTHONMOD=ON \
    -DGENERATE_MODEL=ON \
    -DPYTHON_MODULE_INSTALL_PATH=${location}/damaris_python \
    -DCMAKE_INSTALL_PREFIX=${location}/damaris-install 
make install
cd ../../
