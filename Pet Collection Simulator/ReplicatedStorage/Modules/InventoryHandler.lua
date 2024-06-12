local RS = game:GetService("ReplicatedStorage")
local PL = game:GetService("Players")
local TS = game:GetService("TextService")
local RSS = game:GetService("RunService")

local LocalPlayer = PL.LocalPlayer

local RSModules = RS:WaitForChild("Modules")
local RSEvents = RS:WaitForChild("Events")
local RSTemplates = RS:WaitForChild("Templates")
local RSAssets = RS:WaitForChild("Assets")

local Config = require(RSModules:WaitForChild("Configuration"))
local Notify = require(RSModules:WaitForChild("NotificationHandler"))
local Short = require(RSModules:WaitForChild("Short"))

local PetActionRequest = RSEvents:WaitForChild("PetActionRequest")

local leaderstats = LocalPlayer:WaitForChild("leaderstats")
local otherstats = LocalPlayer:WaitForChild("otherstats")
local PetsFolder = LocalPlayer:WaitForChild("Pets")

local PetAssets = RSAssets:WaitForChild("Pets")

local Gems = leaderstats:WaitForChild("Gems")
local PetEquipped = otherstats:WaitForChild("PetEquipped")
local PetStorage = otherstats:WaitForChild("PetStorage")
local MaxPetStorage = otherstats:WaitForChild("MaxPetStorage")
local MaxPetEquip = otherstats:WaitForChild("MaxPetEquip")

-- UI Components
local PlayerGui = LocalPlayer.PlayerGui
local MainGui = PlayerGui:WaitForChild("MainGui")
local MainFrame = MainGui:WaitForChild("MainFrames")
local CenterFrame = MainFrame:WaitForChild("CenterFrame")
local CenterFrame_ = CenterFrame:WaitForChild("Frames")
local PetsFrame = CenterFrame_:WaitForChild("PetsFrame")
local SubPetFrame = PetsFrame:WaitForChild("SubFrame")
local InventoryFrame = SubPetFrame:WaitForChild("InventoryFrame")
local PetStatsFrame = InventoryFrame:WaitForChild("PetStatsFrame")
local PetScrollFrame = InventoryFrame:WaitForChild("ScrollFrame")
local RenameFrame = InventoryFrame:WaitForChild("RenameFrame")
local UpgradeFrame = InventoryFrame:WaitForChild("UpgradeFrame")
local SubPetScrollFrame = PetScrollFrame:WaitForChild("SubFrame")

local PetNameLabel = PetStatsFrame:WaitForChild("PetNameLabel")
local CustomNameLabel = PetStatsFrame:WaitForChild("CustomNameLabel")
local ClickMultiplier = PetStatsFrame:WaitForChild("ClickMultiplier")
local GemsMultiplier = PetStatsFrame:WaitForChild("GemsMultiplier")
local EquipButton = PetStatsFrame:WaitForChild("EquipButton")
local DeleteButton = PetStatsFrame:WaitForChild("DeleteButton")
local RenameButton = PetStatsFrame:WaitForChild("RenameButton")
local EquipButtonLabel = EquipButton:WaitForChild("TextLabel")
local RarityFrame = PetStatsFrame:WaitForChild("Rarity")
local RarityLabel =RarityFrame:WaitForChild("TextLabel")
local ConfirmRename = RenameFrame:WaitForChild("ConfirmRename")
local CancelRename = RenameFrame:WaitForChild("CancelRename")
local RenameTextBox = RenameFrame:WaitForChild("RenameTextBox")
local UpgradeButton = PetStatsFrame:WaitForChild("UpgradeButton")
local CancelUpgrade = UpgradeFrame:WaitForChild("CancelUpgrade")
local ConfirmUpgrade = UpgradeFrame:WaitForChild("ConfirmUpgrade")
local UpgradeCostLabel = UpgradeFrame:WaitForChild("UpgradeCostLabel")

