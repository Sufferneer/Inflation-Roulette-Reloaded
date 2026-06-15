package states.easterEggStartups;

import flixel.group.FlxSpriteContainer;
import objects.particles.Explosion;

class RoomOneOhOneStartupState extends SuffState {
	final soulsCirclingPaths:Array<String> = ['cyan', 'orange', 'blue', 'purple', 'green', 'yellow'];
	final soulCenterPath:String = 'red';
	final soulSize:Int = 32;
	var soulCirclingRadius:Float = 32 * 6;
	var tickSpeed:Float = 1;
	var allowToSkip:Bool = true;
	var skipIntroTimer:FlxTimer;
	var ambientSound:FlxSound;
	var explodeSound:FlxSound;

	var bg:FlxBackdrop;
	var soulCenter:FlxSprite;
	var souls:FlxSpriteContainer = new FlxSpriteContainer();

	override function create() {
		super.create();

		Window.setTitle('YOU\'RE SUPPOSED TO OBEY ME');

		explodeSound = new FlxSound().loadEmbedded(Paths.sound('explosionLoud'));
		explodeSound.volume = Preferences.data.uiSoundVolume;

		ambientSound = new FlxSound().loadEmbedded(Paths.sound('ui/startup/roomoneohone/vibRibbon'));
		ambientSound.volume = Preferences.data.musicVolume;
		ambientSound.play();

		bg = new FlxBackdrop(Paths.image('ui/menus/easterEggStartups/roomoneohone/bg'));
		bg.color = 0xFFFFFFFF;
		bg.velocity.set(60, 60);
		add(bg);

		var bgWhat = new FlxSprite().makeGraphic(Std.int(FlxG.width * 1.1), Std.int(FlxG.height * 1.1), 0xFF000000);
		bgWhat.screenCenter();
		bgWhat.alpha = 0.75;
		add(bgWhat);

		var bgMask = new FlxSprite().loadGraphic(Paths.image('ui/menus/easterEggStartups/mask'));
		bgMask.scale.set(1.1, 1.1);
		add(bgMask);

		add(souls);
		for (num => s in soulsCirclingPaths) {
			var soul:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/menus/easterEggStartups/roomoneohone/souls/$s'));
			soul.setGraphicSize(soulSize);
			soul.updateHitbox();
			soul.offset.y = soul.height - soulSize;
			soul.ID = num;
			souls.add(soul);
		}

		soulCenter = new FlxSprite().loadGraphic(Paths.image('ui/menus/easterEggStartups/roomoneohone/souls/$soulCenterPath'));
		soulCenter.setGraphicSize(soulSize);
		soulCenter.updateHitbox();
		soulCenter.offset.y = soulCenter.height - soulSize;
		soulCenter.screenCenter();
		add(soulCenter);

		skipIntroTimer = new FlxTimer().start(8, function(_) {
			skipIntro();
		});
	}

	function skipIntro() {
		if (!allowToSkip)
			return;

		ambientSound.time = 8 * 1000;

		FlxTween.num(tickSpeed, FlxG.drawFramerate * 0.75, 7, {
			ease: FlxEase.quadIn,
			onComplete: function(_) {
			}
		}, function(num:Float) {
			tickSpeed = num;
		});

		FlxTween.color(bg, 6, bg.color, 0xFFFF0000, {
			ease: FlxEase.cubeIn,
			onUpdate: function(_) {
				bg.alpha = 0.25;
			}
		});
		FlxTween.tween(bg.velocity, {x: 5120, y: 5120}, 7, {ease: FlxEase.quintIn});

		FlxTween.num(ambientSound.pitch, 2, 4, {}, function(num:Float) {
			ambientSound.pitch = num;
		});

		FlxTween.num(soulCirclingRadius, 24, 7, {
			ease: FlxEase.quintIn,
			onComplete: function(_) {
				souls.kill();
				soulCenter.kill();
				if (!Preferences.data.decreaseDetail) {
					for (i in 0...16) {
						var explode:Explosion = new Explosion(0, 0, FlxG.random.int(2, 6), 0);
						explode.x = FlxG.random.float(0, FlxG.width - explode.width);
						explode.y = FlxG.random.float(0, FlxG.height - explode.height);
						add(explode);
					}
				} else {
					var explode:Explosion = new Explosion(0, 0, 10, 0);
					explode.screenCenter();
					add(explode);
				}
				explodeSound.play();
				new FlxTimer().start(0.25, function(_) {
					ambientSound.stop();
					explodeSound.stop();
					FlxTransitionableState.skipNextTransIn = true;
					SuffState.switchState(new MainMenuState());
				});
			}
		}, function(num:Float) {
			soulCirclingRadius = num;
		});

		allowToSkip = false;
	}

	var tick:Float = 0;

	override function update(elapsed:Float) {
		super.update(elapsed);

		soulCenter.y = (FlxG.height - soulCenter.height) / 2 + Math.sin(SuffState.timePassedOnState * 2) * 8;
		if (souls.alive) {
			for (soul in souls) {
				soul.x = soulCenter.x + Math.sin(tick - soul.ID / souls.members.length * Math.PI * 2) * soulCirclingRadius;
				soul.y = soulCenter.y + Math.cos(tick - soul.ID / souls.members.length * Math.PI * 2) * soulCirclingRadius;
			}
		}

		tick += elapsed * tickSpeed;

		var shakeIntensity = (tickSpeed - 1) / 4 * Preferences.data.cameraEffectIntensity;
		var shakeForceX = FlxG.random.float(-shakeIntensity, shakeIntensity);
		var shakeForceY = FlxG.random.float(-shakeIntensity, shakeIntensity);
		FlxG.camera.x = Std.int(shakeForceX);
		FlxG.camera.y = Std.int(shakeForceY);

		if (Controls.justPressed('exit') || Controls.justPressed('shoot') || FlxG.mouse.justPressed) {
			skipIntroTimer.cancel();
			skipIntro();
		}
	}
}
