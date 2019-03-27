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
    * Yellow - Fixed @ (7,4)
    * Green - Fixed @ (18,-5)
    * Purple - Fixed @ (18, -10)
    * Pink - Fixed @ (22,-15)
    * Black01 - Fixed @ (22,-4)
    * Black02 - Fixed @ (29,-4)
    * Blue - Fixed @ (29,2)
    * Teal - Fixed @ (18,9)
    * Orange - Fixed @ (22,16)
    * Red - Fixed @ (12,9)

* Distance Matrix
machine name, x, y, machine-1, machine-2, machine-3, machine-4, machine-5, machine-6, machine-7, machine-8, machine-9, machine-10, gate
machine-1, 7, 4, 0, 5.022018, 2.520624, 3.482703, 8.985762, 15.046808, 18.048473, 12.025907, 18.991301, 6.830718, 4.329324
machine-2, 18, -5, 5.022018, 0, 2.501395, 1.539315, 3.963744, 10.024791, 13.026454, 7.003889, 13.969284, 1.8087, 9.351342
machine-3, 18, -10, 2.520624, 2.501395, 0, 0.96208, 6.465138, 12.526185, 15.527849, 9.505283, 16.470676, 4.310094, 6.849948
machine-4, 22, -15, 3.482703, 1.539315, 0.96208, 0, 5.503058, 11.564105, 14.565769, 8.543203, 15.508598, 3.348014, 7.812028
machine-5, 22, -4, 8.985762, 3.963744, 6.465138, 5.503058, 0, 6.061047, 9.062711, 3.040145, 10.00554, 2.155044, 13.315086
machine-6, 29, -4, 15.046808, 10.024791, 12.526185, 11.564105, 6.061047, 0, 3.001664, 3.020902, 3.944493, 8.216091, 19.376133
machine-7, 29, 2, 18.048473, 13.026454, 15.527849, 14.565769, 9.062711, 3.001664, 0, 6.022566, 0.942829, 11.217754, 22.377798
machine-8, 18, 9, 12.025907, 7.003889, 9.505283, 8.543203, 3.040145, 3.020902, 6.022566, 0, 6.965394, 5.195189, 16.355232
machine-9, 22, 16, 18.991301, 13.969284, 16.470676, 15.508598, 10.00554, 3.944493, 0.942829, 6.965394, 0, 12.160583, 23.320627
machine-10, 12, 9, 6.830718, 1.8087, 4.310094, 3.348014, 2.155044, 8.216091, 11.217754, 5.195189, 12.160583, 0, 11.160042
gate, 2, 4, 4.329324, 9.351342, 6.849948, 7.812028, 13.315086, 19.376133, 22.377798, 16.355232, 23.320627, 11.160042, 0


## To-Do

* Distance CSV to Optaplanner team
* Infinispan communication
* 