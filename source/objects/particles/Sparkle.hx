package objects.particles;

class Sparkle extends FlxSprite {
	static final framerates:Array<Int> = [18, 30];
	public var finishCallback:Sparkle->Void = null;

	public function new(x:Float = 0, y:Float = 0, finishCallback:Sparkle->Void = null) {
		super(x, y);
		var graphic = Paths.image('game/particles/sparkle');
		loadGraphic(graphic, true, Std.int(graphic.height), Std.int(graphic.height));
		animation.add('idle', [0, 1, 2, 3, 2, 1, 0], FlxG.random.int(framerates[0], framerates[1]), false);
		animation.play('idle', true);
		var scale = FlxG.random.float(0.5, 1);
		this.scale.set(scale, scale);
		if (!Preferences.data.decreaseDetail)
			this.blend = ADD;
		updateHitbox();
		offset.x += width / 2;
		offset.y += height / 2;
		antialiasing = !Preferences.data.enableForcedAliasing;
		angle = FlxG.random.int(1, 7) * 45;
		angularVelocity = FlxG.random.int(-6, 6, [0]) * 15;
		this.finishCallback = finishCallback;
		animation.onFinish.add(function(_) {
			if (finishCallback != null)
				finishCallback(this);
			else
				this.destroy();
		});
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
