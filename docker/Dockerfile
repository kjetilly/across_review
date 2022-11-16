FROM ubuntu:22.10



ARG DEBIAN_FRONTEND=noninteractive
ARG BUILD_FOLDER=/opt/src
RUN mkdir -p $BUILD_FOLDER
RUN apt-get update && \
    apt-get install -y \
        build-essential \
        cmake \
        gcc \
        git \
        libboost-all-dev \
        libhdf5-openmpi-dev \
        libopenmpi-dev \
        libsuitesparse-dev \
        libxerces-c-dev \
        openmpi-bin \
        openmpi-common \
        paraview \
        paraview-dev \
        python3 \
        python3-pip \
        python3-mpi4py \
        unzip \
        wget \
        xsdcxx \
        && \
    rm -rf /var/lib/apt/lists/* && \
    # This next section is just to make `python` an available command
    echo '#!/bin/bash' > /usr/bin/python && \
    echo 'python3 "$@"' >> /usr/bin/python && \
    chmod a+x /usr/bin/python && \
    # This next bit is  not nice, but hacking for the demo (zoltan does not find mpi otherwise)
    cp -r /usr/lib/x86_64-linux-gnu/openmpi/include/* /usr/include/ && \
    cp -r /usr/lib/x86_64-linux-gnu/openmpi/lib/* /usr/lib64


RUN cd ${BUILD_FOLDER} &&\
    git clone https://gitlab.inria.fr/Damaris/damaris.git -b dask_pub_sub && \
    cd damaris && \
    mkdir -p build && \
    cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release \
        -DENABLE_HDF5=ON \
        -DENABLE_PYTHON=ON \
        -DENABLE_PYTHONMOD=ON \
        -DGENERATE_MODEL=ON \
        -DPYTHON_MODULE_INSTALL_PATH=${BUILD_FOLDER}/damaris_python \
    make install


COPY opm-sources ${BUILD_FOLDER}/opm-sources
 
RUN cd ${BUILD_FOLDER} && \
    cd opm-sources && \
    bash build_zoltan.sh

RUN cd ${BUILD_FOLDER} && \
    cd opm-sources && \
    bash build_dune.sh

RUN cd ${BUILD_FOLDER} && \
    cd opm-sources && \
    bash build_opm.sh
