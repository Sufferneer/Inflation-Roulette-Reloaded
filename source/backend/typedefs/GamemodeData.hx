package backend.typedefs;

typedef GamemodeData = {
	// name:String,
	// description:String,
	?color:String,

	?cylinderSize:Int,
	?cylinderLiveCount:Int,
	?cylinderReloadOnNoLives:Bool,
	?cylinderInitialDamage:Int,
	?cylinderDamageChangeOnLive:Int,
	?cylinderDamageChangeOnBlank:Int,
	?cylinderTrueRandomness:Bool,

	?skillsTangible:Bool,
	?skillsFixedPool:Array<String>,
	?skillsRandomPool:Array<String>,
	?skillsCostMultiplier:Float,
	?skillsReplenishCountOnLive:Int,
	?skillsReplenishCountOnBlank:Int,

	?cpuMinLevel:Int,
	?cpuMaxLevel:Int,

	?scoreWinBonusMultiplier:Float,
	?scoreEdgingBonusMultiplierRange:Array<Float>,
	?scoreSkillBonusRequirement:Int,
	?scoreSkillBonusMultiplier:Float
}
