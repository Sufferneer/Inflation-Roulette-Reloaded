package ui.objects;

class SuffBoolean extends SuffButton {
	public var currentValue(default, set):Bool;
	public var onChangeCallback:Bool->Void;
	public var name:String = '';

	var outline:FlxSprite;
	var parent:FlxSprite;

	public function new(x:Float, y:Float, callback:Bool->Void, defaultValue:Bool = false) {
		onChangeCallback = callback;

		outline = new FlxSprite();
		outline.frames = Paths.sparrowAtlas('ui/menus/options/boolean/outline');
		outline.animation.addByPrefix('true', 'on', 24, false);
		outline.animation.addByPrefix('false', 'off', 24, false);
		outline.animation.play('true');
		outline.updateHitbox();
		super(x, y, outline.width, outline.height, false);
		this.onClick = function() {
			this.currentValue = !this.currentValue;
			onChangeCallback(this.currentValue);
		}

		parent = new FlxSprite();
		parent.frames = Paths.sparrowAtlas('ui/menus/options/boolean/base');
		parent.animation.addByPrefix('true', 'on', 24, false);
		parent.animation.addByPrefix('false', 'off', 24, false);

		add(outline);
		add(parent);

		this.currentValue = defaultValue;

		parent.animation.play('' + defaultValue, true, false, parent.animation.getByName('' + defaultValue).frames.length - 1);

		camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		outline.visible = this.hovered;
	}

	private function set_currentValue(value:Bool):Bool {
		currentValue = value;
		parent.animation.play('' + value, true);
		outline.animation.play('' + value, true);
		return value;
	}
}
