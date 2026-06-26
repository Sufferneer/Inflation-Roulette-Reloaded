package objects.particles;
import flixel.graphics.FlxGraphic;

class Scrap extends FlxSprite {
	var _swaySpeed:Float = 3;
	var _swayDist:Float = 180;

	public static var floorY:Float = 690;

	public function new(x, y, characterID:String = 'goober') {
		super(x, y);
		var leImage:FlxGraphic = Paths.image('game/particles/scraps/$characterID');
		loadGraphic(leImage, true, leImage.height, leImage.height);
		animation.add('idle', [FlxG.random.int(0, Std.int(leImage.width / leImage.height) - 1)]);
		animation.play('idle');
		this._swaySpeed = FlxG.random.float(1, 3);
		this._swayDist = FlxG.random.float(45, 180);
	}

	var age:Float = 0;

	public override function update(elapsed:Float) {
		super.update(elapsed);
		age += elapsed;
		if (y + velocity.y * elapsed >= floorY - height * 0.5) {
			velocity.y = 0;
			acceleration.y = 0;
			angle = FlxMath.lerp(angle, 0, elapsed * 3);
		} else {
			offset.x = Math.sin(age * _swaySpeed) * _swayDist;
			angle = Math.sin(age * _swaySpeed) * _swayDist / 5;

			velocity.y = FlxMath.lerp(velocity.y, 150, elapsed * 3);
		}
		velocity.x = FlxMath.lerp(velocity.x, 0, elapsed * 5);
	}
}
