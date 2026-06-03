package states;

import backend.Addons;
import backend.GameplayManager;
import backend.CharacterManager;
import backend.SplashManager;
import openfl.utils.Assets.Assets.getBitmapData;
import openfl.utils.Assets;
import backend.AndroidUtils;

class PreloadState extends SuffState {
	#if !html5
	var bg:FlxSprite;
	var preloadTxt:FlxText;
	#end

	var loadingProgress:Int = -1;
	var loadingTexts:Array<String> = ['characters', 'gameplay', 'music', 'achievements', 'toasts', 'tooltip', 'cursor', 'splashes'];

	override function create() {
		super.create();

		FlxG.save.bind('game', Utilities.getSavePath());
		Preferences.loadPrefs();
		if (AndroidUtils.checkAllFilesPermission())
			Addons.pushGlobalAddons();
		Language.initialize();

		#if !html5
		bg = new FlxSprite().loadGraphic(Paths.image('ui/menus/preload/loadingArt'));
		bg.alpha = 0;
		preloadTxt = new FlxText(0, 0, FlxG.width, '', 32);
		preloadTxt.alignment = CENTER;

		bg.screenCenter();
		bg.y = Std.int((FlxG.height - (bg.height + preloadTxt.height + 10)) / 2);
		preloadTxt.y = bg.y + bg.height + 10;

		add(bg);
		add(preloadTxt);
		FlxTween.tween(bg, {alpha: 1}, 0.5, {
			onComplete: function(_) {
				loadShit();
			}
		});
		#else
		loadShit();
		#end
		CursorHandler.cursorVisible = false;
	}

	function loadShit() {
		loadingProgress++;
		#if !html5
		preloadTxt.text = Language.getPhrase('preloadMenu.progress.' + loadingTexts[loadingProgress]);
		#end
		new FlxTimer().start(FlxG.elapsed, function(_) {
			switch (loadingTexts[loadingProgress]) {
				case 'characters':
					CharacterManager.initialize();
					#if (!html && !mobile)
					CharacterManager.precacheSprites();
					#end
				case 'gameplay':
					GameplayManager.initialize();
				case 'music':
					#if (!html && !mobile)
					var musicList = Utilities.textFileToArray('data/extras/jukebox/musicList.txt', true);
					for (music in musicList) {
						trace('Cached music: $music');
						Paths.music(music);
					}
					#end
				case 'achievements':
					Achievements.initialize();
				case 'toasts':
					MusicToast.initialize();
					AchievementToast.initialize();
					trace('Setup Music Toasts and Achievement Toasts');
				case 'tooltip':
					Tooltip.initialize();
					// shhhhh
					ScreenSafeZone.recalculateConstants();
					trace('Setup Tooltip and Recalculated Screen Safe Zone');
				case 'cursor':
					CursorHandler.initialize();
					CursorHandler.cursorVisible = true;
					trace('Setup Custom Cursor');
				case 'splashes':
					SplashManager.parseSplashes();
			}
			if (loadingProgress >= loadingTexts.length - 1)
				finishLoadingShit();
			else
				loadShit();
		});
	}

	function finishLoadingShit() {
		#if !html5
		/*
		SCRAM YOU FUCKER GET THE FUCK OUTTA HERE
		
		LIKE GET THE FUCK OUT OF HERE
		
		SERIOUSLY
		
		GET OUT
		
		NO
		
		SHOO
		
		OUT
		
		ARF ARF ARFARFARFARF
		
		NO
		
		No
		
		no
		
		:/
		
		ya know what whatever
		 */
		#if _ALLOW_EASTER_EGGS
		if ((Date.now().getHours() == 21 && Date.now().getMinutes() == 21) || FlxG.random.bool(1 / 1024 * 100)) {
			var originalDimensions:Array<Float> = [bg.width, bg.height];
			bg.loadGraphic(Paths.image('ui/menus/preload/areWeFuckingForRealBro'));
			bg.setGraphicSize(Std.int(originalDimensions[0]), Std.int(originalDimensions[1]));
			bg.updateHitbox();
			preloadTxt.visible = false;
			Achievements.advanceProgress('nineTwentyTwo', [true]);
			SuffState.playUISound(Paths.sound('void'));
			new FlxTimer().start(1, function(_) {
				FlxG.camera.fade(0xFF000000, 0, false);
				new FlxTimer().start(4.0, function(_) {
					goToStartupState();
				});
			});
		} else
		#end
		{
			preloadTxt.text = Language.getPhrase('preloadMenu.finished');
			FlxG.camera.fade(0xFF000000, 1, false, function() {
				goToStartupState();
			});
		}
		#else
		goToStartupState();
		#end
	}
	
	function goToStartupState() {
		#if _CHECK_FOR_UPDATES
		if (Preferences.data.checkForUpdates) {
			var http = new haxe.Http("https://raw.githubusercontent.com/Sufferneer/Inflation-Roulette/main/curVersion.txt");

			http.onData = function (data:String) {
				OutdatedVersionState.latestVersion = data.split('\n')[0].trim();
				var curVersion:String = FlxG.stage.application.meta.get('version');
				trace('Current Version: ' + OutdatedVersionState.latestVersion + ', Your Version: ' + curVersion);
				if (OutdatedVersionState.latestVersion != curVersion) {
					trace('Versions not matching');
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					SuffState.switchState(new OutdatedVersionState());
				} else {
					SuffState.switchState(new InitStartupState());
				}
			}

			http.onError = function (error) {
				trace('Error: $error');
				SuffState.switchState(new InitStartupState());
			}

			http.request();
		} else {
			SuffState.switchState(new InitStartupState());
		}
		#else
		SuffState.switchState(new InitStartupState());
		#end
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
