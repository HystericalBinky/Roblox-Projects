local ServerStorage = game:GetService("ServerStorage")

local bindables = ServerStorage:WaitForChild("Bindables")
local gameOverEvent = bindables:WaitForChild("GameOver")

local mob = require(script.Mob)
local tower = require(script.Tower)
local map = workspace.UnderwaterRuins

local info = workspace.Info
local gameOver = false

map.Base.Humanoid.HealthChanged:Connect(function(health)
	if health <= 0 then
		gameOver = true
	end
end)

gameOverEvent.Event:Connect(function()
	gameOver = true
end)

for i=3, 0, -1 do
	print("Game starting in... ", i)
	task.wait(1)
end

for wave=1, 10 do
	info.Wave.Value = wave
	
	if wave < 3 then
		mob.Spawn("PaperBall", 4 * wave, map)
	elseif wave == 3 then
		mob.Spawn("PlasticBag", 4, map)
	
	elseif wave > 3 and wave < 6 then
		mob.Spawn("PaperBall", wave * 2, map)
		mob.Spawn("PlasticBag", wave * 1, map)
	elseif wave == 6 then
		mob.Spawn("WaterBottle", 6, map)
	elseif wave > 6 and wave < 10 then
		mob.Spawn("PaperBall", wave * 3, map)
		mob.Spawn("PlasticBag", wave * 2, map)
		mob.Spawn("WaterBottle", wave * 1, map)
	end
	
	repeat
		task.wait(1)
	until #workspace.Mobs:GetChildren() == 0 or gameOver
	
	if gameOver then
		print("GAME OVER")
		break
	end
	
	for i=5, 0, -1 do
		print("Next wave starting in... ", i)
		task.wait(1)
	end
end