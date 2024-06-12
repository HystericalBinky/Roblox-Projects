local HS = game:GetService("HttpService")
local LiveLikesFolder = workspace:WaitForChild("Core"):WaitForChild("LiveLikes")
local Display = LiveLikesFolder:WaitForChild("Display")
local Gui = Display:WaitForChild("Gui")
local Frame = Gui:WaitForChild("Frame")


local LiveLikes = {
	requestInterval = 0.21; --Limit: 500 Request per Minute 
	UniID = 5974705269;
	API = "https://games.roproxy.com/v1/games/%s/votes";
	Goal = 100
}

function LiveLikes:Init()
	LiveLikes:updateData()
end

function LiveLikes:Listener()

end

function LiveLikes:decodeData(Data)
	local suc,DecodedData = pcall(function()
		return HS:JSONDecode(Data)
	end)
	if suc then
		return DecodedData
	end
end

function LiveLikes:getData()
	local suc,Data = pcall(function()
		return	HS:GetAsync(string.format(self.API,self.UniID))
	end)

	if suc then
		return LiveLikes:decodeData(Data)
	end
end

function LiveLikes:getUpVotes()
	local voteData = LiveLikes:getData()
	if not voteData then return end
	return voteData.upVotes
end

function LiveLikes:updateData()
	task.spawn(function()
		while task.wait(self.requestInterval) do
			local upVotes = LiveLikes:getUpVotes()
			if upVotes then
				local LiveLikesLabel = Frame:WaitForChild("LiveLikesLabel")
				LiveLikesLabel.Text = "Likes: " .. upVotes .. "/" .. self.Goal
			end
		end
	end)
end

return LiveLikes