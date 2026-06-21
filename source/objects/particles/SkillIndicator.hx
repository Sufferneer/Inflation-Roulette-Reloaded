package objects.particles;

import flixel.effects.FlxFlicker;

class SkillIndicator extends FlxSprite {
	public function new(x:Float = 0, originalY:Float = 0, skillID:String = 'reload') {
		super(x, originalY);
		loadGraphic(Paths.image('ui/icons/skills/$skillID'));
		setGraphicSize(80);
		updateHitbox();
		offset.x += width / 2;
		offset.y += height / 2;

		FlxTween.tween(this, {y: originalY - 60}, 0.5, {ease: FlxEase.expoOut, onComplete: function(_) {
			if (!Preferences.data.enablePhotosensitiveMode) {
				FlxFlicker.flicker(this, 0.5, 1 / 30, function(_) {
					this.destroy();
				});
			} else {
				FlxTween.tween(this, {alpha: 0}, 0.5, {
					onComplete: function(_) {
						this.destroy();
					}
				});
			}
		}});
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
