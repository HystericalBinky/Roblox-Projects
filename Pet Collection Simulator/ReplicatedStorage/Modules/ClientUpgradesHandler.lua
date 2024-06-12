local PL = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local CS = game:GetService("CollectionService")

local Player = PL.LocalPlayer
local CodesFolder = Player:WaitForChild("CodesFolder")
local leaderstats = Player:WaitForChild("leaderstats")
local upgradestats = Player:WaitForChild("upgradestats")

local Tokens = leaderstats:WaitForChild("Tokens")

local ClickMultiplier = upgradestats:WaitForChild("ClickMultiplier")
local ExtraEquips = upgradestats:WaitForChild("ExtraEquips")
local ExtraStorage = upgradestats:WaitForChild("ExtraStorage")
local RebirthCost = upgradestats:WaitForChild("RebirthCost")

local PlayerGui = Player.PlayerGui

local MainGui = PlayerGui:WaitForChild("MainGui")
local MainFrames = MainGui:WaitForChild("MainFrames")

local CenterFrame = MainFrames:WaitForChild("CenterFrame")
local CenterFrames_ = CenterFrame:WaitForChild('Frames')

local UpgradesFrame = CenterFrames_:WaitForChild("UpgradesFrame")
local UpgradesSubFrame = UpgradesFrame:WaitForChild("SubFrame")

local UpgradesList = UpgradesSubFrame:WaitForChild("ScrollingFrame"):WaitForChild("Frame")
local ClickUpgrade = UpgradesList:WaitForChild("ClickUpgradeFrame")
local EquipUpgrade = UpgradesList:WaitForChild("EquipUpgradeFrame")
local RebirthUpgrade = UpgradesList:WaitForChild("RebirthUpgradeFrame")
local StorageUpgrade = UpgradesList:WaitForChild("StorageUpgradeFrame")

local ClickPurchaseBTn = ClickUpgrade:WaitForChild("PurchaseButton")
local EquipPurchaseBTn = EquipUpgrade:WaitForChild("PurchaseButton")
local RebirthPurchaseBTn = RebirthUpgrade:WaitForChild("PurchaseButton")
local StoragePurchaseBTn = StorageUpgrade:WaitForChild("PurchaseButton")

local ClickUpgradeCounter = ClickUpgrade:WaitForChild("UpgradeCounter")
local EquipUpgradeCounter = EquipUpgrade:WaitForChild("UpgradeCounter")
local RebirthUpgradeCounter = RebirthUpgrade:WaitForChild("UpgradeCounter")
local StorageUpgradeCounter = StorageUpgrade:WaitForChild("UpgradeCounter")

local ClickUpgradePrice = 0
local EquipUpgradePrice = 0
local RebirthUpgradePrice = 0
local StorageUpgradePrice = 0

local RSEvents = RS:WaitForChild("Events")
local RSModules = RS:WaitForChild("Modules")

local Confetti = require(RSModules:WaitForChild("Confetti"))
local Short = require(RS:WaitForChild("Modules"):WaitForChild("Short"))
local InventoryHandler = require(RSModules:WaitForChild("InventoryHandler"))
local ClientRebirthHandler = require(RSModules:WaitForChild("ClientHandler"):WaitForChild("ClientRebirthHandler"))
local NotificationHandler = require(RSModules:WaitForChild("NotificationHandler"))
local Config = require(RSModules:WaitForChild("Configuration"))
local BGFX = require(RSModules:WaitForChild("BackgroundFX"))
local Notify = require(RSModules:WaitForChild("NotificationHandler"))
local ClientHandler = require(RSModules:WaitForChild("ClientHandler"):WaitForChild("UserInterfaceHandler"))
local EffectsHandler = ClientHandler.EffectsHandler

local BuyUpgradeRemote = RSEvents:WaitForChild("BuyUpgradeRemote")
local UpgradeSuccess = RSEvents:WaitForChild("UpgradeSuccess")
local UpgradeFail = RSEvents:WaitForChild("UpgradeFail")

local RightSFX = RS:WaitForChild("Sounds"):WaitForChild("RightSFX")
local WrongSFX = RS:WaitForChild("Sounds"):WaitForChild("WrongSFX")

PurchaseRequestDebounce = false

local ClientUpgradesHandler = {}

function ClientUpgradesHandler:Prompt()
	BGFX:Toggle(true)
	EffectsHandler:TweenFrame(UpgradesFrame,true)
