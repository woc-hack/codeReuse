#getting nP data 
from pymongo import MongoClient
from bson.json_util import dumps

client = MongoClient("mongodb://da1.eecs.utk.edu/")
db = client['WoC']
coll = db["P_metadata.T"]

with open('../data/projects/nP.p','r') as f:
    projects = f.read().splitlines()

res=[]
for p in projects:
    c=coll.find({"ProjectID" : p}, no_cursor_timeout=True)
    for r in c:
        res.append(r)
    c.close()

json=dumps(res)
with open('../data/projects/nP.mongo','w') as f:
    f.write(json)
