package ui.objects;

class GameLogo extends FlxSprite {
	public static final logoScale:Float = 0.35;

    public function new(x, y) {
        super(x, y);
		loadGraphic(Paths.image('ui/menus/gameLogo'));
		scale.set(logoScale, logoScale);
		updateHitbox();
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
	}
}