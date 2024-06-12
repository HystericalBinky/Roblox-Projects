local PL = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local RSS = game:GetService("RunService")

local RSModules = RS:WaitForChild("Modules")

local SSModules = SS:WaitForChild("Modules")
local SSTemplates = SS:WaitForChild("Templates")

local EasyData = require(SSModules:WaitForChild("EasyData"))
local ApplyData = require(script:WaitForChild("ApplyData"))
local Config = require(RSModules:WaitForChild("Configuration"))
local HatchHandler = require(SSModules:WaitForChild("HatchHandler"))
local GamepassHandler = require(script:WaitForChild("GamepassHandler"))

local __PlayerPetsFolder = workspace:WaitForChild("Pets")

local DataHandler = {
	Profiles = {},
	KeyString = "Player_%s"
}

function DataHandler:Init()
	DataHandler:Listener()
end

function DataHandler:Listener()
	PL.PlayerAdded:Connect(function(Player)
		Player.CharacterAppearanceLoaded:Connect(function()
			DataHandler:PlayerAdded(Player)
		end)
	end)
	PL.PlayerRemoving:Connect(function(Player)
		DataHandler:PlayerRemoving(Player)
	end)
	game:BindToClose(function()
		if RSS:IsStudio() then return end
		for PlayerUserId,b in pairs(PL:GetPlayers()) do
			DataHandler:UpdateProfile(b,true)
		end
	end)
	DataHandler:AutoSave()
end

function DataHandler:PlayerAdded(Player)
	DataHandler:Get(Player)
end

function DataHandler:PlayerRemoving(Player)
	DataHandler:UpdateProfile(Player,true)
end

function DataHandler:AutoSave()
	task.spawn(function()
		warn("Auto Save Initialized!")
		while task.wait(Config.DataStore.AutoSaveInterval) do
			for PlayerUserId,b in pairs(PL:GetPlayers()) do
				DataHandler:UpdateProfile(b,false)
			end
		end
	end)
end

function DataHandler:Get(Player)
	local leaderstats = SSTemplates:WaitForChild("leaderstats"):Clone()
	local otherstats = SSTemplates:WaitForChild("otherstats"):Clone()
	local worldstats = SSTemplates:WaitForChild("worldstats"):Clone()
	local upgradestats = SSTemplates:WaitForChild("upgradestats"):Clone()
	local indexstats = SSTemplates:WaitForChild("indexstats"):Clone()
	local CodesFolder = Instance.new("Folder")
	local PetFolder = Instance.new("Folder")
	local PlayerPetFolder = Instance.new("Folder")

	CodesFolder.Name,CodesFolder.Parent = "CodesFolder",Player
	PetFolder.Name,PetFolder.Parent = "Pets",Player
	PlayerPetFolder.Name,PlayerPetFolder.Parent = Player.Name,__PlayerPetsFolder
	leaderstats.Parent,otherstats.Parent,worldstats.Parent,upgradestats.Parent,indexstats.Parent = Player,Player,Player,Player,Player

	local Data = {
		["leaderstats"] = {
			Clicks = leaderstats:WaitForChild("Clicks").Value,
			Gems = leaderstats:WaitForChild("Gems").Value,
			Tokens = leaderstats:WaitForChild("Tokens").Value,
			Tix = leaderstats:WaitForChild("Tix").Value,
			Rebirths = leaderstats:WaitForChild("Rebirths").Value,
		},
		["otherstats"] = {
			Eggs = otherstats:WaitForChild("Eggs").Value,
			Spins = otherstats:WaitForChild("Spins").Value,
			["Time Played"] = otherstats:WaitForChild("Time Played").Value,
			["Total Clicks"] = otherstats:WaitForChild("Total Clicks").Value,
			["Total Gems"] = otherstats:WaitForChild("Total Gems").Value,
			["Total Tokens"] = otherstats:WaitForChild("Total Tokens").Value,
			["Total Tix"] = otherstats:WaitForChild("Total Tix").Value,
		},
		["upgradestats"] = {
			ClickMultiplier = upgradestats:WaitForChild("ClickMultiplier").Value,
			ExtraEquips = upgradestats:WaitForChild("ExtraEquips").Value,
			ExtraStorage = upgradestats:WaitForChild("ExtraStorage").Value,
			RebirthCost = upgradestats:WaitForChild("RebirthCost").Value,
		},
		["CodesFolder"] = {},
		["worldstats"] = {},
		["PetsFolder"] = {},
		["indexstats"] = {},
	}

	local GetData = EasyData:GetData(self.KeyString:format(Player.UserId),Data)

	if GetData ~= nil then

		if GetData.CodesFolder then
			for a,b in pairs(GetData.CodesFolder) do 
				if b == true then
					local BoolValue = Instance.new("BoolValue")
					BoolValue.Name,BoolValue.Parent = a,CodesFolder
				end
			end
		end

		if GetData.PetsFolder then
			for a,b in pairs(GetData.PetsFolder) do
				local StringINT = Instance.new("StringValue")
				StringINT.Name = b.PetName
				StringINT.Value = a
				StringINT:SetAttribute("CustomName",b.CustomName)
				StringINT:SetAttribute("Equipped",b.Equipped)
				StringINT:SetAttribute("Level",b.Level)
				StringINT:SetAttribute("Multiplier1",b.Multiplier1)
				StringINT:SetAttribute("Multiplier2",b.Multiplier2)
				StringINT:SetAttribute("PetImage",b.PetImage)
				StringINT:SetAttribute("PetType",b.PetType)
				StringINT.Parent = PetFolder
				if StringINT:GetAttribute("Equipped") then HatchHandler:EquipPet(Player,StringINT) end
			end	
			for a,b in pairs(GetData.PetsFolder) do
				otherstats:WaitForChild("PetStorage").Value += 1
			end
		end

		if GetData.worldstats then
			for a,b in pairs(GetData.worldstats) do 
				if worldstats:FindFirstChild(a) then continue end
				if b == true then
					local BoolValue = Instance.new("BoolValue")
					BoolValue.Name,BoolValue.Value,BoolValue.Parent = a,true,worldstats
				end
			end
		end
		
		if GetData.indexstats then
			for a,b in pairs(GetData.indexstats) do
				local FoundValue = Instance.new("BoolValue")
				FoundValue.Parent = indexstats
				FoundValue.Name = b.Value
			end
		end

		ApplyData:Apply(Player,GetData)
		DataHandler:AddProfile(Player,GetData)
	else
		DataHandler:AddProfile(Player,Data)
	end

	task.spawn(function()
		GamepassHandler:UpdateGamepassFeatures(Player)
	end)
