package backend;

import backend.Gamemode;
import backend.Gameplay.Gameplay.setPlayerCount;
import tjson.TJSON.TJSON.parse;
import tjson.TJSON;
import backend.typedefs.CharacterCosmeticData;

class Gameplay {
	public static var globalCharacterList:Array<String> = [];
	public static var selectedCharacterList:Array<String> = ['goober', 'goober', 'goober', 'goober'];

	public static var cpuControlled:Array<Bool> = [false, true, true, true];
	public static var cpuLevel:Array<Int> = [2, 2, 2, 2];

	public static var currentStage:String = 'reloaded';
	public static var globalStageList:Array<String> = ['reloaded'];

	public static var defaultGamemode:Gamemode;
	public static var currentGamemode:Gamemode;

	public static var currentFiller:Filler;
	public static var globalFillerList:Array<String> = ['reloaded'];

	public function new() {
		// ass
	}

	public static function initialize() {
		globalCharacterList = Paths.readFolderDirectories('data/characters', 'data/characters/characterList.txt', 'stats.json');
		trace(globalCharacterList);
		setPlayerCount(4);

		defaultGamemode = new Gamemode('reloaded');
		currentGamemode = new Gamemode('reloaded');

		currentFiller = new Filler('air');
		globalFillerList = Paths.readDirectories('data/fillers', 'data/fillers/fillerList.txt', 'json');

		currentStage = 'reloaded';
		globalStageList = Paths.readDirectories('data/stages', 'data/stages/stageList.txt', 'json');
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
			var sheet = 'game/characters/$char/$i';
			Paths.sparrowAtlas(sheet);
			trace('Cached sprite sheet: $sheet');
		}
	}

	public static function parseRandomCharacters() {
		// Make a copy of the list excluding "random"
		var list = [for (i in globalCharacterList) if (!selectedCharacterList.contains(i) && i != 'random') i];
		// If list is empty (full of randoms)
		if (list.length <= 0) list = globalCharacterList.copy();
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

	public static function isMultiplayer() {
		return [for (i in cpuControlled) if (!i) i].length > 1;
	}
}
