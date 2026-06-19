package backend.typedefs;

typedef FillerData = {
	?displayColor:String,
	?gasColor:String,
	?liquidColor:String,

	?tintColor:String,
	?destabilizationFactor:Array<Float>, // [0, 0, 0]

	?gurgles:FillerSoundData,
	?creaks:FillerSoundData,
	?belches:FillerSoundData,
	?leaks:FillerSoundData,
	?bursts:FillerSoundData, // "air"

	?gravityMultiplier:Float, // 1
	?stumbleForce:Float, // 0
	?navelLeaks:Bool, // false
	?npcOnPop:String, // ""

	?particleType:String,
}