end

function DataHandler:Set(Player,isLeaving)
	local PlayerUserId = Player.UserId
	if self.Profiles[PlayerUserId] then

		local succ,err = pcall(function()
			return EasyData:SetData(self.KeyString:format(PlayerUserId),self.Profiles[PlayerUserId])
		end)

		if succ then
			if isLeaving then
				self.Profiles[PlayerUserId] = nil
				if __PlayerPetsFolder:FindFirstChild(Player.Name) then 
					__PlayerPetsFolder:FindFirstChild(Player.Name):Destroy() 
				end
				warn(string.format("[%s] profile saved and cleared!", PlayerUserId))
				
			else
				warn(string.format("[%s] profile updated and auto saved!", PlayerUserId))
			end

		elseif err then
			warn(err)
		end

	end
end

function DataHandler:AddProfile(Player,SaveData)
	if self.Profiles[Player.UserId] == nil then
		self.Profiles[Player.UserId] = SaveData
		print(string.format("Created a profile for %s",Player.UserId))
	end
end

function DataHandler:UpdateProfile(Player,isLeaving)
	local leaderstats = Player:WaitForChild("leaderstats")
	local otherstats = Player:WaitForChild("otherstats")
	local CodesFolder = Player:WaitForChild("CodesFolder")
	local worldstats = Player:WaitForChild("worldstats")
	local upgradestats = Player:WaitForChild("upgradestats")
	local indexstats = Player:WaitForChild("indexstats")
	local Pets = Player:WaitForChild("Pets")
	
	local Data = {
		["leaderstats"] = {
			Clicks = leaderstats:WaitForChild("Clicks").Value,
			Gems = leaderstats:WaitForChild("Gems").Value,
			Tokens = leaderstats:WaitForChild("Tokens").Value,
			Tix = leaderstats:WaitForChild("Tix").Value,
			Rebirths = leaderstats:WaitForChild("Rebirths").Value,
		},
		["otherstats"] = {
			Eggs = otherstats:WaitForChild("Eggs").Value,
			["Time Played"] = otherstats:WaitForChild("Time Played").Value,
			["Total Clicks"] = otherstats:WaitForChild("Total Clicks").Value,
			["Total Gems"] = otherstats:WaitForChild("Total Gems").Value,
			Spins = otherstats:WaitForChild("Spins").Value,
			["Total Tokens"] = otherstats:WaitForChild("Total Tokens").Value,
			["Total Tix"] = otherstats:WaitForChild("Total Tix").Value,
		},
		["upgradestats"] = {
			ClickMultiplier = upgradestats:WaitForChild("ClickMultiplier").Value,
			ExtraEquips = upgradestats:WaitForChild("ExtraEquips").Value,
			ExtraStorage = upgradestats:WaitForChild("ExtraStorage").Value,
			RebirthCost = upgradestats:WaitForChild("RebirthCost").Value,
		},
		["CodesFolder"] = {},
		["worldstats"] = {},
		["PetsFolder"] = {},
		["indexstats"] = {},
	}

	--Import Codes
	table.clear(Data.CodesFolder)
	for _,b in pairs(CodesFolder:GetChildren()) do
		if b:IsA("BoolValue") then
			if b.Value == true then
				Data.CodesFolder[b.Name] = true
			end
		end
	end
	
	table.clear(Data.PetsFolder)
	for _,b in pairs(Pets:GetChildren()) do
		if not b:IsA("StringValue") then continue end
		Data.PetsFolder[b.Value] = {
			PetName = b.Name,
			CustomName = b:GetAttribute("CustomName"),
			Equipped = b:GetAttribute("Equipped"),
			Level = b:GetAttribute("Level"),
			Multiplier1 = b:GetAttribute("Multiplier1"),
			Multiplier2 = b:GetAttribute("Multiplier2"),
			PetImage = b:GetAttribute("PetImage"),
			PetType = b:GetAttribute("PetType")
		}
	end
	
	table.clear(Data.worldstats)
	for _,b in pairs(worldstats:GetChildren()) do
		if not b:IsA("BoolValue") then continue end
		if b.Value == false then continue end
		Data.worldstats[b.Name] = true
	end
	
	table.clear(Data.indexstats)
	for _,b in pairs(indexstats:GetChildren()) do
		if not b:IsA("BoolValue") then continue end
		Data.indexstats[b.Name] = {
			Value = b.Name,
		}
	end

	if self.Profiles[Player.UserId] ~= nil then
		self.Profiles[Player.UserId] = Data
		warn(string.format("Creating %s's Profile:",Player.Name))
		print(self.Profiles[Player.UserId])
	else
		warn(string.format("%s has no Profile",Player.Name))
		Player:Kick("An error occured while updating your data. Please rejoin!")
	end
	DataHandler:Set(Player,isLeaving)
end

return DataHandler