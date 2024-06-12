local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local modules = ReplicatedStorage:WaitForChild("Modules")
local health = require(modules:WaitForChild("Health"))

local gold = Players.LocalPlayer:WaitForChild("Gold")
local events = ReplicatedStorage:WaitForChild("Events")
local functions = ReplicatedStorage:WaitForChild("Functions")
local requestTowerFunction = functions:WaitForChild("RequestTower")
local towers = ReplicatedStorage:WaitForChild("Towers")
local spawnTowerEvent = events:WaitForChild("SpawnTower")
local noTowerArea = game.Workspace.UnderwaterRuins.NoTowerArea
local camera = workspace.CurrentCamera
local gui = script.Parent
local map = workspace:WaitForChild("UnderwaterRuins")
local base = map:WaitForChild("Base")
local info = workspace:WaitForChild("Info")

local towerToSpawn = nil
local canPlace = false
local rotation = 0
local placedTowers = 0
local maxTowers = 20

local function SetupGui()
	health.Setup(base, gui.Info.Health.HealthBar)

	info.Wave.Changed:Connect(function(change)
		gui.Info.Health.HealthBar.Wave.Text = "Wave " .. change
	end)

	gold.Changed:Connect(function(change)
		gui.Gold.Text = "$" .. gold.Value
	end)
	gui.Gold.Text = "$" .. gold.Value
end

SetupGui()

local function MouseRaycast(blacklist)
	local mousePosition = UserInputService:GetMouseLocation()
	local mouseRay = camera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
	local raycastParams = RaycastParams.new()
	
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = blacklist
	
	local raycastResult = workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 1000, raycastParams)
	
	return raycastResult
end

local function RemovePlaceholderTower()
	if towerToSpawn then
		towerToSpawn:Destroy()
		towerToSpawn = nil
		rotation = 0
	end
	for i, object in ipairs(noTowerArea:GetDescendants()) do
		if object:IsA("BasePart") then
			object.Transparency = 1
		end
	end
end

local function AddPlaceholderTower(name)
	local towerExists = towers:FindFirstChild(name)
	if towerExists then
		RemovePlaceholderTower()
		towerToSpawn = towerExists:Clone()
		towerToSpawn.Parent = workspace
		
		for i, object in ipairs(towerToSpawn:GetDescendants()) do
			if object:IsA("BasePart") then
				object.CollisionGroup = "Tower"
				object.Material = Enum.Material.ForceField
			end
		end
	end
end

local function ColorPlaceholderTower(color)
	for i, object in ipairs(towerToSpawn:GetDescendants()) do
		if object:IsA("BasePart") then
			object.Color = color
		end
	end
end

gui.Title.Text = "" .. placedTowers .. "/" .. maxTowers

for i, tower in pairs(towers:GetChildren()) do
	local button = gui.Towers.Template:Clone()
	local config = tower:WaitForChild("Config")
	button.Name = tower.Name
	button.Image = config.Image.Texture
	button.Visible = true
	button.LayoutOrder = config.Price.Value
	button.Price.Text = "$" .. config.Price.Value
	button.Parent = gui.Towers
	
	button.Activated:Connect(function()
		local allowedToSpawn = requestTowerFunction:InvokeServer(tower.Name)
		if allowedToSpawn then
			AddPlaceholderTower(tower.Name)
		end
	end)
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	
	if towerToSpawn then
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if canPlace then
				spawnTowerEvent:FireServer(towerToSpawn.Name, towerToSpawn.PrimaryPart.CFrame)
				placedTowers += 1
				gui.Title.Text = "" .. placedTowers .. "/" .. maxTowers

				RemovePlaceholderTower()
			end
		elseif input.KeyCode == Enum.KeyCode.R then
			rotation += 90
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if towerToSpawn then
		local result = MouseRaycast({towerToSpawn})
		if result and result.Instance then
			if result.Instance.Parent.Name == "TowerArea" then
				canPlace = true
				ColorPlaceholderTower(Color3.new(0,1,0))
				for i, object in ipairs(noTowerArea:GetDescendants()) do
					if object:IsA("BasePart") then
						object.Transparency = 0.5
					end
				end
			else
				canPlace = false
				ColorPlaceholderTower(Color3.new(1,0,0))
				for i, object in ipairs(noTowerArea:GetDescendants()) do
					if object:IsA("BasePart") then
						object.Transparency = 0.5
					end
				end
			end
			local x = result.Position.X
			local y = result.Position.Y  + towerToSpawn["Left Leg"].Size.Y + (towerToSpawn.PrimaryPart.Size.Y/2)
			local z = result.Position.Z

			local CFrame = CFrame.new(x,y,z) * CFrame.Angles(0, math.rad(rotation), 0)
			towerToSpawn:SetPrimaryPartCFrame(CFrame)
		end
	end
end)