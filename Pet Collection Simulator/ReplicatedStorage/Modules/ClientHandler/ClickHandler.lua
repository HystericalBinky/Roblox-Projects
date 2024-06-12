local RS = game:GetService("ReplicatedStorage")
local RSS = game:GetService("RunService")
local MS = game:GetService("MarketplaceService")
local PL = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local Player = PL.LocalPlayer
local PlayerMouse = Player:GetMouse()
local PlayerCamera = workspace.CurrentCamera
local PlayerGui = Player.PlayerGui

local ScreenSize = PlayerCamera.ViewportSize

local leaderstats = Player:WaitForChild("leaderstats")
local Clicks = leaderstats:WaitForChild("Clicks")

local RSEvents = RS:WaitForChild("Events")
local RSModules = RS:WaitForChild("Modules")
local RSMusic = RS:WaitForChild("Sounds")

local ClickSFX = RSMusic:WaitForChild("ClickSFX")

local Config = require(RSModules:WaitForChild("Configuration"))

local PlayerClickEvents = RSEvents:WaitForChild("PlayerClickEvents")

local MainGui = PlayerGui:WaitForChild("MainGui")

local MainFrames = MainGui:WaitForChild("MainFrames")

local BottomFrame = MainFrames:WaitForChild("BottomFrame")
local ClickButton = BottomFrame:WaitForChild("ClickButton")
local Free_AutoClick = BottomFrame:WaitForChild("Free_AutoClick")
local AutoClick = BottomFrame:WaitForChild("AutoClick")

local UserInterfaceHandler = require(script.Parent:WaitForChild("UserInterfaceHandler"))
local NotifyModule = require(RSModules:WaitForChild("NotificationHandler"))
local BackgroundFX = require(RSModules:WaitForChild("BackgroundFX"))
local Short = require(RSModules:WaitForChild("Short"))

local myClickEvent = PlayerClickEvents:WaitForChild(Player.Name)

local ClickHandler = {
	ClickDB = false,
	isFreeAutoClick = false,
	isAutoClick = false,
	storedClicks = 0,
	isOnButton = false
}

function ClickHandler:Init()
	ClickHandler:Listener()
	ClickHandler:freeAutoClickInit()
	ClickHandler:AutoClickInit()
end

function ClickHandler:Listener()
	ClickButton.MouseButton1Down:Connect(function()
		self.isOnButton = true
	end)
	ClickButton.MouseButton1Up:Connect(function()
		ClickHandler:playerClicks()
		self.isOnButton = false
	end)
	UIS.InputBegan:Connect(function(input,isProcessed)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local CursorLocation = {
				x = PlayerMouse.X / MainGui.AbsoluteSize.X,
				y = PlayerMouse.Y / MainGui.AbsoluteSize.Y,
			}
			
			if not self.isOnButton then
				task.spawn(function()
					UserInterfaceHandler.EffectsHandler:TweenClick(CursorLocation)
				end)
				task.spawn(function()
					ClickHandler:playerClicks()
				end)
			end
		end
	end)
	Free_AutoClick.MouseButton1Up:Connect(function()
		if Player:IsInGroup(Config.GroupFeature.GroupID) then
			if not self.isFreeAutoClick and not self.isAutoClick then
				self.isFreeAutoClick = true
				Free_AutoClick.BackgroundColor3 = Config.Colors.Green
			else
				self.isFreeAutoClick = false
				Free_AutoClick.BackgroundColor3 = Config.Colors.White
			end
		else
			NotifyModule:Notify(Config.GroupFeature.AutoClickMSG)
		end

	end)
	AutoClick.MouseButton1Up:Connect(function()	
		if not MS:UserOwnsGamePassAsync(Player.UserId,Config.GamepassID.AutoClick) then 
			MS:PromptGamePassPurchase(Player,Config.GamepassID.AutoClick) 
			BackgroundFX:Toggle(true)
			return 
		end


		if not self.isAutoClick and not self.isFreeAutoClick then
			self.isAutoClick = true
			AutoClick.BackgroundColor3 = Config.Colors.Green
		else
			self.isAutoClick = false
			AutoClick.BackgroundColor3 = Config.Colors.White
		end
	end)
	Clicks:GetPropertyChangedSignal("Value"):Connect(function(s)
		ClickHandler:ClickPop()
	end)
end

function ClickHandler:playerClicks()
	if not self.ClickDB and ClickHandler.isFreeAutoClick == false and ClickHandler.isAutoClick == false then
		self.ClickDB = true
		ClickHandler:Click()
		task.wait(0.1)
		self.ClickDB = false
	end
end

function ClickHandler:freeAutoClickInit()
	task.spawn(function()
		while task.wait(0.33) do
			if self.isFreeAutoClick then
				ClickHandler:Click()
			end
		end
	end)
end

function ClickHandler:AutoClickInit()
	task.spawn(function()
		while task.wait(0.1) do
			if self.isAutoClick then
				ClickHandler:Click()
			end
		end
	end)
end

function ClickHandler:Click()
	ClickSFX:Play()
	myClickEvent:FireServer()
end

function ClickHandler:ClickPop()
	local addedValue = Clicks.Value -  self.storedClicks

	local randomAxis = {
		x = math.random(1,MainGui.AbsoluteSize.X) / MainGui.AbsoluteSize.X,
		y = math.random(1,MainGui.AbsoluteSize.Y) / MainGui.AbsoluteSize.Y
	}

	UserInterfaceHandler.EffectsHandler:TweenPopUps(Short.en(addedValue),randomAxis)

	self.storedClicks = Clicks.Value
end 

return ClickHandler