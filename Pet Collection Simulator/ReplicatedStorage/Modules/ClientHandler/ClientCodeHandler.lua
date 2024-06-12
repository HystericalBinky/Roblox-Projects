local PL = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local CS = game:GetService("CollectionService")

local Player = PL.LocalPlayer
local CodesFolder = Player:WaitForChild("CodesFolder")
local leaderstats = Player:WaitForChild("leaderstats")

local Confetti = require(RS:WaitForChild("Modules"):WaitForChild("Confetti"))

local PlayerGui = Player.PlayerGui

local MainGui = PlayerGui:WaitForChild("MainGui")
local MainFrames = MainGui:WaitForChild("MainFrames")

local CenterFrame = MainFrames:WaitForChild("CenterFrame")
local CenterFrames_ = CenterFrame:WaitForChild('Frames')

local CodesFrame = CenterFrames_:WaitForChild("CodesFrame")
local CodesSubFrame = CodesFrame:WaitForChild("SubFrame")

local VerifyButton = CodesSubFrame:WaitForChild("VerifyButton")
local CodeTextBox = CodesSubFrame:WaitForChild("CodeTextBox")

local RSEvents = RS:WaitForChild("Events")
local RSModules = RS:WaitForChild("Modules")

local Config = require(RSModules:WaitForChild("Configuration"))
local Notify = require(RSModules:WaitForChild("NotificationHandler"))

local CodesRemote = RSEvents:WaitForChild("CodesRemote")

local ClientCodeHandler = {}

function ClientCodeHandler:Init()
	ClientCodeHandler:Listener()
end

function ClientCodeHandler:Listener()
	VerifyButton.MouseButton1Up:Connect(function()
		ClientCodeHandler:CheckCode()
	end)
end

function ClientCodeHandler:CheckCode()
	local CodeRemoteResponse,Message = CodesRemote:InvokeServer(CodeTextBox.Text)
	
	if CodeRemoteResponse then
		Notify:Notify(Message)
		Confetti.Play()
		CodeTextBox.Text = ""
	else
		Notify:Notify(Message)
		CodeTextBox.Text = ""
	end
end


return ClientCodeHandler
