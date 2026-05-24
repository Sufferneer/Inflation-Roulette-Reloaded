package backend;

import backend.typedefs.MusicMetadata;
import backend.Addons;
import flash.media.Sound;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import lime.utils.Assets;
import openfl.display.BitmapData;
import openfl.display3D.textures.RectangleTexture;
import openfl.utils.Assets as OpenFlAssets;
import openfl.system.System;
import openfl.geom.Rectangle;
import tjson.TJSON as Json;

/**
 * List of functions for getting assets.
 */
class Paths {
	/**
	 * The current used extension for sounds.
	 */
	inline public static var SOUND_EXT = #if _USE_MP3 "mp3" #else "ogg" #end;

	/**
	 * List of directories to be ignored during memory clearing.
	 */
	public static var dumpExclusions:Array<String> = [];

	/**
	 * Preload belly sounds to memory to prevent crashes and lag spikes.
	 */
	public static function precacheBellySounds() {
		var creakType:String = 'air';
		var gurgleType:String = 'air';
		var belchType:String = 'air';
		var burstType:String = 'air';
		for (i in 1...Constants.CREAKS_SAMPLE_COUNT + 1) {
			var key:String = 'game/belly/creaks/creak_' + i;
			precacheSound(key);
		}
		for (i in 1...Constants.GURGLES_SAMPLE_COUNT + 1) {
			var key:String = 'game/belly/gurgles/gurgle_' + i;
			precacheSound(key);
		}
		for (i in 1...Constants.BELCHES_SAMPLE_COUNT + 1) {
			var key:String = 'game/belly/belches/belch_' + i;
			precacheSound(key);
		}
		for (i in 1...Constants.FWOOMPS_SAMPLE_COUNT + 1) {
			var key:String = 'game/belly/fwoomps/fwoompLarge_' + i;
			precacheSound(key);
			key = 'game/belly/fwoomps/fwoompSmall_' + i;
			precacheSound(key);
		}
		precacheSound('game/belly/burst');
	}

	public static function precacheSound(key:String) {
		if (!localTrackedAssets.contains(key)) {
			Paths.sound(key);
		}
	}

