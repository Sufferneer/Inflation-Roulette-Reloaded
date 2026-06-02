package backend;

import flixel.graphics.FlxGraphic;
import flixel.util.FlxSpriteUtil;
import openfl.Lib;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import hre.RegExp;

/**
 * Utilities for various functions.
 */
class Utilities {
	/**
	 * Reads a text file, separates each line, and returns them as an Array.
	 * 
	 * @param path The directory relative to the asset folder of the game.
	 */
	inline public static function textFileToArray(path:String, addons:Bool = true):Array<String> {
		var daList:String = null;
		var lePath = Paths.getPath(path);
		#if sys
		if (FileSystem.exists(lePath))
			daList = File.getContent(lePath);
		#if _ALLOW_ADDONS
		if (addons) {
			for (addon in Addons.globalAddons) {
				var lePath = Paths.addons(addon + '/' + path);
				if (FileSystem.exists(lePath))
					daList = daList + '\n' + File.getContent(lePath);
			}
		}
		#end
		#end
		if (daList == null && OpenFlAssets.exists(lePath, TEXT))
			daList = Assets.getText(lePath);
		var leList:Array<String> = listFromString(daList);
		while (leList.remove('') == true) {
			leList.remove('');
		}
		return leList;
	}

	/**
	 * Splits a String into an Array of substrings, then remove any leading and trailing whitespaces from each item.
	 * 
	 * @param string The String to be split.
	 */
	inline public static function listFromString(string:String):Array<String> {
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length)
			daList[i] = daList[i].trim();

