#!/bin/bash


set -e
if [[ $(type -P "gcc-11") ]]
then
    CC=$(which gcc-11)
    CXX=$(which g++-11)
else
    CC=$(which gcc)
    CXX=$(which g++)
fi
location=$(pwd)
parallel_build_tasks=1
extra_prefix=$1
install_prefix=$location/opm-install-josh

for repo in opm-common opm-grid opm-models opm-simulators
do
    cd $location
    if [[ ! -d $repo ]]; then
	if [[ "$repo" == "opm-simulators" ]]
	then
	    git clone https://github.com/jcbowden/${repo} -b damariswriter-for-sim-fields-v5
	else
	    git clone https://github.com/OPM/${repo}
	    cd ${repo}
	    git checkout `git rev-list -n 1 --before="2023-09-28 18:37" master`
	    cd ..;
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
	-DCMAKE_PREFIX_PATH="$(realpath $location/../../xsd-install);$(realpath $location/../damaris-install);$location/zoltan/;$location/dune;$location/boost;$location/opm-common;$location/opm-material;$location/opm-grid;$location/opm-models;${extra_prefix}" \
	-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
	-DBUILD_EXAMPLES=OFF \
	-DCMAKE_INSTALL_PREFIX=$install_prefix \
	-DBUILD_TESTING=OFF \
	-Wno-dev \
	${USE_DAMARIS} \
	..
    make -j$parallel_build_tasks
    make install
done
cd $location
