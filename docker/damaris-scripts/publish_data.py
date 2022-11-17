# Python code: stats_3dmesh_dask.py
# Author: Josh Bowden, Inria
# Description:
# Part of the Damaris examples of using Python integration with Dask distributed
# To run this example on Grid5000 (OAR job scheduler), use the script: stats_launcher.sh
# The script is designed to test the damaris4py.damaris_stats class named DaskStats
#

import numpy as np


# N.B. This file is read by each Damaris server process on each iteration that is
#      specified by the frequency="" in the <pyscript> XML sttribute.


def main(DD):
   
    try:
        print(f"{DD.keys()=}")
        print(f"{DD['iteration_data']=}")
        print(f"{DD['damaris_env']=}")      
        print(f"{DD['dask_env']=}")      
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
    # finally: is always called.
    finally:
        pass


if __name__ == '__main__':
    main(DamarisData)
