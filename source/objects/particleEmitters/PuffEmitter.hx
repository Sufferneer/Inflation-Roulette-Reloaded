package objects.particleEmitters;

import objects.particles.Puff;

class PuffEmitter extends FlxObject {
	public function new(x, y, floorY:Float = 690) {
		super(x, y);
		
		for (i in 0...FlxG.random.int(16, 20)) {
			var puff = new Puff(x, y, floorY);
			var direction = FlxG.random.float(-180, 180);
			var force = FlxG.random.float(720, 1080);
			puff.velocity.x = Math.cos(direction * Constants.TO_RADIANS) * force;
			puff.velocity.y = Math.sin(direction * Constants.TO_RADIANS) * force;
			FlxG.state.add(puff);
		}
		this.destroy();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}