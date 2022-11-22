# Author: Josh Bowden
# Company: Inria
# Date: 10/11/2022
# 
# Basis of this code as per the Bokeh documentation
# https://docs.bokeh.org/en/latest/docs/user_guide/server/app.html
# 
# If running on a cluster with a login node, you need to reverse tunnel from the compute node to the cluster login node:
#
#  >nohup bokeh serve view_app --port 5100 --args -s <scheduler file> & 
#  >ssh -NR 5100:localhost:5100 user@login.node &
#
# Then from your machine where you want to run the web browser to view the app:
#  >ssh -NL 5100:localhost:5100 user@login.node &
# 
# Now, again, on your local maching (from where you ran the second ssh port forwarding command above) 
# open a browser and point it to: localhost:51000/view_app
#
# To publish data to this app:
#
#    from dask.distributed import Pub
#    pub = Pub(name='SIMULATION_DATA')
#    simulation_data = (iteration_x, data_y,"string")   # Publish a tuple of data on each iteration
#    pub.get(simulation_data) # This will be recieved by any subscribers (like the one in the app below)
#

from functools import partial
from threading import Thread
from random import random

from bokeh.models import ColumnDataSource,  Div, CategoricalColorMapper
from bokeh.plotting import curdoc, figure
from bokeh.layouts import column, row, layout

# from bokeh.palettes import d3
from bokeh.transform import factor_cmap
from bokeh.palettes import Spectral6

from dask.distributed import Client
from dask.distributed import Sub, Pub
import re

# from tornado import gen

import sys, getopt, time


# @gen.coroutine
async def stream_update(x, y, sim_string):
    
    source.stream(dict(x=[x], y=[y], sim_string=[sim_string]), rollover=1000000)  # rollover limits number of data points that will be kept for display
    # palette = d3['Category10'][len(source['sim_string'].unique())]
    # color_map = CategoricalColorMapper(factors=source['sim_string'].unique(),palette=palette)
    
    


def blocking_task(client):
    global count, idx
    sub = Sub(name='SIMULATION_DATA', client=client)
    while True:
        simulation_data = sub.get() # this blocks until data arrives
        print(f"got data {simulation_data=}")
        # time.sleep(0.05)
        # pressure_data = random() * 5.0
        count +=1
        sample = int(re.search(r'realization-(\d+)\/', simulation_data[2]).group(1))
        doc.add_next_tick_callback(partial(stream_update, x=simulation_data[0], y=simulation_data[1], sim_string=sample))


sched_file = ''
try:
    opts, args = getopt.getopt(sys.argv[1:],"hs:",["scheduler-file="])
except getopt.GetoptError:
    print( 'ERROR launching Bokeh server: Could not get the Dask scheduler file argument '+ str(sys.argv[0:],) + ' [ -s | --scheduler-file ] <schedulerfile.json> ')
    sys.exit(2)
for opt, arg in opts:
    if opt == '-h':
        print('INFO: to launch the Bokeh server, specify the Dask scheduler file as an argument: >bokeh serve view_app --port 5100 --args [ -s | --scheduler-file ] <schedulerfile.json> ')
        sys.exit()
    elif opt in ("-s", "--scheduler-file"):
        sched_file = arg
    else :
        print( 'ERROR launching Bokeh server: Could not get the Dask scheduler file argument '+ str(sys.argv[0:],) + ' [ -s | --scheduler-file ] <schedulerfile.json> ')
        sys.exit(2)

# Create a Dask client to use for the Pub-Sub system
print(f"{sched_file=}")
client = Client(scheduler_file=sched_file)
# client = 'mystring'

# this must only be modified from a Bokeh session callback
source = ColumnDataSource(data=dict(x=[], y=[], sim_string=['no_sim_string']))

# This is important! Save curdoc() to make sure all threads
# see then same document.
doc = curdoc()

idx = 0
count = 0


TOOLTIPS = [
    ("Value ", "@y"),
    ("Iteration", "@x"),
    ("Simulation ", "@sim_string"),
]

#  width = 600, height = 600, 
# p.x_axis_type="datetime"
# p.y_axis_type="log"
# p.x_axis=
# p.xaxis.axis_label_text_color = "#aa6666"
# p.xaxis.axis_label_standoff = 30
# p.legend.location = "bottom_left"
# tools = 'pan,wheel_zoom,box_zoom,box_select,hover,reset,save'
p = figure(  title='Live update of simulation field data', tooltips=TOOLTIPS)
p.xaxis.axis_label = 'Timestep'
p.yaxis.axis_label = 'Pressure (Ave) / bar'

from bokeh.transform import linear_cmap
from bokeh.palettes import   brewer
num_sims = 10  # we need to specify this - hardcoded is fine for now
palate = brewer['Paired'][num_sims]
l = p.circle(x='x', y='y', color=linear_cmap('sim_string' , palate,  1.0, float(num_sims)), size=5, source=source)

#l = p.circle(x='x', y='y',  size=10, source=source)
# l = p.circle(x='x', y='y', color=factor_cmap('sim_string', palette=Spectral6, factors=source.data['sim_string']) , size=10, source=source) 



# Create layouts
# app_title = div
# graph = column(app_title, p)
graph = column(p)
layout = layout( graph, name='bokeh_jinja_figure')

# doc.add_root(p)
doc.add_root(layout)

thread = Thread(target=blocking_task,  args=[client])
thread.start()


