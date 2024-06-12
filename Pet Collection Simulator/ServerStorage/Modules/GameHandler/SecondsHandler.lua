local SecondsHandler = {}

function SecondsHandler:Init(Player)
	local otherstats = Player:WaitForChild("otherstats")
	local Seconds = otherstats:WaitForChild("Seconds")
	local TopTimePlayed = otherstats:WaitForChild("Time Played")
	task.spawn(function()
		while task.wait(1) do
			Seconds.Value += 1
			TopTimePlayed.Value += 1
			--break when max gift reached!
		end	
	end)
end

return SecondsHandler