local CountStats = SubPetFrame:WaitForChild("CountStats")
local EquipLabelCount = CountStats:WaitForChild("EquipCount"):WaitForChild("EquipLabel")
local StorageCount = CountStats:WaitForChild("StorageCount"):WaitForChild("StorageLabel") 

local InventoryHandler = {
	CurrentPet = nil
}

function InventoryHandler:Init()
	InventoryHandler:Listener()
end

function InventoryHandler:Listener()
	warn("Inventory initiated!")
	InventoryHandler:UpdatePetInventory()
	InventoryHandler:UpdateInventoryCount()
	PetsFolder.ChildAdded:Connect(function(PetInstance)
		InventoryHandler:UpdatePetInventory()
	end)
	PetsFolder.ChildRemoved:Connect(function(PetInstance)
		warn("A pet just got removed!")
		InventoryHandler:UpdatePetInventory()
	end)
	PetEquipped:GetPropertyChangedSignal("Value"):Connect(function()
		EquipLabelCount.Text = string.format("%i/%i",PetEquipped.Value,MaxPetEquip.Value)
	end)
	PetStorage:GetPropertyChangedSignal("Value"):Connect(function()
		StorageCount.Text = string.format("%i/%i",PetStorage.Value,MaxPetStorage.Value)
	end)
	EquipButton.MouseButton1Up:Connect(function()
		InventoryHandler:EquipSystem()
	end)
	DeleteButton.MouseButton1Up:Connect(function()
		InventoryHandler:DeletePet()
	end)
	RenameButton.MouseButton1Up:Connect(function()
		RenameFrame.Visible = true
		PetScrollFrame.Visible = false
		UpgradeFrame.Visible = false
	end)
	CancelRename.MouseButton1Up:Connect(function()
		RenameFrame.Visible = false
		PetScrollFrame.Visible = true
		RenameTextBox.Text = ""
	end)
	ConfirmRename.MouseButton1Up:Connect(function()
		InventoryHandler:RenamePet()
	end)
	UpgradeButton.MouseButton1Up:Connect(function()
		if not self.CurrentPet then return end
		UpgradeCostLabel.Text = string.format("Costs %s Gems",self.CurrentPet:GetAttribute("Level") * (self.CurrentPet:GetAttribute("Level") * Config.PetUpgradeSettings.StartingGemsPrice))
		UpgradeFrame.Visible = true
		RenameFrame.Visible = false
		PetScrollFrame.Visible = false
	end)
	CancelUpgrade.MouseButton1Up:Connect(function()
		UpgradeFrame.Visible = false
		RenameFrame.Visible = false
		PetScrollFrame.Visible = true
	end)	
	ConfirmUpgrade.MouseButton1Up:Connect(function()
		InventoryHandler:UpgradePet()
	end)
end

function InventoryHandler:UpdateInventoryCount()
	RSS.Heartbeat:Connect(function()
		EquipLabelCount.Text = string.format("%i/%i",PetEquipped.Value,MaxPetEquip.Value)
		StorageCount.Text = string.format("%i/%i",PetStorage.Value,MaxPetStorage.Value)
	end)
end

function InventoryHandler:UpdatePetInventory()
	for a,b in pairs(SubPetScrollFrame:GetChildren()) do
		if not b:IsA("TextButton") then continue end
		b:Destroy()
	end
	
	for a,b in pairs(PetsFolder:GetChildren()) do
		if not b:IsA("StringValue") then continue end
		InventoryHandler:AddPetButton(b)
	end
	
	PetStatsFrame.Visible = false
	RenameFrame.Visible = false
	PetScrollFrame.Visible = true
	
	InventoryHandler:ActivatePetButton()
	InventoryHandler:SortPetInventory()
end

function InventoryHandler:ActivatePetButton()
	for a,b in pairs(SubPetScrollFrame:GetChildren()) do
		if not b:IsA("TextButton") then continue end
		if not b:GetAttribute("PetID") then continue end
		b.MouseButton1Up:Connect(function()
			InventoryHandler:UpdatePetStats(b)
		end)
	end
