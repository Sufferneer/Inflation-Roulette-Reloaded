package backend;

import flixel.system.FlxAssets;

class Language {
	public static final defaultLanguage:String = 'en-us';
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

	public static function fetchPhrases(langID:String = 'en-us'):Map<String, String> {
		phrasesCount.set(langID, 0);
		var lePhrases:Map<String, String> = [];
		var loadedText:Array<String> = Utilities.textFileToArray('lang/$langID.lang');
		for (text in loadedText) {
			// Ignore comments and empty lines
			if (text.startsWith('//') || text == '\n' && text.length <= 0)
				continue;
			var splitText:Array<String> = text.split(' = ');
			if (splitText[1] == null) splitText[1] = '';
			lePhrases.set(splitText[0], splitText[1].replace('\\n', '\n').replace('\\s', ' '));
			phrasesCount[langID] += 1;
			// For some reason, Haxe does not recognize \n as a newline character when reading from a text file
			// Also replace \s with whitespace
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
