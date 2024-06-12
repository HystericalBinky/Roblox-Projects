local DefaultScreenSize = Vector2.new(1920, 1080) --// Change this to YOUR screen size.
local CurrentScreenHeight = game.Players.LocalPlayer:GetMouse().ViewSizeY
local PlayerGui = game.Players.LocalPlayer.PlayerGui

function ScaleStroke(stroke)
	if stroke:GetAttribute("AlreadyScaled") then return end

	stroke.Thickness = stroke.Thickness * (CurrentScreenHeight / DefaultScreenSize.Y)
	
	stroke:SetAttribute("AlreadyScaled", true)
end

PlayerGui.DescendantAdded:Connect(function(v)
	if v:IsA("UIStroke") then
		ScaleStroke(v)
	end
end)

workspace.DescendantAdded:Connect(function(v)
	if v:IsA("UIStroke") then
		ScaleStroke(v)
	end
end)