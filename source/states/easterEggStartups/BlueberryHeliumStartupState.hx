package states.easterEggStartups;

import flixel.group.FlxSpriteContainer;
import backend.Controls;

class BlueberryHeliumStartupState extends SuffState {
	override function create() {
		super.create();

		Window.setTitle('我要食魚翅啊');

		startIntro();
	}

	var bg:FlxSprite;
	var scanlines:FlxSpriteContainer = new FlxSpriteContainer();
	var terminal:FlxTypedContainer<FlxText> = new FlxTypedContainer<FlxText>();
	final scanlineHeight:Int = 4;
	final terminalCompilationTxt:Array<String> = [
		"Compiling group: haxe",
		" - src/ui/objects/GitHubButton.cpp",
		" - src/__boot__.cpp",
		" - src/ui/objects/AddonMenuBG.cpp",
		" - src/ui/objects/GameLogo.cpp",
		" - src/ui/plugins/CursorHandler.hx.cpp",
		" - src/backend/Constants.cpp",
		" - src/objects/particles/ConfettiEmitter.cpp",
		" - src/ui/plugins/MusicToast.cpp",
		" - src/substates/PauseSubState.cpp",
		" - src/backend/SplashManager.cpp",
		" - src/states/CharacterSelectState.cpp",
		" - src/lime/utils/AssetCache.cpp  [haxe,release]",
		" - src/ui/objects/SuffBoolean.cpp",
		" - src/objects/Skill.cpp",
		" - src/ui/objects/GameIcon.cpp",
		" - src/states/easterEggStartups/ImHighOnCrackStartupState.cpp",
		" - src/ui/objects/AddonMenuItem.cpp",
		" - src/states/StartupState.cpp",
		" - src/states/easterEggStartups/BlueberryHeliumStartupState.cpp",
		" - src/ui/objects/CharacterBanner.cpp",
		" - src/ui/objects/SuffBox.cpp",
		" - src/states/InitStartupState.cpp",
		" - src/backend/Addons.cpp",
		" - src/backend/Utilities.cpp",
		" - src/states/MainMenuState.cpp",
		" - src/substates/OptionsSubState.cpp",
		" - src/ui/objects/SkillCard.cpp",
		" - src/Main.cpp",
		" - src/ui/SuffTransition.cpp",
		" - src/substates/GameOnSubState.cpp",
		" - src/objects/Character.cpp",
		" - src/ui/plugins/Tooltip.cpp",
		" - src/objects/particles/ScrapEmitter.cpp",
		" - src/backend/Paths.cpp",
		" - src/ui/SuffState.cpp",
		" - src/ui/objects/CharacterCard.cpp",
		" - src/states/PlayState.cpp",
		" - src/ui/objects/ReadySign.cpp",
		" - src/backend/Gamemode.cpp",
		" - src/ui/objects/SuffIconButton.cpp",
		" - src/ui/objects/SuffTransitionBlock.cpp",
		" - src/states/AddonsMenuState.cpp",
		" - src/backend/CharacterManager.cpp",
		" - src/substates/GamemodeSelectSubState.cpp",
		" - src/ui/objects/CreditsSketch.cpp",
		" - src/ui/objects/SuffButton.cpp",
		" - src/states/CreditsState.cpp",
		" - src/openfl/display/FPS.cpp  [haxe,release]",
		" - src/ui/objects/AddonMenuBGTile.cpp",
		" - src/ui/objects/CharacterSelectText.cpp",
		" - src/ui/objects/SuffSlider.cpp",
		"Link: ApplicationMain.exe",
		"    Creating library ApplicationMain.lib and object ApplicationMain.exp"
	];
	var terminalCurLine:Int = 0;
	var tobi:FlxSprite;
	var ambientSound:FlxSound;
	var fanSound:FlxSound;
	var allowToSkip:Bool = true;
	var loadedObjects:Bool = false;
	var skipIntroTimer:FlxTimer;

	function startIntro() {
		ambientSound = new FlxSound().loadEmbedded(Paths.sound('ui/startup/blueberryhelium/fanAmbience'));
		ambientSound.looped = true;
		ambientSound.play();

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF202020);
		add(bg);

		add(terminal);
		addTextToTerminal('D:\\CODING\\Inflation-Roulette-Reloaded>');
		addTextToTerminal('');

