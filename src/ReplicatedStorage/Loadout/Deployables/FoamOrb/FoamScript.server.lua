local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Blaster.Constants)

local smoke = script.Parent
local sound = smoke.Sound

--CollectionService:AddTag(smoke, Constants.RAY_EXCLUDE_TAG) --haha blocks bullets
sound:Play()
task.wait(5)
smoke.Color = Color3.new(0.666667, 0.666667, 0.498039)
task.wait(2)
smoke:Destroy()