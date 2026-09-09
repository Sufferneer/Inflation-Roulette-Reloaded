package objects.particleEmitters;

import objects.particles.Sparkle;
import flixel.group.FlxSpriteContainer.FlxTypedSpriteContainer;

class SparkleEmitter extends FlxTypedSpriteContainer<Sparkle> {
	var spawnTick:Float = 0;
	var spawnRate:Float = 1;
	public var parent:FlxObject;
	public var spawnWidth:Float = 0;
	public var spawnHeight:Float = 0;
	public function new(spawnRate:Float = 1, x:Float = 0, y:Float = 0, width:Float = 150, height:Float = 150, parent:FlxObject = null) {
		super(x, y);
		this.spawnRate = spawnRate;
		this.parent = parent;
		this.spawnWidth = width;
		this.spawnHeight = height;
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);

		if (parent != null) {
			if (Std.isOfType(parent, FlxSprite)) {
				var parent:FlxSprite = cast parent;
				this.setPosition(parent.x - parent.offset.x, parent.y - parent.offset.y);
			} else {
				this.setPosition(parent.x, parent.y);
			}
		}
		spawnTick -= elapsed * spawnRate;
		if (spawnTick <= 0) {
			spawnTick = FlxG.random.float();
			add(new Sparkle(this.spawnWidth * FlxG.random.float(), this.spawnHeight * FlxG.random.float(), function(me) {
				this.remove(me, true);
				me.destroy();
			}));
		}
	}
}