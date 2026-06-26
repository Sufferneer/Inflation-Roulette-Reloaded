package ui.plugins;

import flixel.graphics.FlxGraphic;

class Tooltip extends FlxSpriteGroup {
	public static var instance:Null<Tooltip> = null;
	public static final tooltipWidth:Int = 484;

	var bg:FlxSprite;
	var bgOutline:FlxSprite;
	var tooltipText:FlxText;

	public static var text(default, set):String = '';

	static final padding:FlxPoint = new FlxPoint(12, 8);
	static final position:FlxPoint = new FlxPoint(40, -8);
	static final altPosition:FlxPoint = new FlxPoint(-12, 50);

	public static var enabled:Bool = false;

	public function new() {
		super();

		FlxGraphic.defaultPersist = true;

		scrollFactor.set();

		tooltipText = new FlxText(padding.x, padding.y, tooltipWidth, '');
		tooltipText.setFormat(Paths.font('default'), 32, FlxColor.WHITE, LEFT);
		tooltipText.graphic.persist = true;

		bg = new FlxSprite().makeGraphic(1, 1, 0xFF000000, 'plugins/tooltip/bg');
		bg.alpha = 0.7;
		bgOutline = new FlxSprite().loadGraphic(Utilities.makeBorder(1, 1, 4, 0xFFFFFFFF, 'plugins/tooltip/outline'));
		bgOutline.graphic.persist = true;

		add(bg);
		add(bgOutline);
		add(tooltipText);

		FlxGraphic.defaultPersist = false;
	}

	public static function initialize() {
		FlxG.plugins.drawOnTop = true;
		instance = new Tooltip();
		text = '';
		FlxG.plugins.add(instance);
	}

	private static function set_text(value:String):String {
		text = value;
		if (instance == null)
			return value;
		instance.visible = false;

		if (Preferences.data.hideTooltip)
			return value;

		instance.tooltipText.font = Paths.font('default');
		instance.tooltipText.text = text;
		var experimental = new FlxText(0, 0, 0, text);
		experimental.setFormat(Paths.font('default'), 32, FlxColor.WHITE, LEFT);
		var leWidth = Math.min(tooltipWidth, experimental.width) + padding.x * 2;
		var leHeight = instance.tooltipText.height + padding.y * 2;
		experimental.destroy();

		instance.bg.scale.set(leWidth, leHeight);
		instance.bg.updateHitbox();

		Paths.destroyGraphic(FlxG.bitmap.get('plugins/tooltip/outline'));
		instance.bgOutline.loadGraphic(Utilities.makeBorder(leWidth, leHeight, 4, 0xFFFFFFFF, 'plugins/tooltip/outline'));
		instance.visible = (CursorHandler.cursorVisible) && (text.length > 0);
		return value;
	}

	override function update(elapsed:Float) {
		if (instance == null) {
			return;
		}
		super.update(elapsed);
		
		instance.camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
		var leMousePos:FlxPoint = FlxG.mouse.getScreenPosition(this.camera);
		#if !mobile
		if (leMousePos.x + position.x > FlxG.width - instance.bg.width) {
			instance.x = leMousePos.x - instance.bg.width + altPosition.x;
		} else {
			instance.x = leMousePos.x + position.x;
		}
		if (leMousePos.y + position.y > FlxG.height - instance.bg.height) {
			instance.y = leMousePos.y - instance.bg.height + altPosition.y;
		} else {
			instance.y = leMousePos.y + position.y;
		}
		instance.y = FlxMath.bound(instance.y, 0, FlxG.height - instance.bg.height);
		#else
		instance.x = (leMousePos.x > FlxG.width / 2) ? ScreenSafeArea.X : FlxG.width - instance.bg.width - ScreenSafeArea.X;
		instance.y = (leMousePos.y > FlxG.height / 2) ? (Preferences.data.showDebugText ? Main.debugText.height + ScreenSafeArea.Y : ScreenSafeArea.Y) : FlxG.height - instance.bg.height - ScreenSafeArea.Y;
		#end
	}
}
