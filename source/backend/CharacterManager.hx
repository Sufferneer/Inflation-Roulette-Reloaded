package backend;

import tjson.TJSON;
import backend.typedefs.CharacterCosmeticData;

class CharacterManager {
	public static var globalCharacterList:Array<String> = [];
	public static var selectedCharacterList:Array<String> = ['goober', 'goober', 'goober', 'goober'];
	public static var cpuControlled:Array<Bool> = [false, true, true, true];
	public static var cpuLevel:Array<Int> = [2, 2, 2, 2];

	public function new() {
		// ass
	}

	public static function initialize() {
		globalCharacterList = Paths.readFolderDirectories('data/characters', 'data/characters/characterList.txt', 'stats.json');
		trace(globalCharacterList);
		setPlayerCount(4);
	}

	public static function precacheSprites() {
		for (i in globalCharacterList) {
			precacheSpriteSheets(i);
		}
		precacheResultsAssets();
	}

	public static function precacheResultsAssets() {
		Paths.music('resultsStart');
		Paths.music('resultsLoop');
		for (i in globalCharacterList) {
			Paths.sparrowAtlas('ui/menus/results/characters/$i');
		}
	}

	public static function precacheSpriteSheets(char:String) {
		var rawJson:CharacterCosmeticData = cast TJSON.parse(Paths.getTextFromFile('data/characters/$char/cosmetic.json'));
		for (i in rawJson.spriteSheets) {
			Paths.sparrowAtlas('game/characters/$char/$i');
		}
	}

	public static function parseRandomCharacters() {
		var list = globalCharacterList.copy();
		for (i in 0...selectedCharacterList.length) {
			if (selectedCharacterList[i] == 'random') {
				var picked = FlxG.random.getObject(list);
				selectedCharacterList[i] = picked;
				list.remove(picked);
				if (list.length <= 0)
					list = globalCharacterList.copy();
			}
		}
	}

	public static function setPlayerCount(value:Int = 4) {
		selectedCharacterList = [for (i in 0...value) 'goober'];
		cpuControlled = [for (i in 0...value) true];
		cpuControlled[0] = false;
		cpuLevel = [for (i in 0...value) 2];
	}
}