end

function InventoryHandler:UpdatePetStats(PetButton)
	
	PetStatsFrame.Visible = true
	
	PetNameLabel.Text = PetButton:GetAttribute("PetName")
	CustomNameLabel.Text = string.format('"%s"',PetButton:GetAttribute("CustomName"))
	ClickMultiplier.Text = string.format("x%s",Short.en(PetButton:GetAttribute("Multiplier1")))
	GemsMultiplier.Text = string.format("x%s",Short.en(PetButton:GetAttribute("Multiplier2")))
	
	EquipButton.BackgroundColor3 = PetButton:GetAttribute("Equipped") and Config.Colors.Purple or Config.Colors.Green 
	
	EquipButtonLabel.Text = PetButton:GetAttribute("Equipped") and "Unequip" or "Equip" 
	RarityFrame.BackgroundColor3 = Color3.fromRGB(unpack(Config.RarityTypeModule.Type[PetButton:GetAttribute("PetType")].Color))
	RarityLabel.Text = PetButton:GetAttribute("PetType")
	
	self.CurrentPet = PetButton
	
end

function InventoryHandler:AddPetButton(PetInstance)
	local PetButton = RSTemplates:WaitForChild("PetButton"):Clone()
	local ButtonStroke = PetButton:WaitForChild("UIStroke")
	local PetMult1Label = PetButton:WaitForChild("PetMultiplier")
	local PetView = PetButton:WaitForChild("PetView")
	

	local PetType = PetInstance:GetAttribute("PetType")

	local PetModel = PetAssets:FindFirstChild(PetInstance.Name)
	
	if PetModel then
		local Camera = Instance.new("Camera",PetView)

		local ModelClone = PetModel:Clone()
		local Pos = ModelClone.PrimaryPart.Position

		--PetView.Image = PetInstance:GetAttribute("PetImage")

		PetView.CurrentCamera = Camera

		ModelClone.Parent = PetView
		ModelClone:PivotTo(ModelClone:GetPivot() * CFrame.Angles(0, math.rad(45), 0))
		Camera.CFrame = CFrame.new(Vector3.new(Pos.X + ModelClone.PrimaryPart.Size.X + 2, Pos.Y, Pos.Z), Pos)

		ButtonStroke.Color = Color3.fromRGB(unpack(Config.RarityTypeModule.Type[PetType].Color))
		PetMult1Label.Text = Short.en(PetInstance:GetAttribute("Multiplier1"))
		PetButton.Parent = SubPetScrollFrame
		PetButton:SetAttribute("PetID",PetInstance.Value)
		PetButton:SetAttribute("CustomName",PetInstance:GetAttribute("CustomName"))
		PetButton:SetAttribute("PetName",PetInstance.Name)
		PetButton:SetAttribute("Multiplier1",PetInstance:GetAttribute("Multiplier1"))
		PetButton:SetAttribute("Multiplier2",PetInstance:GetAttribute("Multiplier2"))
		PetButton:SetAttribute("PetType",PetInstance:GetAttribute("PetType"))
		PetButton:SetAttribute("Equipped",PetInstance:GetAttribute("Equipped"))
		PetButton:SetAttribute("Level",PetInstance:GetAttribute("Level"))

		PetButton.BackgroundColor3 = PetButton:GetAttribute("Equipped") and Config.Colors["Pastel Green"] or Config.Colors["Pastel Blue"]
	end

end

function InventoryHandler:SortPetInventory()
	local PetButtons = {}
	for a,b in pairs(SubPetScrollFrame:GetChildren()) do
		if not b:IsA("TextButton") then continue end
		table.insert(PetButtons, {Button = b, MultValue = b:GetAttribute("Multiplier1")})
	end
	
	table.sort(PetButtons, function(a, b)
		return a.MultValue > b.MultValue
	end)
	
	local layoutOrder = 1
	for _, ButtonData in ipairs(PetButtons) do
		local PetButton = ButtonData.Button
		local MultValue = ButtonData.MultValue
		PetButton.LayoutOrder = layoutOrder
		layoutOrder = layoutOrder + 1
	end
