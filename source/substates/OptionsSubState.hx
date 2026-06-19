package substates;

import ui.objects.SuffBoolean;
import ui.objects.SuffIconButton;
import ui.objects.SuffSlider;
import states.PlayState;
import ui.objects.SuffScrollBar;
import substates.ScreenSafeAreaSubState;

class OptionsSubState extends SuffSubState {
	public static var notInGame:Bool = true;

	var bg:FlxSprite;
	var bg2:FlxSprite;
	var exitButton:SuffIconButton;

	var scrollBar:SuffScrollBar;

	var optionsGroup:FlxSpriteGroup = new FlxSpriteGroup();

	static var optionsXPadding:Float = 32;
	static final optionsYPadding:Float = 32;

	var optionsMaxWidth:Float = 0;
	var optionsY:Float = 0;
	var optionsScrollUpperLimit:Float = 0;
	var optionsScrollLowerLimit:Float = 0;

	var touchedMusicOption:Bool = false;

	public function new() {
		super();

		Window.setTitle(Language.getPhrase('optionsMenu.windowDisplay'));

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.75;
		add(bg);

		bg2 = new FlxSprite();
		add(bg2);

		if (notInGame) {
			SuffState.playMusic('options');
		}

		add(optionsGroup);
		optionsGroup.camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
		generateOptions();

		scrollBar = new SuffScrollBar(0, 0, function(percent:Float) {
			optionsGroup.y = FlxMath.lerp(0, FlxG.height - (optionsGroup.height + 64), percent);
		}, 32, optionsGroup.height + 64);
		bg2.makeGraphic(Std.int(Math.min(FlxG.width - scrollBar.width - ScreenSafeArea.X, optionsXPadding + optionsMaxWidth + optionsXPadding)), FlxG.height, FlxColor.BLACK);
		bg2.alpha = 0.375;

		scrollBar.x = bg2.width;
		scrollBar.camera = this.camera;
		add(scrollBar);

		exitButton = new SuffIconButton(20, 20 + ScreenSafeArea.Y, 'buttons/exit', null, 2);
		exitButton.x = FlxG.width - exitButton.width - 20 - ScreenSafeArea.X;
		exitButton.onClick = function() {
			exitOptionsMenu();
		};
		add(exitButton);

		camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
	}

