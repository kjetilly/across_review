
from functools import partial
from threading import Thread
from random import random

import re

from tornado import gen

import sys
import getopt
import time
from dask.distributed import Client
from dask.distributed import Sub
import queue


def blocking_task(client, dataqueue):
    sub = Sub(name='SIMULATION_DATA', client=client)
    while True:
        simulation_data = sub.get()  # this blocks until data arrives
        print("Got data, putting it on the queue")
        dataqueue.put(simulation_data)



if __name__ == '__main__':
    print("Running dask server")
    import argparse
    import numpy as np
    import os


    parser = argparse.ArgumentParser(description="Runs the server doing the machine learning.")
    parser.add_argument('-s', '--scheduler-file', required=True, type=str, help="The scheduler file from dask")
    args = parser.parse_args()
    sched_file = args.scheduler_file

    client = Client(scheduler_file=sched_file)
    num_sims = 10  # we need to specify this - hardcoded is fine for now

    # Maximum number of samples to buffer
    maxsize = 10
    dataqueue = queue.Queue(maxsize=maxsize)
    thread = Thread(target=blocking_task,  args=[client, dataqueue])
    thread.start()

    import torch

    output_dir = os.environ['ACROSS_DATA_DIR']
    while True:
        data = dataqueue.get()
        print("Got data from the queue")
        print(f"{os.getcwd()=}")
        timestep = data[0]
        sample = data[2]
        pressure = data[1]
        print(f"{timestep=}, {sample=}")

        np.savetxt(os.path.join(output_dir, f'data_{sample}_{timestep}.txt'), pressure)
