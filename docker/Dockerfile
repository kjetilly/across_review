FROM ubuntu:22.10



ARG DEBIAN_FRONTEND=noninteractive
ARG BUILD_FOLDER=/opt/src

ENV ERT_VENV /venvs/ert
ENV FLOW_VENV /venvs/flow

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
        #pybind11-dev \
        #pybind11-json-dev \
        python3 \
        python3-venv \
        #python3-mpi4py \
        python3-pip \
        #python3-pybind11 \
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

RUN python -m venv $ERT_VENV
RUN python -m venv $FLOW_VENV

RUN . $ERT_VENV/bin/activate && pip3 install pybind11
RUN . $ERT_VENV/bin/activate && cd ${BUILD_FOLDER} && \
    git clone https://github.com/kjetilly/ert.git -b hq && \
    cd ert && \
    # We need to tag this to get python setup.py to work
    # if you know a better way, please let me know
    git config --global user.email 'user@user.org' && \
    git config --global user.name 'Dr. User User' && \
    git tag -a v2.36.0 -m 'Version now' && \
    pip install conan && \
    #pip install -r dev-requirements.txt && \
    pip install --upgrade pip wheel setuptools && \
    # python setup.py install && \
    pip install --editable . && \
    # debugging
    pip install ipython pudb 


RUN . $FLOW_VENV/bin/activate && pip3 install dask[complete] pybind11 mpi4py ipython pudb

RUN . $FLOW_VENV/bin/activate && cd ${BUILD_FOLDER} &&\
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
 
RUN . $FLOW_VENV/bin/activate && cd ${BUILD_FOLDER} && \
    cd opm-sources && \
    bash build_zoltan.sh

RUN . $FLOW_VENV/bin/activate && cd ${BUILD_FOLDER} && \
    cd opm-sources && \
    bash build_dune.sh

# opm-common opm-material opm-grid opm-models opm-simulators
RUN . $FLOW_VENV/bin/activate && cd ${BUILD_FOLDER} && \
    cd opm-sources && \
    bash build_opm_component.sh opm-common

RUN . $FLOW_VENV/bin/activate && cd ${BUILD_FOLDER} && \
    cd opm-sources && \
    bash build_opm_component.sh opm-material

RUN . $FLOW_VENV/bin/activate && cd ${BUILD_FOLDER} && \
    cd opm-sources && \
    bash build_opm_component.sh opm-grid

RUN . $FLOW_VENV/bin/activate && cd ${BUILD_FOLDER} && \
    cd opm-sources && \
    bash build_opm_component.sh opm-models

RUN . $FLOW_VENV/bin/activate && cd ${BUILD_FOLDER} && \
    cd opm-sources && \
    bash build_opm_component.sh opm-simulators

RUN cd /root && \
    wget https://github.com/It4innovations/hyperqueue/releases/download/v0.13.0/hq-v0.13.0-linux-x64.tar.gz && \
    cd /usr/bin && \
    tar xvf /root/hq-v0.13.0-linux-x64.tar.gz && \
    rm -rf /root/hq-v0.13.0-linux-x64.tar.gz && \
    chmod a+rwx hq

# We will have two main scripts that we will use from the outside
# of the docker container. Both will start the bokeh server and
# dask scheduler 
COPY run-scripts/run_ert.sh /usr/bin/run_ert.sh
COPY run-scripts/run_ert_venv.sh /usr/bin/run_ert_venv.sh
COPY run-scripts/run_flow.sh /usr/bin/run_flow.sh
COPY run-scripts/flow_venv.sh /usr/bin/flow_venv.sh
RUN chmod a+x /usr/bin/run_flow.sh /usr/bin/run_ert.sh /usr/bin/run_ert_venv.sh /usr/bin/flow_venv.sh

COPY damaris-scripts /damaris-scripts
RUN chmod -R a+rX /damaris-scripts

RUN mkdir /data/ && chmod a+rwx /data
ENV DASK_FILE /data/dask.json
ENV FLOW_DAMARIS_CONFIG_XML_FILE /damaris-scripts/damaris.xml

# DASK
EXPOSE 8787 
# BOKEH
EXPOSE 5006


