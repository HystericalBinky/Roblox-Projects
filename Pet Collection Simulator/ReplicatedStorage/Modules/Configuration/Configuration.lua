return {
	Worlds = require(script:WaitForChild("WorldSettings")),
	Tags =  require(script:WaitForChild("Tags")),
	GamepassID = require(script:WaitForChild("GamepassID")),
	DataStore = require(script:WaitForChild("DataStore")),
	Animation = require(script:WaitForChild("Animation")),
	Codes =  require(script:WaitForChild("Codes")),
	MinuteGift = require(script:WaitForChild("MinuteGift")),
	SpinWheel = require(script:WaitForChild("SpinWheel")),
	Colors = require(script:WaitForChild("Colors")),
	GroupFeature = require(script:WaitForChild("GroupFeature")),
	RebirthSettings = require(script:WaitForChild("RebirthSettings")),
	RarityTypeModule = require(script:WaitForChild("RarityTypeModule")),
	EggModule = require(script:WaitForChild("EggModule")),
	PetStatsModule = require(script:WaitForChild("PetStatsModule")),
	PetUpgradeSettings = require(script:WaitForChild("PetUpgradeSettings")),
	RandomPetName = require(script:WaitForChild("RandomPetName")),
	FriendBoost = require(script:WaitForChild("FriendBoost")),
	DevProducts = require(script:WaitForChild("DevProducts")),
	CurrencyImages = require(script:WaitForChild("CurrencyImages")),
	UGCSettings = require(script:WaitForChild("UGCSettings")),
	Location = {
		SpawnedPetFolder = workspace:WaitForChild("Pets"),
		EggFolder = workspace:WaitForChild("Core"):WaitForChild("Eggs")
	},
	PetSettings = {
		MaxPetCircleRadius = 9
	},
	EggSettings = {
		MaxMagnitude = 10
	},
	
}