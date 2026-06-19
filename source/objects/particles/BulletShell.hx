package objects.particles;
import backend.Gameplay;

class BulletShell extends FlxSprite {
	var floorY:Float = 690;
	var spawnPuff:Bool = false;
	public function new(x:Float = 0, y:Float = 0, ?floorY:Float = 690, spawnPuff:Bool = false) {
		super(x, y);
		loadGraphic(Paths.image('game/particles/shell'), true, 20, 30);
		animation.add('idle', spawnPuff ? [0] : [1]);
		animation.play('idle');
		offset.x += width / 2;
		offset.y += height / 2;
		angle = 90 + FlxG.random.float(-20, 20);
		velocity.x = FlxG.random.float(-300, 300);
		velocity.y = FlxG.random.float(-300, 0);
		this.floorY = floorY;
		this.spawnPuff = spawnPuff;
		angularVelocity = FlxG.random.float(-180, 180);
		acceleration.y = 4000;
	}

	var despawning:Bool = false;
	var bouncesLeft:Int = 6;
	var puffSpawnTimer:Float = 0.1;

	public override function update(elapsed:Float) {
		if (spawnPuff) {
			puffSpawnTimer -= elapsed;
			if (puffSpawnTimer <= 0) {
				var puff = Type.createInstance(Gameplay.currentFiller.particleType, [this.x, this.y, floorY]);
				puff.scale.set(0.625, 0.625);
				puff.color = Gameplay.currentFiller.particleColor;
				FlxG.state.members.insert(FlxG.state.members.indexOf(this), puff);
				if (Gameplay.currentFiller.particleType == Liquid)
					puffSpawnTimer = 0.01;
				else
					puffSpawnTimer = 0.1;
			}
		}
		if (y >= floorY && bouncesLeft > 0) {
			bouncesLeft --;
			velocity.y *= -0.5 + FlxG.random.float(-0.2, 0.2);
			this.y += velocity.y * elapsed;
			velocity.x *= 0.75;
			angularVelocity = FlxG.random.float(-1080, 1080);
			if (!Preferences.data.decreaseSounds)
				SuffState.playSound(Paths.sound('game/shell'), Math.pow(bouncesLeft / 6, 2) * 0.5, 1 + FlxG.random.float(-0.02, 0.02));
			if (bouncesLeft <= 0) {
				velocity.x = velocity.y = acceleration.y = angularVelocity = 0;
				angle = 90 * FlxG.random.int(-1, 1, [0]);
				if (!despawning) {
					FlxTween.tween(this, {alpha: 0}, 2, {startDelay: 5 + FlxG.random.float() * 5, onComplete: function(_) {
						this.destroy();
					}});
					despawning = true;
					spawnPuff = false;
				}
			}
		}
		super.update(elapsed);
	}
}
