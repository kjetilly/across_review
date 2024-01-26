target_dir=installdir
BUILD_FOLDER=${target_dir}/src
. ${target_dir}/flow_venv/bin/activate
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
