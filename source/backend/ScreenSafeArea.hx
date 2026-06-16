package backend;

class ScreenSafeArea {
	public static var X:Int = 0;
	public static var Y:Int = 0;

	public static function recalculateConstants() {
		X = Std.int((FlxG.width * Preferences.data.screenSafeArea * 0.2) / 2);
		Y = Std.int((FlxG.height * Preferences.data.screenSafeArea * 0.2) / 2);
	}
}
