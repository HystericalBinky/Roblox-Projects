local PhysicsService = game:GetService("PhysicsService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local events = ReplicatedStorage:WaitForChild("Events")
local spawnTowerEvent = events:WaitForChild("SpawnTower")
local animateTowerEvent = events:WaitForChild("AnimateTower")
local functions = ReplicatedStorage:WaitForChild("Functions")
local requestTowerFunction = functions:WaitForChild("RequestTower")

local maxTowers = 20
local tower = {}

function FindNearestTarget(newTower, range)
	local nearestTarget = nil

	for i, target in ipairs(workspace.Mobs:GetChildren()) do
		local distance = (target.HumanoidRootPart.Position - newTower.HumanoidRootPart.Position).Magnitude
		if distance < range then
			nearestTarget = target
			range = distance
		end
	end

	return nearestTarget
end

function tower.Attack(newTower, player)
	local config = newTower.Config
	local target = FindNearestTarget(newTower, config.Range.Value)
	if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
		
		local targetCFrame = CFrame.lookAt(newTower.HumanoidRootPart.Position, target.HumanoidRootPart.Position)
		newTower.HumanoidRootPart.BodyGyro.CFrame = targetCFrame
			
		animateTowerEvent:FireAllClients(newTower, "Attack")
		
		target.Humanoid:TakeDamage(config.Damage.Value)
		
		player.Gold.Value += config.Damage.Value
		
		task.wait(config.Cooldown.Value)
	end
	
	task.wait(0.01)
	
	tower.Attack(newTower, player)
end

function tower.Spawn(player, name, cframe)
	local allowedToSpawn = tower.CheckSpawn(player, name)
	
	if allowedToSpawn then
		
		local newTower = ReplicatedStorage.Towers[name]:Clone()
		newTower.HumanoidRootPart.CFrame = cframe
		newTower.Parent = workspace.Towers
		newTower.HumanoidRootPart:SetNetworkOwner(nil)
		
		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		bodyGyro.D = 0
		bodyGyro.CFrame = newTower.HumanoidRootPart.CFrame
		bodyGyro.Parent = newTower.HumanoidRootPart
		
		for i, object in ipairs(newTower:GetDescendants()) do
			if object:IsA("BasePart") then
				object.CollisionGroup = "Tower"
			end
		end
		
		player.Gold.Value -= newTower.Config.Price.Value
		player.PlacedTowers.Value += 1
		
		coroutine.wrap(tower.Attack)(newTower, player)
	else
		warn("Requested tower does not exist:", name)
	end
end

spawnTowerEvent.OnServerEvent:Connect(tower.Spawn)

function tower.CheckSpawn(player, name)
	local towerExists = ReplicatedStorage.Towers:FindFirstChild(name)

	if towerExists then
		if towerExists.Config.Price.Value <= player.Gold.Value then
			if player.PlacedTowers.Value < maxTowers then
				return true
			else
				warn("Player has reached max limit")
			end
		else
			warn("Player cannot afford")
		end
	else
		warn("That tower does not exist")
	end
	
	return false
end
requestTowerFunction.OnServerInvoke = tower.CheckSpawn

return tower