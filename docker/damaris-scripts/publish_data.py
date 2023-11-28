# Python code: stats_3dmesh_dask.py
# Author: Josh Bowden, Inria
# Description:
# Part of the Damaris examples of using Python integration with Dask distributed
# To run this example on Grid5000 (OAR job scheduler), use the script: stats_launcher.sh
# The script is designed to test the damaris4py.damaris_stats class named DaskStats
#


# N.B. This file is read by each Damaris server process on each iteration that is
#      specified by the frequency="" in the <pyscript> XML sttribute.


def main(DD):
    should_flush = True

    def printfunction(statement, flush=False):
        pass  # print(statement, flush=flush)

    printfunction("Running iteration", flush=should_flush)

    try:
        import mpi4py
        from mpi4py.MPI import Comm
        from dask.distributed import Client
        from dask.distributed import Sub, Pub
        from damaris4py.server import getservercomm
        from damaris4py.dask import damaris_dask
        from damaris4py.server import getclientcomm

        # from damaris4py.server import magicnumber_string

        import numpy as np
        import os
        import re
        import logging

        # client_comm = getclientcomm()
        # print(f"{client_comm=}", flush=True)

        # print(f"magicnumber={magicnumber_string()}", flush=True)

        damaris_comm = getservercomm()
        print(f"{damaris_comm=}", flush=True)

        iteration = DD["iteration_data"]["iteration"]

        # if iteration % 10 != 0:
        #     return
        with Client(
            scheduler_file=DD["dask_env"]["dask_scheduler_file"], timeout="2s"
        ) as client:
            PRESSURE = damaris_dask.return_dask_array_v3(
                DD, client, "PRESSURE", damaris_comm, print_array_component=False
            )
            pub = Pub(name="SIMULATION_DATA", client=client)

            printfunction(f"{iteration=}", flush=should_flush)
            if True:  # PRESSURE is not None:
                try:
                    # data = (
                    #     DD["iteration_data"]["PRESSURE"]["numpy_data"]["P0_B0"] * 1e-5
                    # )  # data = PRESSURE.compute()#
                    data = PRESSURE
                except:
                    # If we don't succeed in getting the data, we just ignore it
                    logging.warning("Failed getting data")
                    return

                if np.any(np.isnan(data)):
                    logging.warning("nan in pressure data")
                    return
                printfunction(f"{data=}", flush=should_flush)
                try:
                    sample = int(
                        re.search(r"realization-(\d+)\/", os.getcwd()).group(1)
                    )
                except:
                    sample = 0

                pub.put((iteration, data, sample))
                printfunction("Published data", flush=should_flush)
    except KeyError as err:
        print(
            "Python ERROR: KeyError: No damaris data of name: ", err, flush=should_flush
        )
    except PermissionError as err:
        print("Python ERROR: PermissionError!: ", err, flush=should_flush)
    except ValueError as err:
        print("Python ERROR: Damaris Data problem!: ", err, flush=should_flush)
    except UnboundLocalError as err:
        print("Python ERROR: Damaris data not assigned!: ", err, flush=should_flush)
    except NameError as err:
        print("Python ERROR: NameError: ", err, flush=should_flush)
    except Exception as err:
        print("Unknown error : ", err, flush=should_flush)
    # finally: is always called.
    except:
        print("Really unknown error", flush=True)
    finally:
        pass


if __name__ == "__main__":
    main(DamarisData)
