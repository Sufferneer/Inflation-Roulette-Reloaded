package backend;

import flixel.input.keyboard.FlxKey;

class Controls {
	public static var keybinds:Map<String, Array<FlxKey>>;

	public static function justPressed(key:String) {
		return FlxG.keys.anyJustPressed(getKeyList(key)) == true;
	}
	public static function pressed(key:String) {
		return FlxG.keys.anyPressed(getKeyList(key)) == true;
	}
	public static function justReleased(key:String) {
		return FlxG.keys.anyJustReleased(getKeyList(key)) == true;
	}
	
	public static function getKeyList(key:String) {
		return [for (i in keybinds.get(key)) if (i != FlxKey.NONE) i];
	}

	public static function reloadKeybinds() {
		keybinds = Preferences.keybinds;
	}
}