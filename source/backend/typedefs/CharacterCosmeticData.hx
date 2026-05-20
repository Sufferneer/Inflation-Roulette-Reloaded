package backend.typedefs;

typedef CharacterCosmeticData = {
	?spriteSheets:Array<String>,
	animations:Array<AnimationData>,
	belchThreshold:Int,
	gurgleThreshold:Int,
	creakThreshold:Int,
	antialiasing:Bool,
	?disablePopping:Bool,
	?originPosition:Array<Int>,
	?poppedCameraOffset:Array<Int>,
	?cameraOffset:Array<Int>,
	?particleOffsets:CharacterParticleOffsetsData,
	// ?headParticlePosition:Map<String, Array<Array<Int>>>,
	?poppingVelocityMultiplier:Array<Float>,
	?poppingGravityMultiplier:Float
}
