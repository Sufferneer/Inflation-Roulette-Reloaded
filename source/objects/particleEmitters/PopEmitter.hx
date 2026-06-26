package objects.particleEmitters;

import objects.particles.Puff;
import states.PlayState;

class PopEmitter extends FlxObject {
	public function new(x, y, floorY:Float = 690, particle:Class<FlxSprite>, particleCountMultiplier:Float = 1, color:FlxColor = 0xFFFFFFFF) {
		super(x, y);
		
		for (i in 0...Math.ceil(FlxG.random.int(30, 40) * particleCountMultiplier)) {
			var puff = Type.createInstance(particle ?? Puff, [x, y, floorY]);
			puff.color = color;
			var direction = FlxG.random.float(-180, 180);
			var force = FlxG.random.float(720, 1080);
			puff.velocity.x = Math.cos(direction * Constants.TO_RADIANS) * force;
			puff.velocity.y = Math.sin(direction * Constants.TO_RADIANS) * force;
			PlayState.instance.particleGroup.add(puff);
		}
		this.destroy();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}