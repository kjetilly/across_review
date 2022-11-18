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
        pybind11-dev \
        pybind11-json-dev \
        python3 \
        python3-mpi4py \
        python3-pip \
        python3-pybind11 \
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

RUN pip3 install dask[complete]

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
        -DCMAKE_INSTALL_PREFIX=${BUILD_FOLDER}/damaris-install \
        -DPYTHON_MODULE_INSTALL_PATH=${BUILD_FOLDER}/damaris_python && \
    make install

COPY opm-sources ${BUILD_FOLDER}/opm-sources
 
RUN cd ${BUILD_FOLDER} && \
    cd opm-sources && \
    bash build_zoltan.sh

RUN cd ${BUILD_FOLDER} && \
    cd opm-sources && \
    bash build_dune.sh

# opm-common opm-material opm-grid opm-models opm-simulators
RUN cd ${BUILD_FOLDER} && \
    cd opm-sources && \
    bash build_opm_component.sh opm-common

RUN cd ${BUILD_FOLDER} && \
    cd opm-sources && \
    bash build_opm_component.sh opm-material

RUN cd ${BUILD_FOLDER} && \
    cd opm-sources && \
    bash build_opm_component.sh opm-grid

RUN cd ${BUILD_FOLDER} && \
    cd opm-sources && \
    bash build_opm_component.sh opm-models

RUN cd ${BUILD_FOLDER} && \
    cd opm-sources && \
    bash build_opm_component.sh opm-simulators

RUN cd ${BUILD_FOLDER} && \
    git clone https://github.com/vojtechcima/ert.git -b hq && \
    cd ert && \
    # We need to tag this to get python setup.py to work
    # if you know a better way, please let me know
    git config --global user.email 'user@user.org' && \
    git config --global user.name 'Dr. User User' && \
    git tag -a v2.36.0 -m 'Version now' && \
    pip install conan && \
    # Yes, I know this is horrible:
    pip install -r dev-requirements.txt && \
    # Need to update conan remote (old one is deprecated) 
    # conan remote update conancenter https://center.conan.io && \
    python setup.py install && \
    # Something is messed up with our python setup, but leaving for now:
    pip install xtgeo --upgrade --force-reinstall 

# We will have two main scripts that we will use from the outside
# of the docker container. Both will start the bokeh server and
# dask scheduler 
COPY run-scripts/run_ert.sh /usr/bin/run_ert.sh
COPY run-scripts/run_flow.sh /usr/bin/run_flow.sh
RUN chmod a+x /usr/bin/run_flow.sh /usr/bin/run_ert.sh

COPY damaris-scripts /damaris-scripts
RUN chmod -R a+rX /damaris-scripts

RUN mkdir /data/ && chmod a+rwx /data
ENV DASK_FILE /data/dask.json
ENV FLOW_DAMARIS_CONFIG_XML_FILE /damaris-scripts/damaris.xml

# DASK
EXPOSE 8787 
# BOKEH
EXPOSE 5006