local BlurFOV_FX = {
	DefaultFOV = 70,
	EffectFOV = 80,
}

local RS = game:GetService("ReplicatedStorage")
local LI = game:GetService("Lighting")

local RSModules = RS:WaitForChild("Modules")
local OptiMotion = require(RSModules:WaitForChild("OptiMotion"))

local BlurFX = LI:WaitForChild("Blur")
local PlayerCamera = workspace:WaitForChild("Camera")

function BlurFOV_FX:Toggle(isOn)
	
	local MotionInfo = {
		Tweeninfo = {0.1,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.In,
			0,
			false,
			0},
		TweenProperty = {
			FieldOfView = isOn and self.EffectFOV or self.DefaultFOV,
		},
	}
	
	if not isOn then
		BlurFX.Enabled = isOn
		OptiMotion:Play(PlayerCamera,MotionInfo)
	else
		BlurFX.Enabled = isOn
		OptiMotion:Play(PlayerCamera,MotionInfo)
	end
end

return BlurFOV_FX