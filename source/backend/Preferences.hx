package backend;

/**
 * Default list of settings to be used in-game.
 */
class SaveVariables {
	public var maxFramerate:Int = 60;
	public var enableFullscreen:Bool = false;
	public var pauseOnUnfocus:Bool = false;
	public var enablePopping:Bool = true;
	public var ignoreEliminatedPlayers:Bool = false;
	public var enableDebugKeybinds:Bool = false;
	public var enablePhotosensitiveMode:Bool = false;
	public var enableForcedAliasing:Bool = false;
	public var alwaysPlayMainMenuAnims:Bool = false;
	public var cameraSpeed:Float = 0.75;
	public var cameraEffectIntensity:Float = 1;
	public var screenSafeZone:Float = 0.2;
	public var enableLetterbox:Bool = true;
	public var showMusicToast:Bool = false;
	public var useBuiltInCursor:Bool = true;
	public var hideHUD:Bool = false;
	public var hideTooltip:Bool = false;
	public var musicVolume:Float = 0.25;
	public var gameSoundVolume:Float = 1;
	public var uiSoundVolume:Float = 0.5;
	public var playCursorSounds:Bool = true;
	public var enableBellyGurgles:Bool = false;
	public var enableBellyCreaks:Bool = true;
	public var cacheOnGPU:Bool = true;
	public var showDebugText:Bool = false;
	public var showFramerateOnDebugText:Bool = true;
	public var showMemoryUsageOnDebugText:Bool = true;
	public var showCurrentStateOnDebugText:Bool = false;
	public var checkForUpdates:Bool = true;
	public var enableGLSL:Bool = true;
	public var decreaseDetail:Bool = false;
	public var language:String = 'en-US';

	public var keybinds:Map<String, Array<FlxKey>> = [
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

	public function new() {
	}
}

/**
 * Handles the player's game settings.
 */
class Preferences {
	public static var data:SaveVariables = null;
	public static var defaultData:SaveVariables = null;

	public static final manuallyProcessedKeys = ['keybinds'];

	public static function savePrefs() {
		FlxG.save.bind('preferences', Utilities.getSavePath());

		for (key in Reflect.fields(data)) {
			if (manuallyProcessedKeys.contains(key)) continue;
			if (Reflect.getProperty(FlxG.save.data, key) == null)
				Reflect.setField(FlxG.save.data, key, Reflect.field(defaultData, key));
			else
				Reflect.setField(FlxG.save.data, key, Reflect.field(data, key));
		}
		FlxG.save.data.keybinds = data.keybinds;

		var save:FlxSave = new FlxSave();
		save.bind('preferences', Utilities.getSavePath());
		save.mergeData(data, true);
		save.data.keybinds = data.keybinds;
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
		for (key in Reflect.fields(data)) {
			if (manuallyProcessedKeys.contains(key) || !Reflect.hasField(save, key)) continue;
			Reflect.setField(data, key, Reflect.field(save, key));
		}

		var saveKeybinds:Map<String, Array<FlxKey>> = cast Reflect.field(save, 'keybinds');
		if (saveKeybinds != null) {
			for (name => value in saveKeybinds)
				data.keybinds.set(name, value);
		} else {
			Reflect.setField(save, 'keybinds', new Map<String, Array<FlxKey>>());
		}
		Controls.reloadKeybinds();
		ScreenSafeZone.recalculateConstants();

		if (Main.debugText != null) {
			Main.debugText.updateText();
		}

		#if !html5
		FlxG.autoPause = data.pauseOnUnfocus;
		#end

		FlxG.fullscreen = data.enableFullscreen;

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
