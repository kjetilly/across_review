#!/bin/bash
set -e
bash build_zoltan.sh
bash build_damaris.sh
bash build_dune.sh
bash build_opm.sh