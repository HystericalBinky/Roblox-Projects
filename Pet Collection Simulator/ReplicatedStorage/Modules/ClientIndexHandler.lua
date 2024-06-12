local ClientIndexHandler = {}

local RS = game:GetService("ReplicatedStorage")
local PL = game:GetService("Players")

local Player = PL.LocalPlayer

local indexstats = Player.indexstats

local RSModules = RS:WaitForChild("Modules")

local Basic = Color3.fromRGB(35, 203, 41)
local Uncommon = Color3.fromRGB(85, 255, 255)
local Rare = Color3.fromRGB(254, 5, 9)
local Epic = Color3.fromRGB(98, 46, 164)
local Legendary = Color3.fromRGB(243, 142, 29)
local Mythical = Color3.fromRGB(213, 94, 217)
local Divine = Color3.fromRGB(250, 246, 5)
local Immortal = Color3.fromRGB(11, 1, 117)
local Limited = Color3.fromRGB(70, 0, 138)
local Event = Color3.fromRGB(5, 250, 144)

local allpetscount = 0

function ClientIndexHandler:GetAllPetsCount()
	allpetscount = 0
	local children = Player.PlayerGui.MainGui.MainFrames.CenterFrame.Frames.IndexFrame.SubFrame.PetsFrame.ScrollFrame.SubFrame:GetDescendants()
	for _, child in children do
		if child:IsA("TextButton") then
			allpetscount += 1
		end
	end
end

function ClientIndexHandler:Init()
	local model = RS.Assets.Pets:GetDescendants()
	for _, desc in model do
		if desc:IsA("Model") and desc.Parent:IsA("Model") == false then
			local pet = desc
			local clonedPet = pet:Clone()

			local indexframe = RS.Templates.PetIndex:Clone()
			indexframe.Parent = Player.PlayerGui.MainGui.MainFrames.CenterFrame.Frames.IndexFrame.SubFrame.PetsFrame.ScrollFrame.SubFrame

			clonedPet.Parent = indexframe.PetView
			indexframe.PetName.Text = clonedPet.Name

			for _, setting in clonedPet:GetDescendants() do
				if setting:IsA("Folder") then
					local rarity = setting.Rarity.Value
					local egg = setting.Egg.Value
					local petorder = setting.PetOrder.Value
					if rarity == "Basic" then 
						-- This grabs the rarity from the pet if you have custom raritys copy the line of code and paste it and change the values arround
						indexframe.BackgroundColor3 = Basic
						indexframe.LayoutOrder = (1 * 1000) + (egg * 10) + petorder
					elseif rarity == "Uncommon" then
						indexframe.BackgroundColor3 = Uncommon
						indexframe.LayoutOrder = (2 * 1000) + (egg * 10) + petorder
					elseif rarity == "Rare" then
						indexframe.BackgroundColor3 = Rare
						indexframe.LayoutOrder = (3 * 1000) + (egg * 10) + petorder
					elseif rarity == "Epic" then
						indexframe.BackgroundColor3 = Epic
						indexframe.LayoutOrder = (4 * 1000) + (egg * 10) + petorder
					elseif rarity == "Legendary" then
						indexframe.BackgroundColor3 = Legendary
						indexframe.LayoutOrder = (5 * 1000) + (egg * 10) + petorder
					elseif rarity == "Mythical" then
						indexframe.BackgroundColor3 = Mythical
						indexframe.LayoutOrder = (6 * 1000) + (egg * 10) + petorder
					elseif rarity == "Divine" then
						indexframe.BackgroundColor3 = Divine
						indexframe.LayoutOrder = (7 * 1000) + (egg * 10) + petorder
					elseif rarity == "Immortal" then
						indexframe.BackgroundColor3 = Immortal
						indexframe.LayoutOrder = (8 * 1000) + (egg * 10) + petorder
					elseif rarity == "Limited" then
						indexframe.BackgroundColor3 = Limited
						indexframe.LayoutOrder = (9 * 1000) + (egg * 10) + petorder
					elseif rarity == "Event" then
						indexframe.BackgroundColor3 = Event
						indexframe.LayoutOrder = (10 * 1000) + (egg * 10) + petorder
					end
				end
			end

			local pos = clonedPet.PrimaryPart.Position
			local camera = Instance.new("Camera")
			indexframe.PetView.CurrentCamera = camera
			clonedPet:PivotTo(clonedPet:GetPivot() * CFrame.Angles(0, math.rad(45), 0))
			camera.CFrame = CFrame.new(Vector3.new(pos.X + clonedPet.PrimaryPart.Size.X + 2, pos.Y, pos.Z), pos)

			indexframe.Name = clonedPet.Name
			
			self.GetAllPetsCount()
			
			local petcount = Player.PlayerGui.MainGui.MainFrames.CenterFrame.Frames.IndexFrame.SubFrame.CountStats.PetCount:WaitForChild("CountLabel")
			petcount.Text = #Player.indexstats:GetChildren() .. "/" .. allpetscount
			
			if indexstats:FindFirstChild(clonedPet.Name) then
				indexframe.PetView.ImageColor3 = Color3.fromRGB(255, 255, 255)
				indexframe.UnownedText.Visible = false
			else
				indexframe.PetView.ImageColor3 = Color3.fromRGB(24, 24, 24)
				indexframe.UnownedText.Visible = true
			end
		end
	end
end

function ClientIndexHandler:Update()
	local model = RS.Assets.Pets:GetDescendants()
	
	self.GetAllPetsCount()
	
	local petcount = Player.PlayerGui.MainGui.MainFrames.CenterFrame.Frames.IndexFrame.SubFrame.CountStats.PetCount:WaitForChild("CountLabel")
	petcount.Text = #Player.indexstats:GetChildren() .. "/" .. allpetscount
	
	for _, desc in model do
		if desc:IsA("Model") and desc.Parent:IsA("Model") == false then
			local indexframe = Player.PlayerGui.MainGui.MainFrames.CenterFrame.Frames.IndexFrame.SubFrame.PetsFrame.ScrollFrame.SubFrame:FindFirstChild(desc.Name)
			if indexstats:FindFirstChild(desc.Name) then
				indexframe.PetView.ImageColor3 = Color3.fromRGB(255, 255, 255)
				indexframe.UnownedText.Visible = false
			else
				indexframe.PetView.ImageColor3 = Color3.fromRGB(24, 24, 24)
				indexframe.UnownedText.Visible = true
			end
		end
	end
end

return ClientIndexHandler