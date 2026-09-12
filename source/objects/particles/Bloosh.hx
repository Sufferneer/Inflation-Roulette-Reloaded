package objects.particles;

import shaders.DiscolorationMaskedShader;
import states.PlayState;

class Bloosh extends FlxSprite {
	// Balt is bloosh!
	// - Ari

	public function new(x:Float = 0, y:Float = 0) {
		super(x, y);
		var graphic = Paths.getImage('game/particles/bloosh');
		loadGraphic(graphic, true, Std.int(graphic.height), Std.int(graphic.height));
		animation.add('idle', [for (i in 0...5) i], 10, false);
		offset.x += width / 2;
		offset.y += height / 2;
		this.alpha = 0.75;
		animation.play('idle', true);
		animation.onFinish.add(function(_) {
			this.kill();
			FlxG.state.remove(this, true);
			this.destroy();
		});
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
