local PL = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RSS = game:GetService("RunService")
local CS = game:GetService("CollectionService")
local MS = game:GetService("MarketplaceService")
local UIS = game:GetService("UserInputService")

local LocalPlayer = PL.LocalPlayer 
local PlayerGui = LocalPlayer.PlayerGui

local leaderstats = LocalPlayer:WaitForChild("leaderstats")
local otherstats = LocalPlayer:WaitForChild("otherstats")

local MaxPetStorage = otherstats:WaitForChild("MaxPetStorage")
local PetStorage = otherstats:WaitForChild("PetStorage")

local RSModules = RS:WaitForChild("Modules")
local RSTemplates = RS:WaitForChild("Templates")
local RSEvents = RS:WaitForChild("Events")
local RSSounds = RS:WaitForChild("Sounds")
local RSAssets = RS:WaitForChild("Assets")

local PetsFolder = RSAssets:WaitForChild("Pets")

local RequestEggRemote = RSEvents:WaitForChild("RequestEgg")

local OptiMotion = require(RSModules:WaitForChild("OptiMotion"))
local Notify = require(RSModules:WaitForChild("NotificationHandler"))
local BGFX = require(RSModules:WaitForChild("BackgroundFX"))
local Short = require(RSModules:WaitForChild("Short"))
local Configuration = require(RSModules:WaitForChild("Configuration"))

local EggModule = Configuration.EggModule
local RarityTypeModule = Configuration.RarityTypeModule

local EggPreviewUi = PlayerGui:WaitForChild("EggPreviewUI")
local EggFrame = EggPreviewUi:WaitForChild("EggFrame")
local PriceFrame = EggFrame:WaitForChild("PriceFrame")
local PriceLabel = PriceFrame:WaitForChild("PriceLabel")
local PriceImage = PriceFrame:WaitForChild("PriceImage")
local EggSubFrame = EggFrame:WaitForChild("EggSubFrame"):WaitForChild("ScrollingFrame")
local EggButtons = EggFrame:WaitForChild("EggButtons")

local HatchImageFolder = RSTemplates:WaitForChild("HatchImages")
local HatchGUI = PlayerGui:WaitForChild("HatchGUI")
local HatchFrame = HatchGUI:WaitForChild("HatchFrames")

local MainGui = PlayerGui:WaitForChild("MainGui")

local HatchSFX = RSSounds:WaitForChild("ClaimSFX")

local isHatching = false
local canAutoHatch = false

local EggPreviewHandler = {
	CurrentEgg = nil,
	CurrencyImage = {
		Clicks = "rbxassetid://14415967782",
		Gems = "rbxassetid://14416093199",
		Rebirths = "rbxassetid://14357783055",
		Tokens = "rbxassetid://14576085605",
		Robux = "rbxassetid://14601310897",
		Tix = "rbxassetid://17596029064",
	},
	EggType = nil,
	EggProductID = nil
}

function EggPreviewHandler:Init()
	EggPreviewUi.Enabled = true
	EggPreviewHandler:Listener()
	EggPreviewHandler:InitAutoHatch()
end

function EggPreviewHandler:Listener()
	RSS.Heartbeat:Connect(function()
		EggPreviewHandler:EggPreviewInit2(PL.LocalPlayer.Character)
	end)
	for a,b in pairs(EggButtons:GetChildren()) do
		if not b:IsA("TextButton") then continue end
		b.MouseButton1Up:Connect(function()
			if b.LayoutOrder ~= 1 and self.EggType == "Robux" then return end
			if b:GetAttribute("KeyValue") ~= "Y" then
				EggPreviewHandler:eggRequest(b:GetAttribute("KeyValue"))
			else
				EggPreviewHandler:EnableAutoHatch()
			end
		end)
	end
	UIS.InputEnded:Connect(function(input,isProcessed)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		if self.CurrentEgg == nil then return end 
		if input.KeyCode.Name == "E" then
			EggPreviewHandler:eggRequest(input.KeyCode.Name)
		elseif input.KeyCode.Name == "R"  and self.EggType ~= "Robux" or input.KeyCode.Name == "T" and self.EggType ~= "Robux"  then
			EggPreviewHandler:eggRequest(input.KeyCode.Name)
		elseif input.KeyCode.Name == "Y"  and self.EggType ~= "Robux" then
			EggPreviewHandler:EnableAutoHatch()
		end
	end)
	local function RequestEggListen(isSuccess, Result)
		if isSuccess then
			if Result == nil then Notify:Notify("An error occured!") return end
			EggPreviewHandler:HatchAnimation(Result,"Single")
		end
	end
	RequestEggRemote.OnClientInvoke = RequestEggListen
