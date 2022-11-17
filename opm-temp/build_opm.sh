#!/bin/bash


set -e
CC=$(which gcc-11)
CXX=$(which g++-11)
location=$(pwd)
parallel_build_tasks=4
cd $location

for repo in opm-common opm-material opm-grid opm-models opm-simulators
do
    cd $location
    if [[ ! -d $repo ]]; then
        if [[ $repo != 'opm-simulators' ]]; then
            git clone https://github.com/OPM/$repo.git
            cd $repo
            git checkout `git rev-list -n 1 --first-parent --before="2022-11-06 13:37" master`
            cd -
        else
            git clone https://github.com/kjetilly/opm-simulators -b kjetilly_review
	        cp opm-simulators_CMakeLists.txt ./opm-simulators/CMakeLists.txt
            cp opm-simulators-prereqs.cmake ./opm-simulators/
        fi
    fi
    cd $repo
    if [[ ! -d build ]]; then
        mkdir build
    fi
    cd build
    USE_DAMARIS=''
    TESTING=''
    if [[ $repo == 'opm-simulators' ]]; then
        USE_DAMARIS='-DUSE_DAMARIS_LIB=ON'
        TESTING='-DBUILD_EXAMPLES=OFF -DBUILD_TESTING=OFF'
    fi
    cmake -DCMAKE_C_COMPILER=$CC \
        -DCMAKE_CXX_COMPILER=$CXX \
        -DUSE_MPI=1  \
        -DCMAKE_PREFIX_PATH="$location/damaris-install/;$location/zoltan/;$location/dune;$location/boost;$location/opm-common;$location/opm-material;$location/opm-grid;$location/opm-models" \
        -DCMAKE_BUILD_TYPE=Release \
        -Wno-dev \
        ${USE_DAMARIS} \
        -DBUILD_EXAMPLES=OFF -DBUILD_TESTING=OFF \
        ..
    make -j$parallel_build_tasks
    #make install
done
