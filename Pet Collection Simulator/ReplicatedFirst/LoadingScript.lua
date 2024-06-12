local Player = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")

local TweenService = game:GetService('TweenService')
local StarterGUI = game:GetService('StarterGui')

local ContentProvider = game:GetService('ContentProvider')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

if not UserInputService.WindowFocused then
	UserInputService.WindowFocused:Wait()
end

local GameName="Pet Legends Simulator!"
local function setup()
	local setup_successful,error_settingup = pcall(function()
		script.Parent:RemoveDefaultLoadingScreen()
		if not game:IsLoaded() then
			game.Loaded:Wait()
		end
		local GUI=script:WaitForChild('LoadingScreen')
		local function start_settings()
			--[[]]--
			local tries=10
			repeat 
				local success,E=pcall(function()
					StarterGUI:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
					StarterGUI:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
					StarterGUI:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
					StarterGUI:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
				end)
				tries=tries-1
				wait()
			until tries<1 or success
		end
		local function preload()
			local LoadingAssets=game.StarterGui:GetDescendants()
			local Loaded=0
			repeat wait() until Player:FindFirstChild('PlayerGui')
			GUI.Frame.TextLabel.Text=GameName
			GUI.Frame.TextLabel.TextTransparency=1
			GUI.Frame.TextLabel.Position=UDim2.new(0.231,0,0.35,0)
			GUI.Frame.Bar.Fill.Size=UDim2.new(0.1,0,0,0)
			GUI.Frame.Percentage.Text="0%"
			GUI.Frame.Assets.Text="Assets Loaded: 0/"..#LoadingAssets
			GUI.Parent=Player.PlayerGui
			delay(1,function()
				TweenService:Create(GUI.Frame.TextLabel,TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0),{TextTransparency=0,Position=UDim2.new(0.231,0,0.386,0)}):Play()
			end)
			for i = 1, #LoadingAssets do 
				local asset = LoadingAssets[i]
				ContentProvider:PreloadAsync({asset})
				Loaded=Loaded+1
				GUI.Frame.Assets.Text="Assets Loaded: "..Loaded.."/"..#LoadingAssets
				local XSize=Loaded/#LoadingAssets
				if XSize<0.1 then XSize=0.1 end
				GUI.Frame.Percentage.Text=math.floor((XSize*100)+0.5).."%"
				TweenService:Create(GUI.Frame.Bar.Fill,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0),{Size=UDim2.new(XSize,0,1,0)}):Play()
			end
			task.wait(2)
			local Fade=GUI.Fade
			local A=TweenService:Create(Fade,TweenInfo.new(0.75,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0),{BackgroundTransparency=0})
			A.Completed:Connect(function()
				StarterGUI:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
				StarterGUI:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
				GUI.Frame:Destroy()
				local B=TweenService:Create(Fade,TweenInfo.new(0.75,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0),{BackgroundTransparency=1})
				B:Play()
				B.Completed:Connect(function()
					GUI:Destroy()
					print("Loading Completed")
				end)
			end)
			A:Play()
		end
		start_settings()		
		preload()
	end)
end

setup()