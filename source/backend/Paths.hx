package backend;

import backend.typedefs.MusicMetadata;
import backend.Addons;
import openfl.media.Sound;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import lime.utils.Assets;
import openfl.display.BitmapData;
import openfl.utils.Assets as OpenFlAssets;
import openfl.system.System;
import tjson.TJSON as Json;
import flixel.addons.display.FlxRuntimeShader;

/**
 * List of functions for getting assets.
 */
@:access(openfl.display.BitmapData)
class Paths {
	/**
	 * The current used extension for sounds.
	 */
	inline public static var SOUND_EXT = #if _USE_MP3 "mp3" #else "ogg" #end;
	inline public static var VIDEO_EXT = "mp4";

	/**
	 * List of directories to be ignored during memory clearing.
	 */
	public static var dumpExclusions:Array<String> = [
		'assets/music/',
		// 'text',
		'assets/images/ui/plugins/',
		'plugins/',
		'assets/images/ui/menus/achievements/icons/'
	];
	
	public static function isDumpExcluded(key:String) {
		for (prefix in dumpExclusions)
			if (key.startsWith(prefix))	return true;
		return false;
	}

	/**
	 * Clear stored assets in memory that is currently not used.
	 */
	public static function clearUnusedMemory() {
		// clear non-local assets in the tracked assets list
		for (key in currentTrackedTextures.keys()) {
			// if it is not currently contained within the used local assets
			if (!localTrackedAssets.contains(key) && !isDumpExcluded(key)) {
				destroyGraphic(currentTrackedTextures.get(key)); // get rid of the graphic
				currentTrackedTextures.remove(key); // and remove the key from local cache map
			}
		}
		for (key in currentTrackedShaders.keys()) {
			// if it is not currently contained within the used local assets
			if (!localTrackedAssets.contains(key) && !isDumpExcluded(key)) {
				currentTrackedShaders[key] = null;
				currentTrackedShaders.remove(key);
			}
		}

		System.gc();
	}

	/**
	 * List of locally tracked assets.
	 */
	public static var localTrackedAssets:Array<String> = [];

	/**
	 * Clear all assets not in the tracked assets list.
	 */
	@:access(flixel.system.frontEnds.BitmapFrontEnd._cache)
	public static function clearStoredMemory() {
		// clear anything not in the tracked assets list
		for (key in FlxG.bitmap._cache.keys()) {
			if (!currentTrackedTextures.exists(key) && !isDumpExcluded(key) && !FlxG.bitmap.get(key).persist) {
				destroyGraphic(FlxG.bitmap.get(key));
				currentTrackedTextures.remove(key);
			}
		}

		// clear all sounds that are cached
		for (key => asset in currentTrackedSounds) {
			if (!localTrackedAssets.contains(key) && !isDumpExcluded(key) && asset != null) {
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
			}
		}
		// flags everything to be cleared out next unused memory clear
		localTrackedAssets = [];
	}

	public static function destroyGraphic(graphic:FlxGraphic) {
		// free some gpu memory
		@:privateAccess
		if (graphic != null && graphic.bitmap != null && graphic.bitmap.__texture != null)
			graphic.bitmap.__texture.dispose();
		FlxG.bitmap.remove(graphic);
		graphic.persist = false;
		graphic.destroy();
	}


	/**
	 * Convert a relative directory to a directory in the `assets` folder.
	 * 
	 * @param file The path.
	 */
	public static function getPath(file:String):String {
		return 'assets/$file';
	}

	/**
	 * Convert a relative image directory to a directory in the `assets/images` folder.
	 * 
	 * @param file The image path.
	 */
	public static function getImagePath(file:String, suffix:Bool = true):String {
		#if _ALLOW_ADDONS
		var key = getAddonsPath('images/' + file + (suffix ? '.png' : ''));
		if (key != null)
			return key;
		#end
		return getPath('images/' + file + (suffix ? '.png' : ''));
	}

	public static function getMusicPath(file:String, suffix:Bool = true):String {
		#if _ALLOW_ADDONS
		var key = getAddonsPath('music/' + file + (suffix ? '.$SOUND_EXT' : ''));
		if (key != null)
			return key;
		#end
		return getPath('music/' + file + (suffix ? '.$SOUND_EXT' : ''));
	}

