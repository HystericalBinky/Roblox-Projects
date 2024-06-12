local RS = game:GetService("ReplicatedStorage")
local PL = game:GetService("Players")

local Player = PL.LocalPlayer

local PlayerGui = Player.PlayerGui
local MainGui = PlayerGui:WaitForChild("MainGui")

local RSModules = RS:WaitForChild("Modules")
local RSTemplates = RS:WaitForChild("Templates")

local Config = require(RSModules:WaitForChild("Configuration"))
local OptiMotion = require(RSModules:WaitForChild("OptiMotion"))

local EffectsHandler = {}

function EffectsHandler:TweenFrame(Frame,isVisible)
	local Sizes = {
		[true] = UDim2.new(0.47, 0,1.412, 0),
		[false] = UDim2.new(0,0,0,0)
	}
	
	local MotionInfo = {
		Tweeninfo = {Config.Animation.UserInterface.Duration,
			Config.Animation.UserInterface.EasingStyle,
			Config.Animation.UserInterface.EasingDirection,
			Config.Animation.UserInterface.RepeatCount,
			Config.Animation.UserInterface.Reverse,
			Config.Animation.UserInterface.DelayTime},
		TweenProperty = {
			Size = Sizes[isVisible],
			Position = UDim2.new(0.5,0,0.5,0),
			Visible = isVisible,
		},
	}
	
	local SetDefault = isVisible and Sizes[false] or not isVisible and Sizes[true]
	Frame.Size = SetDefault
	OptiMotion:Play(Frame,MotionInfo)
end

function EffectsHandler:TweenButton(Button,Size)
	local MotionInfo = {
		Tweeninfo = {Config.Animation.Buttons.Duration,
			Config.Animation.Buttons.EasingStyle,
			Config.Animation.Buttons.EasingDirection,
			Config.Animation.Buttons.RepeatCount,
			Config.Animation.Buttons.Reverse,
			Config.Animation.Buttons.DelayTime},
		TweenProperty = {
			Size = Size,
		},
	}
	OptiMotion:Play(Button,MotionInfo)
end

function EffectsHandler:TweenPopUps(Clicks,Position)
	
	local ClickPop = RSTemplates:WaitForChild("ClickPop"):Clone()
	local ClickLabel = ClickPop:WaitForChild("ClickLabel")
	
	local TweenIn = {
		Tweeninfo = {Config.Animation.ClickPopups.Duration,
			Config.Animation.ClickPopups.EasingStyle,
			Config.Animation.ClickPopups.EasingDirection,
			Config.Animation.ClickPopups.RepeatCount,
			Config.Animation.ClickPopups.Reverse,
			Config.Animation.ClickPopups.DelayTime},
		TweenProperty = {
			Position = UDim2.new(Position.x,0,Position.y,0),
			GroupTransparency = 0
		},
	}
	
	local TweenOut = {
		Tweeninfo = {Config.Animation.ClickPopupsOut.Duration,
			Config.Animation.ClickPopupsOut.EasingStyle,
			Config.Animation.ClickPopupsOut.EasingDirection,
			Config.Animation.ClickPopupsOut.RepeatCount,
			Config.Animation.ClickPopupsOut.Reverse,
			Config.Animation.ClickPopupsOut.DelayTime},
		TweenProperty = {
			Size = UDim2.new(0,0,0,0),
			GroupTransparency = 1
		},
	}
	
	ClickLabel.Text = string.format("+%s",Clicks)
	ClickPop.GroupTransparency = 1
	ClickPop.Position = UDim2.new(Position.x,0,Position.y + 0.1,0)
	ClickPop.Parent = MainGui
	
	OptiMotion:Play(ClickPop,TweenIn)
	
	task.wait(TweenIn.Tweeninfo[1])
	
	OptiMotion:Play(ClickPop,TweenOut)
	
	task.wait(TweenOut.Tweeninfo[1])
	
	ClickPop:Destroy()
end

function EffectsHandler:TweenClick(Mouse)
	local ClickFX = RSTemplates:WaitForChild("ClickFX"):Clone()
	local Main = ClickFX:WaitForChild("Main")
	
	local BGTweenIn = {
		Tweeninfo = {Config.Animation.ClickFX.Duration,
			Config.Animation.ClickFX.EasingStyle,
			Config.Animation.ClickFX.EasingDirection,
			Config.Animation.ClickFX.RepeatCount,
			Config.Animation.ClickFX.Reverse,
			Config.Animation.ClickFX.DelayTime},
		TweenProperty = {
			Size = UDim2.new(1,0,1,0),
			Transparency = 1
		},
	}
	
	ClickFX.Parent = MainGui
	ClickFX.Position = UDim2.new(Mouse.x,0,Mouse.y,0)
	
	OptiMotion:Play(Main,BGTweenIn)
	
	task.wait(BGTweenIn.Tweeninfo[1])
	
	ClickFX:Destroy()
end

return EffectsHandler