		return daList;
	}

	inline public static function formatKey(key:Null<FlxKey>):String {
		var keyName = 'NONE';
		if (key != null) keyName = '$key';
		return Language.getPhrase('keybind.' + keyName, [], Utilities.capitalize(keyName));
	}

	/**
	 * Find the shortest distance between two points (represented by an Array) via Pythagorean theorem.
	 * 
	 * @param SpriteA 1st value: X Position, 2nd value: Y Position
	 * @param SpriteB 1st value: X Position, 2nd value: Y Position
	 */
	public static function distanceBetweenPoints(SpriteA:Array<Float>, SpriteB:Array<Float>):Float {
		return Math.sqrt(Math.pow(SpriteB[0] - SpriteA[0], 2) + Math.pow(SpriteB[1] - SpriteA[1], 2));
	}

	/**
	 * Change the appearance of the mouse cursor.
	 * 
	 * @param tag The cursor used.
	 * @param pressed Whether to use the pressed version of the cursor.
	 */
	public static function changeCursorImage(tag:String, pressed:Bool = false):Void {
		var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/cursor/${tag}' + (pressed ? 'Held' : '')));
		FlxG.mouse.load(spr.pixels, 1, -7, -6);
	}

	/**
	 * Generates a rectangular border.
	 * 
	 * @param tag The cursor used.
	 * @param pressed Whether to use the pressed version of the cursor.
	 */
	public static function makeBorder(width:Float, height:Float, thickness:Int = 5, color:FlxColor = 0xFFFFFFFF):FlxGraphic {
		var spr:FlxSprite = new FlxSprite().makeGraphic(Std.int(width), Std.int(height), 0x0);
		FlxSpriteUtil.drawRect(spr, 0, 0, Std.int(width), Std.int(height), 0x0, {color: color, thickness: thickness * 2}, {smoothing: false});
		return spr.graphic;
	}

	/**
	 * Inverse linear interpolation function.
	 * Calculates the percentage along a range of two values, based on the given lerped value.
	 * 
	 * @param a Starting range.
	 * @param b Ending range.
	 * @param v Lerped value.
	 */
	inline public static function invLerp(a:Float, b:Float, v:Float):Float {
		return (v - a) / (b - a);
	}

	/**
	 * Custom (and unnecessary) function that converts bytes into a human-readable String with appropriate units.
	 * 
	 * @param Bytes The number of bytes to be converted.
	 * @param Precision The number of decimal places to round off to.
	 */
	public static function formatBytes(Bytes:Float, Precision:Int = 2):String {
		var units:Array<String> = ["B", "KiB", "MiB", "GiB", "TiB", "PiB", "EiB", "ZiB", "YiB", "RiB", "QiB"];
		var curUnit = 0;
		while (Bytes >= 1024 && curUnit < units.length - 1) {
			Bytes /= 1024;
			curUnit++;
		}
		return FlxMath.roundDecimal(Bytes, Precision) + ' ' + units[curUnit];
	}

	/**
	 * Opens a hyperlink using your default browser.
	 * 
	 * @param site The URL of the website to be browsed.
	 */
	inline public static function browserLoad(site:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	/**
	 * Returns the directory of the game's save file. Useful for save file access.
	 */
	inline public static function getSavePath():String {
		@:privateAccess
		return FlxG.stage.application.meta.get('company') + '/' + FlxG.stage.application.meta.get('file');
	}

	inline public static function getActualGameTitle():String {
		@:privateAccess
		return haxe.macro.Compiler.getDefine("title");
	}

	/**
	 * Replaces hyphens (-) from a String with whitespaces and returns it.
	 */
	public static function dashToSpace(string:String):String {
		return string.replace("-", " ");
	}

	/**
	 * Replaces whitespaces from a String with hyphens (-) and returns it.
	 */
	public static function spaceToDash(string:String):String {
		return string.replace(" ", "-");
	}

	/**
	 * Positions the center of the game window to a point relative to the top-left of your monitor.
	 * 
	 * @param point The center point where the game window will be placed.
	 */
	public static inline function centerWindowOnPoint(?point:FlxPoint) {
		Lib.application.window.x = Std.int(point.x - (Lib.application.window.width / 2));
		Lib.application.window.y = Std.int(point.y - (Lib.application.window.height / 2));
	}

	/**
	 * Gets the center coordinates of your screen relative to the top-left of your monitor, and returns it as a FlxPoint.
	 */
	public static inline function getCenterWindowPoint():FlxPoint {
		return FlxPoint.get(Lib.application.window.x + (Lib.application.window.width / 2), Lib.application.window.y + (Lib.application.window.height / 2));
	}

	/**
	 * Capitalizes the first letters of each word in a String and returns it.
	 * 
	 * @param str The string to be formatted.
	 */
	public static function capitalize(str:String):String {
		return str.charAt(0).toUpperCase() + str.substr(1, str.length - 1).toLowerCase();
	}

	public static function getUsername():String {
		#if sys
		return Sys.environment()["USERNAME"];
		#else
		return 'User';
		#end
	}

	#if sys
	public static function getExecutablePath(backslash:Bool = #if windows true #else false #end):String {
		if (!backslash)
			return haxe.io.Path.directory(Sys.executablePath()).replace('\\', '/');
		return haxe.io.Path.directory(Sys.executablePath());
	}
	#end

	public static inline function getDarkerShade(color:FlxColor, darkness:Float = 0.25, hueShifted:Bool = true) {
		var hue = color.hue;
		var saturation = color.saturation;
		if (hueShifted) {
			if (hue >= 120 && hue < 270)
				hue += 30 * FlxMath.signOf(darkness);
			else
				hue -= 30 * FlxMath.signOf(darkness);

			saturation = Math.min(1, saturation * 1.1);
		}
		var brightness = Math.min(1, Math.pow(color.brightness * (1 - darkness), Constants.GOLDEN_RATIO));
		return FlxColor.fromHSB(hue, saturation, brightness);
	}

	public static inline function getLighterShade(color:FlxColor, lightness:Float = 0.25, hueShifted:Bool = true) {
		var hue = color.hue;
		var saturation = color.saturation;
		if (hueShifted) {
			if (hue >= 60 && hue <= 270)
				hue -= 30 * FlxMath.signOf(lightness);
			else
				hue = Math.min(hue + 30 * FlxMath.signOf(lightness), 60);

			saturation = Math.max(0, saturation - lightness);
		}
		var brightness = Math.min(1, color.brightness * 1.1);
		return FlxColor.fromHSB(hue, saturation, brightness);
	}

	inline static public function replaceWithSubstr(original:String = '', char:String = ''):String {
		var or:String = original;
		var ret:String = '';
		for (i in 0...or.length) {
			var leChar = char;
			if (original.charAt(i) == ' ')
				leChar = ' ';
			ret += leChar;
		}
		return ret;
	}
	
	inline static public function supportedBySuffirat(str:String):Bool {
		var regex = new RegExp('[\u0000-\u017F]|[\u0370-\u04FF]');
		// Supported Characters: NUL to ſ, Ͱ to ӿ
		return regex.test(str);
	}
}
