package backend.typedefs;

typedef CharacterCosmeticData = {
	spriteSheets:Array<String>,
	animations:Array<AnimationData>,
	?belchThreshold:Int,
	?leakThreshold:Int,
	?gurgleThreshold:Int,
	?creakThreshold:Int,
	?voicePitch:Float,
	?antialiasing:Bool,
	?disablePopping:Bool,
	?originPosition:Array<Int>,
	?poppedCameraOffset:Array<Int>,
	?cameraOffset:Array<Int>,
	?particleOffsets:CharacterParticleOffsetsData,
	?poppingVelocityMultiplier:Array<Float>,
	?poppingGravityMultiplier:Float
}
