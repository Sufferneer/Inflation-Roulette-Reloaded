package backend;

import backend.lunarDate.LunarDate;
import backend.typedefs.SplashCollectionData;
import backend.typedefs.SplashGroupData;
import tjson.TJSON as Json;

class SplashManager {
	public static var activeSplashes:Array<String> = [];
	public static var activeColors:Array<FlxColor> = [];

	public static var usesLunarCalendar:Bool = false;
	public static var isSpecialDay:Bool = false;

	public function new() {
		// Constructor
	}

	public static function parseSplashes() {
		activeSplashes = [];

		var rawJson = Paths.getTextFromFile('data/splashes.json');
		var collection:SplashCollectionData = cast Json.parse(rawJson);

		var gregorianCurrentTime = Date.now();
		var lunarCurrentTime = LunarDate.now();
		trace(gregorianCurrentTime);
		trace(lunarCurrentTime);

		for (splash in collection.shared) {
			activeSplashes.push(splash);
			trace('Shared splash added: $splash');
		}

		isSpecialDay = false;
		for (grp in collection.unique) {
			var group:SplashGroupData = cast grp;
			if (group.start != null && group.end != null) {
				var potentiallyLunar:Bool = false;
				var currentMonth:String = '0';
				var currentDay:String = '0';
				var currentYear:Int = 1;
				if (!group.useLunarCalender) {
					currentYear = gregorianCurrentTime.getFullYear();
					currentMonth = StringTools.lpad(gregorianCurrentTime.getMonth() + 1 + '', '0', 2);
					currentDay = StringTools.lpad(gregorianCurrentTime.getDate() + '', '0', 2);
				} else {
					potentiallyLunar = true;
					currentYear = lunarCurrentTime.year;
					currentMonth = StringTools.lpad(lunarCurrentTime.month + '', '0', 2);
					currentDay = StringTools.lpad(lunarCurrentTime.date + '', '0', 2);
				}
				var currentTime:Date = Date.fromString('$currentYear-$currentMonth-$currentDay');

				var leStartDate:Array<String> = group.start.split('-');
				var leEndDate:Array<String> = group.end.split('-');
				for (s in 0...leStartDate.length) {
					leStartDate[s] = StringTools.lpad(leStartDate[s], '0', 2);
				}
				for (s in 0...leEndDate.length) {
					leEndDate[s] = StringTools.lpad(leEndDate[s], '0', 2);
				}
				var startTime:Date = Date.fromString('$currentYear-${leStartDate[0]}-${leStartDate[1]}');
				var endTime:Date = Date.fromString('$currentYear-${leEndDate[0]}-${leEndDate[1]}');

				if (startTime.getTime() > endTime.getTime()) {
					if (endTime.getTime() < currentTime.getTime()) {
						endTime = Date.fromString('${currentYear + 1}-${leEndDate[0]}-${leEndDate[1]}');
					} else {
						startTime = Date.fromString('${currentYear - 1}-${leStartDate[0]}-${leStartDate[1]}');
					}
				}

				if (startTime.getTime() <= currentTime.getTime() && currentTime.getTime() <= endTime.getTime()) {
					trace('${group.name} - $startTime - $currentTime - $endTime');
					isSpecialDay = true;
					if (potentiallyLunar)
						usesLunarCalendar = true;
					for (splash in group.splashes) {
						activeSplashes.push(splash);
						trace('Time-based splash added: $splash');
					}
					for (color in group.colors) {
						activeColors.push(FlxColor.fromString(color));
					}
				}
			}
		}

		if (!isSpecialDay) {
			for (splash in collection.fallback) {
				activeSplashes.push(splash);
				trace('Fallback splash added: $splash');
			}
			activeColors = Constants.DEFAULT_SPLASH_TEXT_COLORS;
		}
		trace('Colors: ', activeColors);
	}
}