	/**
	 * Clear stored assets in memory that is currently not used.
	 */
	public static function clearUnusedMemory() {
		// clear non local assets in the tracked assets list
		for (key in currentTrackedTextures.keys()) {
			// if it is not currently contained within the used local assets
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key)) {
				var obj = currentTrackedTextures.get(key);
				@:privateAccess
				if (obj != null) {
					// remove the key from all cache maps
					FlxG.bitmap._cache.remove(key);
					openfl.Assets.cache.removeBitmapData(key);
					currentTrackedTextures.remove(key);

					// and get rid of the object
					obj.persist = false; // make sure the garbage collector actually clears it up
					obj.destroyOnNoUse = true;
					obj.destroy();
				}
			}
		}

		// run the garbage collector for good measure lmfao
		System.gc();
	}

	/**
	 * List of locally tracked assets.
	 */
	public static var localTrackedAssets:Array<String> = [];

	/**
	 * Clear all assets not in the tracked assets list.
	 */
	public static function clearStoredMemory() {
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys()) {
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null && !currentTrackedTextures.exists(key)) {
				openfl.Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}

		// clear all sounds that are cached
		for (key => asset in currentTrackedSounds) {
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && asset != null) {
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
			}
		}
		// flags everything to be cleared out next unused memory clear
		localTrackedAssets = [];
	}

	/**
	 * Convert a relative directory to a directory in the `assets` folder.
	 * 
	 * @param file
	 */
	public static function getPath(file:String):String {
		return 'assets/$file';
	}

	/**
	 * Convert a relative image directory to a directory in the `assets/images` folder.
	 * 
	 * @param file
	 */
	public static function getImagePath(file:String, suffix:Bool = true):String {
		#if _ALLOW_ADDONS
		var key = addonFolders('images/' + file + (suffix ? '.png' : ''));
		if (key != null)
			return key;
		#end
		return getPath('images/' + file + (suffix ? '.png' : ''));
	}

	public static function getMusicPath(file:String, suffix:Bool = true):String {
		#if _ALLOW_ADDONS
		var key = addonFolders('music/' + file + (suffix ? '.$SOUND_EXT' : ''));
		if (key != null)
			return key;
		#end
		return getPath('music/' + file + (suffix ? '.$SOUND_EXT' : ''));
	}

	public static function getSoundPath(file:String, suffix:Bool = true):String {
		#if _ALLOW_ADDONS
		var key = addonFolders('sounds/' + file + (suffix ? '.$SOUND_EXT' : ''));
		if (key != null)
			return key;
		#end
		return getPath('sounds/' + file + (suffix ? '.$SOUND_EXT' : ''));
	}

	/**
	 * Add the sound extention string to the end of a directory.
	 * 
	 * @param file
	 */
	public static function appendSoundExt(file:String):String {
		return file + '.$SOUND_EXT';
	}

	/**
	 * Scans a folder, then returns its contents' names.
	 * @param path The folder to be scanned.
	 * @param listPath A list txt file for organizing the contents.
	 * @param fileFormat The file format to check for the scanned items. (the period is excluded)
	 * @param addons Whether the function checks the addon folders as well.
	 */
	inline public static function readDirectories(path:String, listPath:String = '', fileFormat:String = '', addons:Bool = true) {
		var pathsInFolder:Array<String> = Utilities.textFileToArray(listPath);
		#if sys
		// Main folder
		if (FileSystem.exists(Paths.getPath(path))) {
			for (i in FileSystem.readDirectory(Paths.getPath(path))) {
				if (!i.endsWith('.$fileFormat'))
					continue;
				var item = i.replace('.$fileFormat', '');
				if (!pathsInFolder.contains(item) && !FileSystem.isDirectory(Paths.getPath(path + '/' + i)))
					pathsInFolder.push(item);
			}
		}

		#if _ALLOW_ADDONS
		if (addons) {
			for (addon in Addons.getGlobalAddons()) {
				if (FileSystem.exists(Paths.addons(addon + '/' + path))) {
					for (i in FileSystem.readDirectory(Paths.addons(addon + '/' + path))) {
						var item = i.replace('.$fileFormat', '');
						if (!pathsInFolder.contains(item) && !FileSystem.isDirectory(Paths.addons(addon + '/' + path + '/' + i)))
							pathsInFolder.push(item);
					}
				}
			}
		}
		#end
		#else
		for (num => item in pathsInFolder) {
			pathsInFolder[num] = item.replace('.$fileFormat', '');
		}
		#end
		return pathsInFolder;
	}

	/**
	 * Scans a folder, then returns its subfolder's names.
	 * @param path The folder to be scanned.
	 * @param listPath A list txt file for organizing the contents.
	 * @param fileToCheck The relative path of the file to be checked for it to be included.
	 * @param addons Whether the function checks the addon folders as well.
	 */
	inline public static function readFolderDirectories(path:String, listPath:String = '', fileToCheck:String = '', addons:Bool = true) {
		var pathsInFolder:Array<String> = Utilities.textFileToArray(listPath);
		#if sys
		// Main folder
		if (FileSystem.exists(Paths.getPath(path))) {
			for (i in FileSystem.readDirectory(Paths.getPath(path))) {
				if (!pathsInFolder.contains(i)
					&& FileSystem.isDirectory(Paths.getPath('$path/$i'))
					&& FileSystem.exists(Paths.getPath('$path/$i/$fileToCheck')))
					pathsInFolder.push(i);
			}
		}

		#if _ALLOW_ADDONS
		if (addons) {
			for (addon in Addons.getGlobalAddons()) {
				if (FileSystem.exists(Paths.addons('$addon/$path'))) {
					for (i in FileSystem.readDirectory(Paths.addons('$addon/$path'))) {
						if (!pathsInFolder.contains(i) && FileSystem.isDirectory(Paths.addons('$addon/$path/$i')) && FileSystem.exists(Paths.addons('$addon/$path/$i/$fileToCheck')))
							pathsInFolder.push(i);
					}
				}
			}
		}
		#end
		#end
		return pathsInFolder;
	}

	/**
	 * Find the XML file for a Sparrow v2 spritesheet.
	 * 
	 * @param file
	 */
	public static function getSparrowXmlPath(file:String):String {
		#if _ALLOW_ADDONS
		var key = addonFolders('images/' + file + '.xml');
		if (key != null)
			return key;
		#end
		return getPath('images/' + file + '.xml');
	}

	/**
	 * Return a Sound in the `sounds/` folder.
	 * 
	 * @param key The filename of the sound.
	 */
	static public function sound(key:String):Sound {
		var sound:Sound = returnSound('sounds', key);
		return sound;
	}

	/**
	 * Return a Sound with variations in the `sounds/` folder.
	 * 
	 * @param key The base filename of the sound.
	 * @param min The minimum suffix value.
	 * @param max The maximum suffix value.
	 */
	inline static public function soundRandom(key:String, min:Int, max:Int) {
		return sound(key + '_' + FlxG.random.int(min, max));
	}

	/**
	 * Return a Sound in the `music/` folder.
	 * 
	 * @param key The filename of the music.
	 */
	inline static public function music(key:String):Sound {
		var file:Sound = returnSound('music', key);
		return file;
	}

	/**
	 * Return a MusicMetadata of a song in the `music/` folder by accessing its JSON metadata file.
	 * 
	 * @param tag The filename of the music.
	 */
	inline static public function musicMetadata(tag:String):MusicMetadata {
		var usedTag:String = tag;
		var json:MusicMetadata = null;
		var rawJson = getTextFromFile('music/' + usedTag + '.json');
		if (rawJson != null) {
			json = cast Json.parse(rawJson);
		}
		return json;
	}

	/**
	 * The list of textures stored in memory for quick access.
	 */
	public static var currentTrackedTextures:Map<String, FlxGraphic> = [];

	/**
	 * Returns a FlxGraphic in the `images/` folder.
	 * 
	 * @param key The directory of the image in the `images/` folder.
	 * @param allowGPU Whether to allow VRAM to store this image or not.
	 */
	static public function image(key:String, useLang:Bool = true, ?allowGPU:Bool = true):FlxGraphic {
		var bitmap:BitmapData = null;
		var file:String = null;

		#if _ALLOW_ADDONS
		file = addonsImages(key);
		if (currentTrackedTextures.exists(file)) {
			localTrackedAssets.push(file);
			return currentTrackedTextures.get(file);
		} else if (FileSystem.exists(file))
			bitmap = BitmapData.fromFile(file);
		else
		#end

		if (useLang) {
			file = lang('images/$key.png');
			if (!fileExists(file))
				file = getPath('images/$key.png');
		} else {
			file = getPath('images/$key.png');
		}
		#if sys
		if (FileSystem.exists(file))
			bitmap = BitmapData.fromFile(file);
		else
		#end
		{
			if (currentTrackedTextures.exists(file)) {
				localTrackedAssets.push(file);
				return currentTrackedTextures.get(file);
			} else if (OpenFlAssets.exists(file, IMAGE))
				bitmap = OpenFlAssets.getBitmapData(file);
		}

		if (bitmap != null) {
			var retVal = cacheBitmap(file, bitmap, allowGPU);
			if (retVal != null)
				return retVal;
		}

		trace('Image does not exist: [$file]');
		return null;
	}

	/**
	 * Stores a texture into memory.
	 * 
	 * @param file The directory of the image in the `images/` folder.
	 * @param bitmap The bitmap data to be stored.
	 * @param allowGPU Whether to allow VRAM to be used or not.
	 */
	static public function cacheBitmap(file:String, ?bitmap:BitmapData = null, ?allowGPU:Bool = true) {
		if (bitmap == null) {
			#if sys
			if (FileSystem.exists(file))
				bitmap = BitmapData.fromFile(file);
			else
			#end
			{
				if (OpenFlAssets.exists(file, IMAGE))
					bitmap = OpenFlAssets.getBitmapData(file);
			}
		}

		localTrackedAssets.push(file);
		#if desktop
		if (allowGPU && Preferences.data.cacheOnGPU) {
			var texture:RectangleTexture = FlxG.stage.context3D.createRectangleTexture(bitmap.width, bitmap.height, BGRA, true);
			texture.uploadFromBitmapData(bitmap);
			bitmap.image.data = null;
			bitmap.dispose();
			bitmap.disposeImage();
			bitmap = BitmapData.fromTexture(texture);
		}
		#end
		var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, file);
		newGraphic.persist = true;
		newGraphic.destroyOnNoUse = false;
		currentTrackedTextures.set(file, newGraphic);
		return newGraphic;
	}

	/**
	 * Reads a text file's contents, then converts it to a String.
	 * 
	 * @param key The directory of the text file.
	 */
	static public function getTextFromFile(key:String, addons:Bool = true):String {
		var path = getPath(key);
		#if sys
		#if _ALLOW_ADDONS
		if (addons) {
			if (FileSystem.exists(addonFolders(key)))
				return File.getContent(addonFolders(key));
		}
		#end
		if (FileSystem.exists(path))
			return File.getContent(path);
		#end

		if (OpenFlAssets.exists(path, TEXT))
			return Assets.getText(path);
		return null;
	}

	inline static public function font(key:String, useLang:Bool = true) {
		if (useLang && fileExists(lang('fonts/${key}_${Preferences.data.language}.ttf')))
			return lang('fonts/${key}_${Preferences.data.language}.ttf');
		return getPath('fonts/$key.ttf');
	}

	public static function fileExists(path:String, ?type:AssetType = null) {
		#if sys
		if (FileSystem.exists(path)) {
			return true;
		}
		#end
		if (OpenFlAssets.exists(path, type)) {
			return true;
		}
		return false;
	}

	/**
	 * Returns a Sparrow v2 Altas to be used for animations for sprites.
	 * 
	 * @param key The directory of both the image and XML file.
	 * @param allowGPU Whether to allow VRAM to store the texture altas or not.
	 */
	inline static public function sparrowAtlas(key:String, ?allowGPU:Bool = true):FlxAtlasFrames {
		var imageLoaded:FlxGraphic = image(key, allowGPU);
		#if _ALLOW_ADDONS
		var xmlExists:Bool = false;

		var xml:String = addonsXml(key);
		if (FileSystem.exists(xml))
			xmlExists = true;

		return FlxAtlasFrames.fromSparrow(imageLoaded, (xmlExists ? File.getContent(xml) : getPath('images/$key.xml')));
		#else
		return FlxAtlasFrames.fromSparrow(imageLoaded, getPath('images/$key.xml'));
		#end
	}

	/**
	 * Map of Sounds that is stored in memory.
	 */
	public static var currentTrackedSounds:Map<String, Sound> = [];

	/**
	 * Returns a Sound by its directory.
	 * 
	 * @param path The directory.
	 * @param key The name to be assigned for the sound for quick access.
	 */
	public static function returnSound(path:String, key:String) {
		var gottenPath:String = appendSoundExt(getPath('$path/$key'));

		#if _ALLOW_ADDONS
		var addonLibPath:String = '';
		if (path != null)
			addonLibPath += '$path';

		var file:String = addonsSounds(addonLibPath, key);
		if (FileSystem.exists(file)) {
			if (!currentTrackedSounds.exists(file)) {
				currentTrackedSounds.set(file, Sound.fromFile(file));
			}
			localTrackedAssets.push(file);
			return currentTrackedSounds.get(file);
		}
		#end

		#if sys
		if (FileSystem.exists(gottenPath)) {
			if (!currentTrackedSounds.exists(gottenPath)) {
				currentTrackedSounds.set(gottenPath, Sound.fromFile(gottenPath));
			}
			localTrackedAssets.push(key);
			return currentTrackedSounds.get(gottenPath);
		}
		#end
		gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
		if (!currentTrackedSounds.exists(gottenPath))
			#if sys
			currentTrackedSounds.set(gottenPath, Sound.fromFile(gottenPath));
			#else
			{
				currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(Paths.getPath(appendSoundExt('$path/$key'))));
			}
			#end
			localTrackedAssets.push(gottenPath);
		return currentTrackedSounds.get(gottenPath);
	}

	inline static public function lang(key:String = '') {
		return getPath('lang/${Preferences.data.language}/$key');
	}

	#if _ALLOW_ADDONS
	inline static public function addons(key:String = '') {
		return 'addons/' + key;
	}

	inline static public function addonsSounds(path:String, key:String) {
		var langPath = addonFolders('lang/${Preferences.data.language}/' + path + '/' + key + '.' + SOUND_EXT);
		if (fileExists(langPath))
			return langPath;
		return addonFolders(path + '/' + key + '.' + SOUND_EXT);
	}

	inline static public function addonsImages(key:String) {
		var langPath = addonFolders('lang/${Preferences.data.language}/images/' + key + '.png');
		if (fileExists(langPath))
			return langPath;
		return addonFolders('images/' + key + '.png');
	}

	inline static public function addonsXml(key:String) {
		var langPath = addonFolders('lang/${Preferences.data.language}/images/' + key + '.xml');
		if (fileExists(langPath))
			return langPath;
		return addonFolders('images/' + key + '.xml');
	}

	static public function addonFolders(key:String) {
		for (addon in Addons.getGlobalAddons()) {
			var fileToCheck:String = addons(addon + '/' + key);
			if (FileSystem.exists(fileToCheck))
				return fileToCheck;
		}
		return null;
	}
	#end
}
