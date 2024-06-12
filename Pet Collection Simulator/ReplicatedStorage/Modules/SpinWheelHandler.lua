local PL = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local RSModules = RS:WaitForChild("Modules")
local RSEvents = RS:WaitForChild("Events")
local RSTemplates = RS:WaitForChild("Templates")
local RSSounds = RS:WaitForChild("Sounds")

local Config = require(RSModules:WaitForChild("Configuration"))
local OptiMotion = require(RSModules:WaitForChild("OptiMotion"))

local ClaimSFX = RSSounds:WaitForChild("ClaimSFX")
local SpinWheelSFX = RSSounds:WaitForChild("SpinWheelSFX")

local SpinRE = RSEvents:WaitForChild("SpinRemote")

local Short = require(RSModules:WaitForChild("Short"))

local SpinWheelHandler = {}

function SpinWheelHandler:ClientInit()
	SpinWheelHandler:ClientListener()
end

function SpinWheelHandler:ClientListener()
	local LocalPlayer = PL.LocalPlayer
	local PlayerGui = LocalPlayer.PlayerGui
	local MainGui = PlayerGui:WaitForChild("MainGui") --Replace this
	local Frames = MainGui:WaitForChild("MainFrames")
	local CenterFrame = Frames:WaitForChild("CenterFrame")
	local CenterFrames = CenterFrame:WaitForChild("Frames")
	local SpinFrame = CenterFrames:WaitForChild("SpinsFrame")
	local SpinFrameSub = SpinFrame:WaitForChild("SpinFrame")
	local SpinWheel = SpinFrameSub:WaitForChild("Spin") --Replace this
	local Notify = require(RSModules:WaitForChild("NotificationHandler"))
	
	local SpinButton = SpinFrame:WaitForChild("SpinButton") --Replace this
	
	local isWaitingforSpin = false
	
	SpinWheelHandler:LoadSpinRewards(LocalPlayer, SpinWheel)
	
	local leaderstats = LocalPlayer:WaitForChild("leaderstats")
	local rebirths = leaderstats:WaitForChild("Rebirths")
	
	rebirths.Changed:Connect(function()
		task.wait(0.1)
		SpinWheelHandler:LoadSpinRewards(LocalPlayer, SpinWheel)
	end)
	
	SpinButton.MouseButton1Up:Connect(function()
		
		if not isWaitingforSpin then
			isWaitingforSpin = true
			
			local isSpinREInvoke__,SpinNumber = SpinRE:InvokeServer()
	
			if isSpinREInvoke__ then
				SpinWheelHandler:SpinWheel(LocalPlayer,SpinNumber,SpinWheel)
			else
				Notify:Notify(SpinNumber)
			end
			
			task.wait(0.3)
			isWaitingforSpin = false
		end
		
		if isWaitingforSpin then return end
		
	end)
end

function SpinWheelHandler:LoadSpinRewards(Player, SpinWheel)
	SpinWheel.Rotation = Random.new():NextInteger(0,360)
	
	local leaderstats = Player:WaitForChild("leaderstats")
	local rebirths = leaderstats:WaitForChild("Rebirths")

	for _,b in pairs(SpinWheel:GetChildren()) do
		if not b:IsA("ImageLabel") then continue end
	end

	local circumference = SpinWheel.AbsoluteSize.X * math.pi
	local divNumbers = #Config.SpinWheel

	local absdivWidth = (circumference/divNumbers)
	local divWidth = absdivWidth/SpinWheel.AbsoluteSize.X

	for a,b in pairs(Config.SpinWheel) do
		local PivotDivision = RSTemplates:WaitForChild("SectorPivot"):Clone()
		local textIconRotation = (a-1) * (360/divNumbers)
		
		PivotDivision.Parent = SpinWheel
		PivotDivision.Name = a
		PivotDivision.Sector.Size = UDim2.new(divWidth,0,0.5,0)
		PivotDivision.Rotation = textIconRotation
		if b.Name ~= "Spins" and b.Name ~= "Gems" then
			PivotDivision.Sector.RewardAmount.Text = "x" .. Short.en(math.floor(b.Amount * (1.5 ^ rebirths.Value)))
		else
			PivotDivision.Sector.RewardAmount.Text = "x" .. Short.en(b.Amount)
		end
		PivotDivision.Sector.RewardImage.Image = "rbxassetid://" .. b.Image
		PivotDivision.Sector.ImageColor3 = b.Color
	end
	
