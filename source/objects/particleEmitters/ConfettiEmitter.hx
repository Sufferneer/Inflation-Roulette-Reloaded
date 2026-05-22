package objects.particleEmitters;

import flixel.graphics.FlxGraphic;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxEmitter.FlxEmitterMode;
import flixel.effects.particles.FlxParticle;
import objects.particles.Confetti;
import states.PlayState;
import backend.Preferences;

class ConfettiEmitter extends FlxTypedEmitter<Confetti> {
	public function new(x:Float, y:Float, angle:Float, floorY:Float = 690) {
		super(x, y);
		particleClass = Confetti;
		Confetti.floorY = floorY;

		var leImage:FlxGraphic = Paths.image('game/particles/confetti');
		loadParticles(leImage, 30, 0, true);

		launchAngle.set(angle - 45, angle + 45);
		angularVelocity.set(-90, 90);
		speed.set(250, 500);
		lifespan.set(30, 30);

		start(true, !Preferences.data.decreaseDetail ? 0.1 : 0.05, 0);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}