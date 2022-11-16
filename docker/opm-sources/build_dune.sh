#!/bin/bash
set -e
dune_version='v2.8.0'
location=`pwd`

CC=$(which gcc)
CXX=$(which g++)

parallel_build_tasks=16


#############################################
### Dune
#############################################

cd $location
install_prefix=$location/dune
for repo in dune-common dune-geometry dune-grid dune-istl
do
    echo "=== Cloning and building module: $repo"
    if [[ ! -d $repo ]]; then
        #git clone -b releases/2.8 https://gitlab.dune-project.org/core/$repo.git
        wget https://gitlab.dune-project.org/core/${repo}/-/archive/${dune_version}/${repo}-${dune_version}.zip
        unzip ${repo}-${dune_version}.zip
        mv ${repo}-${dune_version} $repo
        rm -rf ${repo}-${dune_version}.zip
    fi
    cd $repo
    #git pull
    rm -rf build
    if [[ ! -d build ]]; then
        mkdir build
    fi
    cd build
    cmake -DCMAKE_BUILD_TYPE=Release  \
        -DCMAKE_C_COMPILER=$CC \
        -DCMAKE_PREFIX_PATH=$install_prefix \
        -DCMAKE_INSTALL_PREFIX=$install_prefix \
        -DCMAKE_CXX_COMPILER=$CXX \
        ..
    make -j $parallel_build_tasks
    make install
    cd $location
done