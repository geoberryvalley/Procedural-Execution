local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local MapFolder = ReplicatedStorage.Map
local DoorwaysFolder = MapFolder.Doorways
local RoomTemplatesFolder = MapFolder.RoomTemplates
local InWorldFolder = Workspace.RandomlyGeneratedMap
local PlaceablesFolder = Workspace.Placeables
local roofFolder = Workspace.Roof

local Queue = require(ReplicatedStorage.Utility.Queue)

local remotes = ReplicatedStorage.Gameplay.Remotes
local generateMapRemote = remotes.GenerateMap
local setScanningAirRemote = remotes.SetScanningAir

local bombRoomLocation = {4,4} --starts at 1,1 (bottom left corner --) and goes to 7,7 (top right corner ++)

local mapSize = 7
local wallCount = mapSize + 1
local roomGrid = table.create(mapSize)
local xWalls = table.create(wallCount) -- ||||||||||| walls 8x7
local zWalls = table.create(mapSize) -- ----------- walls 7x8

for x=1, mapSize do
	roomGrid[x] = table.create(mapSize)
	xWalls[x] = table.create(mapSize)
	zWalls[x] = table.create(wallCount)
end
xWalls[8] = table.create(mapSize)

local function getRandomChild(parent)
	local children = parent:GetChildren()
	return children[math.random(1, #children)]
end

local function roomGridToV3(grid : {})
	local vect = Vector3.new((grid[1] * 20) - 80,-1.5,(grid[2] * 20) - 80)
	return vect
end

local function xWallGridToV3(grid : {})
	local vect = Vector3.new((grid[1] * 20) - 90,6.5,(grid[2] * 20) - 80)
	return vect
end

local function zWallGridToV3(grid : {})
	local vect = Vector3.new((grid[1] * 20) - 80,6.5,(grid[2] * 20) - 90)
	return vect
end

local function roomFolderNameToSize(name : string)
	local res = string.split(name,"x")
	res[1] = tonumber(res[1])
	res[2] = tonumber(res[2])
	return res
end

local function resetroomGridAndWalls()
	for x=1, mapSize do
		for y=1, mapSize do
			roomGrid[x][y] = nil
			xWalls[x][y] = nil
			zWalls[x][y] = nil
		end
		zWalls[x][8] = nil
	end
	xWalls[8] = table.create(mapSize)
end

local function fillRoomGridAndWalls(start : {}, size : {}, flip : boolean)
	local sizeName = table.concat(size,"x")
	--flip the room (rotate it to be horizontal)
	if flip then
		local temp = size[1]
		size[1] = size[2]
		size[2] = temp
	end
	
	for x=0, size[1]-1 do
		for y=0, size[2]-1 do
			roomGrid[start[1]+x][start[2]+y] = {sizeName,flip, (x==0 and y==0)}
			if x == 0 and xWalls[start[1]+x][start[2]+y] == nil then
				xWalls[start[1]+x][start[2]+y] = "W"
			end
			if x == size[1]-1 and xWalls[start[1]+x+1][start[2]+y] == nil then
				xWalls[start[1]+x+1][start[2]+y] = "W"
			end
			if y == 0 and zWalls[start[1]+x][start[2]+y] == nil then
				zWalls[start[1]+x][start[2]+y] = "W"
			end
			if y == size[2]-1 and zWalls[start[1]+x][start[2]+y+1] == nil then
				zWalls[start[1]+x][start[2]+y+1] = "W"
			end
		end
	end
end

--finds an empty adjacent tile on the room grid
-- returns the tile and the direction as a {x,z} or nil if there is no space
local function findEmptyAdjacent(x : IntValue,z : IntValue) --returns {{posX, posY}, {List of possible directions as 2d vectors}}
	local retTable = {{x,z},{}}
	--make sure the room isn't empty
	if roomGrid[x][z] == nil then
		return retTable
	end
	
	local temp = {
		{1,0},
		{0,1},
		{-1,0},
		{0,-1}
	}
	
	--check for empty spaces
	for i,v in pairs(temp) do
		local x1 = x + v[1]
		local z1 = z + v[2]
		if x1 > 0 and x1 <= mapSize and z1 > 0 and z1 <= mapSize then
			if roomGrid[x1][z1] == nil then
				if v[2] == 0 and xWalls[math.max(x,x1)][z1] == "W" then
					table.insert(retTable[2], v)
				elseif v[1] == 0 and zWalls[x1][math.max(z,z1)] == "W" then
					table.insert(retTable[2], v)
				end
				
			end
		end
	end
	return retTable
end

local function findExteriorDoorSpots(x : IntValue, z : IntValue) --returns a list of {x,z, "x" or "z"} that are xWall, zWall spots to put the door
	local retTable = {}
	--make sure the room isn't empty
	if roomGrid[x][z] == nil then
		return retTable
	end

	local temp = {
		{1,0},
		{0,1},
		{-1,0},
		{0,-1}
	}

	--check for empty spaces
	for i,v in pairs(temp) do
		local x1 = x + v[1]
		local z1 = z + v[2]
		if x1 <= 0 or x1 > mapSize then --adjacent tile out of bounds =  its ok to put a door there
			table.insert(retTable, {math.max(x,x1),z, "x"})
		elseif z1 <= 0 or z1 > mapSize then
			table.insert(retTable, {x,math.max(z,z1), "z"})
		else --not OOB
			if roomGrid[x1][z1] == nil then --adjacent room is empty so its okay
				if v[2] == 0 and xWalls[math.max(x,x1)][z] == "W" then
					table.insert(retTable, {math.max(x,x1),z,"x"})
				elseif v[1] == 0 and zWalls[x][math.max(z,z1)] == "W" then
					table.insert(retTable, {x,math.max(z,z1),"z"})
				end
			end
		end
	end
	--reformat retTable so that it returns {xWall, zWall} locations
	return retTable
end

--checks to see if there is space for a room in the map given a starting location
local function isThereSpaceForThisRoom(startX : IntValue, startZ : IntValue, size : {})
	local sizeX = size[1]
	local sizeZ = size[2]
	--if it is out of bounds then return false
	if startX <= 0 or startX > mapSize or startZ <= 0 or startZ > mapSize then
		return false
	end
	for x=0, sizeX-1 do
		local curX = startX + x
		for z=0, sizeZ-1 do
			local curZ = startZ + z
			--if the space is already taken then return false
			if curX > mapSize or curZ > mapSize or curX < 1 or curZ < 1 or roomGrid[curX][curZ] ~= nil then
				return false
			end
		end
	end
	return true
end

generateMapRemote.Event:Connect(function()
	--reset map
	InWorldFolder:ClearAllChildren()
	roofFolder:ClearAllChildren()
	PlaceablesFolder:ClearAllChildren()
	resetroomGridAndWalls()
	--generate bomb room
	--choose a room
	local bombRoomSizeFolder = RoomTemplatesFolder:GetChildren()[math.random(1,#RoomTemplatesFolder:GetChildren())]
	local bombRoomSize = roomFolderNameToSize(bombRoomSizeFolder.Name)
	
	fillRoomGridAndWalls({bombRoomLocation[1] - math.random(0,bombRoomSize[1]-1),bombRoomLocation[2] - math.random(0,bombRoomSize[2]-1)},
		bombRoomSize, false)
		
		-- add other rooms (based on remaining space) then add doors
	--generate the rest of the map
	local maxTiles = math.random(15,18)
	local tileCount = 0
	
	--add rooms and connecting green doors
	while tileCount < maxTiles do
		--print(tileCount,"/",maxTiles," tiles, adding room...")
		local adjacentSpaces = {}
		
		--find all edges with empty adjacent
		for x=1, mapSize do
			for z=1, mapSize do
				local temp = findEmptyAdjacent(x,z)
				if #temp[2] > 0 then
					table.insert(adjacentSpaces, temp)
				end
			end
		end
		
		--chose a random adjacent edge
		--print("adjspaces:",#adjacentSpaces)
		local chosenSpace = adjacentSpaces[math.random(1,#adjacentSpaces)] --choose a random tile
		local temp = chosenSpace[2][math.random(1,#chosenSpace[2])] --choose a random direction
		local randomDoor = {"G","G","E", "N"}
		chosenSpace[2] = temp
		
		--add green door
		if chosenSpace[2][2] == 0 then --vertical green door (no z change)
			xWalls[math.max(0,chosenSpace[2][1]) + chosenSpace[1][1]][chosenSpace[1][2]] = randomDoor[math.random(1,#randomDoor)] --add door
		elseif chosenSpace[2][1] == 0 then --horizontal green door (no x change)
			zWalls[chosenSpace[1][1]][math.max(0,chosenSpace[2][2]) + chosenSpace[1][2]] = randomDoor[math.random(1,#randomDoor)] --add door
		end
		
		--find random room that fits
		local moveDirection
		local moveAxis
		local possibleRooms = {} --each entry is {start, dimensions, isFlipped}
		if chosenSpace[2][2] == 0 then
			moveDirection = {0,-1}
			moveAxis = 2
		else
			moveDirection = {-1,0}
			moveAxis = 1
		end
		--find all possible rooms and positions
		for i,v in pairs(RoomTemplatesFolder:GetChildren()) do
			for pass=1, 2 do --first pass and flipped pass
				--setup
				local dim = roomFolderNameToSize(v.Name)
				if pass == 2 then
					dim = {dim[2],dim[1]}
				end

				--find the x,z for the origin of the room to check (origin is in bottom left)
				local curSpot = {chosenSpace[1][1] + chosenSpace[2][1], chosenSpace[1][2] + chosenSpace[2][2]}
				if chosenSpace[2][1] == 0 and chosenSpace[2][2] == -1 then
					curSpot = {chosenSpace[1][1], chosenSpace[1][2] - dim[2]}
				elseif chosenSpace[2][2] == 0 and chosenSpace[2][1] == -1 then
					curSpot = {chosenSpace[1][1] - dim[1], chosenSpace[1][2]}
				end

				--loop through all possible positions for this room
				for i=1,dim[moveAxis] do
					local temp = isThereSpaceForThisRoom(curSpot[1],curSpot[2],dim)
					if temp then
						if pass == 2 then
							table.insert(possibleRooms, {curSpot, {dim[2], dim[1]}, true})
						else
							table.insert(possibleRooms, {curSpot, dim, false})
						end
						
					end
				end
			end
		end
		--pick a random room from the list
		local chosenRoom = possibleRooms[math.random(1,#possibleRooms)]
		if not chosenRoom then --debug text cuz this is mathematically impossible
			print("DEBUG CRASH: could not find room to add!!")
			return nil
		end
		--add the room
		fillRoomGridAndWalls(chosenRoom[1],chosenRoom[2],chosenRoom[3])
		--increment
		tileCount += chosenRoom[2][1] * chosenRoom[2][2] + 1 --add for scale factor to stop room spam
	end
	
	--add red doors and exterior green door
	--breadth-first search to find the farthest tiles (guaranteed that farthest tile is attached to a wall... I think)
	--bfs setup
	local directions = {{0,1},{0,-1},{-1,0},{1,0}}
	local distanceTiles = {}
	local tilesChecked = table.create(mapSize)
	for x=1, mapSize do
		tilesChecked[x] = table.create(mapSize,false)
	end
	local tilesToCheck = Queue.new()
	Queue.enqueue(tilesToCheck,{4,4,1}) --x, z, distance
	tilesChecked[4][4] = true
	--run bfs
	while not Queue.is_empty(tilesToCheck) do
		local curTile = Queue.dequeue(tilesToCheck)
		--add tile to distanceTiles
		if not distanceTiles[curTile[3]] then
			distanceTiles[curTile[3]] = {}
		end
		table.insert(distanceTiles[curTile[3]],curTile)
		
		--check all adjacent tiles
		for i,dir in pairs(directions) do
			local potentialTile = {math.clamp(curTile[1] + dir[1], 1, mapSize), math.clamp(curTile[2] + dir[2],1,mapSize)}
			--check to see if it is not already checked and there is a room there
			if not tilesChecked[potentialTile[1]][potentialTile[2]] and roomGrid[potentialTile[1]][potentialTile[2]] ~= nil then 
				--check if tile has a wall inbetween
				--find the wall inbetween
				local inbetweenWallType
				if dir[2] == 0 then --change in x
					inbetweenWallType = xWalls[math.max(curTile[1],potentialTile[1])][potentialTile[2]]
				elseif dir[1] == 0 then --change in z
					inbetweenWallType = zWalls[potentialTile[1]][math.max(curTile[2],potentialTile[2])]
				end
				--if there is no wall then add tile to tilesToCheck.
				if inbetweenWallType ~= "W" then
					--add to tiles to check
					tilesChecked[potentialTile[1]][potentialTile[2]] = true
					Queue.enqueue(tilesToCheck,{potentialTile[1],potentialTile[2],curTile[3]+1})
				end
			end
		end
	end
	
	--add green door
	--find the most distant tile
	local farthestTile = distanceTiles[#distanceTiles][math.random(1,#distanceTiles[#distanceTiles])]
	local farthestWalls = findExteriorDoorSpots(farthestTile[1],farthestTile[2])
	local farthestWall = farthestWalls[math.random(1,#farthestWalls)]
	local farthestWindow = farthestWalls[math.random(1,#farthestWalls)]
	--change the wall to a window
	if farthestWindow[3] == "x" then
		xWalls[farthestWindow[1]][farthestWindow[2]] = "V"
	elseif farthestWindow[3] == "z" then
		zWalls[farthestWindow[1]][farthestWindow[2]] = "V"
	end
	--change the wall to a green door
	if farthestWall[3] == "x" then
		xWalls[farthestWall[1]][farthestWall[2]] = "G"
	elseif farthestWall[3] == "z" then
		zWalls[farthestWall[1]][farthestWall[2]] = "G"
	end
	
	--add red doors
	local redDoorCount = 0
	local cDist = math.max(#distanceTiles // 2+1, 4)
	while redDoorCount < 2 do
		--pick a random tile with distance cDist
		local cDistTiles = distanceTiles[cDist]
		local randomTileIndex = math.random(1,#cDistTiles)
		local randomTile = cDistTiles[randomTileIndex]
		--find a random wall
		local randomWalls = findExteriorDoorSpots(randomTile[1],randomTile[2])
		if #randomWalls > 0 then
			local randomWall = randomWalls[math.random(1,#randomWalls)]
			--change the wall to a red door
			if randomWall[3] == "x" then
				xWalls[randomWall[1]][randomWall[2]] = "R"
			elseif randomWall[3] == "z" then
				zWalls[randomWall[1]][randomWall[2]] = "R"
			end
			redDoorCount += 1
			print("red door at distance", cDist, "/", #distanceTiles)
			cDist += math.random(0,1)
		else
			table.remove(cDistTiles,randomTileIndex)
		end
	end
	
	
	
	print("DEBUG: PLACING TIME")
	
	--terrible naming conventions but im too lazy to fix it
	local wallFolder = Instance.new("Folder")
	wallFolder.Parent = InWorldFolder
	wallFolder.Name = "WallFolder"
	
	local DoorwaysFolder = MapFolder.Doorways
	print("placing xWalls...")
	--place xWalls
	print(xWalls)
	for x=1,wallCount do
		for z=1,mapSize do
			local wall : Model
			if xWalls[x][z] == nil or xWalls[x][z] == "N" then
				continue --skip
			elseif xWalls[x][z] == "W" then
				wall = getRandomChild(DoorwaysFolder.Walls):Clone()
			elseif xWalls[x][z] == "G" then
				wall = getRandomChild(DoorwaysFolder.GreenDoors):Clone()
			elseif xWalls[x][z] == "R" then
				wall = getRandomChild(DoorwaysFolder.RedDoors):Clone()
			elseif xWalls[x][z] == "V" then
				wall = getRandomChild(DoorwaysFolder.Viewports):Clone()
			elseif xWalls[x][z] == "E" then
				wall = DoorwaysFolder.Special.EmptyDoor:Clone()
			end
			wall.Parent = wallFolder
			wall:PivotTo(CFrame.lookAt(xWallGridToV3({x,z}),xWallGridToV3({x,z})+Vector3.new(1,0,0)))
		end
	end
	
	print("placing zWalls...")
	--place zWalls
	print(zWalls)
	for x=1,mapSize do
		for z=1,wallCount do
			local wall : Model
			if zWalls[x][z] == nil or zWalls[x][z] == "N" then
				continue --skip
			elseif zWalls[x][z] == "W" then
				wall = getRandomChild(DoorwaysFolder.Walls):Clone()
			elseif zWalls[x][z] == "G" then
				wall = getRandomChild(DoorwaysFolder.GreenDoors):Clone()
			elseif zWalls[x][z] == "R" then
				wall = getRandomChild(DoorwaysFolder.RedDoors):Clone()
			elseif zWalls[x][z] == "V" then
				wall = getRandomChild(DoorwaysFolder.Viewports):Clone()
			elseif zWalls[x][z] == "E" then
				wall = DoorwaysFolder.Special.EmptyDoor:Clone()
			end
			wall.Parent = wallFolder
			wall:PivotTo(CFrame.new(zWallGridToV3({x,z})))
			
		end
	end
	
	print("placing rooms...")
	print(roomGrid)
	
	local scanAirFolder = Instance.new("Folder")
	scanAirFolder.Parent = InWorldFolder
	scanAirFolder.Name = "ScanAirFolder"
	
	local roomFolder = Instance.new("Folder")
	roomFolder.Parent = InWorldFolder
	roomFolder.Name = "RoomFolder"
	
	--place rooms
	for x=1,mapSize do
		for z=1,mapSize do
			local room : Model
			local curGrid = roomGrid[x][z]
			if curGrid == nil then
				--add scanning air to the map in empty spots
				local scanAir = DoorwaysFolder.ScanningAir:Clone()
				scanAir.Position = roomGridToV3({x,z})
				scanAir.Parent = scanAirFolder
			else
				local roof = DoorwaysFolder.Roof:Clone()
				roof.Position = roomGridToV3({x,z}) + Vector3.new(0,12,0)
				roof.Parent = roofFolder
				if curGrid[3] then --if it is the main room
					room = getRandomChild(RoomTemplatesFolder[curGrid[1]]):Clone() --get a random room of the right size
					room.Parent = roomFolder
					room:PivotTo(CFrame.new(roomGridToV3({x,z})))
					if curGrid[2] then --rotate
						local xSize = roomFolderNameToSize(curGrid[1])[1]
						--print("xSize of curGrid",curGrid[1],xSize)
						--rotation magic that works, idk how though lol
						room.PrimaryPart.PivotOffset = CFrame.new(room.PrimaryPart.PivotOffset.Position + Vector3.new((xSize-1)*20,0,0))
						room:PivotTo(room:GetPivot() * CFrame.Angles(0,math.rad(90),0))
						room:PivotTo(room:GetPivot() * CFrame.new(0,0,(xSize-1)*-20))
					end
				end
			end
		end
	end
	print("finished loading map")
	setScanningAirRemote:Fire()
	
end)