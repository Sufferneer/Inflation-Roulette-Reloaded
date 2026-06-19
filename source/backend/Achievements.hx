package backend;

import backend.enums.AchievementTier;
import backend.enums.AchievementType;
import backend.typedefs.AchievementData;

class Achievements {
	public static var achievementsList:Map<String, AchievementData> = new Map<String, AchievementData>();
	public static var achievementIDs:Array<String> = [];

	public static var curProgress:Map<String, Dynamic> = [];
	public static var enabled:Bool = true;

	// Haxe scrambles all me maps bruh!!!
	private static function createAchievement(id:String, data:AchievementData) {
		var importedData:AchievementData = data;
		importedData.id = id;
		achievementIDs.push(id);
		achievementsList.set(id, importedData);

		trace('Created achievement: $id');
	}

	public static function initialize() {
		achievementsList = [];
		achievementIDs = [];
		// Experiences
		createAchievement('firstWin', {tier: COMMON, type: BOOLEAN});
		createAchievement('pressurizeYourself', {tier: LAME, type: BOOLEAN});
		#if _ALLOW_UTILITIES
		createAchievement('exportCharacterProject', {
			tier: GOOD,
			type: BOOLEAN
		});
		#end
		createAchievement('winByYourself', {
			tier: LAME,
			type: BOOLEAN,
			alwaysAchievable: true
		});
		// Challenges
		createAchievement('doublePressurize', {tier: GOOD, type: BOOLEAN});
		createAchievement('noPressureWin', {tier: GOOD, type: BOOLEAN});

		createAchievement('fullPressureWin', {tier: COMMON, type: BOOLEAN});
		createAchievement('maximumScore', {tier: EPIC, type: BOOLEAN});
		createAchievement('minimumScore', {tier: LAME, type: BOOLEAN});
		createAchievement('winAgainstStrategicCPUs', {
			tier: GOOD,
			type: BOOLEAN
		});

		createAchievement('rarePolarizeSuccess', {
			tier: GOOD,
			type: BOOLEAN
		});
		createAchievement('eliminateByAssault', {
			tier: COMMON,
			type: BOOLEAN
		});
		createAchievement('intentionalLoseByPolarize', {
			tier: EPIC,
			type: BOOLEAN
		});
		createAchievement('twoPlayers', {tier: COMMON, type: BOOLEAN});
		createAchievement('sixPlayers', {tier: GOOD, type: BOOLEAN});
		// Milestones
		createAchievement('sabotages', {
			tier: COMMON,
			type: NUMBER,
			target: 50
		});

		createAchievement('liveShots', {
			tier: COMMON,
			type: NUMBER,
			target: 100
		});
		createAchievement('allGameModeWins', {
			tier: COMMON,
			type: LIST,
			items: ['reloaded', 'inequality', 'classic', 'charge', 'fiftyFifty'],
			itemTranslationKey: 'gamemode.%.name'
		});
		createAchievement('allCharacterWins', {
			tier: GOOD,
			type: LIST,
			items: ['goober', 'asimo', 'chester', 'shib'],
			itemTranslationKey: 'character.%.name.short'
		});
		createAchievement('allFillerWins', {
			tier: COMMON,
			type: LIST,
			items: ['air', 'water', 'soda', 'slime', 'berry'],
			itemTranslationKey: 'filler.%.name'
		});
		#if (_ALLOW_EASTER_EGGS && !mobile)
		createAchievement('allEasterEggs', {
			tier: GOOD,
			type: LIST,
			items: ['roomoneohone', 'blueberryhelium', 'imhighoncrack', 'ibeesbees', 'cogitoergosum', 'youreboringme'],
			itemTranslationKey: '%',
			hideIcon: true,
			hideName: true,
			// hideDescription: true,
			// This might not be a good idea.
			hideItems: true
		});
		#end

		createAchievement('noLife', {
			tier: LAME,
			type: BOOLEAN,
			hideFromMenu: true,
			resettable: false
		});

		// Hidden
		createAchievement('findCameraman', {
			tier: COMMON,
			type: BOOLEAN,
			hideIcon: true,
			hideName: true,
			silent: true
		});
		createAchievement('nineTwentyOne', {
			tier: LAME,
			type: BOOLEAN,
			hideIcon: true,
			hideName: true,
			silent: true
		});

		for (id => data in achievementsList) {
			switch (data.type) {
				case BOOLEAN:
					curProgress.set(id, [false]);
				case NUMBER:
					curProgress.set(id, [0]);
				case LIST:
					curProgress.set(id, []);
			}
		}
		if (FlxG.save.data == null || FlxG.save.data.achievements == null) {
			FlxG.save.data.achievements = curProgress;
			FlxG.save.flush();
		} else {
			for (id => data in achievementsList) {
				if (FlxG.save.data.achievements.exists(id)) {
					curProgress.set(id, FlxG.save.data.achievements.get(id));
				}
			}
		}
	}

	public static function isLocked(id:String) {
		switch (Achievements.achievementsList.get(id).type) {
			case BOOLEAN:
				return !curProgress.get(id)[0];
			case NUMBER:
				return curProgress.get(id)[0] < Achievements.achievementsList.get(id).target;
			case LIST:
				var locked:Bool = false;
				var requirements:Array<String> = curProgress.get(id);
				for (item in Achievements.achievementsList.get(id).items) {
					if (!requirements.contains(item))
						locked = true;
				}
				return locked;
		}
	}

	public static function advanceProgress(id:String, progress:Array<Dynamic>) {
		if (!enabled && Achievements.achievementsList[id]?.alwaysAchievable != true) {
			trace('Cannot advance $id; Achievements disabled');
			return;
		}
		if (!Achievements.achievementIDs.contains(id)) {
			trace('Achievement $id does not exist');
			return;
		}
		var prevLocked:Bool = isLocked(id);
		switch (Achievements.achievementsList[id].type) {
			case BOOLEAN:
				curProgress[id][0] = true;
			case NUMBER:
				curProgress[id][0] = Std.int(FlxMath.bound(curProgress[id][0] + progress[0], 0, Achievements.achievementsList[id].target));
			case LIST:
				var requirements:Array<String> = curProgress.get(id);
				for (item in progress) {
					if (!requirements.contains(item))
						requirements.push(item);
				}
		}
		trace('Achievement $id advanced');
		var curLocked:Bool = isLocked(id);
		if (!curLocked)
			trace('Achievement $id got!');
		if (prevLocked != curLocked && !curLocked && prevLocked && Achievements.achievementsList[id].silent != true) {
			AchievementToast.enqueue(id);
		}
		FlxG.save.data.achievements = curProgress;
		FlxG.save.flush();
	}

	public static function resetProgress(id:String) {
		switch (Achievements.achievementsList[id].type) {
			case BOOLEAN:
				curProgress.set(id, [false]);
			case NUMBER:
				curProgress.set(id, [0]);
			case LIST:
				curProgress.set(id, []);
		}
		FlxG.save.data.achievements = curProgress;
		FlxG.save.flush();
	}
}
