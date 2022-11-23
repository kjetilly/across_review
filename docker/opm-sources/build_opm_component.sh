#!/bin/bash


set -e
CC=$(which gcc)
CXX=$(which g++)
location=$(pwd)
parallel_build_tasks=1
repo=$1

cd $location
if [[ ! -d $repo ]]; then
    if [[ $repo != 'opm-simulators' ]]; then
        git clone https://github.com/OPM/$repo.git
        cd $repo
        git checkout `git rev-list -n 1 --first-parent --before="2022-11-06 13:37" master`
        
        cd -
    else
        git clone https://github.com/kjetilly/opm-simulators -b kjetilly_review
        cd opm-simulators
        cp ../opm-simulators_CMakeLists.txt ./CMakeLists.txt
        cp ../opm-simulators-prereqs.cmake ./
        cd ..
    fi
fi
cd $repo
if [[ ! -d build ]]; then
    mkdir build
fi
cd build
USE_DAMARIS=''
if [[ $repo == 'opm-simulators' ]]; then
    USE_DAMARIS='-DUSE_DAMARIS_LIB=ON'
fi
cmake -DCMAKE_C_COMPILER=$CC \
    -DCMAKE_CXX_COMPILER=$CXX \
    -DUSE_MPI=1  \
    -DCMAKE_PREFIX_PATH="$(realpath $location/../damaris-install);$location/zoltan/;$location/dune;$location/boost;$location/opm-common;$location/opm-material;$location/opm-grid;$location/opm-models" \
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_TESTING=OFF \
    -Wno-dev \
    ${USE_DAMARIS} \
    ..
make -j$parallel_build_tasks
make install

