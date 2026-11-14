package backend;

import flixel.system.FlxAssets;
import tjson.TJSON as Json;
import haxe.DynamicAccess;
import sys.FileSystem;
using StringTools;
using StringTools;
using StringTools;

using StringTools;

enum LanguageFormat {
	DEFAULT_JSON5; // e.g. en-us.json5
	UPPERCASE_JSON5; // e.g. en-US.json5
	DEFAULT_JSON; // e.g. en-us.json
	UPPERCASE_JSON; // e.g. en-US.json
	DEFAULT_LEGACY; // e.g. en-us.lang
	UPPERCASE_LEGACY; // e.g. en-US.lang
}

class Language {
	public static final defaultLanguage:String = 'en-us';
	public static var phrases:Map<String, Dynamic> = [];
	public static var fallbackPhrases:Map<String, Dynamic> = null;
	public static var fallbackKeys:Array<String> = [];

	public static var phrasesCount:Map<String, Int> = [];
	public static var languageFormats:Map<String, LanguageFormat> = []; // Language ID => LanguageFormat

	public static function initialize() {
		var prefLang = Preferences.data.language.split('-');
		if (prefLang.length > 1) {
			prefLang[1] = prefLang[1].toLowerCase();
			if (prefLang[0] == 'ca' && prefLang[1] == 'ad')
				prefLang[1] = 'es';
		}
		Preferences.data.language = prefLang.join('-');
		Preferences.savePrefs();
		phrases = fetchPhrases(Preferences.data.language);
		if (phrases == null) {
			trace('$prefLang does not exist. Using en-us');
			Preferences.data.language = defaultLanguage;
			phrases = fetchPhrases(defaultLanguage);
		}
		if (fallbackPhrases == null)
			fallbackPhrases = fetchPhrases(defaultLanguage);
		if (fallbackKeys.length <= 0)
			fallbackKeys = fetchKeys(defaultLanguage);

		FlxAssets.FONT_DEFAULT = Paths.getFont('default');
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
		File.saveContent('exports/lang/${Preferences.data.language}_UNMATCHING.json5', rawJson);

		return true;
	}

	public static function parseLangLegacy(rawText:String = ''):Map<String, String> {
		var lePhrases:Map<String, String> = [];
		var loadedText:Array<String> = Utilities.stringToArray(rawText);
		for (text in loadedText) {
			// Ignore comments and empty lines
			if (text.startsWith('//') || text == '\n' && text.length <= 0)
				continue;
			var splitText:Array<String> = text.split(' = ');
			if (splitText[1] == null) splitText[1] = '';
			lePhrases.set(splitText[0], splitText[1].replace('\\n', '\n').replace('\\s', ' '));
			// For some reason, Haxe does not recognize \n as a newline character when reading from a text file
			// Also replace \s with whitespace
		}
		return lePhrases;
	}

	public static function getLangFormat(langID:String = 'en-us', ?addon:String = ''):Null<LanguageFormat> {
		var lowercaseID = langID.toLowerCase();
		if (languageFormats.exists('$lowercaseID-$addon'))
			return languageFormats.get('$lowercaseID-$addon');
		var what = lowercaseID.split('-');
		var uppercaseID = what[0] + '-' + what[1].toUpperCase();
		var languageFormat:LanguageFormat = null;
		if (addon == '') { // If an addon is not specified
			if (Paths.fileExists(Paths.getPath('lang/$lowercaseID.json5'), TEXT)) languageFormat = DEFAULT_JSON5;
			else if (Paths.fileExists(Paths.getPath('lang/$uppercaseID.json5'), TEXT)) languageFormat = UPPERCASE_JSON5;
			else if (Paths.fileExists(Paths.getPath('lang/$lowercaseID.json'), TEXT)) languageFormat = DEFAULT_JSON;
			else if (Paths.fileExists(Paths.getPath('lang/$uppercaseID.json'), TEXT)) languageFormat = UPPERCASE_JSON;
			else if (Paths.fileExists(Paths.getPath('lang/$lowercaseID.lang'), TEXT)) languageFormat = DEFAULT_LEGACY;
			else if (Paths.fileExists(Paths.getPath('lang/$uppercaseID.lang'), TEXT)) languageFormat = UPPERCASE_LEGACY;
		} else {
			if (FileSystem.exists(Paths.getPathInAddons('$addon/lang/$lowercaseID.json5'))) languageFormat = DEFAULT_JSON5;
			else if (FileSystem.exists(Paths.getPathInAddons('$addon/lang/$uppercaseID.json5'))) languageFormat = UPPERCASE_JSON5;
			else if (FileSystem.exists(Paths.getPathInAddons('$addon/lang/$lowercaseID.json'))) languageFormat = DEFAULT_JSON;
			else if (FileSystem.exists(Paths.getPathInAddons('$addon/lang/$uppercaseID.json'))) languageFormat = UPPERCASE_JSON;
			else if (FileSystem.exists(Paths.getPathInAddons('$addon/lang/$lowercaseID.lang'))) languageFormat = DEFAULT_LEGACY;
			else if (FileSystem.exists(Paths.getPathInAddons('$addon/lang/$uppercaseID.lang'))) languageFormat = UPPERCASE_LEGACY;
		}
		languageFormats.set('$lowercaseID-$addon', languageFormat); // Stores format in memory
		trace('Language $lowercaseID-$addon determined to be of the format $languageFormat');
		return languageFormat;
	}

