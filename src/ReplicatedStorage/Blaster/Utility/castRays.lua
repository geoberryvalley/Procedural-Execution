local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Constants = require(ReplicatedStorage.Blaster.Constants)
local canPlayerDamageHumanoid = require(ReplicatedStorage.Blaster.Utility.canPlayerDamageHumanoid)

export type RayResult = {
	taggedHumanoid: Humanoid?,
	isHeadshot: boolean, --added headshots
	position: Vector3,
	normal: Vector3,
	instance: Instance?,
}

local function castRays(
	player: Player,
	position: Vector3,
	directions: { Vector3 },
	radius: number,
	staticOnly: boolean?
): { RayResult }
	local exclude = CollectionService:GetTagged(Constants.RAY_EXCLUDE_TAG)

	if staticOnly then
		local nonStatic = CollectionService:GetTagged(Constants.NON_STATIC_TAG)
		-- Append nonStatic to exclude
		table.move(nonStatic, 1, #nonStatic, #exclude + 1, exclude)
	end

	-- Always include the player's character in the exclude list
	if player.Character then
		table.insert(exclude, player.Character)
	end

	local collisionGroup = nil

	-- If the player is on a team, use that team's collision group to ensure the ray passes through
	-- characters and forcefields on that team.
	if player.Team and not player.Neutral then
		collisionGroup = player.Team.Name
	end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = true
	params.FilterDescendantsInstances = exclude
	if collisionGroup then
		params.CollisionGroup = collisionGroup
	end

	local rayResults = {}

	for _, direction in directions do
		-- In order to provide a simple form of bullet magnetism, we use spherecasts with a small radius instead of raycasts.
		-- This allows closely grazing shots to register as hits, making blasters feel a bit more accurate and improving the 'game feel'.
		local raycastResult = Workspace:Spherecast(position, radius, direction, params)
		local rayResult: RayResult = {
			position = position + direction,
			normal = direction.Unit,
		}

		if raycastResult then
			rayResult.position = raycastResult.Position
			rayResult.normal = raycastResult.Normal
			rayResult.instance = raycastResult.Instance
			rayResult.isHeadshot = false; --default to bodyshot
	
			local humanoid = raycastResult.Instance.Parent:FindFirstChildOfClass("Humanoid")
			if humanoid and canPlayerDamageHumanoid(player, humanoid) then
				local head = humanoid.Parent:FindFirstChild("Head")
				rayResult.taggedHumanoid = humanoid
				print("client shot hit")
				if head and head:IsA("Part") then
					local headCFrame, headSize = head.CFrame, head.Size
					local headMin = headCFrame.Position - headSize / 2
					local headMax = headCFrame.Position + headSize / 2
					local hitPosition = raycastResult.Position
					local isInsideHead = (hitPosition.X+radius >= headMin.X and hitPosition.X-radius <= headMax.X) and
					                     (hitPosition.Y+radius >= headMin.Y and hitPosition.Y-radius <= headMax.Y) and
										 (hitPosition.Z+radius >= headMin.Z and hitPosition.Z-radius <= headMax.Z)
					rayResult.isHeadshot = isInsideHead
					--print("hs?",isInsideHead)
				end
			end
		end
		table.insert(rayResults, rayResult)
	end

	return rayResults
end

return castRays

