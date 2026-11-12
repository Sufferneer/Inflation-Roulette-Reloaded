package backend.typedefs;

typedef StageData = {
	id:String,
	?music:String,
	?cameraShader:String,
	stageCameraZoom:Float,
	characterCameraZoom:Float,
	cameraBounds:Array<Float>,
	backgroundObjects:Array<StageObjectData>,
	tableObjects:Array<StageObjectData>,
	foregroundObjects:Array<StageObjectData>,
	characterX:Array<Float>,
	characterY:Float,
	gunY:Float,
	gunScrollFactor:Array<Float>,

	?formatVersion:String, // Current: 2.0.0 (for 3.0.0+), Default: 1.0.0 (for 1.0.0 - 2.2.0)
	?rules:StageRulesData
}
