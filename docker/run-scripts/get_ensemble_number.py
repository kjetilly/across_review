#!/usr/bin/env python
# Yes, this could probably a have been a bash script...
import re
import os


currentdir = os.getcwd()
sample = int(re.search(r"realization-(\d+)\/iter", currentdir).group(1))

print(f"{sample}")