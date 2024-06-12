local RS = game:GetService("ReplicatedStorage")
local PL = game:GetService("Players")
local RSS = game:GetService("RunService")
local WS = game:GetService("Workspace")
local PL = game:GetService("Players")

local Player = PL.LocalPlayer
local otherstats = Player:WaitForChild("otherstats")

local RSModules = RS:WaitForChild("Modules")

local Configuration = require(RSModules:WaitForChild("Configuration"))
local PetFolder = Configuration.Location.SpawnedPetFolder

local Spacing = 5
local PetSize = 3
local MaxClimbHeight = 6

local RayParams = RaycastParams.new()
local RayDirection = Vector3.new(0, -500, 0)

local PetHandler = {}

function PetHandler:Init()
	PetHandler:Listener()
end

function RearrangeTables(Pets, Rows, MaxRowCapacity)
	table.clear(Rows)
	local AmountOfRows = math.ceil(#Pets / MaxRowCapacity)
	for i = 1, AmountOfRows do
		table.insert(Rows, {})
	end
	for i, v in Pets do
		local Row = Rows[math.ceil(i / MaxRowCapacity)]
		table.insert(Row, v)
	end
end

function GetRowWidth(Row, Pet)
	if Pet ~= nil then
		local SpacingBetweenPets = Spacing - Pet.PrimaryPart.Size.X
		local RowWidth = 0
		
		if #Row == 1 then
			return 0
		end
		
		for i, v in Row do
			if i ~= #Row then
				RowWidth += Pet.PrimaryPart.Size.X + SpacingBetweenPets
			else
				RowWidth += Pet.PrimaryPart.Size.X
			end
		end
		
		return RowWidth
	end
end

function PetHandler:Listener()
	RSS.Heartbeat:Connect(function(Deltatime)
		for _, PlayerPetFolder in PetFolder:GetChildren() do
			if not PetFolder:FindFirstChild(PlayerPetFolder.Name) then return end
			local Character = PL[PlayerPetFolder.Name].Character or PL[PlayerPetFolder].CharacterAdded:Wait()
			local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
			local Humanoid = Character:WaitForChild("Humanoid")
			if Character == nil or HumanoidRootPart == nil or Humanoid == nil then return end
			local Pets = {}
			local Rows = {}
			for _, v in PlayerPetFolder:GetChildren() do
				table.insert(Pets, v)
			end
			RayParams.FilterDescendantsInstances = {PetFolder, Character}
			local MaxRowCapacity = math.ceil(math.sqrt(#Pets))
			RearrangeTables(Pets, Rows, MaxRowCapacity)
			for i, Pet in Pets do
				local RowIndex = math.ceil(i / MaxRowCapacity)
				local Row = Rows[RowIndex]
				local RowWidth = GetRowWidth(Row, Pet)
				
				local XOffset = #Row == 1 and 0 or RowWidth/2 - Pet.PrimaryPart.Size.X/2
				local X = (table.find(Row, Pet) - 1) * Spacing
				local Z = RowIndex * Spacing
				local Y = 0
				
				local RayResult = workspace:Blockcast(Pet.PrimaryPart.CFrame + Vector3.new(0, MaxClimbHeight, 0), Pet.PrimaryPart.Size, RayDirection, RayParams)
				if RayResult then
					Y = RayResult.Position.Y + Pet.PrimaryPart.Size.Y/2 + 0.429
				end
				
				local TargetCFrame = CFrame.new(HumanoidRootPart.CFrame.X, 0, HumanoidRootPart.CFrame.Z) * HumanoidRootPart.CFrame.Rotation * CFrame.new(X - XOffset, Y, Z)
				
				Pet.PrimaryPart.CFrame = Pet.PrimaryPart.CFrame:Lerp(TargetCFrame, 0.1)
			end
		end
	end)
end

return PetHandler