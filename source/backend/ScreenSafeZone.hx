package backend;

class ScreenSafeZone {
	public static var X:Int = 0;
	public static var Y:Int = 0;

	public static function recalculateConstants() {
		X = #if mobile Std.int((FlxG.width * Preferences.data.screenSafeZone * 0.2) / 2) #else 0 #end;
		Y = #if mobile Std.int((FlxG.height * Preferences.data.screenSafeZone * 0.2) / 2) #else 0 #end;
	}
}
