local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local CS = game:GetService("CollectionService")
local SS = game:GetService("ServerStorage")
local PPS = game:GetService("ProximityPromptService")
local PL = game:GetService("Players")
local MS = game:GetService("MarketplaceService")

local RSModules = RS:WaitForChild("Modules")
local RSTemplates = RS:WaitForChild("Templates")
local SSModules = SS:WaitForChild("Modules")
local RSEvents = RS:WaitForChild("Events")

local Config = require(RSModules:WaitForChild("Configuration"))

local PlayerClickEvents = RSEvents:WaitForChild("PlayerClickEvents")
local MinuteGiftRE = RSEvents:WaitForChild("MinuteGiftRemote")
local RebirthsRE = RSEvents:WaitForChild("RebirthRemote")
local TokenConvertRE = RSEvents:WaitForChild("TokenConvertRemote")
local TixConvertRE = RSEvents:WaitForChild("TixConvertRemote")
local BuyUpgradeRE = RSEvents:WaitForChild("BuyUpgradeRemote")

local PetActionRequest = RSEvents:WaitForChild("PetActionRequest")
local RequestUGC = RSEvents:WaitForChild("RequestUGC")

local CodesHandler = require(RSModules:WaitForChild("CodesHandler"))
local SpinWheelModule = require(RSModules:WaitForChild("SpinWheelHandler"))
local UGCSettings = Config.UGCSettings

local LiveLikes = require(SSModules:WaitForChild("LiveLikes"))
local HatchHandler = require(SSModules:WaitForChild("HatchHandler"))

local GameHandler = {
	ClickHandler = require(script:WaitForChild("ClickHandler")),
	SecondsHandler = require(script:WaitForChild("SecondsHandler")),
	RebirthsHandler = require(script:WaitForChild("RebirthsHandler")),
	WorldHandler = require(script:WaitForChild("WorldHandler")),
	TokenConvertHandler = require(script:WaitForChild("TokenConvertHandler")),
	TixConvertHandler = require(script:WaitForChild("TixConvertHandler")),
	UpgradesHandler = require(script:WaitForChild("UpgradesHandler")),
	EggLoader = require(script:WaitForChild("EggLoader")),
	PortalLoader = require(script:WaitForChild("PortalLoader"))
}

function GameHandler:Init()
	GameHandler:Listener()
	CodesHandler:Init()
	GameHandler:initiateLeaderboard()
	SpinWheelModule:ServerInit()
	LiveLikes:Init()
	self.WorldHandler:Init()
	self.EggLoader:LoadEggPrice()
	self.PortalLoader:Load()
end

function GameHandler:initiateLeaderboard() 
	warn("Leaderboard Initialized!")
	for _,v in pairs(CS:GetTagged(Config.Tags.Leaderboards)) do
		local Module = require(v)
		Module:Init()
	end
end

function GameHandler:Listener()
	game.Players.PlayerAdded:Connect(function(Player)
		Player.CharacterAppearanceLoaded:Connect(function(PlayerCharacter)
			local PlayerHumanoid = PlayerCharacter:FindFirstChild("Humanoid")
			if not PlayerHumanoid then return end
			local PlayerHead = PlayerCharacter:FindFirstChild("Head")
			if not PlayerHead then return end
			local PlayerNameTag = RSTemplates:WaitForChild("PlayerNameTag"):Clone()
			local PlayerNameLabel = PlayerNameTag:WaitForChild("PlayerName")
		
			local function isOwn(gamepassID)
				local suc,isOwned = pcall(function()
					warn("Calling GamePass Async")
					MS:UserOwnsGamePassAsync(Player.UserId,gamepassID)
				end)
				if not suc then warn("sd") return false end
				if isOwned then warn("sdasd") return true end
				return false
			end
			
			PlayerNameLabel.TextColor3 = MS:UserOwnsGamePassAsync(Player.UserId,Config.GamepassID.VIP) and Config.Colors.YellowGold or Config.Colors.White
			PlayerNameLabel.Text = MS:UserOwnsGamePassAsync(Player.UserId,Config.GamepassID.VIP) and "[👑] " .. Player.DisplayName or Player.DisplayName
			PlayerNameTag.Adornee = PlayerHead
			PlayerNameTag.Parent = PlayerHead
		end)
		GameHandler:onPlayerAdded(Player)
	end)
	game.Players.PlayerRemoving:Connect(function(Player)
		GameHandler:onPlayerRemoving(Player)
	end)
	
	PPS.PromptTriggered:Connect(function(Prompt,Player)
		local Egg = Prompt.Parent.Parent
		local EggData = Config.EggModule[Egg.Name]
		local HatchCount = 1 --1
		if EggData then
			HatchHandler:BuyPet(Player,Egg,EggData,HatchCount)
		end
	end)
	
	PlayerClickEvents.ChildAdded:Connect(function()
		self.ClickHandler:updateClickEvents()
	end)
	PlayerClickEvents.ChildRemoved:Connect(function()
		self.ClickHandler:updateClickEvents()
	end)
	local function MinuteGiftRE__(Player,Index)
		return GameHandler:GivePlayerGift(Player,Index)
	end
	MinuteGiftRE.OnServerInvoke = MinuteGiftRE__
	
	TokenConvertRE.OnServerEvent:Connect(function(Player,ClickAmount)
		self.TokenConvertHandler:check(Player,ClickAmount)
	end)
	
	TixConvertRE.OnServerEvent:Connect(function(Player,ClickAmount)
		self.TixConvertHandler:check(Player,ClickAmount)
	end)
	
	BuyUpgradeRE.OnServerEvent:Connect(function(Player, TokenAmount, UpgradeType)
		self.UpgradesHandler:check(Player, TokenAmount, UpgradeType)
	end)
	
	local function __actionRequest(Player,Action,Params) return GameHandler:PlayerPetActionRequest(Player,Action,Params) end
	local function __RebirthRemote(Player) return self.RebirthsHandler:checkPlayer(Player) end 
	local function __RequestUGC(Player) return GameHandler:CheckUGC(Player)  end

	RebirthsRE.OnServerInvoke = __RebirthRemote
	PetActionRequest.OnServerInvoke = __actionRequest
	RequestUGC.OnServerInvoke  = __RequestUGC
