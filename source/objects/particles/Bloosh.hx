package objects.particles;

class Bloosh extends FlxSprite {
	// Balt is bloosh!
	// - Ari
	public function new(x:Float = 0, y:Float = 0, ?color:FlxColor = 0xFFFFFFFF, ?alpha:Float = 0.5) {
		super(x, y);
		var graphic = Paths.image('game/particles/bloosh');
		loadGraphic(graphic, true, Std.int(graphic.height), Std.int(graphic.height));
		animation.add('idle', [for (i in 0...6) i], FlxG.random.int(12, 20), false);
		animation.play('idle', true);
		offset.x += width / 2;
		offset.y += height / 2;
		this.color = color;
		this.alpha = alpha;
		animation.onFinish.add(function(_) {
			this.destroy();
		});
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
