package objects.particles;

import flixel.effects.FlxFlicker;

class DenialShield extends FlxSprite {
	public function new(x:Float = 0, y:Float = 0) {
		super(x, y);
		loadGraphic(Paths.getImage('game/particles/denialShield'));
		offset.x += width / 2;
		offset.y += height / 2;
		color = 0xFF00C0FF;
		antialiasing = !Preferences.data.enableForcedAliasing;

		if (!Preferences.data.enablePhotosensitiveMode)
			FlxFlicker.flicker(this, 0.25, 1 / 30);
		else {
			alpha = 0;
			FlxTween.tween(this, {alpha: 1}, 0.25);
		}
		FlxTween.tween(this, {alpha: 0}, 1, {
			startDelay: 1,
			onComplete: function(_) {
				FlxG.state.remove(this, true);
				this.destroy();
			}
		});
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
