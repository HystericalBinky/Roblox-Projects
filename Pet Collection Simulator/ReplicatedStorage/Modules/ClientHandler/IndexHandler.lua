local RSS = game:GetService("RunService")
local CS = game:GetService("CollectionService")
local RS = game:GetService("ReplicatedStorage")
local PL = game:GetService("Players")

local Player = PL.LocalPlayer
local leaderstats = Player:WaitForChild("leaderstats")
local Clicks = leaderstats:WaitForChild("Clicks")

local RSModules = RS:WaitForChild("Modules")

local Config = require(RSModules:WaitForChild("Configuration"))
local Short = require(RSModules:WaitForChild("Short"))
local TFM = require(RSModules:WaitForChild("TFMv2"))

local IndexHandler = {}

function IndexHandler:Init()
	IndexHandler:Listener()
end

function IndexHandler:Listener()
	RSS.Heartbeat:Connect(function()
		for _,b in pairs(CS:GetTagged(Config.Tags.Indexes)) do
			IndexHandler:UpdateIndex(b)
		end
		for _,b in pairs(CS:GetTagged(Config.Tags.StatsLabel)) do
			IndexHandler:UpdateStatsIndex(b)
		end
	end)
end

function IndexHandler:UpdateIndex(TextLabel)
	local Source = Player:FindFirstChild(TextLabel:GetAttribute("Source"))
	if not Source then return end
	local Currency = Source:FindFirstChild(TextLabel:GetAttribute("Currency"))
	if not Currency then return end
	local WorldBoostText = "x%s World Boost"
	local FriendBoostText = "+%s%% Friend Boost"
	TextLabel.Text = TextLabel.Name == "Friend" and FriendBoostText:format(math.round((Currency.Value - 1) * 10) / 10) or
		TextLabel.Name == "World" and WorldBoostText:format( math.round((Currency:GetAttribute("Boost")) * 10) / 10 ) or 
		Short.en(Currency.Value)
end

function IndexHandler:UpdateStatsIndex(TextLabel)
	local Source = Player:FindFirstChild(TextLabel:GetAttribute("Source"))
	if not Source then return end
	local Currency = Source:FindFirstChild(TextLabel:GetAttribute("Currency"))
	if not Currency then return end
	local StatsText = "%s: %s"
	TextLabel.Text = Currency.Name == "Time Played" and StatsText:format(Currency.Name,TFM:Convert(Currency.Value, "colon", false)) or StatsText:format(Currency.Name,Short.en(Currency.Value))
end

return IndexHandler