end

function EggPreviewHandler:EnableAutoHatch()
	if MS:UserOwnsGamePassAsync(LocalPlayer.UserId,Configuration.GamepassID["AutoHatch"]) then
		if not canAutoHatch then
			canAutoHatch = true
		else
			canAutoHatch = false
		end
	else
		MS:PromptGamePassPurchase(LocalPlayer,Configuration.GamepassID["AutoHatch"])
	end
end

function EggPreviewHandler:RequestEggInvoke(HatchCount)
	local isSuccess, Result = RequestEggRemote:InvokeServer(self.CurrentEgg,HatchCount)
	if isSuccess then
		return Result
	elseif not isSuccess and Result then
		Notify:Notify(Result)
		return nil
	end
end

function EggPreviewHandler:InitAutoHatch()
	task.spawn(function()
		while true do
			task.wait(1)
			if canAutoHatch and not isHatching then
				if self.CurrentEgg ~= nil and self.EggType ~= "Robux" then  
					if MS:UserOwnsGamePassAsync(LocalPlayer.UserId,Configuration.GamepassID["x8 Hatch"]) and MS:UserOwnsGamePassAsync(LocalPlayer.UserId,Configuration.GamepassID["x3 Hatch"]) then
						local HatchData = EggPreviewHandler:RequestEggInvoke("Octuple")

						if not HatchData then
							print(self.CurrentEg)
							Notify:Notify("An error occured!") canAutoHatch = false warn("disabled autohatch")
						else
							EggPreviewHandler:HatchAnimation(HatchData,"Octuple")
						end

					elseif MS:UserOwnsGamePassAsync(LocalPlayer.UserId,Configuration.GamepassID["x3 Hatch"]) then
						local HatchData = EggPreviewHandler:RequestEggInvoke("Triple")
						if not HatchData then
							Notify:Notify("An error occured!") canAutoHatch = false warn("disabled autohatch")
						else
							EggPreviewHandler:HatchAnimation(HatchData,"Triple")
						end
					else
						local HatchData = EggPreviewHandler:RequestEggInvoke("Single")
						if not HatchData then
							Notify:Notify("An error occured!") canAutoHatch = false warn("disabled autohatch")
						else
							EggPreviewHandler:HatchAnimation(HatchData,"Single")
						end
					end
				else
					canAutoHatch = false
				end
			end
		end
	end)
end

function EggPreviewHandler:eggRequest(keyPressed)
	if not isHatching then
		if keyPressed == "E" then
			if self.EggType ~= "Robux" then
				local HatchData = EggPreviewHandler:RequestEggInvoke("Single")
				if HatchData == nil then Notify:Notify("An error occured!") return end
				
				EggPreviewHandler:HatchAnimation(HatchData,"Single")
			else
				if not self.EggProductID then return end
				if PetStorage.Value >= MaxPetStorage.Value then Notify:Notify("Maximum Pet Storage!") return end
				MS:PromptProductPurchase(LocalPlayer,self.EggProductID)
			end
		elseif keyPressed == "R" then
			if MS:UserOwnsGamePassAsync(LocalPlayer.UserId,Configuration.GamepassID["x3 Hatch"]) then
				local HatchData = EggPreviewHandler:RequestEggInvoke("Triple")
				if HatchData == nil then Notify:Notify("An error occured!") return end
				EggPreviewHandler:HatchAnimation(HatchData,"Triple")
			else
				MS:PromptGamePassPurchase(LocalPlayer,Configuration.GamepassID["x3 Hatch"])
			end
		elseif keyPressed == "T" then
			if MS:UserOwnsGamePassAsync(LocalPlayer.UserId,Configuration.GamepassID["x3 Hatch"]) then
				if MS:UserOwnsGamePassAsync(LocalPlayer.UserId,Configuration.GamepassID["x8 Hatch"]) then
					local HatchData = EggPreviewHandler:RequestEggInvoke("Octuple")
					if HatchData == nil then Notify:Notify("An error occured!") return end
					EggPreviewHandler:HatchAnimation(HatchData,"Octuple")
				else
					MS:PromptGamePassPurchase(LocalPlayer,Configuration.GamepassID["x8 Hatch"])
				end
			else
				MS:PromptGamePassPurchase(LocalPlayer,Configuration.GamepassID["x3 Hatch"])
			end			
		end
	end
end

