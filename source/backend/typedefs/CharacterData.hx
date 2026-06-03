package backend.typedefs;

import backend.typedefs.SkillData;

typedef CharacterData = {
	id:String,
	?cardDisplayedKey:String,
	maxPressure:Int,
	maxConfidence:Int,
	skills:Array<SkillData>
}