end

function GameHandler:getPetDataFromPetID(Player,PetID)
	local PetFolder = Player:WaitForChild("Pets")
	for a,b in pairs(PetFolder:GetChildren()) do
		if not b:IsA("StringValue") then continue end
		if b.Value ~= PetID then continue end
		return b
	end
	return nil
end

function GameHandler:CheckUGC(Player)
	local leaderstats = Player:WaitForChild("leaderstats")
	local otherstats = Player:WaitForChild("otherstats")
	
	local TotalClicks = otherstats:WaitForChild("Total Clicks")
	local Rebirths = leaderstats:WaitForChild("Rebirths")
	
	if not Player:IsInGroup(Config.GroupFeature.GroupID) then return false, Config.GroupFeature.UGCMSG end
	if TotalClicks.Value < Config.UGCSettings.ClicksReq then return false, "Not enough clicks, keep playing!" end
	if Rebirths.Value < Config.UGCSettings.RebirthReq then return false, "Not enough Rebirths!" end
	
	MS:PromptPurchase(Player,Config.UGCSettings.UGC_ItemID)
	return true, "⭐ Claim your Free UGC!"
end

function GameHandler:PlayerPetActionRequest(Player,Action,Parameters)
	local PetData = GameHandler:getPetDataFromPetID(Player,Parameters.PetID)
	if not PetData then return false,"Can't find pet!" end
	if Action == "Equip" then
		print(Parameters)
		if PetData:GetAttribute("Equipped") then return false,"You already equipped this pet!" end
		return HatchHandler:EquipPet(Player,PetData)		
	elseif Action == "Unequip" then
		print(Parameters)
		if not PetData:GetAttribute("Equipped") then return false,"You already Unequipped this pet!" end
		return HatchHandler:UnEquipPet(Player,PetData)
	elseif Action == "Delete" then
		print(Parameters)
		return HatchHandler:DeletePet(Player,PetData)
	elseif Action == "Rename" then
		print(Parameters)
		return HatchHandler:RenamePet(Player,PetData,Parameters.CustomPetName)
	elseif Action == "Upgrade" then
		print(Parameters)
		return HatchHandler:UpgradePet(Player,PetData)
	end
end

function GameHandler:GivePlayerGift(Player,Index)
	local otherstats = Player:WaitForChild("otherstats")
	local SecondsINT = otherstats:WaitForChild("Seconds")
	
	local GiftData = Config.MinuteGift[Index]
	if SecondsINT.Value >= GiftData.Minutes then
		if not SecondsINT:GetAttribute(Index) then
			
			local SourceFolder = Player:WaitForChild(GiftData.Source)
			local Currency = SourceFolder:WaitForChild(GiftData.Currency)
			
			Currency.Value += GiftData.Amount
			
			if SourceFolder.Name == "leaderstats" and otherstats:FindFirstChild("Total " ..GiftData.Source) then 
				otherstats:FindFirstChild("Total " .. GiftData.Source).Value += GiftData.Amount
			end
			SecondsINT:SetAttribute(Index,true)
			return true,"✅ You claimed a gift!"
		else
			warn("This gift is already been claimed!")
			return false,"❎ This gift has already been claimed!"
		end
	else
		warn("Ineligible to claim this gift!")
		return false,"❎ Wait for the timer to claim your gift!"
	end
end

function GameHandler:onPlayerAdded(Player)
	
	GameHandler:UpdatePlayerBoost(Player)
	GameHandler:manageClickEvent(Player, true)
	
	self.SecondsHandler:Init(Player)
end

function GameHandler:onPlayerRemoving(Player)
	GameHandler:UpdatePlayerBoost(Player)
	GameHandler:manageClickEvent(Player, false)
end

function GameHandler:manageClickEvent(Player,isCreate)
	if isCreate then
		local PlayerClickRE = Instance.new("RemoteEvent")
		PlayerClickRE.Name = Player.Name
		PlayerClickRE:SetAttribute("UserID",Player.UserId)
		PlayerClickRE:AddTag(Config.Tags.ClickEventTag)
		PlayerClickRE.Parent = PlayerClickEvents
	else
		local PlayerClickRE = PlayerClickEvents:FindFirstChild(Player.Name)
		if not PlayerClickRE then return end
		PlayerClickRE:Destroy()
	end
end

function GameHandler:UpdatePlayerBoost(Player)
	for a,b in pairs(PL:GetPlayers()) do
		local otherstats = b:WaitForChild("otherstats")
		local FriendBoost = otherstats:WaitForChild("Friend Boost")

		FriendBoost.Value = 1

		for c,d in pairs(PL:GetPlayers()) do
			local suc,res = pcall(function()
				return b:IsFriendsWith(d.UserId)
			end)
			if not suc then warn(res) continue end
			FriendBoost.Value += Config.FriendBoost.BoostPerFriend
		end
	end
end


return GameHandler