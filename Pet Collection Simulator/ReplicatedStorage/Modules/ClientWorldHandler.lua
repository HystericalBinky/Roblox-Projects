local RS = game:GetService("ReplicatedStorage")
local CS = game:GetService("CollectionService")
local PL = game:GetService("Players")
local WS = game:GetService("Workspace")
local MS = game:GetService("MarketplaceService")

local RSModules = RS:WaitForChild("Modules")
local RSEvents = RS:WaitForChild("Events")

local Config = require(RSModules:WaitForChild("Configuration"))
local Notify = require(RSModules:WaitForChild("NotificationHandler"))
local BackgroundFX = require(RSModules:WaitForChild("BackgroundFX"))
local TeleportRemote = RSEvents:WaitForChild("TeleportRemote")
local EffectsHandler = require(RSModules:WaitForChild("ClientHandler")).UIHandler.EffectsHandler

local LocalPlayer = PL.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local MainGui = PlayerGui:WaitForChild("MainGui")
local CenterFrame = MainGui:WaitForChild("MainFrames"):WaitForChild("CenterFrame")
local CenterFrames = CenterFrame:WaitForChild("Frames")
local TeleportFrame = CenterFrames:WaitForChild("TeleportFrame")
local SubFrame = TeleportFrame:WaitForChild("SubFrame")

local UnlockWorldBTN = SubFrame:WaitForChild("UnlockWorldBTN")

local leaderstats = LocalPlayer:WaitForChild("leaderstats")
local worldstats = LocalPlayer:WaitForChild("worldstats")
local Rebirths = leaderstats:WaitForChild("Rebirths")

local ClientWorldHandler = {}

local targetWorldPurchase = nil

function ClientWorldHandler:Init()

	ClientWorldHandler:Listener()
end

function ClientWorldHandler:Listener()

	TeleportRemote.OnClientEvent:Connect(function(WorldName)
		--Check Portal Type
		targetWorldPurchase = nil
		local WorldData = Config.Worlds[WorldName]
		
		if not WorldData then return end
		if WorldData.Type == 'Currency' then
			
			local Source = LocalPlayer:FindFirstChild(WorldData.Source)
			if not Source then return end
			local Currency = Source:FindFirstChild(WorldData.Currency)
			if not Currency then return end
			local PriceNote = "⚠️ You need %s more %s to unlock this world!!"
			local RemainingPrice = WorldData.Price - Currency.Value
			if Currency.Value < WorldData.Price then Notify:Notify(PriceNote:format(RemainingPrice,WorldData.Currency)) return end
			
			if not worldstats:FindFirstChild(WorldName) then
				
				local CodeDesc = SubFrame:WaitForChild("CodesDesc")
				
				local MSG = "Are you sure you want to buy this area for %s %s?"
				
				CodeDesc.Text = MSG:format(WorldData.Price,WorldData.Currency)
				targetWorldPurchase = WorldName
				BackgroundFX:Toggle(true)
				EffectsHandler:TweenFrame(TeleportFrame,true)
			else
				local MSG = "✅ You already unlocked %s!"
				Notify:Notify(MSG:format(WorldName))
			end

			
			
			print("prompt portal purchase")
		elseif  WorldData.Type == 'Rebirths' then
			local MSG = "❌ You need %s more Rebirths to unlock this!"
			local RemainingRB = WorldData.Price - Rebirths.Value
			Notify:Notify(MSG:format(RemainingRB))
		elseif WorldData.Type == 'Gamepass' then
			local MSG = "❌ You need to own %s gamepass to unlock this area!"
			local GamepassInfo = MS:GetProductInfo(WorldData.Id,Enum.InfoType.GamePass)
			Notify:Notify(MSG:format(GamepassInfo.Name))
			BackgroundFX:Toggle(true)
			MS:PromptGamePassPurchase(LocalPlayer,WorldData.Id)
		end
		
		
		--if clicks, gems, tokens, then prompt purchase -> triggered -> pass to server
		
		--if rebirths then notify that they dont have enough rebirth
		
		--if gamepass then prompt purchase

		
	
	end)
	UnlockWorldBTN.MouseButton1Up:Connect(function()
		if not targetWorldPurchase then return end
		if not Config.Worlds[targetWorldPurchase] then return end
		TeleportRemote:FireServer(targetWorldPurchase)
		BackgroundFX:Toggle(false)
		EffectsHandler:TweenFrame(TeleportFrame,false)
	end)
end

function ClientWorldHandler:Teleport(HitPart)
	local Player = PL:GetPlayerFromCharacter(HitPart.Parent)
	if Player then
		
	end
end

return ClientWorldHandler