# Procedural Execution
## About the Project
This project is based on the "Laser Tag" template from ROBLOX, but has been heavily modified from that. Core features include:
* 1,000,000,000+ possible randomly generated maps
* Over a dozen custom weapons and tools to do combat with
* Voice Chat capability for a social experience

### Map Generation Overview
Here is an overview of how the mapmaking algorithm currently works (as of January 2026):
1. The bomb is placed at the center of the map
2. A room of random size goes around the bomb
3. A random number of "points" are selected
4. A random wall with empty space around it is chosen
5. A door is added from the existing room to the new one
6. A new room size is determined (brute force checking) and added, and points are decreased based on the size of the room
7. Steps 4-6 are repeated until points <= 0
8. Breadth-first-search is done to calculate the farthest possible tile, and the exterior green door is added to this tile
9. Red doors are added to tiles that are roughly half the maximum distance
10. The map goes from a set of data values in a 2D array to a physical representation in the game world

## Links:
* The game: https://www.roblox.com/games/125638462450753/Procedural-Execution
* Roblox Template: https://create.roblox.com/docs/resources/templates
