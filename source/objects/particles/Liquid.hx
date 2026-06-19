package objects.particles;

class Liquid extends FlxSprite {
	var floorY:Float = 690;
	public function new(x:Float = 0, y:Float = 0, ?floorY:Float = 690) {
		super(x, y);
		loadGraphic(Paths.image('game/particles/liquid'));
		// loadGraphic(Paths.image('debug/arrowSquare'));
		this.offset.x += this.width / 2;
		this.offset.y += this.height / 2;
		this.originXLerp = this.width / 2;
		this.floorY = floorY;
		this.angle = angle;
		this.alpha = 0.75;
		this.acceleration.y = 4000;
	}

	var onFloor:Bool = false;
	var originXLerp:Float = 0;
	var scaleXLerp:Float = 0;
	var scaleYLerp:Float = 0;

	public override function update(elapsed:Float) {
		if (!onFloor) {
			if (y >= floorY) {
				this.velocity.x = this.velocity.y = this.acceleration.y = this.angularVelocity = this.angle = 0;
				this.scale.x = 3 + FlxG.random.float() * 2;
				this.origin.x = this.width / 2;
				this.origin.y = this.height * 0.25;
				FlxTween.tween(this.scale, {x: 0, y: 0}, 2, {
					onComplete: function(_) this.destroy(),
					startDelay: FlxG.random.float(2, 5)
				});

				this.onFloor = true;
			} else {
				this.angle = Math.atan(this.velocity.y / this.velocity.x) * Constants.TO_DEGREES;
				var speed = Math.sqrt(this.velocity.x * this.velocity.x + this.velocity.y * this.velocity.y);
				originXLerp = FlxMath.lerp(originXLerp, velocity.x == 0 ? this.width / 2 : (velocity.x > 0 ? this.width : 0), elapsed * 8);
				this.origin.x = originXLerp;
				scaleXLerp = FlxMath.lerp(scaleXLerp, 1 + speed * 0.005, elapsed * 8);
				this.scale.x = scaleXLerp;
				scaleYLerp = FlxMath.lerp(scaleYLerp, 1, elapsed * 8);
				this.scale.y = scaleYLerp;
			}
		}
		super.update(elapsed);
	}
}
