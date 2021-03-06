2019 Keynote Dashboard
======================

## Client

The client is created with the Godot game engine.

Import the `project.godot` file into Godot and then run it.

## Server

The server is written in nodejs. 

Setup:

```
cd server
npm install
```

Run it:

```
npm start
```




## Isometric Scene

* 2D Node
    * Establish web socket connection
    * Respond to events:
        * Add mechanic
        * Remove mechanic

* TileMap
    * Mechanic Spawn Point - (2,4)
    * Mechanic Exit points - (7,9), (22,21), (40,3), (30,15)

* Mechanic(s)
    * Dispatch events
    * Future route list

* Machines:
    * Yellow - Fixed @ (8,4)
    * Green - Fixed @ (18,-4)
    * Purple - Fixed @ (18, -11)
    * Pink - Fixed @ (22,-15)
    * Black01 - Fixed @ (22,-4)
    * Black02 - Fixed @ (28,-4)
    * Blue - Fixed @ (28,2)
    * Teal - Fixed @ (21,10)
    * Orange - Fixed @ (22,16)
    * Red - Fixed @ (11,10)
    2.35 (-1,1), .785 (1,1), -.785 (1,-1), -2.35(-1,-1), 
    [(180, 260), (945, 286), (1215, 130), (1620, 156), (1215, 442), (1485, 598), (1260, 780), (450, 728), (315, 1014), (270, 624), (360, 936)]


* Distance Matrix
machine name, x, y, machine-1, machine-2, machine-3, machine-4, machine-5, machine-6, machine-7, machine-8, machine-9, machine-10, gate
machine-1, 180, 260, 0, 831.538361, 1143.365204, 1586.204926, 1119.942841, 1431.769714, 1208.909271, 795.983505, 1291.296616, 588.098923, 1239.32547
machine-2, 900, 312, 831.538361, 0, 311.826889, 755.407166, 311.826874, 623.653748, 861.846939, 1432.165283, 1934.760147, 1224.280701, 1884.096634
machine-c, 1170, 156, 1143.365204, 311.826874, 0, 446.021103, 476.386383, 785.773331, 1171.233887, 1743.992126, 2246.58699, 1536.107544, 2195.923477
machine-d, 1575, 182, 1586.204926, 755.407166, 446.021103, 0, 913.8181, 1223.205048, 1611.10553, 2186.831848, 2684.018707, 1978.947266, 2633.355194
machine-e, 1170, 468, 1119.942825, 311.826889, 476.386383, 913.8181, 0, 311.826874, 727.596054, 1663.07666, 1772.936401, 1512.685165, 1722.272888
machine-f, 1440, 624, 1431.76973, 623.653763, 785.773331, 1223.205048, 311.826889, 0, 415.76918, 1351.249786, 1461.109528, 1559.134369, 1410.446014
machine-g, 1260, 780, 1208.909271, 861.846939, 1171.233887, 1611.10553, 727.596054, 415.76918, 0, 987.480652, 1097.340393, 1195.365234, 1046.67688
machine-h, 450, 728, 795.983505, 1432.165283, 1743.992126, 2186.831848, 1663.07666, 1351.249786, 987.480652, 0, 499.243515, 207.884583, 447.272369
machine-i, 315, 1014, 1291.296616, 1927.478394, 2239.305237, 2682.144958, 1772.936401, 1461.109528, 1097.340393, 499.243515, 0, 704.230988, 103.971146
machine-j, 270, 624, 588.098923, 1224.280701, 1536.107544, 1978.947266, 1512.685181, 1559.134369, 1195.365234, 207.884583, 704.230988, 0, 652.259842
gate, 360, 936, 1239.32547, 1875.507248, 2187.334091, 2630.173813, 1722.272888, 1410.446014, 1046.67688, 447.272369, 103.971146, 652.259842, 0


{"name": "machine-0", "label": "A", "coords": Vector2(180,290), "color": Color.yellow, "distances": []},
{"name": "machine-1", "label": "B", "coords": Vector2(945,320), "color": Color.green, "distances": []},
{"name": "machine-2", "label": "C", "coords": Vector2(1215,160), "color": Color.purple, "distances": []},
{"name": "machine-3", "label": "D", "coords": Vector2(1620,180), "color": Color.pink, "distances": []},
{"name": "machine-4", "label": "E", "coords": Vector2(1200,454), "color": Color.black, "distances": []},
{"name": "machine-5", "label": "F", "coords": Vector2(1500,630), "color": Color.maroon, "distances": []},
{"name": "machine-6", "label": "G", "coords": Vector2(1280,810), "color": Color.blue, "distances": []},
{"name": "machine-7", "label": "H", "coords": Vector2(405,725), "color": Color.lightblue, "distances": []},
{"name": "machine-8", "label": "I", "coords": Vector2(200,1050), "color": Color.orange, "distances": []},
{"name": "machine-9", "label": "J", "coords": Vector2(210,610), "color": Color.red, "distances": []},
{"name": "gate", "label": "", "coords": Vector2(320,936), "color": Color.white, "distances": []}


## To-Do

* Distance CSV to Optaplanner team
* Infinispan communication
* 