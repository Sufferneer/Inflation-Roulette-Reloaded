package states.easterEggStartups;

import flixel.group.FlxSpriteContainer;

class ImHighOnCrackStartupState extends SuffState {
	override function create() {
		super.create();

		Window.setTitle('IM GOING TO PRISON AND NEVER COMING BACK');

		// Precache shards
		for (i in 0...shardCount) {
			Paths.image('ui/menus/easterEggStartups/imhighoncrack/shards/' + i);
		}

		startIntro();
	}

	var logo:FlxSprite;
	var shadows:FlxSpriteContainer = new FlxSpriteContainer();
	var shards:FlxSpriteContainer = new FlxSpriteContainer();
	var bg:FlxBackdrop;
	final shadowCount:Int = 2;
	final shardCount:Int = 73;
	var ambientSound:FlxSound;
	var allowToSkip:Bool = true;
	var loadedObjects:Bool = false;
	var skipIntroTimer:FlxTimer;

	function startIntro() {
		ambientSound = new FlxSound().loadEmbedded(Paths.sound('ui/startup/imhighoncrack/ambience'));
		ambientSound.looped = true;
		ambientSound.play();

		add(shadows);

		bg = new FlxBackdrop(Paths.image('ui/menus/easterEggStartups/imhighoncrack/heartAttack'));
		bg.color = 0xFF00FFFF;
		bg.blend = OVERLAY;
		bg.alpha = 0.375;
		bg.velocity.set(90, 90);
		add(bg);

		var bgMask = new FlxSprite().loadGraphic(Paths.image('ui/menus/easterEggStartups/mask'));
		add(bgMask);

		logo = new FlxSprite().loadGraphic(bg.graphic);
		logo.screenCenter(XY);
		logo.color = 0xFF00FFFF;
		add(logo);

		add(shards);

		for (i in 0...shadowCount) {
			var shadow = new FlxSprite().loadGraphic(bg.graphic);
			shadow.setPosition(logo.x, logo.y);
			shadow.ID = i + 1;
			shadow.color = 0xFF00FFFF;
			shadow.alpha = 0.5 / shadow.ID;
			shadows.add(shadow);
		}

		loadedObjects = true;
		FlxG.drawFramerate = 30;

		skipIntroTimer = new FlxTimer().start(6, function(tmr:FlxTimer) {
			skipIntro();
		});
	}

	function skipIntro() {
		if (!allowToSkip || !loadedObjects)
			return;

		ambientSound.stop();
		ambientSound.destroy();

		skipIntroTimer.cancel();

		shadows.kill();
		bg.kill();

		if (!Preferences.data.decreaseDetail) {
			for (i in 0...shardCount) {
				var shard = new FlxSprite(logo.x, logo.y).loadGraphic(Paths.image('ui/menus/easterEggStartups/imhighoncrack/shards/' + i));
				shard.setGraphicSize(Std.int(logo.width), Std.int(logo.height));
				shard.updateHitbox();
				shards.add(shard);
			}
		} else {
			var shard = new FlxSprite(logo.x, logo.y).loadGraphic(Paths.image('ui/menus/easterEggStartups/imhighoncrack/shardsCombined'));
			shard.setGraphicSize(Std.int(logo.width), Std.int(logo.height));
			shard.updateHitbox();
			shards.add(shard);
		}

		logo.kill();

		FlxG.drawFramerate = FlxG.updateFramerate;

		SuffState.playUISound(Paths.sound('ui/startup/imhighoncrack/crack'));
		new FlxTimer().start(1.25, function(tmr:FlxTimer) {
			SuffState.playUISound(Paths.sound('ui/startup/imhighoncrack/break'));
			if (!Preferences.data.decreaseDetail) {
				if (!Preferences.data.enablePhotosensitiveMode) {
					FlxG.camera.flash(0xFFFFFFFF, 0.25);
				}
				FlxG.camera.shake(0.02 * Preferences.data.cameraEffectIntensity, 0.125);
				for (shard in shards) {
					shard.velocity.set(FlxG.random.int(-320, 320), FlxG.random.int(-360, 180));
					shard.acceleration.y = FlxG.height;
				}
			} else {
				shards.visible = false;
				if (!Preferences.data.enablePhotosensitiveMode) {
					FlxG.camera.flash(0xFFFFFFFF, 2);
				}
			}
			new FlxTimer().start(4, function(tmr:FlxTimer) {
				FlxTransitionableState.skipNextTransIn = true;
				SuffState.switchState(new MainMenuState());
			});
		});

		allowToSkip = false;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (!loadedObjects)
			return;

		if (Controls.justPressed('exit') || Controls.justPressed('shoot') || FlxG.mouse.justPressed) {
			skipIntro();
		}

		if (allowToSkip) {
			logo.y = (FlxG.height - logo.height) / 2 + Math.sin(SuffState.timePassedOnState * 1.5) * 18;
		}

		if (shadows != null) {
			for (shadow in shadows) {
				shadow.x = logo.x + Math.sin(SuffState.timePassedOnState * 2) * 20 * shadow.ID;
				shadow.y = logo.y + Math.sin(SuffState.timePassedOnState * 2) * 20 * shadow.ID;
			}
		}
	}
}
