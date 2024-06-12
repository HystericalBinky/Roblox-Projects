local PL = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local MS = game:GetService("MarketplaceService")

local RSModules = RS:WaitForChild("Modules")

local Config = require(RSModules:WaitForChild("Configuration"))

local GamepassHandler = {}

function GamepassHandler:UpdateGamepassFeatures(Player)
	--Here work here!
	local otherstats = Player:WaitForChild("otherstats")
	local upgradestats = Player:WaitForChild("upgradestats")
	local GamepassINT = otherstats:WaitForChild("Gamepass")
	local MaxPetStorage = otherstats:WaitForChild("MaxPetStorage")
	local MaxPetEquip = otherstats:WaitForChild("MaxPetEquip")
	local ExtraEquipsUpgrade = upgradestats:WaitForChild("ExtraEquips")
	local ExtraStorageUpgrade = upgradestats:WaitForChild("ExtraStorage")

	local function isOwned(GamepassID)
		local suc,isOwned = pcall(function()
			return MS:UserOwnsGamePassAsync(Player.UserId,GamepassID)
		end)
		if not suc then return end
		return isOwned
	end

	GamepassINT:SetAttribute("ClickGamepass",isOwned(Config.GamepassID["x4 Click"]) and 4
		or isOwned(Config.GamepassID["x2 Click"]) and 2
		or Player.MembershipType == Enum.MembershipType.Premium and 1.5
		or isOwned(Config.GamepassID["VIP"]) and 3
		or 1)

	GamepassINT:SetAttribute("RebirthGamepass",isOwned(Config.GamepassID["x2Rebirths"]) and 2
		or 1)

	GamepassINT:SetAttribute("GemsGamepass",isOwned(Config.GamepassID["x2Gems"]) and 2
		or 1)

	MaxPetStorage.Value = isOwned(Config.GamepassID["100Pets"]) and 150 + ExtraStorageUpgrade.Value
		or isOwned(Config.GamepassID["50Pets"]) and 65 + ExtraStorageUpgrade.Value
		or 30 + ExtraStorageUpgrade.Value

	MaxPetEquip.Value = isOwned(Config.GamepassID["8Equip"]) and isOwned(Config.GamepassID["5Equip"]) and 8 + ExtraEquipsUpgrade.Value
		or isOwned(Config.GamepassID["5Equip"]) and 5 + ExtraEquipsUpgrade.Value
		or 4 + ExtraEquipsUpgrade.Value

	if isOwned(Config.GamepassID.VIP) then MaxPetStorage.Value += 10 end
	if Player:IsInGroup(Config.GroupFeature.GroupID) then GamepassINT:SetAttribute("ClickGamepass",GamepassINT:GetAttribute("ClickGamepass") + 1)  end
end

return GamepassHandler