package states.easterEggStartups;
import flixel.group.FlxSpriteContainer;
import objects.particles.Explosion;

class CogitoErgoSumStartupState extends SuffState {
	var allowToSkip:Bool = true;

	var hateSpeech:FlxSound;
	var upThumbnails:FlxSpriteContainer;
	var downThumbnails:FlxSpriteContainer;

	var thumbnailWidth = FlxG.width / 4;
	var thumbnailHeight = FlxG.height / 4;

	var cameraTween:FlxTween;

	var camThumbnail:FlxCamera;
	var camHUD:FlxCamera;

	var skipTimer:FlxTimer;
	var satan:FlxSprite;

	override function create() {
		camThumbnail = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		camHUD = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		camThumbnail.bgColor = 0xFF000000;
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camThumbnail);
		FlxG.cameras.add(camHUD, false);

		FlxG.cameras.setDefaultDrawTarget(camThumbnail, true);

		super.create();

		Window.setTitle('I THINK THEREFORE I AM');

		if (!Preferences.data.decreaseDetail) {
			for (i in 1...21)
				Paths.image('ui/menus/easterEggStartups/cogitoergosum/' + i);
		}

		upThumbnails = new FlxSpriteContainer();
		add(upThumbnails);

		downThumbnails = new FlxSpriteContainer();
		add(downThumbnails);

		for (x in -1...5) {
			for (y in -2...6) {
				var thumbnail = new FlxSprite(thumbnailWidth * x, thumbnailHeight * y).loadGraphic(getRandomThumbnail());
				thumbnail.setGraphicSize(thumbnailWidth, thumbnailHeight);
				thumbnail.updateHitbox();
				thumbnail.antialiasing = !Preferences.data.enableForcedAliasing;
				if (x % 2 == 0) {
					downThumbnails.add(thumbnail);
					thumbnail.velocity.y = thumbnailHeight / 2;
				} else {
					upThumbnails.add(thumbnail);
					thumbnail.velocity.y = -thumbnailHeight / 2;
				}
			}
		}

		satan = new FlxSprite().loadGraphic(Paths.image('ui/menus/easterEggStartups/cogitoergosum/satan'));
		satan.camera = camHUD;
		satan.alpha = 0;
		satan.setGraphicSize(FlxG.width, FlxG.height);
		satan.updateHitbox();
		satan.antialiasing = !Preferences.data.enableForcedAliasing;
		satan.screenCenter();

		var vignette = new FlxSprite().loadGraphic(Paths.image('ui/menus/easterEggStartups/mask'));
		vignette.camera = camHUD;
		vignette.scale.set(2, 2);
		add(satan);
		add(vignette);

		hateSpeech = new FlxSound().loadEmbedded(Paths.soundRandom('ui/startup/cogitoergosum/hate', 1, 2));
		hateSpeech.volume = Preferences.data.gameSoundVolume;
		hateSpeech.play();

		FlxTween.tween(satan, {alpha: 0.5}, hateSpeech.length * 0.001 / 4, {
			startDelay: hateSpeech.length * 0.001 / 4,
			onComplete: function(_) {
				FlxTween.tween(satan, {alpha: 0}, hateSpeech.length * 0.001 / 4, {
					startDelay: hateSpeech.length * 0.001 / 8
				});
			}
		});

		cameraTween = FlxTween.tween(FlxG.camera, {zoom: 0.67}, hateSpeech.length * 0.001);
		var black = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		black.camera = camHUD;
		add(black);
		FlxTween.tween(black, {alpha: 0.25}, 10);

		skipTimer = new FlxTimer().start(hateSpeech.length * 0.001 - 6, function(_) {
			FlxTween.tween(black, {alpha: 1}, 4, {
				onComplete: function (_) {
					new FlxTimer().start(2, function(_) {
						if (!allowToSkip)
							return;
						FlxTransitionableState.skipNextTransIn = true;
						SuffState.switchState(new MainMenuState());
					});
				}
			});
		});
	}

	function getRandomThumbnail() {
		return Paths.image('ui/menus/easterEggStartups/cogitoergosum/' + FlxG.random.int(1, 20));
	}

	function skipIntro() {
		if (!allowToSkip)
			return;

		skipTimer.cancel();
		hateSpeech.stop();
		FlxTween.cancelTweensOf(satan);
		satan.destroy();
		SuffState.playSound(Paths.sound('ui/startup/cogitoergosum/exit'));
		SuffState.playSound(Paths.sound('explosionLoud'));
		if (!Preferences.data.decreaseDetail) {
			for (i in 0...16) {
				var explode:Explosion = new Explosion(0, 0, FlxG.random.int(2, 6), 0);
				explode.x = FlxG.random.float(0, FlxG.width - explode.width);
				explode.y = FlxG.random.float(0, FlxG.height - explode.height);
				add(explode);
			}
			for (member in downThumbnails) {
				detach(member);
			}
			for (member in upThumbnails) {
				detach(member);
			}
		} else {
			var explode:Explosion = new Explosion(0, 0, 10, 0);
			explode.screenCenter();
			add(explode);
			for (member in downThumbnails) {
				member.destroy();
			}
			for (member in upThumbnails) {
				member.destroy();
			}
		}

		camHUD.alpha = 0.25;
		FlxG.camera.shake(0.01 * Preferences.data.cameraEffectIntensity, 3);
		new FlxTimer().start(1, function(_) {
			FlxG.camera.fade(0xFF000000, 2, false, function() {
				new FlxTimer().start(1, function(_) {
					FlxTransitionableState.skipNextTransIn = true;
					SuffState.switchState(new MainMenuState());
				});
			});
		});

		allowToSkip = false;
	}

	function detach(member:FlxSprite) {
		member.velocity.x = FlxG.random.int(-320, 320);
		member.velocity.y = -FlxG.height + FlxG.random.int(-360, 360);
		member.angularVelocity = FlxG.random.int(-180, 180);
		member.acceleration.y = FlxG.height * 4;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		for (member in downThumbnails) {
			if (member.y > FlxG.height + thumbnailHeight) {
				member.y = -thumbnailHeight * 2;
				if (!Preferences.data.decreaseDetail)
					member.loadGraphic(getRandomThumbnail());
			}
		}
		for (member in upThumbnails) {
			if (member.y < -thumbnailHeight * 2) {
				member.y = FlxG.height + thumbnailHeight;
				if (!Preferences.data.decreaseDetail)
					member.loadGraphic(getRandomThumbnail());
			}
		}
		if (Controls.justPressed('exit') || Controls.justPressed('shoot') || FlxG.mouse.justPressed) {
			skipIntro();
		}
	}
}
