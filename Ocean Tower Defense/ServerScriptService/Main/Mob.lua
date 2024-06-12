local ServerStorage = game:GetService("ServerStorage")
local PhysicsService = game:GetService("PhysicsService")
local ServerStorage = game:GetService("ServerStorage")

local mob = {}

function mob.Move(mob, map)
	local humanoid = mob:WaitForChild("Humanoid")
	local waypoints = map.Waypoints

	for waypoint=1, #waypoints:GetChildren() do
		humanoid:MoveTo(waypoints[waypoint].Position)
		humanoid.MoveToFinished:Wait()
	end
	
	mob:Destroy()
	
	map.Base.Humanoid:TakeDamage(humanoid.Health)
	
end

function mob.Spawn(name, quantity, map)
	local mobExists = ServerStorage.Mobs:FindFirstChild(name)
	
	if mobExists then
		for i=1, quantity do
			task.wait(0.5)
			local newMob = mobExists:Clone()
			newMob.HumanoidRootPart.CFrame = map.Start.CFrame
			newMob.Parent = workspace.Mobs
			newMob.HumanoidRootPart:SetNetworkOwner(nil)
			
			for i, object in ipairs(newMob:GetDescendants()) do
				if object:IsA("BasePart") then
					object.CollisionGroup = "Mob"
				end
			end
			
			newMob.Humanoid.Died:Connect(function()
				task.wait(0.5)
				newMob:Destroy()
			end)

			coroutine.wrap(mob.Move)(newMob, map)
		end
	else
		warn("Requested mob does not exist:", name)
	end
end

return mob
