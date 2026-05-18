package objects.particleEmitters;

import flixel.graphics.FlxGraphic;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxEmitter.FlxEmitterMode;
import objects.particles.Scrap;

class ScrapEmitter extends FlxTypedEmitter<Scrap> {
	public function new(x, y, characterID:String, floorY:Float = 690) {
		super(x, y, 25);
		particleClass = Scrap;
		Scrap.floorY = floorY;

		var leImage:FlxGraphic = Paths.image('game/particles/scraps/$characterID');
		loadParticles(leImage, FlxG.random.int(6, 10), 0, true);

		start(true, 0.2, 0);
		launchMode = FlxEmitterMode.SQUARE;
		velocity.set(-1440 * 2, -480 * 4, 1440 * 2, 360 * 3);
		acceleration.set(0, 150);
		lifespan.set(999, 999);
		scale.set(1.0, 1.5);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}