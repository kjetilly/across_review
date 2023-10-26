#!/usr/bin/env python
# Yes, this could probably a have been a bash script...
import re
import os
import sys

currentdir = os.getcwd()
sample = int(re.search(r"realization-(\d+)\/iter", currentdir).group(1))

with open(sys.argv[1]) as finput:
    with open("damaris_local.xml", "w") as foutput:
        for line in finput:
            foutput.write(
                line.replace("opm-flow", f"opm-flow-{sample}")
                .replace(
                    "PUBLISH_DATA_SCRIPT",
                    os.getenv(
                        "ACROSS_PUBLISH_DATA_SCRIPT", "/damaris-scripts/publish_data.py"
                    ),
                )
                .replace("DASKFILE", os.getenv("DASK_FILE", "/data/dask.json"))
            )
