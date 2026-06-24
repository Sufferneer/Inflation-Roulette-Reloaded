package backend.typedefs;

typedef CharacterCosmeticData = {
	spriteSheets:Array<String>,
	animations:Array<AnimationData>,
	?belchThreshold:Int,
	?leakThreshold:Int,
	?navelLeakThreshold:Int,
	?gurgleThreshold:Int,
	?creakThreshold:Int,
	?voicePitch:Float,
	?antialiasing:Bool,
	?disablePopping:Bool,
	?poppingVelocityMultiplier:Array<Float>,
	?poppingGravityMultiplier:Float
}