end

function ClientUpgradesHandler:UpdatePrice()
	-- Click Upgrade
	if ClickMultiplier.Value == 1 then
		ClickUpgradePrice = 995000
		ClickPurchaseBTn.TextLabel.Text = Short.en(ClickUpgradePrice)
	elseif ClickMultiplier.Value == 1.33 then
		ClickUpgradePrice = 167500000000
		ClickPurchaseBTn.TextLabel.Text = Short.en(ClickUpgradePrice)
	elseif ClickMultiplier.Value == 1.66 then
		ClickUpgradePrice = 1295000000000
		ClickPurchaseBTn.TextLabel.Text = Short.en(ClickUpgradePrice)
	elseif ClickMultiplier.Value == 1.99 then
		ClickUpgradePrice = math.huge
		ClickPurchaseBTn.TextLabel.Text = "MAX"
		ClickPurchaseBTn.Interactable = false
	end
	
	-- Equip Upgrade
	if ExtraEquips.Value == 0 then
		EquipUpgradePrice = 365000000000
		EquipPurchaseBTn.TextLabel.Text = Short.en(EquipUpgradePrice)
	elseif ExtraEquips.Value == 1 then
		EquipUpgradePrice = math.huge
		EquipPurchaseBTn.TextLabel.Text = "MAX"
		EquipPurchaseBTn.Interactable = false
	end
	
	-- Rebirth Upgrade
	if RebirthCost.Value == 1 then
		RebirthUpgradePrice = 500000000
		RebirthPurchaseBTn.TextLabel.Text = Short.en(RebirthUpgradePrice)
	elseif RebirthCost.Value == 0.9 then
		RebirthUpgradePrice = 15000000000
		RebirthPurchaseBTn.TextLabel.Text = Short.en(RebirthUpgradePrice)
	elseif RebirthCost.Value == 0.8 then
		RebirthUpgradePrice = math.huge
		RebirthPurchaseBTn.TextLabel.Text = "MAX"
		RebirthPurchaseBTn.Interactable = false
	end
	
	-- Storage Upgrade
	if ExtraStorage.Value == 0 then
		StorageUpgradePrice = 2250000
		StoragePurchaseBTn.TextLabel.Text = Short.en(StorageUpgradePrice)
	elseif ExtraStorage.Value == 5 then
		StorageUpgradePrice = 673000000
		StoragePurchaseBTn.TextLabel.Text = Short.en(StorageUpgradePrice)
	elseif ExtraStorage.Value == 10 then
		StorageUpgradePrice = 14000000000
		StoragePurchaseBTn.TextLabel.Text = Short.en(StorageUpgradePrice)
	elseif ExtraStorage.Value == 15 then
		StorageUpgradePrice = 338000000000
		StoragePurchaseBTn.TextLabel.Text = Short.en(StorageUpgradePrice)
	elseif ExtraStorage.Value == 20 then
		StorageUpgradePrice = math.huge
		StoragePurchaseBTn.TextLabel.Text = "MAX"
		StoragePurchaseBTn.Interactable = false
	end
	
	ClientUpgradesHandler:UpdateCount()
end

