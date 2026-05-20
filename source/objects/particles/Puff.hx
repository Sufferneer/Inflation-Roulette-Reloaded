package objects.particles;

class Puff extends FlxSprite {
	var floorY:Float = 690;
	public function new(x, y, floorY) {
		super(x, y);
		var graphic = Paths.image('game/particles/puff');
		loadGraphic(graphic, true, Std.int(graphic.height), Std.int(graphic.height));
		animation.add('idle', [FlxG.random.int(0, 3)]);
		animation.play('idle', true);
		offset.x += width / 2;
		offset.y += height / 2;
		alpha = 0.5;
		var scale = 1 + FlxG.random.float();
		this.scale.set(scale, scale);
		this.floorY = floorY;
		angularVelocity = FlxG.random.float(-45, 45);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (velocity.x > 0) {
			velocity.x -= 1080 * elapsed;
		} else if (velocity.x < 0) {
			velocity.x += 1080 * elapsed;
		}
		if (velocity.y > -200) {
			velocity.y -= 1080 * elapsed;
		} else if (velocity.y < -200) {
			velocity.y += 1080 * elapsed;
		}
		if (y > floorY)
			velocity.y = 0;
		if (Math.abs(velocity.x) <= 32) {
			scale.x -= elapsed / 2;
			scale.y -= elapsed / 2;
		}
		if (this != null && (scale.x <= 0 || scale.y <= 0)) {
			this.destroy();
			return;
		}
	}
}