end

function SpinWheelHandler:SpinWheel(Player, SpinNumber, SpinWheel)

	local leaderstats = Player:WaitForChild("leaderstats")
	local rebirths = leaderstats:WaitForChild("Rebirths")
	
	local Notify = require(RSModules:WaitForChild("NotificationHandler"))
	
	local SpinData = Config.SpinWheel[SpinNumber]
	local rotationNumber = SpinNumber * 360

	local goalSector = SpinWheel:FindFirstChild(SpinNumber)
	local divRotation = goalSector.Rotation
	rotationNumber += (360 - divRotation) 

	local MotionInfo = {
		Tweeninfo = {3,
			Enum.EasingStyle.Quint,
			Enum.EasingDirection.Out,
			0,
			false,
			1},
		TweenProperty = {
			Position = UDim2.new(0.5,0,0.5,0),
			Rotation = rotationNumber
		},
	}

	OptiMotion:Play(SpinWheel,MotionInfo)
	
	local timePosition = SpinWheelSFX.TimeLength - (MotionInfo.Tweeninfo[1] + MotionInfo.Tweeninfo[6])
	SpinWheelSFX.TimePosition = timePosition
	SpinWheelSFX:Play()

	task.wait(MotionInfo.Tweeninfo[1] + MotionInfo.Tweeninfo[6])
	
	local MSG = "🍀 %s received %s %s!"
	
	if SpinData.Name ~= "Spins" and SpinData.Name ~= "Gems" then
		Notify:Notify(MSG:format(Player.Name, Short.en(math.floor(SpinData.Amount * (1.5 ^ rebirths.Value))), SpinData.Name))
	else
		Notify:Notify(MSG:format(Player.Name, SpinData.Amount, SpinData.Name))
	end
	--Notify
	
	ClaimSFX:Play()
end

function SpinWheelHandler:ServerInit()
	SpinWheelHandler:ServerListener()
end

function SpinWheelHandler:ServerListener()
	
	local function LoadPlayerSpinRewards__(Player)
	end
	
	local function SpinREOnServerEvent__(Player)
		LoadPlayerSpinRewards__(Player)
		local otherstats = Player:WaitForChild("otherstats")
		local Spins = otherstats:WaitForChild("Spins")

		if Spins.Value >= 1 then
			Spins.Value -= 1
			return SpinWheelHandler:Randomize(Player)
		else
			return false,"❌ Not enough spins!"
		end
	end
	
	SpinRE.OnServerInvoke = SpinREOnServerEvent__
end

function SpinWheelHandler:Randomize(Player)
	local ChosenNumber = math.random(1,#Config.SpinWheel)
	return SpinWheelHandler:RewardPlayer(Player,ChosenNumber)
end

function SpinWheelHandler:RewardPlayer(Player,ChosenNumber)
	warn(Player.Name .. "received!")
	print(Config.SpinWheel[ChosenNumber])
	local ChosenReward = Config.SpinWheel[ChosenNumber]
	--Replace this
	
	local leaderstats = Player:WaitForChild("leaderstats")
	local rebirths = leaderstats:WaitForChild("Rebirths")
	
	local SourceFolder = Player:WaitForChild(ChosenReward.Source)
	local Currency = SourceFolder:WaitForChild(ChosenReward.Name)
	
	if ChosenReward.Name ~= "Spins" and ChosenReward.Name ~= "Gems" then
		Currency.Value += math.floor(ChosenReward.Amount * (1.5 ^ rebirths.Value))
		return true,ChosenNumber
		--Give Reward
	else
		Currency.Value += ChosenReward.Amount
		return true,ChosenNumber
		--Give Reward
	end
end

return SpinWheelHandler