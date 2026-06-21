package backend.typedefs;

import backend.enums.AchievementTier;
import backend.enums.AchievementType;

typedef NPCData = {
	?copyCharacterId:Bool,
	?mergeable:Bool,
	?mergedNpc:String,
	?mergeChance:Float,
	?walkSpeed:Float,
	?idleDuration:Array<Float>,
	?sizeMultiplier:Array<Float>,
	?originPosition:Array<Float>,
	?tauntChance:Float,
	?hitboxSize:Array<Float>,
	?animations:Array<AnimationData>
}
