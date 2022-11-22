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
    print("Running iteration")
    try:
        from dask.distributed import Client
        from dask.distributed import Sub, Pub
        import numpy as np
        import os
        import re
        iteration = DD['iteration_data']['iteration']
        # if iteration % 10 != 0:
        #     return
        with Client(scheduler_file=DD['dask_env']['dask_scheduler_file']) as client:
            pub = Pub(name='SIMULATION_DATA', client=client)

            print(f"{iteration=}")
            data = np.mean(DD['iteration_data']['PRESSURE']
                           ['numpy_data']['P0_B0']*1e-5)
            print(f"{data=}")
            sample = int(
                re.search(r'realization-(\d+)\/', os.getcwd()).group(1))

            pub.put((iteration, data, sample))
            print("Published data")
    except KeyError as err:
        print('Python ERROR: KeyError: No damaris data of name: ', err)
    except PermissionError as err:
        print('Python ERROR: PermissionError!: ', err)
    except ValueError as err:
        print('Python ERROR: Damaris Data problem!: ', err)
    except UnboundLocalError as err:
        print('Python ERROR: Damaris data not assigned!: ', err)
    except NameError as err:
        print('Python ERROR: NameError: ', err)
    except Exception as err:
        print("Unknown error : ", err)
    # finally: is always called.
    finally:
        pass


if __name__ == '__main__':
    main(DamarisData)
