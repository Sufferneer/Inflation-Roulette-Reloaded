package ui.plugins;
import ui.plugins.CursorHandler;

class CursorHandler extends FlxBasic {
	public static var instance:Null<CursorHandler> = null;
	public static var cursorVisible(default, set):Bool = false;

	private static function set_cursorVisible(value:Bool):Bool {
		cursorVisible = value;
		FlxG.mouse.visible = #if !mobile cursorVisible #else false #end;
		return value;
	}

	public function new() {
		super();
	}

	public static function initialize() {
		FlxG.plugins.drawOnTop = true;
		instance = new CursorHandler();
		FlxG.plugins.add(instance);
		cursorVisible = true;
	}

	public static var currentCursorStyle:String = 'default';

	public static final cursorStylePriority:Array<String> = ['rub', 'default'];
	public static function setCursorStyle(value:String) {
		if (value == currentCursorStyle)
			return;
		currentCursorStyle = value;
	}

	public override function update(elapsed:Float) {
		if (instance == null || !cursorVisible)
			return;
		if (Preferences.data.useBuiltInCursor)
            Utilities.changeCursorImage(currentCursorStyle, FlxG.mouse.pressed);
		if (Preferences.data.playCursorSounds) {
			if (FlxG.mouse.justPressed) {
				SuffState.playUISound(Paths.sound('ui/cursorClick'), 0.75, FlxG.random.float(2.5, 5));
			} else if (FlxG.mouse.justReleased) {
				SuffState.playUISound(Paths.sound('ui/cursorClick'), 0.25, FlxG.random.float(1.5, 2));
			}
		}
		super.update(elapsed);
	}
}
