local PL = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RSS = game:GetService("RunService")

local RSModules = RS:WaitForChild("Modules")
local RSEvents = RS:WaitForChild("Events")
local RSTemplates = RS:WaitForChild("Templates")
local RSSounds = RS:WaitForChild("Sounds")

local Confetti = require(RSModules:WaitForChild("Confetti"))

local RightSFX = RSSounds:WaitForChild("RightSFX")
local WrongSFX = RSSounds:WaitForChild("WrongSFX")

local Config = require(RSModules:WaitForChild("Configuration"))

local MinuteGiftRE = RSEvents:WaitForChild("MinuteGiftRemote") --Replace this

local LocalPlayer = PL.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local MainGui = PlayerGui:WaitForChild("MainGui")
local Frames = MainGui:WaitForChild("MainFrames")
local CenterFrame = Frames:WaitForChild("CenterFrame")

local CenterFrames = CenterFrame:WaitForChild("Frames")
local GiftFrame = CenterFrames:WaitForChild("GiftFrame"):WaitForChild("SubFrame"):WaitForChild("GiftListFrame")

local RightFrame = Frames:WaitForChild("RightFrame")
local RightFrameButtons = RightFrame:WaitForChild("Buttons")
local GiftButtons = RightFrameButtons:WaitForChild("Gift")
local GiftCount = GiftButtons:WaitForChild("GiftIcon"):WaitForChild("GiftCount")
local GiftTimeLabel = GiftButtons:WaitForChild("TimeLabel")

local NotificationHandler = require(RSModules:WaitForChild("NotificationHandler"))

local GradientFolder = RSTemplates:WaitForChild("Gradients")

local Seconds = LocalPlayer:WaitForChild("otherstats"):WaitForChild("Seconds") ----Replace this

local TimedGift = {}
local ClaimDB = false
local ClaimedGifts = 0
local leastIndex = 1


function TimedGift:ClientInit()
	TimedGift:LoadGifts()
end

function TimedGift:LoadGifts()
	for a,b in pairs(Config.MinuteGift) do
		local GiftImageTemplate = RSTemplates:WaitForChild("GiftButton"):Clone()
		local GradientColor = GradientFolder:WaitForChild(b.Tier):Clone()
		
		if GiftImageTemplate then
			GradientColor.Parent = GiftImageTemplate
			GiftImageTemplate.Parent = GiftFrame
			GiftImageTemplate:WaitForChild("GiftImage").Image = "rbxassetid://".. b.ImageID
			GiftImageTemplate:WaitForChild("GiftImage"):WaitForChild("CountLabel").Text = "+" .. b.Amount
			GiftImageTemplate:WaitForChild("GiftText").Text = "00:00"
			GiftImageTemplate.LayoutOrder = a
			GiftImageTemplate.Name = tostring(a)
		end
	end
	TimedGift:ActivateTimer()
	TimedGift:ActivateLoadGifts()
end

local function minuteMate(RemainingTime)
	local Minutes = RemainingTime/60
	local Seconds = RemainingTime%60
	return string.format("%02i:%02i", Minutes, Seconds)
end

function TimedGift:getLeastGift()
	for a,b in pairs(Config.MinuteGift) do
		if not b.isClaimed and not b.isReady then
			leastIndex = a
			break
		end
	end
end

function TimedGift:getGiftCount()
	local GiftCount = 0
	for a,b in pairs(Config.MinuteGift) do
		if not b.isClaimed and b.isReady then
			GiftCount += 1
		end
	end
	return GiftCount
end

function TimedGift:ActivateTimer()
	RSS.Heartbeat:Connect(function()
		for a,b in pairs(GiftFrame:GetChildren()) do
			if b:IsA("TextButton") then
				local GiftData = Config.MinuteGift[b.LayoutOrder]
				
				local GiftText = b:WaitForChild("GiftText")
				
				
				
				if GiftData and GiftText then
					if not GiftData.isClaimed then
						local RemainingTime = GiftData.Minutes - Seconds.Value
						if RemainingTime > 0 then
							GiftText.Text = minuteMate(RemainingTime)
						else
							--Color --Replace this
							GiftData.isReady = true
							GiftText.Text = "READY!"
						end
					else
						--Color --Replace this
						GiftText.TextColor3 = Config.Colors.Green
						GiftText.Text = "CLAIMED"
					end
				end
			end
			
		end

		TimedGift:updateGiftCount()
		TimedGift:updateNextGift()

	end)
end

function TimedGift:updateNextGift()
	TimedGift:getLeastGift()
	
	local GiftData = Config.MinuteGift[leastIndex]

	if GiftData then
		local RemainingTime = GiftData.Minutes - Seconds.Value
		GiftTimeLabel.Text = "GIFT IN " .. minuteMate(RemainingTime)
	end
	
	if GiftData.Amount == 50000 and GiftData.isReady == true then
		GiftTimeLabel.Text = "CLAIM GIFT!"
	end
	
	if GiftData.Amount == 50000 and GiftData.isClaimed == true then
		GiftTimeLabel.Text = "GIFTS CLAIMED!"
	end
end

function TimedGift:updateGiftCount()
	TimedGift:getGiftCount()	
	
	if TimedGift:getGiftCount() > 0 then
		GiftCount.Visible = true
		GiftCount.Text = TimedGift:getGiftCount()
	else
		GiftCount.Visible = false
	end
end

function TimedGift:ActivateLoadGifts()
	for a,b in pairs(GiftFrame:GetChildren()) do
		if b:IsA("TextButton") then
			b.MouseButton1Up:Connect(function()
				if not ClaimDB then
					ClaimDB = true
					TimedGift:ClaimGifts(b)
					task.wait(0.3)
					ClaimDB = false
				end
			end)
		end
	end
end

function TimedGift:ClaimGifts(Button)
	local GiftData = Config.MinuteGift[Button.LayoutOrder]
	
	local MinuteGiftSuc,Message = MinuteGiftRE:InvokeServer(Button.LayoutOrder)
	print(MinuteGiftSuc)
	print(Message)
	if not GiftData then return end
	if MinuteGiftSuc then
		ClaimedGifts += 1
		GiftData.isClaimed = true
		RightSFX:Play()
		Confetti.Play()
		NotificationHandler:Notify(Message)
		--NotificationHandler:Notify("✅ You claimed a gift!")
	else
		WrongSFX:Play()
		NotificationHandler:Notify(Message)
		--NotificationHandler:Notify("❎ Wait for the timer to claim your gift!")
	end
end

return TimedGift