local PL = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local RSEvents = RS:WaitForChild("Events")
local RSModules = RS:WaitForChild("Modules")

local Config = require(RSModules:WaitForChild("Configuration"))
local CodesRemote = RSEvents:WaitForChild("CodesRemote") --Replace this

local CodesHandler = {}

function CodesHandler:Init()
	CodesHandler:Listener()
end

function CodesHandler:Listener()
	local function CodesRemoteOnServer(Player,InputCode)
		return CodesHandler:CheckCode(Player,InputCode)
	end
	CodesRemote.OnServerInvoke = CodesRemoteOnServer
end

function CodesHandler:CheckCode(Player,InputCode)
	local Code = Config.Codes[string.upper(InputCode)]
	local PlayerCodesFolder = Player:WaitForChild("CodesFolder")
	if Code then
		if not PlayerCodesFolder:FindFirstChild(string.upper(InputCode)) then
			local CodeIns = Instance.new("BoolValue")
			CodeIns.Name,CodeIns.Value,CodeIns.Parent = string.upper(InputCode),true,PlayerCodesFolder
			return CodesHandler:RewardPlayer(Player,Code)
		else
			return false,"❌ This code has been claimed already!"
		end 
	else
		return false,"❌ Code does not exist!"
	end
end

function CodesHandler:RewardPlayer(Player,CodeData)
	local SourceFolder = Player:WaitForChild(CodeData.Source) 
	local Currency = SourceFolder:WaitForChild(CodeData.Currency)
	Currency.Value += CodeData.Prize
	warn(Player.Name .. " received: " .. CodeData.Prize)
	return true,"✅ Redeemed successfully!"
end

return CodesHandler