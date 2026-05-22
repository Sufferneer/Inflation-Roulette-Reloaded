package states;

import backend.SplashManager;
import backend.lunarDate.LunarDate;
import backend.PlatformMetadata;
#if _OFFICIAL_BUILD
import backend.VersionMetadata;
#end
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import states.AchievementsState;
#if _ALLOW_ADDONS
import states.AddonsMenuState;
#end
import states.CreditsState;
import states.InitStartupState;
import states.LanguageSelectState;
#if _ALLOW_UTILITIES
import utilities.states.UtilitiesMainMenuState;
#end
import substates.OptionsSubState;
import substates.ExtrasSubState;
import substates.GamemodeSelectSubState;
import ui.objects.GameLogo;
import backend.Scoring.Scoring.gradePercent;
import backend.typedefs.ScoreData;
import backend.enums.ScoreRank;
import backend.Scoring;

class MainMenuState extends SuffState {
	public static var initialized:Bool = false;
	static var dongCount:Int = 0;

	var finishedAnimation:Bool = true;

	var bg:FlxSprite;
	var overlay:FlxBackdrop;
	var logo:GameLogo;
	var splashText:FlxText;

	var dongText:FlxText;
	var dongCommentText:FlxText;
	final dongCommentTargets:Array<Int> = [
		0, 10, 20, 50, 100, 200, 300, 320, 340, 360, 380, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200, 1300, 1400, 1500, 2000, 3000, 5000, 10000, 10010
	];

	var buttonGroup:FlxTypedContainer<SuffButton> = new FlxTypedContainer<SuffButton>();
	var topInfoTextGroup:FlxTypedSpriteGroup<FlxText> = new FlxTypedSpriteGroup<FlxText>();
	var bottomInfoTextGroup:FlxTypedSpriteGroup<FlxText> = new FlxTypedSpriteGroup<FlxText>();

	final menuItemPadding:FlxPoint = new FlxPoint(10, 10);
	final menuItemSize:FlxPoint = new FlxPoint(520, 550);

	var creditsButton:SuffButton;

	static final menuItems:Array<Array<String>> = [
		['play'],
		#if _ALLOW_ADDONS
		['addons', #if _ALLOW_UTILITIES 'utilities' #end],
		#end
		['achievements'],
		['options', 'language'],
		['extras', 'donate']
	];

	static final disabledMenuItems:Array<String> = [
		#if mobile 'addons', #end
		'donate'
	];

	var currentEasterEggInput:String = '';

	override public function create():Void {
		Paths.clearUnusedMemory();

		if (FlxG.sound.music == null || SuffState.currentMusicName == 'null') { // idk lmao
			SuffState.playMusic('mainMenu');
		}

		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF347277);
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(64, 64, 128, 128, true, 0x50FFFFFF, 0x0));
		grid.velocity.set(-32, -32);
		add(grid);

		overlay = new FlxBackdrop(Paths.image('ui/transitions/horizontal'), Y);
		overlay.x = -overlay.width / 2 + (FlxG.width - overlay.width) / 2 + 40;
		overlay.velocity.set(0, 32);
		overlay.color = 0xFF105060;
		overlay.alpha = 0.75;
		add(overlay);

		logo = new GameLogo(0, 0, false);
		logo.showVersion = true;
		logo.x = FlxG.width / 2 + (FlxG.width / 2 - logo.width) / 2;
		logo.y = (FlxG.height - logo.height) / 2;
		add(logo);

		dongText = new FlxText(0, 0, 0, '', 32);
		dongText.alignment = CENTER;
		add(dongText);

		splashText = new FlxText(0, 0, FlxG.width * 0.4, 'Empty');
		splashText.setFormat(Paths.font('default', false), 32, FlxColor.YELLOW, CENTER, FlxTextBorderStyle.SHADOW, 0x80000000);
		splashText.text = getRandomSplashText();
		splashText.y = logo.y + logo.height + 10;
		add(splashText);
		tweenSplashTextColor();

		dongCommentText = new FlxText(0, 0, FlxG.width * 0.4, '', 32);
		dongCommentText.x = logo.x + (logo.width - dongCommentText.width) / 2;
		dongCommentText.y = splashText.y;
		dongCommentText.alignment = CENTER;
		add(dongCommentText);

