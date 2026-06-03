package backend.typedefs;

import backend.enums.AchievementTier;
import backend.enums.AchievementType;

typedef AchievementData = {
	?id:String, // Practically required. ID of achievement
	tier:AchievementTier, // Tier of the achievement. Affects achievement plaque and jingle.
	type:AchievementType, // BOOLEAN for conditional achievements, LIST for gauntlet achievements, NUMBER for grinding achievements.
	?alwaysAchievable:Bool,
	?target:Int, // Targetted value to reach. For NUMBER achievements.
	?items:Array<String>, // List of items to be included. For LIST achievements
	?itemTranslationKey:String, // Used in Achievements Menu For LIST achievements
	?hideIcon:Bool,
	?hideName:Bool,
	?hideDescription:Bool,
	?hideItems:Bool, // For LIST achievements
	?silent:Bool,
	?hideFromMenu:Bool,
	?resettable:Bool
}
