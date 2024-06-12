local PL = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local CS = game:GetService("CollectionService")

local Player = PL.LocalPlayer
local CodesFolder = Player:WaitForChild("CodesFolder")
local leaderstats = Player:WaitForChild("leaderstats")

local Clicks = leaderstats:WaitForChild("Clicks")

local PlayerGui = Player.PlayerGui

local MainGui = PlayerGui:WaitForChild("MainGui")
local MainFrames = MainGui:WaitForChild("MainFrames")

local CenterFrame = MainFrames:WaitForChild("CenterFrame")
local CenterFrames_ = CenterFrame:WaitForChild('Frames')

local TokenFrame = CenterFrames_:WaitForChild("TokenFrame")
local TokenSubFrame = TokenFrame:WaitForChild("SubFrame")

local ConvertBTn = TokenSubFrame:WaitForChild("ConvertBTn")
local TokenTextBox = TokenSubFrame:WaitForChild("TokenTextBox")
local TokenDesc = TokenSubFrame:WaitForChild("TokenDesc")

local RSEvents = RS:WaitForChild("Events")
local RSModules = RS:WaitForChild("Modules")

local Short = require(RSModules:WaitForChild("Short"))

local Config = require(RSModules:WaitForChild("Configuration"))
local BGFX = require(RSModules:WaitForChild("BackgroundFX"))
local Notify = require(RSModules:WaitForChild("NotificationHandler"))
local ClientHandler = require(RSModules:WaitForChild("ClientHandler"):WaitForChild("UserInterfaceHandler"))
local EffectsHandler = ClientHandler.EffectsHandler

local TokenConvertRemote = RSEvents:WaitForChild("TokenConvertRemote")
local ClientTokenHandler = {}

local canConvert = false
local clickAmount = 0

function ClientTokenHandler:Init()
	ConvertBTn.MouseButton1Up:Connect(function()
		if canConvert and Clicks.Value >= tonumber(TokenTextBox.Text) then
			TokenConvertRemote:FireServer(clickAmount)
			TokenDesc.Text = "Convert 0 Clicks to 0 Tokens?"
			TokenTextBox.Text = ""
			canConvert = false
			clickAmount = 0
		end
	end)
	TokenTextBox.FocusLost:Connect(function()
		ClientTokenHandler:UpdateText()
	end)
end

function ClientTokenHandler:Prompt()
	BGFX:Toggle(true)
	EffectsHandler:TweenFrame(TokenFrame,true)
end

function ClientTokenHandler:UpdateText()
	if tonumber(TokenTextBox.Text) then
		if Clicks.Value >= tonumber(TokenTextBox.Text) then
			local ClickPreview = Short.en(tonumber(TokenTextBox.Text))
			local TokenPreview = Short.en(tonumber(TokenTextBox.Text) / 2)
			local MSG = "Convert " .. ClickPreview .. " Clicks to " .. TokenPreview .. " Tokens?"
			local TokenValue = math.floor(tonumber(TokenTextBox.Text)/2)
			TokenDesc.Text = MSG:format(TokenTextBox.Text,TokenValue)
			canConvert = true
			clickAmount = tonumber(TokenTextBox.Text)
		else
			canConvert = false
			clickAmount = 0
			TokenTextBox.Text = ""
			Notify:Notify("⚠️ Input a valid amount!")
		end 
	else
		canConvert = false
		clickAmount = 0
		TokenTextBox.Text = ""
		Notify:Notify("⚠️ Input numbers only!")
	end
end

return ClientTokenHandler