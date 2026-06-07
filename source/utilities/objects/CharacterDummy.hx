package utilities.objects;

class CharacterDummy extends FlxSpriteGroup {
	var dummy:FlxSprite;
	var pointer:FlxSprite;
	public function new(x:Float = 0, y:Float = 0) {
        super();
		dummy = new FlxSprite().loadGraphic(Paths.image('ui/menus/utilities/silhouette'));
		dummy.offset.set(dummy.width / 2, 570);
		add(dummy);

		pointer = new FlxSprite().loadGraphic(Paths.image('debug/marker'));
		pointer.offset.set(pointer.width / 2, pointer.height / 2);
		add(pointer);

		this.x = x;
		this.y = y;
	}
}