function EggPreviewHandler:rotateTween(Image,Rotation)
	local MotionInfo ={
		Tweeninfo = {0.3,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.In,
			2,
			true,
			0},
		TweenProperty = {
			Rotation= Rotation,
		},
	}
	OptiMotion:Play(Image,MotionInfo)
	task.wait(MotionInfo.Tweeninfo[1])
end

function EggPreviewHandler:sizeTween(Image)
	local DefaultSize = Image.Size
	Image.Size = UDim2.new(0,0,0,0)
	Image.Visible = true
	local MotionInfo ={
		Tweeninfo = {1,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out,
			0,
			false,
			0},
		TweenProperty = {
			Size = DefaultSize,
		},
	}
	OptiMotion:Play(Image,MotionInfo)
	task.wait(MotionInfo.Tweeninfo[1])
end

function EggPreviewHandler:HatchAnimation(HatchData,HatchFrameName)
	
	if not HatchData then return end
	warn(HatchData)
	MainGui.Enabled = false
	BGFX:Toggle(true)
	isHatching	 = true
		
	for a,b in pairs(HatchData) do
		task.spawn(function()
			local HatchImage = HatchImageFolder:FindFirstChild(HatchFrameName.."EggHatchImage"):Clone()
			local EggImage = HatchImage:WaitForChild("EggImage")
			local PetImage = HatchImage:WaitForChild("PetImage")
			local PetView = PetImage:WaitForChild("PetView")
			local Camera = Instance.new("Camera",PetView)
			local NameText = PetView:WaitForChild("PetName")
			local RarityText = PetView:WaitForChild("PetRarity")
			
			NameText.Visible = false
			RarityText.Visible = false
			
			NameText.Text = b.PetData.Name
			RarityText.Text = b.PetData.Rarity
			RarityText.TextColor3 = Color3.fromRGB(unpack(Configuration.RarityTypeModule.Type[b.PetData.Rarity].Color))

			local PetModel= PetsFolder:FindFirstChild(b.PetData.Name)
			if PetModel then 
				local ModelClone = PetModel:Clone()
				local Pos = ModelClone.PrimaryPart.Position

				PetView.CurrentCamera = Camera

				ModelClone.Parent = PetView
				ModelClone:PivotTo(ModelClone:GetPivot() * CFrame.Angles(0, math.rad(25), 0))
				Camera.CFrame = CFrame.new(Vector3.new(Pos.X + ModelClone.PrimaryPart.Size.X + 2, Pos.Y, Pos.Z), Pos)

				local LayoutHatchFrame = HatchFrameName == "Single" and HatchFrame:WaitForChild("DefaultHatchFrame") 
					or HatchFrameName == "Triple" and HatchFrame:WaitForChild("DefaultHatchFrame") 
					or HatchFrameName == "Octuple" and HatchFrame:WaitForChild("OctupleHatchFrame") 

				--Set Egg Image ID
				--PetImage.Image = b.PetData.PetImageId
				HatchImage.Parent = LayoutHatchFrame
				EggPreviewHandler:sizeTween(EggImage)
				task.wait(0.5)
				EggPreviewHandler:rotateTween(EggImage,15)
				task.wait(1)
				EggPreviewHandler:rotateTween(EggImage,-15)
				task.wait(1)
				EggImage.Visible = false
				NameText.Visible = true
				RarityText.Visible = true
				--Sparkle FX
				EggPreviewHandler:sizeTween(PetImage)
				HatchSFX:Play()
				EggImage.Visible = false
				task.wait(1.3)
				HatchImage:Destroy()
			end
		end)
	end
	
	task.wait(6.8)
	MainGui.Enabled = true
	isHatching = false
	BGFX:Toggle(false)
end

function EggPreviewHandler:ClosestEgg(Character)
	local CurrentClosest = nil
	local ClosestDistance = Configuration.EggSettings.MaxMagnitude

	if Character then
		local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
		if HumanoidRootPart then
			for a,b in pairs(Configuration.Location.EggFolder:GetChildren()) do
				local EggCenter = b:FindFirstChild("EggCenter")
				if not EggCenter then warn(b.Name) continue end
				local Magnitude = (HumanoidRootPart.Position - EggCenter.Position).Magnitude
				if Magnitude <= ClosestDistance then
					CurrentClosest = b
					ClosestDistance = Magnitude
				end
			end
		end
	end

	return CurrentClosest
end

