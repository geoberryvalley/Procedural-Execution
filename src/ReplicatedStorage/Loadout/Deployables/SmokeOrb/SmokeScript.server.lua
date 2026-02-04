local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Blaster.Constants)

local smoke = script.Parent
local sound = smoke.Sound

CollectionService:AddTag(smoke, Constants.RAY_EXCLUDE_TAG)
sound:Play()
task.wait(13)
smoke.Color = Color3.new(0.5,0.5,0.5)
task.wait(2)
smoke:Destroy()