		var topInfoTextList:Array<String> = [];
		if (SplashManager.isSpecialDay) {
			topInfoTextList.push(DateTools.format(Date.now(), '%B %d, %Y'));
		}
		if (SplashManager.usesLunarCalendar) {
			var date = LunarDate.now().toString().split('・');
			topInfoTextList.push(date[0]);
			topInfoTextList.push(date[1] + '・' + date[2]);
		}
		add(topInfoTextGroup);
		for (i in 0...topInfoTextList.length) {
			var infoText = new FlxText(0, 0, 0, topInfoTextList[i]);
			infoText.setFormat(Paths.font((i == 0) ? 'default' : 'unicode'), 16, FlxColor.WHITE);
			infoText.x = FlxG.width - infoText.width - ScreenSafeZone.X;
			infoText.y = infoText.height * i + ScreenSafeZone.Y;
			topInfoTextGroup.add(infoText);
		}

		final bottomInfoTextList:Array<String> = [
			Language.getPhrase('game.title'),
			#if _OFFICIAL_BUILD
			VersionMetadata.getVersionName(FlxG.stage.application.meta.get('version')), Language.getPhrase('game.version.numeral.format',
				[FlxG.stage.application.meta.get('version') + '-' + haxe.macro.Compiler.getDefine('versionState')]),
			#else
			Language.getPhrase('game.version.numeralModded.format', [FlxG.stage.application.meta.get('version') + '-' + haxe.macro.Compiler.getDefine('versionState')]),
			#end
			Language.getPhrase('game.build.format', [PlatformMetadata.getBuildName()])
		];
		add(bottomInfoTextGroup);
		for (i in 0...bottomInfoTextList.length) {
			var infoText = new FlxText(0, 0, 0, bottomInfoTextList[i]);
			infoText.setFormat(Paths.font('default'), 16, FlxColor.WHITE);
			infoText.x = FlxG.width - infoText.width - ScreenSafeZone.X;
			infoText.y = FlxG.height - infoText.height * (bottomInfoTextList.length - i) - ScreenSafeZone.Y;
			bottomInfoTextGroup.add(infoText);
		}

		var creditImage = Paths.image('ui/menus/nicklySufferLogo');
		var creditImageHovered = Paths.image('ui/menus/nicklySufferLogoHighlighted');
		creditsButton = new SuffButton(10 + ScreenSafeZone.X, 0, '', creditImage, creditImageHovered, creditImage.width * 2, creditImage.height * 2, false);
		creditsButton.btnTextColorHovered = 0xFFFFFF00;
		creditsButton.y = FlxG.height - creditsButton.height - 10 - ScreenSafeZone.Y;
		creditsButton.onClick = function() {
			menuButtonFunctions('credits');
		}
		creditsButton.tooltipText = '© 2026 NicklySuffer';
		add(creditsButton);

		add(buttonGroup);

		for (jIndex => j in menuItems) {
			for (iIndex => item in j) {
				var curMenuItemSize:FlxPoint = new FlxPoint((menuItemSize.x - menuItemPadding.x * (j.length - 1)) / j.length,
					(menuItemSize.y - menuItemPadding.y * (menuItems.length - 1)) / menuItems.length);
				var button = new SuffButton(0, 0, Language.getPhrase('mainMenu.$item'), null, null, curMenuItemSize.x, curMenuItemSize.y);
				if (disabledMenuItems.contains(item)) {
					button.disabled = true;
					button.tooltipText = Language.getPhrase('mainMenu.$item.tooltip.disabled');
				}
				button.x = (((FlxG.width - ScreenSafeZone.X * 2) / 2 - 40) - menuItemSize.x) / 2 + (curMenuItemSize.x + menuItemPadding.x) * iIndex;
				button.y = (((FlxG.height - ScreenSafeZone.Y * 2) - ((FlxG.height - ScreenSafeZone.Y * 2) - creditsButton.y)) - menuItemSize.y) / 2 + (curMenuItemSize.y + menuItemPadding.y) * jIndex;
				button.onClick = function() {
					menuButtonFunctions(item);
				};
				buttonGroup.add(button);
			}
		}

		if (!initialized || Preferences.data.alwaysPlayMainMenuAnims)
			runFirstStartupTweens();
		if (!initialized) {
			persistentDraw = true;
			initialized = true;
		}

