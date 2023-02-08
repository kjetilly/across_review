
from functools import partial
from threading import Thread
from random import random

import re

from tornado import gen

import sys
import getopt
import time

import queue
import threading
import numpy as np
import torch
import torch.nn as nn
import os
import copy

def reorder_data(data):
    nx = 20
    ny = 20
    nz = 16 # TODO: We cut the upper 2 cells for now.
    z = np.zeros((nz, ny, nx), dtype=np.float32)
    for i in range(nz):
        for j in range(ny):
            for k in range(nx):
                index = i*ny * nx + j * nx + i
                z[i,j,k] = data[index]
    return z

class DataStore:

    def __init__(self, max_samples = 64):
        assert max_samples > 0
        self._max_samples = max_samples
        self._lock = threading.RLock()
        self._number_of_samples = 0

        self._condition = threading.Condition(self._lock)

    @property
    def has_free_space(self):
        return self._number_of_samples < self._max_samples

    def put(self, data):
        data = reorder_data(np.array(data))
       
        with self._condition:
            if len(self) == 0:
                self._samples = np.zeros((self._max_samples, 1, *data.shape), dtype=np.float32)
            if self.has_free_space:
                self._samples[self._number_of_samples, 0, :] = data.astype(np.float32)
                self._number_of_samples += 1
            else:
                # We randomly insert the new data
                new_index = np.random.randint(0, self._max_samples)
                self._samples[new_index, 0, :] = data
            self._condition.notify_all()
        
    def get_batch(self, batch_size, min_batch_size=0):
        assert min_batch_size <= self._max_samples

        with self._condition:
            while len(self) < min_batch_size:
                self._condition.wait()
            all_indices = np.arange(0, len(self))
            permuted_indices = np.random.permutation(all_indices)
            batch_size = min(batch_size, self._number_of_samples)
            sample_indices = permuted_indices[:batch_size]

            # Note we really want to deepcopy this. pytorch says it
            # shares the memory location with numpy, which is not what we want here
            samples_np = copy.deepcopy(self._samples[sample_indices,:,:])
            return torch.tensor(samples_np)

    def __len__(self):
        return self._number_of_samples

def train(model, datastore, callback):
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    loss_function = nn.MSELoss()

    batch_size = 32
    loss_per_epoch = []
    iteration = 0
    while True:
        samples = datastore.get_batch(batch_size, min_batch_size=16)

        if iteration == 0:
            print(samples)
            print(samples.shape)
        optimizer.zero_grad()
        outputs = model(samples)
        if iteration == 0:
            print(outputs)
            print(outputs.shape)
        loss = loss_function(outputs, samples)
        loss.backward()
        optimizer.step()
        train_loss = loss.item()
        loss_per_epoch.append(train_loss)
        callback(iteration, loss_per_epoch, model)

        iteration += 1

class SaveEvery:
    def __init__(self, basename, every=100):
        self._basename = basename
        self._every = every

    def __call__(self, iteration, loss_per_epoch, model):
        if iteration % self._every == 0:
            model_save_path = f"{self._basename}_model.torch"
            torch.save(model.state_dict(), model_save_path)
            loss_save_path = f"{self._basename}_loss.txt"
            np.savetxt(loss_save_path, loss_per_epoch)

def blocking_task(client, dataqueue):

    from dask.distributed import Sub
    sub = Sub(name='SIMULATION_DATA', client=client)
    while True:
        simulation_data = sub.get()  # this blocks until data arrives
        print("Got data, putting it on the queue")

        if np.prod(simulation_data.shape) == 1:
            continue
        output_dir = os.environ['ACROSS_DATA_DIR']
        np.savetxt(os.path.join(output_dir, f'larger_data_{simulation_data[0]}_{simulation_data[2]}.txt'), simulation_data[1])

        dataqueue.put(simulation_data[1])

def make_conv():
    dnn_down = nn.Sequential(
        nn.Conv3d(1, 16, 3, padding=(1,1,1)),
        nn.MaxPool3d(2,2),
        nn.ReLU(),
        nn.Conv3d(16, 1, 3, padding=(1,1,1)),
        nn.MaxPool3d(2,2))
    
    dnn_up = nn.Sequential(
        nn.ConvTranspose3d(1, 16, 2, stride=2),
        #nn.ReLU(),
        #nn.ConvTranspose1d(16, 16, 2, stride=2),
        nn.ReLU(),
        nn.ConvTranspose3d(16, 1, 2, stride=(2, 2,2)),
        )
    
    return dnn_down, dnn_up

class NeuralNetwork(nn.Module):
    def __init__(self):
        super(NeuralNetwork, self).__init__()
        self.dnn_down, self.dnn_up = make_conv()

    def forward(self, x):
        return self.dnn_up(self.dnn_down(x))

if __name__ == '__main__':
    print("Running dask server")
    import argparse
    from dask.distributed import Client


    parser = argparse.ArgumentParser(description="Runs the server doing the machine learning.")
    parser.add_argument('-s', '--scheduler-file', required=True, type=str, help="The scheduler file from dask")
    args = parser.parse_args()
    sched_file = args.scheduler_file

    client = Client(scheduler_file=sched_file)

    datastore = DataStore()
    thread = Thread(target=blocking_task,  args=[client, datastore])
    thread.start()

    output_dir = os.environ['ACROSS_DATA_DIR']
    callback = SaveEvery(os.path.join(output_dir, "training"))
    model = NeuralNetwork()
    train(model, datastore, callback)
    