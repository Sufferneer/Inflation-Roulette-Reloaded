package objects.particles;

class Explosion extends FlxSprite {
	public function new(x:Float = 0, y:Float = 0, scale:Float = 2, volume:Float = 1, framerateDeviation:Int = 4) {
		super(x, y);
		this.loadGraphic(Paths.image('game/particles/explosion'), true, 66, 100);
		this.animation.add('idle', [for (i in 0...16) i], 24 - FlxG.random.int(-framerateDeviation, framerateDeviation), false);
		this.animation.play('idle');
		this.scale.set(scale, scale);
		this.updateHitbox();
		this.animation.onFinish.add(function(name:String) {
			this.destroy();
		});

		if (volume > 0) {
			SuffState.playSound(Paths.sound('explosion'), volume);
		}
	}
}
