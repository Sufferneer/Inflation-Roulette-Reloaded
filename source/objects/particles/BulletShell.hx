package objects.particles;

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
	var droppedOnFloor:Bool = false;
	var puffSpawnTimer:Float = 0.1;

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (spawnPuff) {
			puffSpawnTimer -= elapsed;
			if (puffSpawnTimer <= 0) {
				var puff = new Puff(this.x, this.y, floorY);
				puff.scale.set(0.625, 0.625);
				FlxG.state.members.insert(FlxG.state.members.indexOf(this), puff);
				puffSpawnTimer = 0.1;
			}
		}
		if (y >= floorY) {
			velocity.y *= -0.55;
			velocity.x *= 0.75;
			angularVelocity = FlxG.random.float(-960, 960);
			if (!droppedOnFloor) {
				SuffState.playSound(Paths.soundRandom('game/shell', 1, 3), 0.5);
				droppedOnFloor = true;
			}
			if (Math.abs(velocity.y) <= 16) {
				velocity.x = velocity.y = acceleration.y = angularVelocity = 0;
				if (!despawning) {
					FlxTween.tween(this, {alpha: 0}, 2, {startDelay: 5 + FlxG.random.float() * 5, onComplete: function(_) {
						this.destroy();
					}});
					despawning = true;
					spawnPuff = false;
				}
			}
		}
	}
}