	public static function getSoundPath(file:String, suffix:Bool = true):String {
		#if _ALLOW_ADDONS
		var key = getAddonsPath('sounds/' + file + (suffix ? '.$SOUND_EXT' : ''));
		if (key != null)
			return key;
		#end
		return getPath('sounds/' + file + (suffix ? '.$SOUND_EXT' : ''));
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
			for (addon in Addons.globalAddons) {
				if (FileSystem.exists(Paths.getPathInAddons(addon + '/' + path))) {
					for (i in FileSystem.readDirectory(Paths.getPathInAddons(addon + '/' + path))) {
						var item = i.replace('.$fileFormat', '');
						if (!pathsInFolder.contains(item) && !FileSystem.isDirectory(Paths.getPathInAddons(addon + '/' + path + '/' + i)))
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
	public static function readFolderDirectories(path:String, listPath:String = '', fileToCheck:String = '', addons:Bool = true) {
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
			for (addon in Addons.globalAddons) {
				if (FileSystem.exists(Paths.getPathInAddons('$addon/$path'))) {
					for (i in FileSystem.readDirectory(Paths.getPathInAddons('$addon/$path'))) {
						if (!pathsInFolder.contains(i) && FileSystem.isDirectory(Paths.getPathInAddons('$addon/$path/$i')) && FileSystem.exists(Paths.getPathInAddons('$addon/$path/$i/$fileToCheck')))
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
		var key = getAddonsPath('images/' + file + '.xml');
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
	static public function getSound(key:String):Sound {
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
	inline static public function getSoundRandom(key:String, min:Int, max:Int) {
		return getSound(key + '_' + FlxG.random.int(min, max));
	}

	/**
	 * Return a Sound in the `music/` folder.
	 * 
	 * @param key The filename of the music.
	 */
	inline static public function getMusic(key:String):Sound {
		var file:Sound = returnSound('music', key);
		return file;
	}

	/**
	 * Return a MusicMetadata of a song in the `music/` folder by accessing its JSON metadata file.
	 * 
	 * @param tag The filename of the music.
	 */
	inline static public function getMusicMetadata(tag:String):MusicMetadata {
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
	static public function getImage(key:String, useLang:Bool = true, ?allowGPU:Bool = true):Null<FlxGraphic> {
		var bitmap:BitmapData = null;
		var file:String = null;

		#if _ALLOW_ADDONS
		file = getAddonsImages(key);
		if (currentTrackedTextures.exists(file)) {
			localTrackedAssets.push(file);
			return currentTrackedTextures.get(file);
		} else if (FileSystem.exists(file))
			bitmap = BitmapData.fromFile(file);
		else
		#end

		if (useLang) {
			file = getLangPath('images/$key.png');
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
			else #end if (OpenFlAssets.exists(file, IMAGE))
				bitmap = OpenFlAssets.getBitmapData(file);
			if (bitmap == null) {
				trace('Bitmap not found: $file');
				return null;
			}
		}

		#if desktop
		if (allowGPU && Preferences.data?.cacheOnGPU && bitmap.image != null) {
			bitmap.lock();
			@:privateAccess
			if (bitmap.__texture == null) {
				bitmap.image.premultiplied = true;
				bitmap.getTexture(FlxG.stage.context3D);
			}
			bitmap.getSurface();
			bitmap.disposeImage();
			bitmap.image.data = null;
			bitmap.image = null;
			bitmap.readable = true;
		}
		#end
		var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, file);
		newGraphic.persist = true;
		newGraphic.destroyOnNoUse = false;
		localTrackedAssets.push(file);
		currentTrackedTextures.set(file, newGraphic);
		return newGraphic;
	}

	static public function getVideo(key:String) {
		#if _ALLOW_ADDONS
		var file:String = getAddonsVideos(key);
		if (FileSystem.exists(file))
			return file;
		#end
		return getPath('videos/$key.$VIDEO_EXT');
	}

	/**
	 * Reads a text file's contents, then converts it to a String.
	 * 
	 * @param key The directory of the text file.
	 */
	static public function getTextFromFile(key:String, addons:Bool = true):Null<String> {
		var path = getPath(key);
		#if sys
		#if _ALLOW_ADDONS
		if (addons) {
			if (FileSystem.exists(getAddonsPath(key)))
				return File.getContent(getAddonsPath(key));
		}
		#end
		if (FileSystem.exists(path))
			return File.getContent(path);
		#end

		if (OpenFlAssets.exists(path, TEXT))
			return Assets.getText(path);
		return null;
	}

	inline static public function getFont(key:String, useLang:Bool = true) {
		if (useLang && fileExists(getLangPath('fonts/${key}_${Preferences.data.language}.ttf')))
			return getLangPath('fonts/${key}_${Preferences.data.language}.ttf');
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
	 * Returns a Sparrow v2 Atlas to be used for animations for sprites.
	 * 
	 * @param key The directory of both the image and XML file.
	 * @param allowGPU Whether to allow VRAM to store the texture atlas or not.
	 */
	static public function getSparrowAtlas(key:String, xmlPath:String = null, ?allowGPU:Bool = true):FlxAtlasFrames {
		var imageLoaded:FlxGraphic = getImage(key, allowGPU);
		#if _ALLOW_ADDONS
		var xmlExists:Bool = false;

		if (xmlPath == null)
			xmlPath = key;
		var xml:String = getAddonsXml(xmlPath);
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
		#if _ALLOW_ADDONS
		var modFile = getAddonsSounds(path, key);
		if (FileSystem.exists(modFile)) {
			if (!currentTrackedSounds.exists(modFile)) {
				currentTrackedSounds.set(modFile, Sound.fromFile(modFile));
			}
			localTrackedAssets.push(key);
			return currentTrackedSounds.get(modFile);
		}
		#end
		var file:String = getPath('$path/$key.$SOUND_EXT');
		// trace(file);
		if (!currentTrackedSounds.exists(file)) {
			var sound:Sound = null;
			try {
				#if sys
				sound = Sound.fromFile(file);
				#else
				sound = OpenFlAssets.getSound(file);
				#end	
			} catch(e) {
				trace('Sound $path/$key does not exist. Using placeholder sound');
				return null;
			}
			if (sound == null) {
				trace('Sound $path/$key does not exist. Using placeholder sound');
				return null;
			}
			currentTrackedSounds.set(file, sound);
		}
		localTrackedAssets.push(file);
		return currentTrackedSounds.get(file);
	}
	
	inline static public function returnDefaultSound() {
		return returnSound('sounds', 'eh');
	}

	inline static public function getLangPath(key:String = '') {
		return getPath('lang/${Preferences.data.language}/$key');
	}

	public static final fragmentHeader:String = '#pragma header\nuniform float iTime;\nuniform float iTimeDelta;\nuniform float iFrameRate;\nuniform vec4 iMouse;\n\n';
	public static var replaceMap:Array<Array<String>> = [
		['void mainImage(', 'void main('],
		['( out vec4 fragColor, in vec2 fragCoord )', '()'],
		['fragCoord', '(openfl_TextureCoordv * openfl_TextureSize)'],
		['iResolution', 'openfl_TextureSize'],
		['fragColor', 'gl_FragColor'],
		['texture(', 'flixel_texture2D('],
		['iChannel0', 'bitmap']
	];
	
	public static var currentTrackedShaders:Map<String, FlxRuntimeShader> = [];

	public static function getShader(path:String):FlxRuntimeShader {
		var file = 'shaders/$path.frag';
		if (currentTrackedShaders.exists(file))
			return currentTrackedShaders.get(file);
		var fragmentStr = Paths.getTextFromFile(file).trim();
		try {
			if (fragmentStr == null || fragmentStr.length <= 0)
				throw 'Shader file non-existent or contents empty.';
			if (fragmentStr.startsWith('#pragma header'))
				fragmentStr = fragmentStr.replace('#pragma header', fragmentHeader);
			else
				fragmentStr = fragmentHeader + fragmentStr;
			for (string in replaceMap) {
				fragmentStr = fragmentStr.replace(string[0], string[1]);
			}
		} catch(e:Dynamic) {
			trace('Shader $path cannot be parsed: ' + e);
			return null;
		}
		var shader:FlxRuntimeShader = new FlxRuntimeShader(fragmentStr);
		localTrackedAssets.push(file);
		currentTrackedShaders.set(file, shader);
		trace('Loaded shader: $path');
		// FlxG.state.add(shader);
		return shader;
	}

	#if _ALLOW_ADDONS
	inline static public function getPathInAddons(key:String = '') {
		return AndroidUtil.getPath() + 'addons/' + key;
	}

	inline static public function getAddonsSounds(path:String, key:String) {
		var langPath = getAddonsPath('lang/${Preferences.data.language}/' + path + '/' + key + '.' + SOUND_EXT);
		if (langPath != null)
			return langPath;
		return getAddonsPath(path + '/' + key + '.' + SOUND_EXT);
	}

	inline static public function getAddonsImages(key:String) {
		var langPath = getAddonsPath('lang/${Preferences.data.language}/images/' + key + '.png');
		if (langPath != null)
			return langPath;
		return getAddonsPath('images/' + key + '.png');
	}

	inline static public function getAddonsVideos(key:String) {
		var langPath = getAddonsPath('lang/${Preferences.data.language}/videos/' + key + VIDEO_EXT);
		if (langPath != null)
			return langPath;
		return getAddonsPath('videos/' + key + VIDEO_EXT);
	}

	inline static public function getAddonsXml(key:String) {
		var langPath = getAddonsPath('lang/${Preferences.data.language}/images/' + key + '.xml');
		if (langPath != null)
			return langPath;
		return getAddonsPath('images/' + key + '.xml');
	}

	static public function getAddonsPath(key:String) {
		for (addon in Addons.globalAddons) {
			var fileToCheck:String = getPathInAddons(addon + '/' + key);
			if (FileSystem.exists(fileToCheck)) {
				// trace('Fetched from addon $addon: $fileToCheck');
				return fileToCheck;
			}
		}
		return null;
	}
	#end
}
