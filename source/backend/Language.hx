package backend;

import flixel.system.FlxAssets;
import hxjson5.Json5;
import tjson.TJSON as Json;
import haxe.DynamicAccess;
import haxe.iterators.DynamicAccessKeyValueIterator;

class Language {
	public static final defaultLanguage:String = 'en-US';
	public static var phrases:Map<String, String> = [];
	public static var fallbackPhrases:Map<String, String> = [];

	public static var phrasesCount:Map<String, Int> = [];

	public static function initialize() {
		phrases = fetchPhrases(Preferences.data.language);
		fallbackPhrases = fetchPhrases(defaultLanguage);

		FlxAssets.FONT_DEFAULT = Paths.font('default');
	}

	public static function getCompletionProgress(languageKey:String) {
		return FlxMath.roundDecimal(phrasesCount.get(languageKey) / phrasesCount.get(defaultLanguage), 3);
	}

	public static function logMissingKeys() {
		var keyList:Array<String> = [];
		for (key in fallbackPhrases.keys()) {
			if (!phrases.exists(key)) {
				keyList.push(key);
				trace(key);
			}
			if (keyList.length >= 14) {
				keyList.push(Language.getPhrase('prompt.andManyMore'));
				break;
			}
		}
		return keyList;
	}

	public static function fetchPhrases(langID:String = 'en-US'):Map<String, String> {
		phrasesCount.set(langID, 0);
		trace('Fetching phrases from $langID');
		var vanillaPhrases:DynamicAccess<String> = Json5.parse(Paths.getTextFromFile('lang/$langID.json5', false));
		var lePhrases:Map<String, String> = [];
		for (key => string in vanillaPhrases) {
			lePhrases.set(key, string);
			phrasesCount[langID] += 1;
		}
		for (addon in Addons.globalAddons) {
			var moddedPhrases:DynamicAccess<String> = Json5.parse(File.getContent(Paths.addons('$addon/lang/$langID.json5')));
			for (key => string in moddedPhrases) {
				lePhrases.set(key, string);
			}
		}
		trace(phrasesCount);
		return lePhrases;
	}

	public static function getPhrase(key:String, parameters:Array<Dynamic> = null, placeholder:String = null):String {
		var phrase:String = phrases.get(key);
		if (phrase == null) // Fallback to the default language if the phrase does not exist in the current language
			phrase = fallbackPhrases.get(key);
		if (phrase == null) { // If the phrase does not exist in the fallback language
			if (placeholder != null) // Empty if phrase is not found and placeholder is empty
				return placeholder;
			return key;
		}
		if (parameters == null) // If no parameters are given, just
			return phrase;
		for (i in 0...parameters.length) {
			var paramKey:String = '%${i + 1}'; // Parameters are 1-indexed in the language files
			var paramValue:Dynamic = parameters[i];
			phrase = phrase.replace(paramKey, Std.string(paramValue));
		}
		return phrase;
	}
}