function ClientUpgradesHandler:UpdateCount()
	-- Click Upgrade
	if ClickMultiplier.Value == 1 then
		
	elseif ClickMultiplier.Value == 1.33 then
		ClickUpgradeCounter:WaitForChild("1").BackgroundColor3 = Config.Colors.Green
	elseif ClickMultiplier.Value == 1.66 then
		ClickUpgradeCounter:WaitForChild("1").BackgroundColor3 = Config.Colors.Green
		ClickUpgradeCounter:WaitForChild("2").BackgroundColor3 = Config.Colors.Green
	elseif ClickMultiplier.Value == 1.99 then
		ClickUpgradeCounter:WaitForChild("1").BackgroundColor3 = Config.Colors.Green
		ClickUpgradeCounter:WaitForChild("2").BackgroundColor3 = Config.Colors.Green
		ClickUpgradeCounter:WaitForChild("3").BackgroundColor3 = Config.Colors.Green
	end
	
	-- Equip Upgrade
	if ExtraEquips.Value == 0 then
		
	elseif ExtraEquips.Value == 1 then
		EquipUpgradeCounter:WaitForChild("1").BackgroundColor3 = Config.Colors.Green
	end
	
	-- Rebirth Upgrade
	if RebirthCost.Value == 1 then
		
	elseif RebirthCost.Value == 0.9 then
		RebirthUpgradeCounter:WaitForChild("1").BackgroundColor3 = Config.Colors.Green
	elseif RebirthCost.Value == 0.8 then
		RebirthUpgradeCounter:WaitForChild("1").BackgroundColor3 = Config.Colors.Green
		RebirthUpgradeCounter:WaitForChild("2").BackgroundColor3 = Config.Colors.Green
	end
	
	-- Storage Upgrade
	if ExtraStorage.Value == 0 then
		
	elseif ExtraStorage.Value == 5 then
		StorageUpgradeCounter:WaitForChild("1").BackgroundColor3 = Config.Colors.Green
	elseif ExtraStorage.Value == 10 then
		StorageUpgradeCounter:WaitForChild("1").BackgroundColor3 = Config.Colors.Green
		StorageUpgradeCounter:WaitForChild("2").BackgroundColor3 = Config.Colors.Green
	elseif ExtraStorage.Value == 15 then
		StorageUpgradeCounter:WaitForChild("1").BackgroundColor3 = Config.Colors.Green
		StorageUpgradeCounter:WaitForChild("2").BackgroundColor3 = Config.Colors.Green
		StorageUpgradeCounter:WaitForChild("3").BackgroundColor3 = Config.Colors.Green
	elseif ExtraStorage.Value == 20 then
		StorageUpgradeCounter:WaitForChild("1").BackgroundColor3 = Config.Colors.Green
		StorageUpgradeCounter:WaitForChild("2").BackgroundColor3 = Config.Colors.Green
		StorageUpgradeCounter:WaitForChild("3").BackgroundColor3 = Config.Colors.Green
		StorageUpgradeCounter:WaitForChild("4").BackgroundColor3 = Config.Colors.Green
	end
end

ClickPurchaseBTn.MouseButton1Up:Connect(function()
	if PurchaseRequestDebounce == false then
		PurchaseRequestDebounce = true
		if Tokens.Value >= ClickUpgradePrice then
			BuyUpgradeRemote:FireServer(ClickUpgradePrice, 1)
		else
			WrongSFX:Play()
			NotificationHandler:Notify("❎ You don't have enough for this upgrade!")
		end
		wait(0.5)
		PurchaseRequestDebounce = false
	end
end)

EquipPurchaseBTn.MouseButton1Up:Connect(function()
	if PurchaseRequestDebounce == false then
		PurchaseRequestDebounce = true
		if Tokens.Value >= EquipUpgradePrice then
			BuyUpgradeRemote:FireServer(EquipUpgradePrice, 2)
		else
			WrongSFX:Play()
			NotificationHandler:Notify("❎ You don't have enough for this upgrade!")
		end
		wait(0.5)
		PurchaseRequestDebounce = false
	end
end)

RebirthPurchaseBTn.MouseButton1Up:Connect(function()
	if PurchaseRequestDebounce == false then
		PurchaseRequestDebounce = true
		if Tokens.Value >= RebirthUpgradePrice then
			BuyUpgradeRemote:FireServer(RebirthUpgradePrice, 3)
		else
			WrongSFX:Play()
			NotificationHandler:Notify("❎ You don't have enough for this upgrade!")
		end
		wait(0.5)
		PurchaseRequestDebounce = false
	end
end)

StoragePurchaseBTn.MouseButton1Up:Connect(function()
	if PurchaseRequestDebounce == false then
		PurchaseRequestDebounce = true
		if Tokens.Value >= StorageUpgradePrice then
			BuyUpgradeRemote:FireServer(StorageUpgradePrice,4)
		else
			WrongSFX:Play()
			NotificationHandler:Notify("❎ You don't have enough for this upgrade!")
		end
		wait(0.5)
		PurchaseRequestDebounce = false
	end
end)

UpgradeSuccess.OnClientEvent:Connect(function(Player)
	InventoryHandler.UpdateInventoryCount()
	ClientRebirthHandler.updateRebirthFrame()
	RightSFX:Play()
	Confetti.Play()
	NotificationHandler:Notify("✅ You bought a upgrade!")
end)

UpgradeFail.OnClientEvent:Connect(function(Player)
	WrongSFX:Play()
	NotificationHandler:Notify("❎ You don't have enough for this upgrade!")
end)

return ClientUpgradesHandler