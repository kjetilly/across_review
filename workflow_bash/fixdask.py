import json
import sys
import re


inname = sys.argv[1]

with open(inname) as f:
    jsonobject = json.load(f)
    port = re.search(r':(\d+)', jsonobject['address']).group(1)
    jsonobject['address'] = f"localhost:{port}"

with open(inname, 'w') as f:
    json.dump(jsonobject, f)
