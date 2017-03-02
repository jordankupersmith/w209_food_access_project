import json
import os



home = "census_tracts_2010/"

target = "us.json"

dirs = os.listdir(home)

result = {}
result["type"] = "FeatureCollection"

featureArray = []

for d in dirs:
	print d 
	with open(home + d) as f:
		try:
			js = json.load(f)
			features = js["features"]
			featureArray.extend(features)
			print home + d + " processed"
		except:
			print "Skipping " + home + d

result["features"] = featureArray

with open(home + target, "w") as t:
	t.write(json.dumps(result))		
