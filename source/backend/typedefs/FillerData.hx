package backend.typedefs;

typedef FillerData = {
	?displayColor:String,
	?gasColor:String,
	?liquidColor:String,

	?tintColor:String,
	?decolorizeFactor:Array<Float>, // [0, 0, 0]

	?gurgles:FillerSoundData,
	?creaks:FillerSoundData,
	?belches:FillerSoundData,
	?leaks:FillerSoundData,
	?bursts:FillerSoundData, // "air"

	?gravityMultiplier:Float, // 1
	?stumbleForce:Float, // 0
	?disablePoppingPhysics:Bool, // false
	?navelLeaks:Bool, // false
	?npcOnPop:String // ""
}
