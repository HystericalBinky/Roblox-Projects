local Confetti = {}

-- Variables
local player = game.Players.LocalPlayer
local playerGui = player.PlayerGui
local ConfettiGui = playerGui:WaitForChild("Confetti")
local Sizes = ConfettiGui:WaitForChild("Sizes"):GetChildren()
local Container = ConfettiGui:WaitForChild("Container")

-- Services
local TweenService = game:GetService("TweenService")

-- Utils
local RNG = Random.new()
local Colors = {
	Color3.fromRGB(255, 0, 0),
	Color3.fromRGB(255, 217, 24),
	Color3.fromRGB(85, 255, 0),
	Color3.fromRGB(0, 170, 255),
	Color3.fromRGB(170, 85, 255),
}

local function ConfettiVisual()
	task.spawn(function()
		for i = 1,75,1 do
			local RandomConfetti = Sizes[math.random(1, #Sizes)]
			
			local NewConfetti = RandomConfetti:Clone()
			NewConfetti.BackgroundColor3 = Colors[math.random(1, #Colors)]
			NewConfetti.Position = UDim2.new(RNG:NextNumber(-0.3,1.3), 0, -0.2, 0)
			NewConfetti.Rotation = RNG:NextNumber(10, 350)
			NewConfetti.Visible = true
			NewConfetti.Parent = Container
			
			local ConfettiFallInfo = TweenInfo.new(RNG:NextNumber(1,2.5), Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
			local ConfettiTween = TweenService:Create(NewConfetti, ConfettiFallInfo, {Position = UDim2.new(NewConfetti.Position.X.Scale, 0, NewConfetti.Position.Y.Scale + 1.3, 0)})
			ConfettiTween:Play()
			
			local CompletedTween = nil
			CompletedTween = ConfettiTween.Completed:Connect(function()
				task.wait(2.8)
				
				CompletedTween:Disconnect()
				CompletedTween = nil
				ConfettiTween:Destroy()
				NewConfetti = nil
				
				for _, frame in Container:GetDescendants() do
					frame:Destroy()
				end
			end)
		end
	end)
end

function Confetti.Play()
	for i = 1,4,1 do
		ConfettiVisual()
		task.wait(0.35)
	end
end

return Confetti