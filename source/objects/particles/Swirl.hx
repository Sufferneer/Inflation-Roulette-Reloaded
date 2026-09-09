package objects.particles;

class Swirl extends FlxSprite {
	public function new(x:Float = 0, y:Float = 0, color:FlxColor = 0xFFFFFFFF, alpha:Float = 0.5) {
		super(x, y);
		var graphic = Paths.getImage('game/particles/swirl');
		loadGraphic(graphic, true, Std.int(graphic.height), Std.int(graphic.height));
		animation.add('idle', [for (i in 0...12) i], FlxG.random.int(10, 14), false);
		animation.play('idle', true);
		offset.x += width / 2;
		offset.y += height / 2;
		angle = FlxG.random.int(0, 4) * 90;
		this.color = color;
		this.alpha = alpha;
		this.velocity.y = FlxG.random.float(-128, -64);
		animation.onFinish.add(function(_) {
			FlxG.state.remove(this, true);
			this.destroy();
		});
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
