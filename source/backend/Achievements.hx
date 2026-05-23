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
		createAchievement('firstWin', {tier: COMMON, type: BOOLEAN});
		createAchievement('sabotages', {
			tier: COMMON,
			type: NUMBER,
			target: 50
		});
		createAchievement('doublePressurize', {tier: GOOD, type: BOOLEAN});
		createAchievement('pressurizeYourself', {tier: LAME, type: BOOLEAN});
		createAchievement('noPressureWin', {tier: GOOD, type: BOOLEAN});
		createAchievement('fullPressureWin', {tier: COMMON, type: BOOLEAN});
		createAchievement('maximumScore', {tier: EPIC, type: BOOLEAN});
		createAchievement('minimumScore', {tier: LAME, type: BOOLEAN});
		createAchievement('allGameModeWins', {
			tier: GOOD,
			type: LIST,
			items: ['reloaded', 'inequality', 'classic', '1v1', 'sixPlayers', 'charge', 'fiftyFifty'],
			itemTranslationKey: 'gamemode.%.name'
		});
		createAchievement('allCharacterWins', {
			tier: GOOD,
			type: LIST,
			items: ['goober', 'asimo', 'chester', 'shibanou'],
			itemTranslationKey: 'character.%.name.short'
		});
		createAchievement('noLife', {
			tier: LAME,
			type: BOOLEAN,
			hideFromMenu: true,
			resettable: false
		});
		#if (_ALLOW_EASTER_EGGS && !mobile)
		createAchievement('allEasterEggs', {
			tier: GOOD,
			type: LIST,
			items: ['roomoneohone', 'blueberryhelium', 'imhighoncrack', 'ibeesbees'],
			itemTranslationKey: '%',
			hideIcon: true,
			hideName: true,
			// hideDescription: true,
			// This might not be a good idea.
			hideItems: true
		});
		#end

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
		if (!enabled) return;
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
		var curLocked:Bool = isLocked(id);
		if (prevLocked != curLocked && !curLocked && prevLocked) {
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
