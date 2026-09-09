package objects.particles;

import flixel.effects.particles.FlxParticle;

class Confetti extends FlxParticle {
	var _swaySpeed:Float = 3;
	var _swayDist:Float = 90;

	var _age:Float = 0;
	var _actualScaleX:Float = 0;
	var _actualScaleY:Float = 0;

	public static var floorY:Float = 690;

	public function new() {
		super();
		this._swaySpeed = FlxG.random.float(2, 6);
		this._swayDist = FlxG.random.float(15, 90);
		this._actualScaleX = FlxG.random.int(50, 100) / 100;
		this._actualScaleY = FlxG.random.int(50, 100) / 100;
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		_age += elapsed;
		if (y + velocity.y * elapsed >= floorY - width / 2) {
			angularVelocity = 0;
			angle = 0;
			velocity.x /= (1 + elapsed * 15);
			velocity.y = 0;
		} else {
			offset.x = Math.sin(_age * _swaySpeed / 4) * _swayDist;
			scale.set(_actualScaleX, Math.sin(_age * _swaySpeed) * _actualScaleY);

			velocity.x = FlxMath.lerp(velocity.x, 0, elapsed / 2);
			velocity.y = FlxMath.lerp(velocity.y, 150, elapsed);
		}
	}
}