end

function InventoryHandler:PetActionRequest____(Action,Params)
	local Success, Message = PetActionRequest:InvokeServer(Action,{PetID = self.CurrentPet:GetAttribute("PetID"),CustomPetName = Params})
	if not Success then Notify:Notify(Message) return false end
	Notify:Notify(Message)
	return true
end

function InventoryHandler:EquipSystem()
	warn("Equipping")
	if not self.CurrentPet then return end
	
	if not self.CurrentPet:GetAttribute("Equipped") then
		if PetEquipped.Value >= MaxPetEquip.Value then Notify:Notify("Max pet equipped!") return end
		local PetActionRequest_Equip = InventoryHandler:PetActionRequest____("Equip")
		if PetActionRequest_Equip then
			self.CurrentPet:SetAttribute("Equipped",true)
			EquipButtonLabel.Text = "Unequip"
			self.CurrentPet.BackgroundColor3 = Config.Colors["Pastel Green"]
			EquipButton.BackgroundColor3 = Config.Colors.Purple	
		end
	else
		local PetActionRequest_Equip = InventoryHandler:PetActionRequest____("Unequip")
		if PetActionRequest_Equip then
			self.CurrentPet:SetAttribute("Equipped",false)
			self.CurrentPet.BackgroundColor3 = Config.Colors["Pastel Blue"]
			EquipButton.BackgroundColor3 = Config.Colors.Green
			EquipButtonLabel.Text = "Equip"
		end
	end
	
	--Fire Remote Function
		--Server Finds the Pet
	--wait for remote func (true or false)
		--Apply Equp & Unequip VFX
end

function InventoryHandler:DeletePet()
	if not self.CurrentPet then return end
	local PetActionRequest_Delete = InventoryHandler:PetActionRequest____("Delete")
	if PetActionRequest_Delete then
		PetStatsFrame.Visible = false
		warn("Successfully Deleted!")
	end
end 

function InventoryHandler:RenamePet()
	if not self.CurrentPet then return end
	if RenameTextBox.Text == "" then Notify:Notify("Enter a valid name!") return end
	if string.len(RenameTextBox.Text) > 10 then Notify:Notify("Must not exceed 10 letters!") RenameTextBox.Text = "" return end
	if Gems.Value < 5 then Notify:Notify("You need " .. 5 - Gems.Value .. " more gems!") RenameTextBox.Text = "" return end

	local PetActionRequest_Rename = InventoryHandler:PetActionRequest____("Rename",RenameTextBox.Text)

	if PetActionRequest_Rename then
		RenameFrame.Visible = false
		PetScrollFrame.Visible = true
		RenameTextBox.Text = ""
		InventoryHandler:UpdatePetInventory()
		warn("Successfully Renamed!")
	end
end

function InventoryHandler:UpgradePet()
	warn("sdasdasd")
	if not self.CurrentPet then return end
	local UpgradePrice = self.CurrentPet:GetAttribute("Level") * (self.CurrentPet:GetAttribute("Level") * Config.PetUpgradeSettings.StartingGemsPrice)

	if Gems.Value < UpgradePrice then Notify:Notify("You need " .. UpgradePrice - Gems.Value .. " more gems!") return end
	
	local PetActionRequest_Upgrade = InventoryHandler:PetActionRequest____("Upgrade")
	
	if PetActionRequest_Upgrade then
		UpgradeFrame.Visible = false
		PetScrollFrame.Visible = true
		InventoryHandler:UpdatePetInventory()
	end
end

--Sorter (Powerful to Weakest)
--Equip and Unequip Features
--Equip Best

return InventoryHandler