	function generateOptions() {
		optionsXPadding = 32 + ScreenSafeArea.X;
		optionsY = optionsYPadding + ScreenSafeArea.Y;
		optionsScrollUpperLimit = optionsY;
		optionsScrollLowerLimit = optionsY;

		optionsGroup.clear();

		createHeading('gameplay');

		#if !mobile
		createButtonOption('controls', function() {
			openSubState(new ControlsOptionsSubState());
		});
		#end

		createBooleanOption("skipEliminatedPlayers",
		function(value:Bool) {
			Preferences.data.skipEliminatedPlayers = value;
		}, Preferences.data.skipEliminatedPlayers);

		createHeading('preferences');

		createBooleanOption("enableBellyCreaks", function(value:Bool) {
			Preferences.data.enableBellyCreaks = value;
		}, Preferences.data.enableBellyCreaks);

		createBooleanOption("enableBellyGurgles", function(value:Bool) {
			Preferences.data.enableBellyGurgles = value;
		}, Preferences.data.enableBellyGurgles);

		createBooleanOption("enableBelching", function(value:Bool) {
			Preferences.data.enableBelching = value;
		}, Preferences.data.enableBelching);

		createBooleanOption('enablePopping',
			function(value:Bool) {
				Preferences.data.enablePopping = value;
			}, Preferences.data.enablePopping);

		createBooleanOption("enableDiscoloration", function(value:Bool) {
			Preferences.data.enableDiscoloration = value;
		}, Preferences.data.enableDiscoloration);

		createBooleanOption("enableOralLeaking", function(value:Bool) {
			Preferences.data.enableOralLeaking = value;
		}, Preferences.data.enableOralLeaking);

		createBooleanOption("enableNavelLeaking", function(value:Bool) {
			Preferences.data.enableNavelLeaking = value;
		}, Preferences.data.enableNavelLeaking);

		createHeading('performance');

		createBooleanOption('decreaseDetail', function(value:Bool) {
			Preferences.data.decreaseDetail = value;
		}, Preferences.data.decreaseDetail);

		createBooleanOption('decreaseSounds', function(value:Bool) {
			Preferences.data.decreaseSounds = value;
		}, Preferences.data.decreaseSounds);

		createBooleanOption('enableForcedAliasing', function(value:Bool) {
			Preferences.data.enableForcedAliasing = value;
		}, Preferences.data.enableForcedAliasing);

		createBooleanOption('enableGLSL', function(value:Bool) {
			Preferences.data.enableGLSL = value;
		}, Preferences.data.enableGLSL);

		#if (openfl && !html5)
		createBooleanOption("cacheOnGPU",
		function(value:Bool) {
			Preferences.data.cacheOnGPU = value;
		}, Preferences.data.cacheOnGPU);
		#end

		// GRAPHICS SETTINGS
		createHeading('visuals');

		createBooleanOption('hideHUD', function(value:Bool) {
			Preferences.data.hideHUD = value;
		}, Preferences.data.hideHUD);

		createBooleanOption('hideTooltip', function(value:Bool) {
			Preferences.data.hideTooltip = value;
		}, Preferences.data.hideTooltip);

		if (notInGame) {
			createButtonOption('screenSafeArea', function() {
				openSubState(new ScreenSafeAreaSubState());
			});
		}

		#if desktop
		createBooleanOption('enableFullscreen', function(value:Bool) {
			Preferences.data.enableFullscreen = value;
		}, Preferences.data.enableFullscreen);
		#end

		createBooleanOption('alwaysPlayMainMenuAnims', function(value:Bool) {
			Preferences.data.alwaysPlayMainMenuAnims = value;
		}, Preferences.data.alwaysPlayMainMenuAnims);

		createBooleanOption('showMusicToast',
			function(value:Bool) {
				Preferences.data.showMusicToast = value;
			}, Preferences.data.showMusicToast);

		createBooleanOption('enableLetterbox',
			function(value:Bool) {
				Preferences.data.enableLetterbox = value;
			}, Preferences.data.enableLetterbox);

		// AUDIO SETTINGS
		createHeading('audio');

		createSliderOption('musicVolume', function(value:Float) {
			Preferences.data.musicVolume = value;
			if (notInGame)
				FlxG.sound.music.volume = Preferences.data.musicVolume;
		}, 0.0, 1.0, 0.05, function(value:Float) {
			return Math.round(value * 100) + '%';
		}, Preferences.data.musicVolume, LOGARITHMIC);

		createSliderOption('gameSoundVolume', function(value:Float) {
			Preferences.data.gameSoundVolume = value;
			SuffState.playSound(Paths.soundRandom('game/weapon', 1, 3));
		}, 0.0, 1.0, 0.05, function(value:Float) {
			return Math.round(value * 100) + '%';
		}, Preferences.data.gameSoundVolume, LOGARITHMIC);

		createSliderOption('uiSoundVolume', function(value:Float) {
			Preferences.data.uiSoundVolume = value;
			SuffState.playUISound(Paths.sound('ui/dong'));
		}, 0.0, 1.0, 0.05, function(value:Float) {
			return Math.round(value * 100) + '%';
		}, Preferences.data.uiSoundVolume, LOGARITHMIC);

		createHeading('accessibility');

		createBooleanOption('enablePhotosensitiveMode', function(value:Bool) {
				Preferences.data.enablePhotosensitiveMode = value;
		}, Preferences.data.enablePhotosensitiveMode);

		createSliderOption('cameraSpeed', function(value:Float) {
			Preferences.data.cameraSpeed = value;
			PauseSubState.usedFollowLerp = 0.1 * Preferences.data.cameraSpeed;
		}, 0.25, 2, 0.05, function(value:Float) {
			return Math.round(value * 100) + '%';
		}, Preferences.data.cameraSpeed);

		createSliderOption('cameraEffectIntensity', function(value:Float) {
			Preferences.data.cameraEffectIntensity = value;
		}, 0, 2, 0.05, function(value:Float) {
			return Math.round(value * 100) + '%';
		}, Preferences.data.cameraEffectIntensity);

		#if !mobile

		createHeading('cursor');

		createBooleanOption('useBuiltInCursor', function(value:Bool) {
			Preferences.data.useBuiltInCursor = value;
			FlxG.mouse.useSystemCursor = !value;
		}, Preferences.data.useBuiltInCursor);

		createBooleanOption('playCursorSounds', function(value:Bool) {
			Preferences.data.playCursorSounds = value;
		}, Preferences.data.playCursorSounds);

		#end

		// TECHNICAL SETTINGS
		createHeading('technical');

		createSliderOption('maxFramerate', function(value:Float) {
			Preferences.data.maxFramerate = Math.round(value);
			PauseSubState.usedFollowLerp = 0.1 * Preferences.data.cameraSpeed;
		}, 30, #if !mobile 500 #else 120 #end, 10, function(value:Float) {
			return '' + Math.round(value);
		}, Preferences.data.maxFramerate);
		// Mobile framerate is capped at 120 to avoid device heating up

		#if _CHECK_FOR_UPDATES
		createBooleanOption('checkForUpdates', function(value:Bool) {
			Preferences.data.checkForUpdates = value;
		}, Preferences.data.checkForUpdates);
		#end

		#if (!html5 && !mobile)
		createBooleanOption('pauseOnUnfocus', function(value:Bool) {
			Preferences.data.pauseOnUnfocus = value;
		}, Preferences.data.pauseOnUnfocus);
		#end

		#if !mobile
		createBooleanOption("enableDebugKeybinds", function(value:Bool) {
			Preferences.data.enableDebugKeybinds = value;
		}, Preferences.data.enableDebugKeybinds);
		#end

		#if !mobile
		// DEBUG TEXT SETTINGS
		createHeading('debugText');

		createBooleanOption('showDebugText', function(value:Bool) {
			Preferences.data.showDebugText = value;
			Main.debugText.updateText();
		}, Preferences.data.showDebugText);

