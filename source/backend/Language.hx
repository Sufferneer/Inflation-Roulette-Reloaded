package backend;

import flixel.system.FlxAssets;
import tjson.TJSON as Json;
import haxe.DynamicAccess;
using StringTools;
using StringTools;
using StringTools;

using StringTools;

class Language {
	public static final defaultLanguage:String = 'en-US';
	public static var phrases:Map<String, Dynamic> = [];
	public static var fallbackPhrases:Map<String, Dynamic> = [];
	public static var fallbackKeys:Array<String> = [];

	public static var phrasesCount:Map<String, Int> = [];

	public static function initialize() {
		phrases = fetchPhrases(Preferences.data.language);
		fallbackPhrases = fetchPhrases(defaultLanguage);
		fallbackKeys = fetchKeys(defaultLanguage);

		FlxAssets.FONT_DEFAULT = Paths.font('default');
	}

	public static function getCompletionProgress(languageKey:String) {
		return Math.floor(phrasesCount.get(languageKey) / phrasesCount.get(defaultLanguage) * 1000) / 1000;
	}

	public static function logMissingKeys() {
		var keyList:Array<String> = [];
		for (key in fallbackKeys) {
			if (!phrases.exists(key)) {
				keyList.push(key);
				trace(key);
			}
		}
		for (key in phrases.keys()) {
			if (!fallbackPhrases.exists(key)) {
				keyList.push(key);
				trace(key);
			}
		}
		if (keyList.length > 14) {
			keyList.resize(14);
			keyList.push(Language.getPhrase('prompt.andManyMore'));
		}
		return keyList;
	}

	static function addLineToJSON(rawJson:String, key:String) {
		var rawJson = '\n\t"$key": ';
		if (Std.isOfType(fallbackPhrases.get(key), Array)) {
			var leVar:Array<String> = cast fallbackPhrases.get(key);
			leVar = leVar.map(function(str:String):String {
				str = str.replace('\n', '\\n');
				str = str.replace('\t', '\\t');
				str = str.replace('"', '\\"');
				return '"$str"';
			});
			rawJson += '[\n\t\t';
			rawJson += leVar.join(',\n\t\t');
			rawJson += '\n\t],';
		} else {
			var leVar:String = cast fallbackPhrases.get(key);
			leVar = leVar.replace('\n', '\\n');
			leVar = leVar.replace('\t', '\\t');
			leVar = leVar.replace('"', '\\"');
			rawJson += '"' + leVar + '",';
		}
		return rawJson;
	}

	// Returns if there are no missing keys
	public static function exportUnmatchingKeys():Bool {
		var rawJson:String = '{';
		var hasKeys:Bool = false;
		for (key in fallbackKeys) {
			if (!phrases.exists(key)) {
				rawJson += addLineToJSON(rawJson, key);
				hasKeys = true;
				trace(key);
			}
		}
		var hasDeprecatedKeys:Bool = false;
		for (key in phrases.keys()) {
			if (!fallbackPhrases.exists(key)) {
				if (hasDeprecatedKeys) {
					rawJson += '\n';
					hasDeprecatedKeys = true;
				}
				rawJson += addLineToJSON(rawJson, 'DEPRECATED.$key');
				hasKeys = true;
				trace(key);
			}
		}
		if (!hasKeys)
			return false;
		rawJson = rawJson.substr(0, rawJson.length - 1);
		rawJson += '\n}';
		if (!FileSystem.exists('./exports/lang/'))
			FileSystem.createDirectory('./exports/lang/');
		File.saveContent('exports/lang/${Preferences.data.language}_UNMATCHED.json', rawJson);

		return true;
	}

	public static function fetchPhrases(langID:String = 'en-US'):Map<String, Dynamic> {
		phrasesCount.set(langID, 0);
		trace('Fetching phrases from $langID');
		var vanillaPhrases:DynamicAccess<Dynamic> = Json.parse(Paths.getTextFromFile('lang/$langID.json', false));
		var lePhrases:Map<String, Dynamic> = [];
		for (key => string in vanillaPhrases) {
			lePhrases.set(key, string);
			phrasesCount[langID] += 1;
		}
		for (addon in Addons.globalAddons) {
			var moddedPhrases:DynamicAccess<Dynamic> = Json.parse(File.getContent(Paths.addons('$addon/lang/$langID.json')));
			for (key => string in moddedPhrases) {
				lePhrases.set(key, string);
			}
		}
		trace(phrasesCount);
		return lePhrases;
	}

	public static function fetchKeys(langID:String = 'en-US'):Array<String> {
		var keys:Array<String> = [];
		var rawJson:String = Paths.getTextFromFile('lang/$langID.json', false);
		var jsonLines:Array<String> = rawJson.split('\n');
		for (i in 0...jsonLines.length) {
			// jsonLines[i] = jsonLines[i].replace('  ', '');
			jsonLines[i] = jsonLines[i].trim();
			if (jsonLines[i].startsWith('//'))
				continue;
			if (!jsonLines[i].contains('":'))
				continue;
			var keyValuePair:Array<String> = jsonLines[i].split('":');
			keyValuePair[0] = keyValuePair[0].substr(1, keyValuePair[0].length - 1);
			keys.push(keyValuePair[0]);
		}
		return keys;
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

	public static function getPhraseList(key:String, parameters:Array<Dynamic> = null, placeholder:Array<String> = null):Array<String> {
		var phrase:Array<String> = phrases.get(key);
		if (phrase == null) // Fallback to the default language if the phrase does not exist in the current language
			phrase = fallbackPhrases.get(key);
		if (phrase == null) { // If the phrase does not exist in the fallback language
			if (placeholder != null) // Empty if phrase is not found and placeholder is empty
				return placeholder;
			return [key];
		}
		if (parameters == null) // If no parameters are given, just
			return phrase;
		for (j in 0...phrase.length) {
			for (i in 0...parameters.length) {
				var paramKey:String = '%${i + 1}'; // Parameters are 1-indexed in the language files
				var paramValue:Dynamic = parameters[i];
				phrase[j] = phrase[j].replace(paramKey, Std.string(paramValue));
			}
		}
		return phrase;
	}
}
