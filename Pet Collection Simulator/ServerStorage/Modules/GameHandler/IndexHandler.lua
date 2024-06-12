local IndexHandler = {}

local RS = game:GetService("ReplicatedStorage")
local PL = game:GetService("Players")

local RSModules = RS:WaitForChild("Modules")

function IndexHandler:RegisterPet(Player, Pet)
	local indexstats = Player.indexstats
	
	if not indexstats:FindFirstChild(Pet) then
		local FoundValue = Instance.new("BoolValue")
		FoundValue.Parent = indexstats
		FoundValue.Name = Pet
	end
end
	
return IndexHandler