function EggPreviewHandler:EggPreviewInit2(Character)
	if Character then
		local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
		if HumanoidRootPart then
			local Egg = EggPreviewHandler:ClosestEgg(Character)
			if Egg then
				local CurrentEggInfo = EggModule[Egg.Name]
				
				if CurrentEggInfo then
					
					local EggCenter = Egg:FindFirstChild("EggCenter")
					if EggCenter then
						if self.CurrentEgg == nil then
							canAutoHatch = false
							EggPreviewUi.Enabled = true
							EggPreviewUi.Adornee = EggCenter
							EggPreviewHandler:inTween(EggFrame,true)

							for c,d in pairs(EggSubFrame:GetChildren()) do
								if not d:IsA("ImageLabel") then continue end
								d:Destroy()
							end

							local function EggExtraFeature(isVisible)
								for c,d in pairs(EggButtons:GetChildren()) do
									if not d:IsA("TextButton") then continue end
									if d.LayoutOrder == 1 then continue end
									d.Visible = isVisible
								end
							end

							if CurrentEggInfo.Currency == "Robux" then
								local ProductInfo = MS:GetProductInfo(CurrentEggInfo.ProductId,Enum.InfoType.Product)
								PriceLabel.Text = "R$ " .. ProductInfo.PriceInRobux
								EggExtraFeature(false)
							else
								PriceLabel.Text = Short.en(CurrentEggInfo.Cost)
								EggExtraFeature(true)
							end

							PriceImage.Image = self.CurrencyImage[CurrentEggInfo.Currency]
							self.EggProductID =  CurrentEggInfo.ProductId
							self.EggType = CurrentEggInfo.Currency

							for c,d in pairs(CurrentEggInfo.Pets) do
								local PetImage = RSTemplates:WaitForChild("PetImage"):Clone()
								local PetView = PetImage:WaitForChild("PetView")
								local Camera = Instance.new("Camera",PetView)
								local PetPercent = PetImage:WaitForChild("PetPercent")
								local PetRarity = PetImage:WaitForChild("PetRarity")

								local PetModel= PetsFolder:FindFirstChild(d.Name)
								if not PetModel then continue end
								local ModelClone = PetModel:Clone()
								local Pos = ModelClone.PrimaryPart.Position

								if EggSubFrame:FindFirstChild(d.Name) == nil then
									PetImage.Parent = EggSubFrame
									PetImage.Name = d.Name
									
									PetView.CurrentCamera = Camera

									ModelClone.Parent = PetView
									ModelClone:PivotTo(ModelClone:GetPivot() * CFrame.Angles(0, math.rad(45), 0))
									Camera.CFrame = CFrame.new(Vector3.new(Pos.X + ModelClone.PrimaryPart.Size.X + 2, Pos.Y, Pos.Z), Pos)
									--ModelClone:SetPrimaryPartCFrame(CFrame.new(Pos))


									--PetImage.Image = d.PetImageId
									PetImage.LayoutOrder = RarityTypeModule.Type[d.Rarity].LayoutOrder
									PetRarity.Text = d.Rarity
									PetRarity.TextColor3 = Color3.fromRGB(unpack(RarityTypeModule.Type[d.Rarity].Color))
									PetPercent.Text = d.RarityPercentage .. "%"
									PetPercent.TextColor3 = Color3.fromRGB(unpack(RarityTypeModule.Type[d.Rarity].Color))
									PetImage.ImageColor3 = d.Secret == true and Color3.fromRGB(0,0,0) or d.Secret == false and Color3.fromRGB(255, 255, 255)
								end

	
	
							end

							self.CurrentEgg = Egg
						else
							if self.CurrentEgg ~= Egg then
								self.CurrentEgg = nil
								self.EggType = nil
							end
						end
					end
					

				end

				
				
			else
				if EggPreviewUi then
					canAutoHatch = false
					EggPreviewUi.Enabled = false
					EggPreviewUi.Adornee = nil
					
					for c,d in pairs(EggSubFrame:GetChildren()) do
						if not d:IsA("ImageLabel") then continue end
						d:Destroy()
					end

					self.CurrentEgg = nil
					self.EggType = nil
				end	
			end
		end
	end
end

function EggPreviewHandler:inTween(Frame,isToggle)

	local Size = {
		[true] = UDim2.new(1, 0,1, 0),
		[false] = UDim2.new(0,0,0,0)
	}

	local MotionInfo = {
		Tweeninfo = {
			0.25,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out,
			0,
			false,
			0
		},
		TweenProperty = {
			Size = Size[isToggle],
		},
	}

	Frame.Size = isToggle and Size[not isToggle] or Size[isToggle]
	OptiMotion:Play(Frame,MotionInfo)

end

return EggPreviewHandler