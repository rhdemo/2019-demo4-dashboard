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

## To-Do

* Distance CSV to Optaplanner team
* Infinispan communication
* 