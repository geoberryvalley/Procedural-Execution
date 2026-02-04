local Players = game:GetService('Players')

local UserInputService = game:GetService("UserInputService")
local StarterGUI = game:GetService("StarterGui")

local player = Players.LocalPlayer

--UserInputService.MouseIconEnabled = false

while not pcall( 
	function () 
		StarterGUI:SetCore("ResetButtonCallback",false)
	end
	) do
	task.wait(0.2)
end
print("nice")