package backend;

import backend.enums.AchievementTier;

/**
 * A store of unchanging, globally relevant values.
 */
@:nullSafety
class Constants {
	// MATH CONSTANTS

	/**
	 * Multiply a radians value by this constant to convert it to degrees.
	 */
	public static final TO_DEGREES:Float = 180 / Math.PI;

	/**
	 * Multiply a degrees value by this constant to convert it to radians.
	 */
	public static final TO_RADIANS:Float = Math.PI / 180;

	public static final GOLDEN_RATIO:Float = (1 + Math.sqrt(5)) / 2;

	// GAMEPLAY CONSTANTS

	/**
	 * How many rounds are stored in the Pump Gun.
	 */
	public static final CYLINDER_CAPACITY:Int = 6;

	/**
	 * How many live rounds are stored in the Pump Gun.
	 */
	public static final LIVE_ROUND_COUNT:Int = 1;

	// VISUAL CONSTANTS
	/**
	 * How fast should the game camera move in default.
	 * 0 means the camera does not move at all.
	 * 1 means the camera moves instantly.
	 */

	/**
	 * The representative color of a player. First item is for Player 1, second is for Player 2, and so on.
	 * Note that every item after the fourth one is unused.
	 */
	public static final PLAYER_COLORS:Array<FlxColor> = [
		0xFFFF0000, // Red
		0xFFFFD000, // Yellow
		0xFF00C000, // Green
		0xFF0060FF, // Blue
		0xFF8000C0, // Purple
		0xFFFF8000, // Orange
		0xFF00D0FF, // Cyan
		0xFFFF00C0, // Magenta
	];

	public static final ACHIEVEMENT_TIER_COLORS:Map<AchievementTier, FlxColor> = [
		AchievementTier.LAME => 0xFFD0A090,
		AchievementTier.COMMON => 0xFFFFFFFF,
		AchievementTier.GOOD => 0xFFFFD000,
		AchievementTier.EPIC => 0xFF00D0FF
	];

	public static final DEFAULT_SPLASH_TEXT_COLORS:Array<FlxColor> = [0xFFFFFF00];

	public static final ORIGINAL_FLXG_WIDTH:Float = 1280;
	public static final ORIGINAL_FLXG_HEIGHT:Float = 720;

	public static final LETTERBOX_RATIO:Float = #if desktop 9 / 20 #else 1 / 2.75 #end;

	/**
	 * The size of CharacterSelectCards.
	 * 1st value is width, 2nd value is height
	 */
	public static final CHARACTER_CARD_DIMENSIONS:Array<Int> = [150, 200];

	#if (_ALLOW_EASTER_EGGS && !mobile)
	public static final EASTER_EGG_INPUTS:Array<String> = ['imhighoncrack', 'blueberryhelium', 'roomoneohone', 'ibeesbees'];
	#end
	public static final ALPHABET_UPPERCASE:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

	// AUDIO CONSTANTS

	/**
	 * How many gurgling sound samples to use.
	 */
	public static final GURGLES_SAMPLE_COUNT:Int = #if !mobile 17 #else 10 #end;

	/**
	 * How many creaking sound samples to use.
	 */
	public static final CREAKS_SAMPLE_COUNT:Int = #if !mobile 9 #else 5 #end;

	/**
	 * How many fwoomping sound samples to use.
	 */
	public static final FWOOMPS_SAMPLE_COUNT:Int = #if !mobile 4 #else 2 #end;

	/**
	 * How many belching sound samples to use.
	 */
	public static final BELCHES_SAMPLE_COUNT:Int = #if !mobile 12 #else 3 #end;
}
