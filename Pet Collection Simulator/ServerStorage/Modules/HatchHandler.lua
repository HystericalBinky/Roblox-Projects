local MS = game:GetService("MarketplaceService")
local PL = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local HS = game:GetService("HttpService")
local TS = game:GetService("TextService")
local SS = game:GetService("ServerStorage")

local RSAssets = RS:WaitForChild("Assets")
local RSTemplates = RS:WaitForChild("Templates")
local RSModules = RS:WaitForChild("Modules")
local Config = require(RSModules:WaitForChild("Configuration"))

local PlayerPetFolders = Config.Location.SpawnedPetFolder
local EggFolder = Config.Location.EggFolder

local EggModule = Config.EggModule

local IndexHandler = require(SS.Modules.GameHandler.IndexHandler)

local PetAssets = RSAssets:WaitForChild("Pets")

local HatchHandler = {
	HatchDB = {}
}

--Hatching System

function HatchHandler:BuyRobuxPet(receiptInfo)
	local Player = PL:GetPlayerByUserId(receiptInfo.PlayerId)
	if not self.HatchDB[Player] then
		self.HatchDB[Player] = Player
		for a,EggData in pairs(EggModule) do
			if EggData.Currency == "Robux" and EggData.ProductId == receiptInfo.ProductId then
				local Egg = EggFolder:FindFirstChild(a)
				local PetDataTable = {}
				table.clear(PetDataTable)
				local HatchData = HatchHandler:ObtainPet(Player, Egg, EggData)	

				table.insert(PetDataTable,HatchData)
				print(PetDataTable)
				self.HatchDB[Player] = nil
				return true,PetDataTable
			end
		end
	end

end

function HatchHandler:BuyPet(Player,Egg,EggData,HatchCount)

	local leaderstats = Player:WaitForChild("leaderstats")
	local otherstats = Player:WaitForChild("otherstats")

	local MaxPetStorage = otherstats:WaitForChild("MaxPetStorage")
	local PetStorage = otherstats:WaitForChild("PetStorage")

	local PetDataTable = {}

	if not self.HatchDB[Player] then
		self.HatchDB[Player] = Player
		if EggData.Currency ~= "Robux" then
			table.clear(PetDataTable)

			for a = 1,HatchCount do
				local DataFolder = Player:WaitForChild(EggData.Source)
				local Currency = DataFolder:WaitForChild(EggData.Currency)
				if Currency.Value >= EggData.Cost then
					if PetStorage.Value < MaxPetStorage.Value then
						Currency.Value -= EggData.Cost
						self.HatchDB[Player] = nil
						local HatchData = HatchHandler:ObtainPet(Player, Egg, EggData)
						table.insert(PetDataTable,HatchData)
					else
						self.HatchDB[Player] = nil
						return false,"Maximum Pet Storage!"
					end
				else
					if #PetDataTable == 0 then
						self.HatchDB[Player] = nil
						return false,"Not enough " .. EggData.Currency
					end
					break
				end
			end
			warn("Returning Pet Table: ")
			warn(PetDataTable)
			return true, PetDataTable
		end
	end
end

function HatchHandler:ObtainPet(Player,Egg,EggData)
	local leaderstats = Player:WaitForChild("leaderstats")
	local otherstats = Player:WaitForChild("otherstats")

	local PetStorage = otherstats:WaitForChild("PetStorage")

	local PlayerEggs = otherstats:FindFirstChild("Eggs")

	local PetNumber,PetData = HatchHandler:HatchRandomPet(EggData)

	PetStorage.Value += 1
	PlayerEggs.Value += 1

	return HatchHandler:SetPetData(Player,PetData,PetNumber,Egg,EggData)
end

function HatchHandler:HatchRandomPet(EggData)
	local TotalEggRarityWeight = 0
	local TotalPetRarityWeight = 0

	--Adding up all pet rarity: 100%
	for a,b in pairs(EggData.Pets) do
		TotalEggRarityWeight += b.RarityPercentage
	end

	--Adding up all pet rarity: 100%
	
	-- Debugging
	local testrandom = Random.new()
	local Randompetn = testrandom:NextNumber(1, TotalEggRarityWeight)
	
	local RandomPetNumber = math.random(1,TotalEggRarityWeight)
	print(RandomPetNumber)
	
	for a,b in pairs(EggData.Pets) do
		TotalPetRarityWeight += b.RarityPercentage
		if TotalPetRarityWeight >= Randompetn then
			print(TotalPetRarityWeight .. "% = " .. Randompetn .. "%")
			print("Chosen Pet: " .. b.Name)
			return a,b
		end
	end
end

local function GenerateID() 
	local GUID = HS:GenerateGUID()
	local extractedGUID = GUID:gsub("[^%w]", "")
	return extractedGUID
end

