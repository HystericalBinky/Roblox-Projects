local PL = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LocalPlayer = PL.LocalPlayer

local RSTemplates = RS:WaitForChild("Templates")
local RSModules = RS:WaitForChild("Modules")

local OptiMotion = require(RSModules:WaitForChild("OptiMotion"))
local Config = require(RSModules:WaitForChild("Configuration"))

local PlayerGUI = LocalPlayer.PlayerGui

local MainGUI = PlayerGUI:WaitForChild("MainGui")
local MainFrames = MainGUI:WaitForChild("MainFrames")
local NotificationFrame = MainFrames:WaitForChild("NotificationFrame")

local NotificationHandler = {}

function NotificationHandler:Notify(Message)
	local NotifationContainer = RSTemplates:WaitForChild("NotifationContainer"):Clone()
	local DonationNotif = NotifationContainer:WaitForChild("NotifationText")
	local DefaultSize = NotifationContainer.Size
	DonationNotif.Text = Message
	NotifationContainer.Parent = NotificationFrame
	NotifationContainer.Size = UDim2.new(0,0,0,0)

	local TweenIn = {
		Tweeninfo = {
			Config.Animation.Notification_In.Duration,
			Config.Animation.Notification_In.EasingStyle,
			Config.Animation.Notification_In.EasingDirection,
			Config.Animation.Notification_In.RepeatCount,
			Config.Animation.Notification_In.Reverse,
			Config.Animation.Notification_In.DelayTime},
		TweenProperty = {
			Size = DefaultSize,
		}
	}

	local TweenOut = {
		Tweeninfo = {
			Config.Animation.Notification_Out.Duration,
			Config.Animation.Notification_Out.EasingStyle,
			Config.Animation.Notification_Out.EasingDirection,
			Config.Animation.Notification_Out.RepeatCount,
			Config.Animation.Notification_Out.Reverse,
			Config.Animation.Notification_Out.DelayTime},
		TweenProperty = {
			GroupTransparency = 1,
		}
	}


	task.spawn(function()
		--Tween In
		OptiMotion:Play(NotifationContainer,TweenIn)
		task.wait(2)
		OptiMotion:Play(NotifationContainer,TweenOut)
		task.wait(TweenOut.Tweeninfo[1])
		NotifationContainer:Destroy()
	end)

end

return NotificationHandler