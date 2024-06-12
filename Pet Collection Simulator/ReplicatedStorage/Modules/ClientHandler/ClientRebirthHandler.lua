local ClientRebirthHandler = {
	isAutoRebirth = false
}

local PL = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RSS = game:GetService("RunService")
local MS = game:GetService("MarketplaceService")

local Player = PL.LocalPlayer
local PlayerGui = Player.PlayerGui
local leaderstats = Player:WaitForChild("leaderstats")
local otherstats = Player:WaitForChild("otherstats")
local upgradestats = Player:WaitForChild("upgradestats")

local RSEvents = RS:WaitForChild("Events")
local RSModules = RS:WaitForChild("Modules")

local Rebirths = leaderstats:WaitForChild("Rebirths")
local Clicks = leaderstats:WaitForChild("Clicks")
local GamepassINT = otherstats:WaitForChild("Gamepass")
local PetMultiplier = otherstats:WaitForChild("PetMultiplier")
local RebirthCostUpgrade = upgradestats:WaitForChild("RebirthCost")

local Config = require(RSModules:WaitForChild("Configuration"))
local Notify = require(RSModules:WaitForChild("NotificationHandler"))
local Short = require(RSModules:WaitForChild("Short"))
local BGFX = require(RSModules:WaitForChild("BackgroundFX"))
local Confetti = require(RSModules:WaitForChild("Confetti"))
local RebirthRemote = RSEvents:WaitForChild("RebirthRemote")

local MainGui = PlayerGui:WaitForChild("MainGui")
local MainFrames = MainGui:WaitForChild("MainFrames")

local CenterFrame = MainFrames:WaitForChild("CenterFrame")
local RightFrame = MainFrames:WaitForChild("RightFrame")

local CenterFrames_ = CenterFrame:WaitForChild('Frames')
local RightFrameButtons = RightFrame:WaitForChild("Buttons")

local AutoRebirth = RightFrameButtons:WaitForChild("AutoRebirth")

local RebirthsFrame = CenterFrames_:WaitForChild("RebirthsFrame")

local RebirthSubFrame = RebirthsFrame:WaitForChild("SubFrame")
local RebirthButton = RebirthSubFrame:WaitForChild("RebirthButton")
local RebirthDescLabel = RebirthSubFrame:WaitForChild("RebirthDesc")

local GemsDesc = RebirthSubFrame:WaitForChild("GemsDesc")
local RebirthPriceLabel = RebirthSubFrame:WaitForChild("Price"):WaitForChild("PriceLabel")

function ClientRebirthHandler:Init()
	ClientRebirthHandler:Listener()
	ClientRebirthHandler:autoRebirthInit()
	ClientRebirthHandler:updateRebirthFrame()
end

function ClientRebirthHandler:autoRebirthInit()
	Clicks:GetPropertyChangedSignal("Value"):Connect(function()
		if not self.isAutoRebirth then return end
		local RebirthData = Config.RebirthSettings
		local RebirthPrice = ((RebirthData.RebirthPrice * (1.5 ^ Rebirths.Value)) * RebirthData.PriceMultiplier) * RebirthCostUpgrade.Value
		if Clicks.Value >= RebirthPrice then
			ClientRebirthHandler:checkRebirth()
		end

	end)
end

function ClientRebirthHandler:updateRebirthFrame()
	RSS.Heartbeat:Connect(function()
		local RebirthData = Config.RebirthSettings
		local RebirthPrice = ((RebirthData.RebirthPrice * (1.5 ^ Rebirths.Value)) * RebirthData.PriceMultiplier) * RebirthCostUpgrade.Value
		RebirthPriceLabel.Text  = Short.en(RebirthPrice)
		
		local DescMSG = "You will have %s Rebirths after rebirthing!"
		local GemsMSG = "You will receive +%s Gems!"
		
		RebirthDescLabel.Text = DescMSG:format(Short.en((Rebirths.Value + GamepassINT:GetAttribute("RebirthGamepass"))))
		GemsDesc.Text = GemsMSG:format(Short.en(((((RebirthData.BaseGems * Rebirths.Value) * RebirthData.PriceMultiplier) + PetMultiplier:GetAttribute("PetMultiplier2")) * GamepassINT:GetAttribute("GemsGamepass"))))
			--((RebirthData.BaseGems * Rebirths.Value) * PetMultiplier:GetAttribute("PetMultiplier2")) * GamepassINT:GetAttribute("GemsGamepass")))
		if Clicks.Value >= RebirthPrice then
			RebirthButton.BackgroundColor3 = Config.Colors.Green
		else
			RebirthButton.BackgroundColor3 = Config.Colors.Red
		end
		
	end)
end

function ClientRebirthHandler:Listener()
	RebirthButton.MouseButton1Up:Connect(function()
		ClientRebirthHandler:checkRebirth()
	end)
	AutoRebirth.MouseButton1Up:Connect(function()
		if not self.isAutoRebirth then
		
			if not MS:UserOwnsGamePassAsync(Player.UserId,Config.GamepassID.AutoRebirth) then 
				Notify:Notify("❎ You don't own Auto Rebirth Gamepass!") 
				BGFX:Toggle(true)
				MS:PromptGamePassPurchase(Player,Config.GamepassID.AutoRebirth)
				return 
			end
			
			self.isAutoRebirth = true
			AutoRebirth.BackgroundColor3 = Config.Colors.Green
		else
			self.isAutoRebirth = false
			AutoRebirth.BackgroundColor3 = Config.Colors.Red
		end
	end)
end

function ClientRebirthHandler:checkRebirth(isFromAuto)
	local Suc,Msg = RebirthRemote:InvokeServer()
	
	if not Suc then Notify:Notify(Msg) return end
	Notify:Notify(Msg)
	Confetti.Play()
end

return ClientRebirthHandler