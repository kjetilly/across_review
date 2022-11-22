The relevant files to look at are:

* `across_review/docker/run-scripts/run_ert_venv.sh`: This is the entrypoint for the dockerfile and where I start the dask-scheduler, dask-worker and the bokeh server

* `across_review/blob/main/docker/run-scripts/flow_venv.sh` this is where I run flow from within ERT. It essentially just calls `mpirun -np 2 flow --enable-damaris-output=true "$@"`

* `across_review/blob/main/docker/damaris-scripts/damaris.xml` this is the xml I provide damaris through flow (will get the regexp treatment)

* `across_review/blob/main/docker/damaris-scripts/publish_data.py` this is where I publish the data from damaris 

* `across_review/blob/main/docker/damaris-scripts/main.py` the bokeh server app. 

You should be able to run this yourself by running from the root of the repository

    docker run -p 5006:5006 --rm -it -u $(id -u):$(id -g) -v $(realpath ert_example):/workflow -w /workflow -e 'NUMBER_OF_CPUS=2' kjetilly/damaris run_ert_venv.sh ensemble_experiment spe1.ert

where `NUMBER_OF_CPUS` can be changed (it is passed on to HQ). 

You can also alter the XML file that is read from OPM Flow by specifiying the environment variable `FLOW_DAMARIS_CONFIG_XML_FILE`