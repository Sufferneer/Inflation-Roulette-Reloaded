package backend;

import backend.Gamemode;

class Gameplay {
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
		defaultGamemode = new Gamemode('reloaded');
		currentGamemode = new Gamemode('reloaded');

		currentFiller = new Filler('air');
		globalFillerList = Paths.readDirectories('data/fillers', 'data/fillers/fillerList.txt', 'json');

		currentStage = 'reloaded';
		globalStageList = Paths.readDirectories('data/stages', 'data/stages/stageList.txt', 'json');
	}
}