		add(scanlines);
		for (i in 0...Math.ceil(FlxG.height / scanlineHeight / 2)) {
			var scanline:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, scanlineHeight, 0xFFFFFFFF);
			scanline.y += i * scanlineHeight * 2;
			scanline.alpha = 0.05;
			scanlines.add(scanline);

			var scanlineCenter:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, Std.int(scanlineHeight / 2), 0xFFFFFFFF);
			scanlineCenter.y += i * scanlineHeight * 2 + scanlineHeight / 4;
			scanlineCenter.alpha = 0.05;
			scanlines.add(scanlineCenter);
		}

		tobi = new FlxSprite(0, 530);
		tobi.frames = Paths.sparrowAtlas('ui/menus/easterEggStartups/blueberryhelium/tobi');
		tobi.animation.addByPrefix('idle', 'tobi idle', 24);
		tobi.animation.addByPrefix('type', 'tobi type', 24);
		tobi.animation.play('idle', true);
		add(tobi);

		loadedObjects = true;

		new FlxTimer().start(1, function(tmr:FlxTimer) {
			FlxTween.tween(tobi, {y: 240}, 0.75, {
				ease: FlxEase.quadInOut,
				onComplete: function(_) {
					FlxTween.tween(tobi, {y: 0}, 0.5, {
						startDelay: 0.5,
						ease: FlxEase.quadInOut,
						onComplete: function(_) {
							new FlxTimer().start(1, function(tmr:FlxTimer) {
								skipIntro();
							});
						}
					});
				}
			});
		});
	}

	function addTextToTerminal(text:String = '') {
		for (text in terminal) {
			text.y -= text.height;
		}
		var leText:FlxText = new FlxText(0, 0, FlxG.width, text);
		leText.setFormat(Paths.font('default', false), 32, 0xFFC0C0C0);
		leText.x = 48;
		leText.y = FlxG.height - leText.height - 48;
		terminal.add(leText);
	}

	function updateTextInTerminal(text:String = '') {
		var leText = terminal.members[terminal.members.length - 1];
		leText.text = text;
		leText.updateHitbox();
	}

	final inputText:String = 'lime test linux -D_OFFICIAL_BUILD';

	function skipIntro() {
		if (!allowToSkip || !loadedObjects)
			return;

		FlxTween.cancelTweensOf(tobi);
		FlxTimer.globalManager.forEach(function(tmr:FlxTimer) {
			tmr.cancel();
		});
		tobi.y = 0;

		SuffState.playUISound(Paths.sound('ui/startup/blueberryhelium/limeTestLinux'), 2);
		FlxTween.num(0, inputText.length, 1.4, {
			onComplete: function(_) {
				tobi.animation.play('idle', true);
				FlxTween.num(1, 1.5, 4, {
					ease: FlxEase.quadInOut
				}, function(num:Float) {
					ambientSound.pitch = num;
				});
				nextLine();
				FlxTween.tween(tobi, {y: 530}, 1, {
					startDelay: 2,
					ease: FlxEase.quadIn,
					onComplete: function(_) {
						FlxTween.tween(FlxG.camera, {zoom: 3}, 1.5, {
							startDelay: 0.5,
							ease: FlxEase.cubeIn,
							onStart: function(_) {
								FlxG.camera.fade(0xFF000000, 1.5, false);
							},
							onComplete: function(_) {
								FlxG.camera.zoom = 1;
								FlxTransitionableState.skipNextTransIn = true;
								SuffState.switchState(new MainMenuState());
							}
						});
						ambientSound.fadeOut(1.5, 0, function(_) {
							ambientSound.stop();
							ambientSound.destroy();
						});
					}
				});
			}
		}, function(num:Float) {
			updateTextInTerminal(inputText.substring(0, Math.round(num)));

			tobi.animation.play('type');
			tobi.offset.set(FlxG.random.int(-1, 1) * 10, FlxG.random.int(-1, 0) * 5);
		});

		allowToSkip = false;
	}

	function nextLine() {
		addTextToTerminal(terminalCompilationTxt[terminalCurLine]);
		terminalCurLine++;
		new FlxTimer().start(FlxG.random.float(1 / 30, 0.2), function(_) {
			if (terminalCurLine < (terminalCompilationTxt.length - 1))
				nextLine();
		});
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (!loadedObjects)
			return;

		if (Controls.justPressed('exit') || Controls.justPressed('shoot') || FlxG.mouse.justPressed) {
			skipIntro();
		}
	}
}
