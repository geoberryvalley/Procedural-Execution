local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Constants = require(ReplicatedStorage.Blaster.Constants)
local lerp = require(ReplicatedStorage.Utility.lerp)

local camera = Workspace.CurrentCamera

local current = Constants.RECOIL_DEFAULT_FOV
local target = Constants.RECOIL_DEFAULT_FOV
local progress = 1
local speed = 2

local function onRenderStepped(deltaTime: number)
	--camera.CFrame *= CFrame.Angles(recoil.Y * deltaTime, recoil.X * deltaTime, 0)
	--camera.FieldOfView = Constants.RECOIL_DEFAULT_FOV + zoom
	--recoil = recoil:Lerp(Vector2.zero, math.min(deltaTime * Constants.RECOIL_STOP_SPEED, 1))
	--zoom = lerp(zoom, 0, math.min(deltaTime * Constants.RECOIL_ZOOM_RETURN_SPEED, 1))
	if (current ~= target) then
		camera.FieldOfView = lerp(current, target, progress)
		progress = math.min(1,progress+(deltaTime*speed))
		current = camera.FieldOfView
	end
	
end

local CameraZoomer = {}

function CameraZoomer.zoom(targetFOV: number, zoomSpeed: number)
	target = targetFOV
	progress = 0
	speed = zoomSpeed
end

RunService:BindToRenderStep(Constants.RECOIL_BIND_NAME, Enum.RenderPriority.Camera.Value + 2, onRenderStepped)

return CameraZoomer