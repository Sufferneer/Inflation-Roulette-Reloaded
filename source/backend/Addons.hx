package backend;

import backend.typedefs.AddonMetadata;
import tjson.TJSON as Json;
import tjson.TJSON.TJSON.parse;
import openfl.utils.Assets;
import lime.utils.Bytes;

class Addons {
	public static var globalAddons:Array<String> = [];

	public static function pushGlobalAddons() {
		globalAddons = [];
		#if _ALLOW_ADDONS
		for (addon in updateAddonList()) {
			var pack:Dynamic = getAddonMetadata(addon);
			if (pack != null)
				globalAddons.push(addon);
		}
		#end
		trace('Loaded addons: ' + globalAddons);
		return globalAddons;
	}

	public static function getAddonDirectories():Array<String> {
		var list:Array<String> = [];
		#if _ALLOW_ADDONS
		var addonsFolder:String = Paths.addons();
		if (FileSystem.exists(addonsFolder)) {
			for (folder in FileSystem.readDirectory(addonsFolder)) {
				var path = haxe.io.Path.join([addonsFolder, folder]);
				if (FileSystem.isDirectory(path) && !list.contains(folder))
					list.push(folder);
			}
		}
		#end
		return list;
	}

	public static function getAddonMetadata(?folder:String = null):AddonMetadata {
		#if _ALLOW_ADDONS
		var path = Paths.addons(folder + '/metadata/metadata.json');
		if (FileSystem.exists(path)) {
			var rawJson:String = File.getContent(path);
			trace(rawJson);
			if (rawJson == null || rawJson.length <= 0)
				return null;
			var leParsedJson:AddonMetadata = Json.parse(rawJson);
			return leParsedJson;
		}
		#end
		return null;
	}

	private static function updateAddonList() {
		#if _ALLOW_ADDONS
		var list:Array<String> = [];

		// Scan for folders
		for (folder in getAddonDirectories()) {
			if (folder.trim().length > 0 && FileSystem.exists(Paths.addons(folder)) && FileSystem.isDirectory(Paths.addons(folder))) {
				list.push(folder);
			}
		}

		return list;
		#end
	}
}
