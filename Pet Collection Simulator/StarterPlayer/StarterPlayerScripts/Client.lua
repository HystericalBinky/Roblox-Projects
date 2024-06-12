local RS = game:GetService("ReplicatedStorage")
local PL = game:GetService("Players")

local Player = PL.LocalPlayer

local RSModules = RS:WaitForChild("Modules")
local ClientHandler = require(RSModules:WaitForChild("ClientHandler"))
local TimedGift = require(RSModules:WaitForChild("TimedGift"))
local SpinWheelModule = require(RSModules:WaitForChild("SpinWheelHandler"))
local ClientWorldHandler = require(RSModules:WaitForChild("ClientWorldHandler"))
local PetHandler = require(RSModules:WaitForChild("PetHandler"))
local EggPreviewHandler = require(RSModules:WaitForChild("EggPreviewHandler"))
local ClientTokenHandler = require(RSModules:WaitForChild("ClientTokenHandler"))
local InventoryHandler = require(RSModules:WaitForChild("InventoryHandler"))
local ShopHandler = require(RSModules:WaitForChild("ShopHandler"))
local UGCHandler = require(RSModules:WaitForChild("UGCHandler"))
local IndexHandler = require(RSModules:WaitForChild("ClientIndexHandler"))


--Game Client Handler
task.spawn(function()
	InventoryHandler:Init()
	PetHandler:Init()
	ClientHandler.ClientRebirthHandler:Init()
end)

EggPreviewHandler:Init()

ClientHandler.ClientCodeHandler:Init()

SpinWheelModule:ClientInit()

ClientTokenHandler:Init()
ClientWorldHandler:Init()

--UI Handler
ClientHandler.UIHandler:Init()
ClientHandler.ClickHandler:Init()
ClientHandler.IndexHandler:Init()

--UI Contents Loader
TimedGift:ClientInit()
UGCHandler:Init()
ShopHandler:Init()
IndexHandler:Init()