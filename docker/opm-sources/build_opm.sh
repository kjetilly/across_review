#!/bin/bash


set -e
CC=$(which gcc)
CXX=$(which g++)
location=$(pwd)
parallel_build_tasks=8
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
	    git clone https://github.com/atgeirr/opm-simulators -b write-global-cell-index-to-damaris
	fi
    fi
	cd $repo
        if [[ ! -d build ]]; then
            mkdir build
        fi
        cd build
        cmake 	-DCMAKE_C_COMPILER=$CC \
		-DCMAKE_CXX_COMPILER=$CXX \
        -DUSE_MPI=1  -DCMAKE_PREFIX_PATH="$location/zoltan/;$location/dune-common/build/;$location/dune-geometry/build/;$location/dune-grid/build/;$location/dune-istl/build/;$location/boost;$location/opm-common;$location/opm-material;$location/opm-grid;$location/opm-models" -DCMAKE_BUILD_TYPE=Release -Wno-dev .. 
        make -j$parallel_build_tasks
done
