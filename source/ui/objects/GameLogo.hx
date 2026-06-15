package ui.objects;

class GameLogo extends FlxSprite {
	public static final logoScale:Float = 0.4;

    public function new(x, y) {
        super(x, y);

		antialiasing = !Preferences.data.enableForcedAliasing;

		loadGraphic(Paths.image('ui/menus/gameLogo'));
		scale.set(logoScale, logoScale);
		updateHitbox();
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
	}
}