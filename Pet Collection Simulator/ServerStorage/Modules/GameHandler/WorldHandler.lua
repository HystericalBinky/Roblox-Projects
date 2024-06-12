local RS = game:GetService("ReplicatedStorage")
local CS = game:GetService("CollectionService")
local PL = game:GetService("Players")
local WS = game:GetService("Workspace")
local MS = game:GetService("MarketplaceService")

local RSModules = RS:WaitForChild("Modules")
local RSEvents = RS:WaitForChild("Events")

local TeleportRemote = RSEvents:WaitForChild("TeleportRemote")

local Config = require(RSModules:WaitForChild("Configuration"))

local PetFolder = Config.Location.SpawnedPetFolder

local WSCore = WS:WaitForChild("Core")
local Portals = WSCore:WaitForChild("Portals")
local SpawnFolder = Portals:WaitForChild("Spawns")

local WorldHandler = {}

function WorldHandler:Init()
	WorldHandler:Listener()
end

local outcomingDB = {}

function WorldHandler:Listener()
	TeleportRemote.OnServerEvent:Connect(function(Player,WorldName)
		local worldstats = Player:WaitForChild("worldstats")
		local WorldData = Config.Worlds[WorldName]
		
		if WorldData.Type ~= "Currency" then return end
		
		if worldstats:FindFirstChild(WorldName) then return end
		local Source = Player:FindFirstChild(WorldData.Source)
		if not Source then return end
		local Currency = Source:FindFirstChild(WorldData.Currency)
		if not Currency then return end
		
		if Currency.Value >= WorldData.Price then
			Currency.Value -= WorldData.Price
			WorldHandler:buyTeleporter(Player,WorldName)
		end
		--Add Data
		--TeleportPlayer
	
	end)
	
	--Outgoing Portals
	for a,PortalHitBox in pairs(CS:GetTagged(Config.Tags.ExportPortal)) do
		if not PortalHitBox:IsA("BasePart") then continue end
		PortalHitBox.Touched:Connect(function(HitPart)
			local Player = PL:GetPlayerFromCharacter(HitPart.Parent)
			if not Player then return end
			local WorldName = PortalHitBox:GetAttribute("World")
			WorldHandler:toTeleport(Player,WorldName)
		end)
	end

	--Incoming Portals
	for a,PortalHitBox in pairs(CS:GetTagged(Config.Tags.ImportPortal)) do
		if not PortalHitBox:IsA("BasePart") then continue end
		PortalHitBox.Touched:Connect(function(HitPart)
			local Player = PL:GetPlayerFromCharacter(HitPart.Parent)
			if not Player then return end
			local WorldName = "Lobby"
			WorldHandler:toTeleport(Player,WorldName)
		end)
	end
	
	
end

function WorldHandler:toTeleport(Player,WorldName)
	if not outcomingDB[Player] then
		outcomingDB[Player] = Player
		
		
		
		local isOwned = WorldHandler:checkTeleport(Player,WorldName)
		if isOwned then
			WorldHandler:teleportPlayer(Player,WorldName)
		else
			TeleportRemote:FireClient(Player,WorldName)
		end

		--Check ownership

		--true then teleport and set data

		--false then fire client and prompt (clientfireserver()) Server listens - pay then teleport

		task.wait(1)
		outcomingDB[Player] = nil
	end
end

function WorldHandler:buyTeleporter(Player,WorldName)
	--add WorldData
	local worldstats = Player:WaitForChild("worldstats")
	local Bool_Int = Instance.new("BoolValue")
	Bool_Int.Name,Bool_Int.Value,Bool_Int.Parent = WorldName,true,worldstats
	WorldHandler:teleportPlayer(Player,WorldName)
end

function WorldHandler:teleportPlayer(Player,WorldName)
	
	local PlayerCharacter = Player.Character
	local HumanoidRootPart = PlayerCharacter:FindFirstChild("HumanoidRootPart")
	local otherstats = Player:WaitForChild("otherstats")
	local World = otherstats:WaitForChild("World")
	
	World.Value = WorldName
	
	World:SetAttribute("Boost", Config.Worlds[WorldName].Boost)
	local WorldSpawn = SpawnFolder:FindFirstChild(WorldName)
	if not WorldSpawn then warn("Can't locate " .. WorldName .. " spawn in WorldSpawn folder") return end
	
	HumanoidRootPart.CFrame = WorldSpawn.CFrame
	local Pets = PetFolder:WaitForChild(Player.Name):GetChildren()
	
	for i, Pet in Pets do
		Pet.PrimaryPart.CFrame = WorldSpawn.CFrame
	end
end

function WorldHandler:checkTeleport(Player,WorldName)
	local WorldData = Config.Worlds[WorldName]
	local leaderstats = Player:WaitForChild("leaderstats")
	local worldstats = Player:WaitForChild("worldstats")
	local Rebirths = leaderstats:WaitForChild("Rebirths")
	print("WorldName: " .. WorldName)
	if not WorldData then return false end
	if WorldData.Type == "Currency" then
		local WorldINT = worldstats:FindFirstChild(WorldName)
		if WorldINT then return true end
	elseif WorldData.Type == "Rebirths" then
		if Rebirths.Value >= WorldData.Price then return true end
	elseif WorldData.Type == "Gamepass" then	
		local suc,isOwned = pcall(function()
			return MS:UserOwnsGamePassAsync(Player.UserId,WorldData.Id)
		end)

		if suc then
			if isOwned then return true end
		end
	end
	return false
end

return WorldHandler
