#getting nP data 
from pymongo import MongoClient
from bson.json_util import dumps

client = MongoClient("mongodb://da1.eecs.utk.edu/")
db = client['WoC']
coll = db["P_metadata.U"]

res=[]
c=coll.aggregate( [{ "$sample": { "size": 1000000 } }] )
for r in c:
    res.append(r)
c.close()

json=dumps(res)
with open('../data/projects/sample.mongo','w') as f:
    f.write(json)
