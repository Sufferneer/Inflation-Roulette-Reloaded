package objects.particles;

class Stain extends FlxSprite {
	public function new(x:Float = 0, y:Float = 0, color:FlxColor = 0xFFFFFFFF) {
		super(x, y);
		loadGraphic(Paths.image('game/particles/stains/' + FlxG.random.int(1, 8)));
		this.antialiasing = !Preferences.data.enableForcedAliasing;
		this.offset.x += this.width / 2;
		this.offset.y += this.height / 2;
		var leScale = FlxG.random.float(0.5, 1.5);
		this.scale.set(leScale, leScale);
		this.color = color;
		this.alpha = 0.5;
		this.flipX = FlxG.random.bool(50);

		FlxTween.tween(this, {alpha: 0}, 4, {
			startDelay: FlxG.random.float(2, 4),
			onComplete: function(_) this.destroy()
		});
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