function HatchHandler:SetPetData(Player,PetData,PetNumber,Egg,EggData)
	local NumberInstance = Instance.new("StringValue")
	local PlayerPetDataFolder = Player:WaitForChild("Pets")
	local RandomPetID = string.format('%s_%s%i', PetData.Name, GenerateID(), os.clock() + (math.random() * 1000000))

	NumberInstance.Parent = PlayerPetDataFolder
	NumberInstance.Name = PetData.Name
	NumberInstance.Value = RandomPetID
	NumberInstance:SetAttribute("Equipped", false)

	NumberInstance:SetAttribute("Multiplier1", EggData.Pets[PetNumber].Mult1)
	NumberInstance:SetAttribute("Multiplier2",  EggData.Pets[PetNumber].Mult2)
	NumberInstance:SetAttribute("CustomName", Config.RandomPetName[math.random(1,#Config.RandomPetName)])
	NumberInstance:SetAttribute("PetType", PetData.Rarity)
	NumberInstance:SetAttribute("PetImage", PetData.PetImageId)
	NumberInstance:SetAttribute("Level",1)
	
	IndexHandler:RegisterPet(Player, PetData.Name)
	
	local EggPetData = {}
	EggPetData['PetData'] = PetData
	EggPetData['EggData'] = EggData
	return EggPetData
end

--Spawning System

function HatchHandler:EquipPet(Player,PetIntData)
	warn("Spawning Pet...")
	local PetClone = PetAssets:FindFirstChild(PetIntData.Name):Clone()
	if not PetClone then warn(string.format("%s can't be found in Assets Folder",PetIntData.Name)) return false,string.format("%s can't be found in Assets Folder",PetIntData.Name) end
	
	local PetMainPart = PetClone.PrimaryPart
	if not PetMainPart then warn("Can't find Pet's Primary part") return false,string.format("Error:2 - Please report to the owner!") end
	local PlayerCharacter = Player.Character
	local PlayerHumanoidRootPart = PlayerCharacter:FindFirstChild("HumanoidRootPart")
	
	local leaderstats = Player:WaitForChild("leaderstats")
	local otherstats = Player:WaitForChild("otherstats")

	local PetEquipped = otherstats:WaitForChild("PetEquipped")
	local MaxPetEquip = otherstats:WaitForChild("MaxPetEquip")
	local Multiplier = otherstats:WaitForChild("PetMultiplier")
	
	local PetPhysics = RSTemplates:WaitForChild("PetPhysics")
	local BodyGyro = PetPhysics:WaitForChild("BodyGyro"):Clone()
	local BodyPosition = PetPhysics:WaitForChild("BodyPosition"):Clone()
	
	local PetNameAtt__ = PetMainPart:FindFirstChild("PetNameAtt")
	
	if not PetNameAtt__ then
		local AttClone = RSTemplates:WaitForChild("AttClone"):WaitForChild("PetNameAtt"):Clone()
		AttClone.Parent = PetMainPart
	end

	local PetNameAttBG = PetMainPart:FindFirstChild("PetNameAtt"):WaitForChild("BG")
	
	local PetCustomName = PetNameAttBG:WaitForChild("PetCustomName")
	local PetName = PetNameAttBG:WaitForChild("PetName")
	local PetType = PetNameAttBG:WaitForChild("PetType")
	
	if PetEquipped.Value >= MaxPetEquip.Value then warn(Player.Name .. " max pet equipped!") return false, PetIntData:SetAttribute("Equipped",false), "Max Pet equipped!" end
	if not PlayerHumanoidRootPart then warn("Can't find player HRP") return false,"Can't find player Humanoid!" end
	
	BodyGyro.Parent = PetClone.PrimaryPart
	BodyPosition.Parent = PetClone.PrimaryPart

	PetClone.PrimaryPart.Position = PlayerHumanoidRootPart.Position
	
	PetName.Text = PetIntData.Name
	PetType.Text = PetIntData:GetAttribute("PetType")
	PetType.TextColor3 = Color3.fromRGB(unpack(Config.RarityTypeModule.Type[PetIntData:GetAttribute("PetType")].Color))
	PetCustomName.Text = '"' .. PetIntData:GetAttribute("CustomName") .. '"'
	
	PetClone:SetAttribute("PetID",PetIntData.Value)
	PetIntData:SetAttribute("Equipped",true)
	PetEquipped.Value += 1
	Multiplier.Value += PetIntData:GetAttribute("Multiplier1")
	Multiplier:SetAttribute("PetMultiplier2",Multiplier:GetAttribute("PetMultiplier2") + PetIntData:GetAttribute("Multiplier2"))
	
	PetClone.Parent = PlayerPetFolders:FindFirstChild(Player.Name)
	
	return true,"Successfully Equipped!"
end

function HatchHandler:UnEquipPet(Player,PetIntData)
	local PlayerPetFolder = PlayerPetFolders:FindFirstChild(Player.Name)
	if not PlayerPetFolder then warn(string.format("%s can't find in PlayerPetFolders",Player.Name)) return end

	local leaderstats = Player:WaitForChild("leaderstats")
	local otherstats = Player:WaitForChild("otherstats")

	local PetEquipped = otherstats:WaitForChild("PetEquipped")	
	local Multiplier = otherstats:WaitForChild("PetMultiplier")

	local function lookForPet(CurrentPetIntData)
		for a,b in pairs(PlayerPetFolder:GetChildren()) do
			if b.Name == CurrentPetIntData.Name and b:GetAttribute("PetID") == CurrentPetIntData.Value and CurrentPetIntData:GetAttribute("Equipped") then
				return b
			end
		end
		warn(string.format("%s pet can't find in PlayerPetFolder",PetIntData.Name)) 
		return nil
	end

	local TargetPet = lookForPet(PetIntData)

	if not TargetPet then return false,"There was an error unequipping this pet" end
	if not PetIntData:GetAttribute("Equipped") then return false,"This is already unequipped" end
	if PetEquipped.Value <= 0 then return false,"There was an error unequipping this pet" end
	
	PetIntData:SetAttribute("Equipped",false)
	PetEquipped.Value -= 1
	Multiplier.Value -= PetIntData:GetAttribute("Multiplier1")
	Multiplier:SetAttribute("PetMultiplier2",Multiplier:GetAttribute("PetMultiplier2") - PetIntData:GetAttribute("Multiplier2"))
	TargetPet:Destroy()
	
	return true,"Successfully Unequipped!"
end

function HatchHandler:DeletePet(Player,PetIntData)
	local otherstats = Player:WaitForChild("otherstats")
	local PetStorage = otherstats:WaitForChild("PetStorage")
	
	PetStorage.Value -= 1
	
	if PetIntData:GetAttribute("Equipped") then warn(HatchHandler:UnEquipPet(Player,PetIntData)) end
	PetIntData:Destroy()
	return true,"Successfully Deleted!"
end 

function HatchHandler:RenamePet(Player,PetIntData,CustomName)
	local leaderstats = Player:WaitForChild("leaderstats")
	local Gems = leaderstats:WaitForChild("Gems")
	
	if PetIntData:GetAttribute("Equipped") then warn(HatchHandler:UnEquipPet(Player,PetIntData)) end
	if Gems.Value < 5 then return false,"You need " .. 5 - Gems.Value .. " more gems!" end
	
	local function getTextObject(message, fromPlayerId)
		local FilteredText
		local success, err = pcall(function()
			FilteredText =  TS:FilterStringAsync(message, fromPlayerId)
		end)
		if success then
			return FilteredText
		else
			return ""
		end
	end

	local function extractFilteredText(FilteredTextObject)
		local filteredMessage
		local success, errorMessage = pcall(function()
			filteredMessage = FilteredTextObject:GetNonChatStringForBroadcastAsync()
		end)
		if success then
			return filteredMessage
		else
			return ""
		end
	end

	Gems.Value -= 5
	PetIntData:SetAttribute("CustomName",extractFilteredText(getTextObject(CustomName, Player.UserId)))
	if not PetIntData:GetAttribute("Equipped") then warn(HatchHandler:EquipPet(Player,PetIntData)) end
	
	return true,"Successfully Renamed!"
end

function HatchHandler:UpgradePet(Player,PetIntData)
	local leaderstats = Player:WaitForChild("leaderstats")
	local Gems = leaderstats:WaitForChild("Gems")

	if PetIntData:GetAttribute("Equipped") then warn(HatchHandler:UnEquipPet(Player,PetIntData)) end
	if Gems.Value < (PetIntData:GetAttribute("Level") * Config.PetUpgradeSettings.StartingGemsPrice) then 
		return false,"You need " .. (PetIntData:GetAttribute("Level") * Config.PetUpgradeSettings.StartingGemsPrice) - Gems.Value .. " more gems!" 
	end
	print(((PetIntData:GetAttribute("Level") * (PetIntData:GetAttribute("Level") * Config.PetUpgradeSettings.StartingGemsPrice))))
	Gems.Value -= (PetIntData:GetAttribute("Level") * (PetIntData:GetAttribute("Level") * Config.PetUpgradeSettings.StartingGemsPrice))
	
	PetIntData:SetAttribute("Level",PetIntData:GetAttribute("Level") + 1)
	PetIntData:SetAttribute("Multiplier1" ,PetIntData:GetAttribute("Multiplier1") + (PetIntData:GetAttribute("Multiplier1") * Config.PetUpgradeSettings.PetUpgradeIncrement))
	PetIntData:SetAttribute("Multiplier2" ,PetIntData:GetAttribute("Multiplier2") + (PetIntData:GetAttribute("Multiplier2") * Config.PetUpgradeSettings.PetUpgradeIncrement))
	if not PetIntData:GetAttribute("Equipped") then warn(HatchHandler:EquipPet(Player,PetIntData)) end
	return true,"Successfully Upgraded!"
end


return HatchHandler