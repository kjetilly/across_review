#!/bin/bash
. ${ERT_VENV}/bin/activate
mpirun -np 2 flow --enable-damaris-output=true "$@"