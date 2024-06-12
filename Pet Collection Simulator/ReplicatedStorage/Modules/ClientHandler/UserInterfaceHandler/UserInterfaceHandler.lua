local PL = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RSS = game:GetService("RunService")
local CS = game:GetService("CollectionService")
local SSER = game:GetService("SocialService")
local MS = game:GetService("MarketplaceService")

local Player = PL.LocalPlayer

local PlayerGui = Player.PlayerGui

local RSModules = RS:WaitForChild("Modules")
local RSMusic = RS:WaitForChild("Sounds")

local ButtonSFX = RSMusic:WaitForChild("ButtonSFX")

local Config = require(RSModules:WaitForChild("Configuration"))
local NotificationHandler = require(RSModules:WaitForChild("NotificationHandler"))
local BackgroundFX = require(RSModules:WaitForChild("BackgroundFX"))
local EffectsHandler = require(script:WaitForChild("EffectsHandler"))

local MainGui = PlayerGui.MainGui
local Frames = MainGui:WaitForChild("MainFrames")


local CenterFrame = Frames:WaitForChild("CenterFrame"):WaitForChild("Frames")

local UserInterfaceHandler = {
	isHovering = false,
	EffectsHandler = require(script:WaitForChild("EffectsHandler"))
}

function UserInterfaceHandler:Init()
	UserInterfaceHandler:Listener()
end

function UserInterfaceHandler:Listener()

	MS.PromptGamePassPurchaseFinished:Connect(function()
		BackgroundFX:Toggle(false)
	end)
	
	
	for _,b in pairs(CS:GetTagged(Config.Tags.Button)) do
		if b:IsA("TextButton") or b:IsA("ImageButton") then
			local defaultSize = b.Size
			local scalePercentage = Config.Animation.Buttons.ScalePercent

			local hoverSize = UDim2.new(defaultSize.X.Scale * scalePercentage,0, defaultSize.Y.Scale * scalePercentage,0)
			
			b.MouseEnter:Connect(function()
				self.isHovering = true
				EffectsHandler:TweenButton(b,hoverSize)
			end)
			b.MouseLeave:Connect(function()
				self.isHovering = true
				EffectsHandler:TweenButton(b,defaultSize)
			end)
			b.MouseButton1Down:Connect(function()
				EffectsHandler:TweenButton(b,defaultSize)
			end)
			b.MouseButton1Up:Connect(function()
				--Animation
				ButtonSFX:Play()
				if not self.isHovering then
					EffectsHandler:TweenButton(b,defaultSize)
				else
					EffectsHandler:TweenButton(b,hoverSize)
				end
				
				if b:HasTag(Config.Tags.MenuButtons) then
					UserInterfaceHandler:manageMenu(b)
				end
				
			end)
		end
	end
	for _,b in pairs(CS:GetTagged(Config.Tags.ExitButton)) do
		if b:IsA("TextButton") or b:IsA("ImageButton") then
			b.MouseButton1Up:Connect(function()
				BackgroundFX:Toggle(false)
				EffectsHandler:TweenFrame(b.Parent,false)
			end)
		end
	end
end

function UserInterfaceHandler:manageMenu(Button)
	local TargetFrame = CenterFrame:FindFirstChild(Button.Name.."Frame")
	if TargetFrame then
		for _,b in pairs(CenterFrame:GetChildren()) do
			if b:IsA("Frame") then
				if b.Name ~= TargetFrame.Name and b.Visible then
					EffectsHandler:TweenFrame(b,false)
					--b.Visible = false
				end
			end
		end

		if not TargetFrame.Visible then
			--Animation On
			BackgroundFX:Toggle(true)
			EffectsHandler:TweenFrame(TargetFrame,true)
			
			--TargetFrame.Visible = true
		else
			--Animation Off
			BackgroundFX:Toggle(false)
			EffectsHandler:TweenFrame(TargetFrame,false)
			--TargetFrame.Visible = false
		end
	elseif Button.Name == "Invite" then
		UserInterfaceHandler:invitePrompt()
	end	
end

function UserInterfaceHandler:invitePrompt()
	local inviteOptions = Instance.new("ExperienceInviteOptions")
	inviteOptions.PromptMessage = "Invite more friends to get more Friend Boost!"

	local success, canSend = pcall(function()
		return SSER:CanSendGameInviteAsync(Player)
	end)

	if not success or not canSend then return end

	local success, errorMessage = pcall(function()
		SSER:PromptGameInvite(Player,inviteOptions)
	end)

	if errorMessage then NotificationHandler:Notify(errorMessage) end
	BackgroundFX:Toggle(true)
	
	
	SSER.GameInvitePromptClosed:Connect(function()
		--Remove Blur
		BackgroundFX:Toggle(false)
	end)
end

return UserInterfaceHandler