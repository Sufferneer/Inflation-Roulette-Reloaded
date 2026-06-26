package objects.particleEmitters;

import flixel.graphics.FlxGraphic;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxEmitter.FlxEmitterMode;
import objects.particles.Scrap;
import states.PlayState;

class ScrapEmitter extends FlxObject {
	public function new(x, y, characterID:String, floorY:Float = 690, scrapCount:Int = 4) {
		super(x, y, 25);
		Scrap.floorY = floorY;

		for (i in 0...scrapCount) {
			var scrap = new Scrap(x, y, characterID);
			velocity.set(
				FlxG.random.int(-1440 * 2, 1440 * 2),
				FlxG.random.int(-480 * 4, 360 * 3)
			);
			acceleration.y = 150;
			if (PlayState.instance != null)
				PlayState.instance.particleGroup.add(scrap);
			else
				FlxG.state.add(scrap);
		}
		destroy();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}