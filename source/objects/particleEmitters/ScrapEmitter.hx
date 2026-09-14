package objects.particleEmitters;

import flixel.graphics.FlxGraphic;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxEmitter.FlxEmitterMode;
import objects.particles.Scrap;
import states.PlayState;
import shaders.DiscolorationShader;

class ScrapEmitter extends FlxObject {
	public function new(x, y, characterID:String, floorY:Float = 690, scrapCount:Int = 4, tint:FlxColor = 0xFFFFFFFF) {
		super(x, y, 25);
		Scrap.floorY = floorY;

		for (i in 0...scrapCount) {
			var scrap = new Scrap(x, y, characterID);
			scrap.color = tint;
			scrap.velocity.set(
				FlxG.random.int(-1440 * 2, 1440 * 2),
				FlxG.random.int(-480 * 4, 360 * 3)
			);
			scrap.acceleration.y = 150;
			if (PlayState?.instance != null)
				PlayState.instance.particleGroup.add(scrap);
			else
				FlxG.state.members.insert(FlxG.state.members.indexOf(this), scrap);
		}
		this.kill();
		FlxG.state.remove(this, true);
		this.destroy();
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
	}
}