local ApplyData = {}

function ApplyData:Apply(Player,GetData)
	for a,b in pairs(GetData) do
		local DataFolder = Player:FindFirstChild(a)
		if DataFolder then
			for c,d in pairs(b) do
				local InsData = DataFolder:FindFirstChild(c)
				if not InsData then continue end
				InsData.Value = d
			end
		end
	end
end


return ApplyData