		createBooleanOption('showFramerateOnDebugText', function(value:Bool) {
			Preferences.data.showFramerateOnDebugText = value;
			Main.debugText.updateText();
		}, Preferences.data.showFramerateOnDebugText);

		#if (openfl && !html5)
		createBooleanOption('showMemoryUsageOnDebugText', function(value:Bool) {
			Preferences.data.showMemoryUsageOnDebugText = value;
			Main.debugText.updateText();
		}, Preferences.data.showMemoryUsageOnDebugText);
		#end

		createBooleanOption('showCurrentStateOnDebugText', function(value:Bool) {
			Preferences.data.showCurrentStateOnDebugText = value;
			Main.debugText.updateText();
		}, Preferences.data.showCurrentStateOnDebugText);
		#end

		var lastItem = optionsGroup.members[optionsGroup.members.length - 1];
		optionsScrollLowerLimit = -(lastItem.y + lastItem.height + optionsYPadding);
		if (optionsScrollLowerLimit < -FlxG.height) {
			optionsScrollLowerLimit += FlxG.height;
		}
	}

	function createHeading(name:String) {
		if (optionsGroup.members.length > 0)
			optionsY += 32;
		var text:FlxText = new FlxText(optionsXPadding, optionsY, 0, Language.getPhrase('optionsMenu.heading.$name'));
		text.setFormat(Paths.font('small'), 32, FlxColor.WHITE, CENTER);
		optionsGroup.add(text);
		optionsY += 48;

		if (text.x + text.width - optionsXPadding > optionsMaxWidth) {
			optionsMaxWidth = text.x + text.width - optionsXPadding;
		}
	}

	function createBooleanOption(ID:String, callback:Bool->Void, defaultValue:Bool) {
		var text:FlxText = new FlxText(optionsXPadding, optionsY, 0, Language.getPhrase('option.${ID}.name'));
		text.setFormat(Paths.font('default'), 48, FlxColor.WHITE, CENTER);
		optionsGroup.add(text);

		var option:SuffBoolean = new SuffBoolean(text.x + text.width + 16, optionsY, callback, defaultValue);
		text.y = option.y + (option.height - text.height) / 2;
		option.camera = this.camera;
		option.tooltipText = Language.getPhrase('option.${ID}.description');
		optionsGroup.add(option);

		optionsY += option.height + 16;
		if (option.x + option.width - optionsXPadding > optionsMaxWidth) {
			optionsMaxWidth = option.x + option.width - optionsXPadding;
		}
	}

	function createSliderOption(ID:String, callback:Float->Void, rangeMin:Float, rangeMax:Float, step:Float, displayFunction:Float->String, defaultValue:Float, scaling:SuffSliderScaling = LINEAR) {
		var text:FlxText = new FlxText(optionsXPadding, optionsY, 0, Language.getPhrase('option.${ID}.name'));
		text.setFormat(Paths.font('default'), 48, FlxColor.WHITE, CENTER);
		optionsGroup.add(text);

		var option:SuffSlider = new SuffSlider(text.x + text.width + 16, optionsY, callback, rangeMin, rangeMax, step, displayFunction,
		defaultValue, scaling);
		text.y = option.y + (option.height - text.height) / 2;
		option.camera = this.camera;
		option.tooltipText = Language.getPhrase('option.${ID}.description');
		optionsGroup.add(option);

		optionsY += option.height + 16;
		if (option.x + option.width - optionsXPadding > optionsMaxWidth) {
			optionsMaxWidth = option.x + option.width - optionsXPadding;
		}
	}

	function createButtonOption(ID:String, callback:Void->Void) {
		var text:FlxText = new FlxText(Language.getPhrase('option.${ID}.name'), 48);
		var button:SuffButton = new SuffButton(optionsXPadding, optionsY, text.text, text.width + 80, 96);
		button.btnTextSize = 48;
		button.onClick = callback;
		button.camera = this.camera;
		button.tooltipText = Language.getPhrase('option.${ID}.description');
		optionsGroup.add(button);

		optionsY += button.height + 16;
	}

	function exitOptionsMenu() {
		Preferences.savePrefs();
		Preferences.loadPrefs();
		if (touchedMusicOption) {
			PauseSubState.resetMusic = true;
		}
		Tooltip.text = '';
		Window.setTitle(Language.getPhrase('mainMenu.windowDisplay'));
		close();
		if (notInGame) {
			SuffState.playMusic('mainMenu');
		} else {
			PlayState.instance.camHUD.visible = !Preferences.data.hideHUD;
		}
	}

	var allowMouseScrolling:Bool = true;

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (Controls.justPressed('exit')) {
			exitOptionsMenu();
		}

		allowMouseScrolling = true;
		for (opt in optionsGroup) {
			if (Std.isOfType(opt, SuffBoolean)) {
				var option:SuffBoolean = cast opt;
				if (option.hovered) {
					allowMouseScrolling = false;
				}
			} else if (Std.isOfType(opt, SuffSlider)) {
				var option:SuffSlider = cast opt;
				if (option.pressed) {
					allowMouseScrolling = false;
				}
			}
		}
	}
}
