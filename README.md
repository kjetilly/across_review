To run this yourselves, you could do something like:

```bash
   cd /path/to/checkout/repository/at/branch/cae
   cd docker
   docker build . -t opmlearn
   cd ../ert_example
   docker run -it --rm -u $(id -u):$(id -g) -w $(pwd) -v $(pwd):$(pwd) -e \
       ACROSS_DATA_DIR=$(pwd)/data opmlearn  run_ert_venv.sh ensemble_experiment \
       spe1_local.ert
```

By default, we do not save the data for this large case (would require 12 TB). If you want to save the data, you can enable this by adding `-e ACROSS_SAVE_DATA=TRUE` to the docker command line, this will also save the data to `$(pwd)/data`` (account for at least **12 TB**).