	public static function getLangRawText(langID:String = 'en-us', addon:String = '', format:LanguageFormat = DEFAULT_JSON5) {
		var lowercaseID = langID.toLowerCase();
		var what = lowercaseID.split('-');
		var uppercaseID = what[0] + '-' + what[1].toUpperCase();
		var rawText = '';
		if (addon == '') {
			switch (format) {
				case DEFAULT_JSON5:
					rawText = Paths.getTextFromFile('lang/$lowercaseID.json5', false);
				case UPPERCASE_JSON5:
					rawText = Paths.getTextFromFile('lang/$uppercaseID.json5', false);
				case DEFAULT_JSON:
					rawText = Paths.getTextFromFile('lang/$lowercaseID.json', false);
				case UPPERCASE_JSON:
					rawText = Paths.getTextFromFile('lang/$uppercaseID.json', false);
				case DEFAULT_LEGACY:
					rawText = Paths.getTextFromFile('lang/$lowercaseID.lang', false);
				case UPPERCASE_LEGACY:
					rawText = Paths.getTextFromFile('lang/$uppercaseID.lang', false);
			}
		} else {
			switch (format) {
				case DEFAULT_JSON5:
					rawText = File.getContent(Paths.getPathInAddons('$addon/lang/$lowercaseID.json5'));
				case UPPERCASE_JSON5:
					rawText = File.getContent(Paths.getPathInAddons('$addon/lang/$uppercaseID.json5'));
				case DEFAULT_JSON:
					rawText = File.getContent(Paths.getPathInAddons('$addon/lang/$lowercaseID.json'));
				case UPPERCASE_JSON:
					rawText = File.getContent(Paths.getPathInAddons('$addon/lang/$uppercaseID.json'));
				case DEFAULT_LEGACY:
					rawText = File.getContent(Paths.getPathInAddons('$addon/lang/$lowercaseID.lang'));
				case UPPERCASE_LEGACY:
					rawText = File.getContent(Paths.getPathInAddons('$addon/lang/$uppercaseID.lang'));
			}
		}
		return rawText;
	}

	public static function parseLangRawText(rawText:String = '', format:LanguageFormat):Map<String, Dynamic> {
		switch (format) {
			case DEFAULT_LEGACY | UPPERCASE_LEGACY:
				return cast parseLangLegacy(rawText);
			default:
				var map:DynamicAccess<Dynamic> = cast Json.parse(rawText);
				var outputMap:Map<String, Dynamic> = [];
				for (key => object in map) {
					outputMap.set(key, object);
				}
				return outputMap;
		}
		return [];
	}

	public static function fetchPhrases(langID:String = 'en-us'):Map<String, Dynamic> {
		var lePhrases:Map<String, Dynamic> = null;
		langID = langID.toLowerCase();
		phrasesCount.set(langID, 0);
		var langFormat = getLangFormat(langID, '');
		var langRawText = getLangRawText(langID, '', langFormat);
		var langMap = parseLangRawText(langRawText, langFormat);
		if (langMap != null) {
			trace('Fetching phrases from $langID');
			if (lePhrases == null)
				lePhrases = [];
			for (key => string in langMap) {
				lePhrases.set(key, string);
				phrasesCount[langID] += 1;
			}
		}
		#if _ALLOW_ADDONS
		for (addon in Addons.globalAddons) {
			var langFormat = getLangFormat(langID, addon);
			if (langFormat == null) continue;
			var langRawText = getLangRawText(langID, addon, langFormat);
			var langMap = parseLangRawText(langRawText, langFormat);
			if (langMap == null) continue;
			if (lePhrases == null)
				lePhrases = [];
			for (key => string in langMap) {
				lePhrases.set(key, string);
				phrasesCount[langID] += 1;
			}
		}
		#end
		trace(phrasesCount);
		return lePhrases;
	}

	public static function fetchKeys(langID:String = 'en-us'):Array<String> {
		var keys:Array<String> = [];
		var rawJson:String = Paths.getTextFromFile('lang/$langID.json5', false) ?? Paths.getTextFromFile('lang/$langID.json', false);
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
		if (phrase == null) { // Fallback to the default language if the phrase does not exist in the current language
			phrase = fallbackPhrases.get(key);
			// trace('$key not yet translated in current language. Using English phrase');
		}
		if (phrase == null) { // If the phrase does not exist in the fallback language
			if (placeholder != null) { // Empty if phrase is not found and placeholder is empty
				// trace('$key does not exist. Using placeholder value');
				return placeholder;
			}
			// trace('$key does not exist.');
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
