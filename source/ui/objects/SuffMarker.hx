package ui.objects;

class SuffMarker extends FlxSprite {
	public function new(x:Float = 0, y:Float = 0, ?color:FlxColor = 0xFFFFFFFF) {
		super(x, y);
		loadGraphic(Paths.image('debug/marker'));
		offset.x += width / 2;
		offset.y += height / 2;
		this.color = color;
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
