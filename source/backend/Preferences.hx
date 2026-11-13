package backend;

import backend.WindowUtil;

/**
 * Default list of settings to be used in-game.
 */
class SaveVariables {
	public var maxFramerate:Int = 60;
	public var pauseOnUnfocus:Bool = false;
	public var enablePopping:Bool = true;
	public var skipEliminatedPlayers:Bool = false;
	public var enableDebugKeybinds:Bool = false;
	public var enablePhotosensitiveMode:Bool = false;
	public var enableForcedAliasing:Bool = false;
	public var alwaysPlayMenuAnims:Bool = false;
	public var cameraSpeed:Float = 0.75;
	public var cameraEffectIntensity:Float = 1;
	public var screenSafeArea:Float = 0;
	public var enableLetterbox:Bool = true;
	public var showMusicToast:Bool = false;
	public var useBuiltInCursor:Bool = true;
	public var hideHUD:Bool = false;
	public var hideTooltip:Bool = false;
	public var musicVolume:Float = 0.35;
	public var gameSoundVolume:Float = 1;
	public var uiSoundVolume:Float = 0.5;
	public var playCursorSounds:Bool = true;
	public var enableBellyGurgles:Bool = false;
	public var enableBellyCreaks:Bool = true;
	public var enableBelching:Bool = true;
	public var enableDiscoloration:Bool = true;
	public var enableOralLeaking:Bool = false;
	public var enableNavelLeaking:Bool = false;
	public var enableBellyRubbing:Bool = true;
	public var cacheOnGPU:Bool = false;
	public var showDebugText:Bool = false;
	public var showFramerateOnDebugText:Bool = true;
	public var showMemoryUsageOnDebugText:Bool = true;
	public var showCurrentStateOnDebugText:Bool = false;
	public var checkForUpdates:Bool = true;
	public var enableGLSL:Bool = true;
	public var decreaseDetail:Bool = false;
	public var decreaseSounds:Bool = false;
	public var language:String = 'en-us';
	public var resolution:Array<Int> = [0, 0]; // Unset, will be calculated by game

	public function new() {
	}
}

/**
 * Handles the player's game settings.
 */
class Preferences {
	public static var data:SaveVariables = null;
	public static var defaultData:SaveVariables = null;

	public static var keybinds:Map<String, Array<FlxKey>> = [];
	public static var defaultKeybinds:Map<String, Array<FlxKey>> = [
		'shoot' => [ENTER, Z],
		'exit' => [ESCAPE, X],
		'camera' => [BACKSLASH, C],
		'skill1' => [ONE, NUMPADONE],
		'skill2' => [TWO, NUMPADTWO],
		'skill3' => [THREE, NUMPADTHREE],
		'skill4' => [FOUR, FlxKey.NONE],
		'pause' => [ESCAPE, FlxKey.NONE],
		'up' => [FlxKey.UP, W, FlxKey.NONE],
		'left' => [FlxKey.LEFT, A],
		'down' => [FlxKey.DOWN, S],
		'right' => [FlxKey.RIGHT, D],
		'debug1' => [SLASH, FlxKey.NONE],
		'debug2' => [PERIOD, FlxKey.NONE],
		'debug3' => [COMMA, FlxKey.NONE],
		'debug4' => [M, FlxKey.NONE],
		'debug5' => [N, FlxKey.NONE]
	];

	public static final manuallyProcessedKeys = ['keybinds'];

	public static function savePrefs() {
		var save:FlxSave = new FlxSave();
		save.bind('preferences', Utilities.getSavePath());
		save.mergeData(defaultData, true);
		for (key in Reflect.fields(data)) {
			if (manuallyProcessedKeys.contains(key)) continue;
			if (Reflect.getProperty(save.data, key) == null)
				Reflect.setField(save.data, key, Reflect.field(defaultData, key));
			else
				Reflect.setField(save.data, key, Reflect.field(data, key));
		}
		save.flush();

		var save:FlxSave = new FlxSave();
		save.bind('controlsV2', Utilities.getSavePath());
		save.data.keybinds = keybinds;
		save.flush();

		trace("Preferences saved!");
	}

	/**
	 * Loads the player's game settings from the save directory to the game.
	 */
	public static function loadPrefs() {
		if (data == null)
			data = new SaveVariables();
		if (defaultData == null)
			defaultData = new SaveVariables();

		var save:FlxSave = new FlxSave();
		save.bind('preferences', Utilities.getSavePath());
		if (save?.data != null) {
			for (key in Reflect.fields(data)) {
				if (manuallyProcessedKeys.contains(key) || !Reflect.hasField(save.data, key)) continue;
				Reflect.setField(data, key, Reflect.field(save.data, key));
			}
		} else {
			for (key in Reflect.fields(data)) {
				if (manuallyProcessedKeys.contains(key)) continue;
				Reflect.setField(data, key, Reflect.field(defaultData, key));
			}
		}
		trace(WindowUtil.AVAILABLE_RESOLUTIONS);
		trace(data.resolution);
		if (WindowUtil.resolutionIndexOf(data.resolution) == -1)
			data.resolution = [0, 0];
		if (data.resolution[0] == 0 || data.resolution[1] == 0) {
			var usedResStr:Array<Int> = WindowUtil.AVAILABLE_RESOLUTIONS[Std.int(WindowUtil.AVAILABLE_RESOLUTIONS.length / 2)];
			data.resolution = usedResStr;
		}
		
		var save:FlxSave = new FlxSave();
		save.bind('controlsV2', Utilities.getSavePath());
		if (save?.data?.keybinds != null) {
			var saveKeybinds:Map<String, Array<FlxKey>> = save.data.keybinds;
			for (name => value in saveKeybinds)
				keybinds.set(name, value);
		} else {
			save.data.keybinds = defaultKeybinds;
			for (name => value in defaultKeybinds)
				keybinds.set(name, value);
		}
		Controls.reloadKeybinds();
		ScreenSafeArea.recalculateConstants();

		if (Main.debugText != null) {
			Main.debugText.updateText();
		}

		#if !html5
		FlxG.autoPause = data.pauseOnUnfocus;
		#end
		
		WindowUtil.resizeWindow(data.resolution[0], data.resolution[1]);
		WindowUtil.screenCenter();

		FlxG.mouse.useSystemCursor = !data.useBuiltInCursor;

		if (data.maxFramerate > FlxG.drawFramerate) {
			FlxG.updateFramerate = data.maxFramerate;
			FlxG.drawFramerate = data.maxFramerate;
		} else {
			FlxG.drawFramerate = data.maxFramerate;
			FlxG.updateFramerate = data.maxFramerate;
		}
	}
}