		super.create();
	}

	function runFirstStartupTweens() {
		finishedAnimation = false;
		var logoX = logo.x;
		var logoY = logo.y;
		logo.showVersion = false;
		logo.animated = true;
		logo.x = (FlxG.width - logo.width) / 2;
		logo.y = -logo.height;
		FlxTween.tween(logo, {y: logoY}, 1, {
			ease: FlxEase.quintOut,
			startDelay: 0.5
		});
		FlxTween.tween(logo, {x: logoX}, 1, {
			ease: FlxEase.quintInOut,
			startDelay: 1.5,
			onComplete: function(_) {
				logo.showVersion = true;
			}
		});

		var overlayPos = overlay.x;
		overlay.x = -overlay.width;
		FlxTween.tween(overlay, {x: overlayPos}, 1, {
			ease: FlxEase.cubeOut,
			startDelay: 1.75
		});

		for (num => button in buttonGroup.members) {
			var originalX:Float = button.x;
			button.x = button.width * -1;

			FlxTween.tween(button, {x: originalX}, 0.75, {
				ease: FlxEase.cubeOut,
				startDelay: 2 + num * 0.1
			});
		}

		for (num => text in topInfoTextGroup.members) {
			var originalX:Float = text.x;
			text.x = FlxG.width;
			FlxTween.tween(text, {x: originalX}, 1, {
				ease: FlxEase.cubeOut,
				startDelay: 2 + num * 0.2
			});
		}

		for (num => text in bottomInfoTextGroup.members) {
			var originalX:Float = text.x;
			text.x = FlxG.width;
			FlxTween.tween(text, {x: originalX}, 1, {
				ease: FlxEase.cubeOut,
				startDelay: 2 + num * 0.2
			});
		}

		var originalCreditsButtonX:Float = creditsButton.x;
		creditsButton.x = -creditsButton.width;
		FlxTween.tween(creditsButton, {x: originalCreditsButtonX}, 1, {
			ease: FlxEase.cubeOut,
			startDelay: 2.5
		});

		var original_splashTextY:Float = splashText.y;
		splashText.y = FlxG.height * 1.25;
		FlxTween.tween(splashText, {y: original_splashTextY}, 0.75, {
			startDelay: 2.0,
			ease: FlxEase.cubeOut,
			onComplete: function(_) {
				finishedAnimation = true;
			}
		});
	}

	function getRandomSplashText() {
		return SplashManager.activeSplashes[FlxG.random.int(0, SplashManager.activeSplashes.length - 1)];
	}

	function changeSplashText() {
		var leText = getRandomSplashText();
		while (leText == splashText.text) {
			leText = getRandomSplashText();
		}
		if (Utilities.supportedBySuffirat(leText))
			splashText.font = Paths.font('default', false);
		else
			splashText.font = Paths.font('unicode');
		splashText.text = leText;
	}

	function fadeSplashText() {
		FlxTween.tween(splashText, {y: FlxG.height}, 1, {
			ease: FlxEase.cubeIn,
			onComplete: function(twn:FlxTween) {
				changeSplashText();
				FlxTween.tween(splashText, {y: logo.y + logo.height + 10}, 1, {ease: FlxEase.cubeOut});
			}
		});
	}

	var curColor:Int = 0;

	function tweenSplashTextColor() {
		if (SplashManager.activeColors.length <= 1)
			return;
		curColor = FlxMath.wrap(curColor + 1, 0, SplashManager.activeColors.length - 1);
		FlxTween.cancelTweensOf(splashText, ['color']);
		FlxTween.color(splashText, 1, splashText.color, SplashManager.activeColors[curColor], {
			onComplete: function(_) {
				tweenSplashTextColor();
			}
		});
	}

	function menuButtonFunctions(menu:String) {
		switch (menu.toLowerCase()) {
			case 'play':
				openSubState(new GamemodeSelectSubState());
			case 'options':
				OptionsSubState.notInGame = true;
				openSubState(new OptionsSubState());
			#if _ALLOW_ADDONS
			case 'addons':
				SuffState.switchState(new AddonsMenuState());
			#end
			#if _ALLOW_UTILITIES
			case 'utilities':
				SuffState.switchState(new UtilitiesMainMenuState());
			#end
			case 'language':
				LanguageSelectState.atWarningState = false;
				SuffState.switchState(new LanguageSelectState());
			case 'achievements':
				SuffState.switchState(new AchievementsState());
			case 'extras':
				openSubState(new ExtrasSubState());
			case 'credits':
				SuffState.switchState(new CreditsState());
			case 'donate':
                Utilities.browserLoad('https://ko-fi.com/nicklysuffer');
		}
	}

	var splashTextChangeTimer:Float = 0;
	var displayedLogoScale:Float = GameLogo.logoScale;

	function dong() {
		splashTextChangeTimer = 0;
		displayedLogoScale -= 0.025;
		changeSplashText();
		FlxTween.cancelTweensOf(splashText, ['y']);
		FlxTween.tween(splashText, {y: logo.y + logo.height + 10}, 0.08, {ease: FlxEase.cubeOut});
		SuffState.playUISound(Paths.sound('ui/dong'));

		dongCount++;
		dongText.text = Language.getPhrase('mainMenu.dongs', [dongCount]);
		dongText.x = logo.x + (logo.width - dongText.width) / 2;
		FlxTween.cancelTweensOf(dongText, ['scale.x', 'scale.y', 'angle']);
		dongText.angle = FlxG.random.int(-10, 10);
		dongText.scale.set(FlxG.random.float(1.1, 1.25), FlxG.random.float(1.1, 1.25));
		dongsPerSecond += 1;
		FlxTween.tween(dongText.scale, {x: FlxG.random.float(0.75, 0.9), y: FlxG.random.float(0.75, 0.9)}, 0.05, {
			onComplete: function(_) {
				FlxTween.tween(dongText.scale, {x: 1, y: 1}, 0.05);
			}
		});
		FlxTween.tween(dongText, {angle: 0}, 0.1);
		if (dongTextTick > 2) {
			dongText.y = -dongText.height;
			FlxTween.cancelTweensOf(dongText, ['y']);
			FlxTween.tween(dongText, {y: 16}, 0.5, {
				ease: FlxEase.quintOut
			});
		}
		dongTextTick = 0;

		for (i in 0...dongCommentTargets.length) {
			if (dongCount < dongCommentTargets[i]) {
				dongCommentText.text = Language.getPhrase('mainMenu.dongs.comment.' + dongCommentTargets[i - 1], [], '');
				break;
			}
		}
		if (dongCount >= dongCommentTargets[dongCommentTargets.length - 2])
			Achievements.advanceProgress('noLife', [true]);
	}

	var dongTextTick:Float = 6;
	var dongsPerSecond:Float = 0;

	override function update(elapsed:Float) {
		super.update(elapsed);

		dongTextTick += elapsed;
		if (dongTextTick >= 2 && dongTextTick <= (2 + elapsed)) {
			FlxTween.tween(dongText, {y: -dongText.height * 2}, 4, {
				ease: FlxEase.quadInOut
			});
		}

		dongsPerSecond *= (1 - elapsed);
		splashText.offset.x = -Math.pow(Math.max(0, dongsPerSecond - 5) * 6, 2);
		dongCommentText.alpha = FlxMath.bound(splashText.offset.x / -2000, 0, 1);

		logo.angle = splashText.angle = Math.sin(SuffState.timePassedOnState) * 5;
		displayedLogoScale = FlxMath.lerp(displayedLogoScale, GameLogo.logoScale, elapsed * 10);
		var leScale = displayedLogoScale - Math.pow(Math.sin(SuffState.timePassedOnState / 2), 2) * 0.05;
		logo.scale.set(leScale, leScale);

		splashText.x = logo.x + (logo.width - splashText.width) / 2;
		var splashTextScale = 1 + Math.abs(Math.sin(SuffState.timePassedOnState * Math.PI * 2)) * 0.05;
		splashText.scale.set(splashTextScale, splashTextScale);
		if (finishedAnimation) {
			if (FlxG.mouse.overlaps(logo) && FlxG.mouse.justPressed) {
				dong();
			}

			if (FlxG.mouse.overlaps(bottomInfoTextGroup.members[bottomInfoTextGroup.members.length - 1])
				&& FlxG.mouse.justPressed
				&& (FlxG.save.data.easterEggStartup.length > 0 || currentEasterEggInput.length > 0)) {
				currentEasterEggInput = '';
				FlxG.save.data.easterEggStartup = '';
				FlxG.save.flush();

				SuffState.playUISound(Paths.sound('ui/startup/transition'), 0.75, 3);
			}

			splashTextChangeTimer += elapsed;
			if (splashTextChangeTimer >= 10) {
				splashTextChangeTimer = 0;
				fadeSplashText();
			}
		}

		#if (_ALLOW_EASTER_EGGS && !mobile)
		if (FlxG.keys.firstJustPressed() != FlxKey.NONE) {
			var keyPressed:FlxKey = FlxG.keys.firstJustPressed();
			var keyName:String = Std.string(keyPressed);
			if (Constants.ALPHABET_UPPERCASE.contains(keyName.toUpperCase())) {
				currentEasterEggInput += keyName.toLowerCase();
				if (currentEasterEggInput.length > 16)
					currentEasterEggInput = currentEasterEggInput.substring(1);
				// trace(currentEasterEggInput);

				for (easterEgg in Constants.EASTER_EGG_INPUTS) {
					var formattedInput = currentEasterEggInput.toLowerCase();
					if (currentEasterEggInput.toLowerCase() == easterEgg) {
						FlxG.save.data.easterEggStartup = formattedInput;
						Achievements.advanceProgress('allEasterEggs', [formattedInput]);
						FlxG.save.flush();
						SuffState.switchState(new InitStartupState(), INTERMISSION, true);
						break;
					}
				}
			}
		}
		#end
	}
}
