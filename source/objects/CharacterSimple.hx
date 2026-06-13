package objects;

import backend.typedefs.CharacterData;
import backend.typedefs.CharacterCosmeticData;
import flixel.graphics.frames.FlxAtlasFrames;
import tjson.TJSON as Json;
import backend.GameplayManager;

class CharacterSimple extends FlxSprite {
	// Metadata //
	public var id:String = 'unnamed';
	public var originPosition:Array<Int> = [0, 0];

	public var animSoundPaths:Map<String, Array<String>>;

	// Gameplay Variables //
	public var currentPressure:Int = 0;
	public var maxPressure:Int = 4;

	public var gurgleThreshold:Int = 2;
	public var creakThreshold:Int = 4;

	// Cosmetic Variables //
	public var idleAfterAnimation:Bool = true;
	public var disableBellySounds:Bool = false;
	public var popped:Bool = false;

	var gurgleTimer:Float = 0;
	var creakTimer:Float = 0;

	public function new(character:String, x:Float = 0, y:Float = 0) {
		super(x, y);

		this.id = character;
		var rawJson = Paths.getTextFromFile('data/characters/' + id + '/stats.json');
		var json:CharacterData = cast Json.parse(rawJson);

		var rawJson2 = Paths.getTextFromFile('data/characters/' + id + '/cosmetic.json');
		var spriteJson:CharacterCosmeticData = cast Json.parse(rawJson2);

		// name = json.name;
		/*
		if (json.description != null)
			description = json.description;
		*/
		maxPressure = json.maxPressure;
		if (spriteJson.originPosition != null)
			originPosition = spriteJson.originPosition;
		gurgleThreshold = spriteJson.gurgleThreshold;
		creakThreshold = spriteJson.creakThreshold;

		var combinedAtlas:FlxAtlasFrames = Paths.sparrowAtlas('game/characters/$id/${spriteJson.spriteSheets[0]}');
		for (i in 1...spriteJson.spriteSheets.length) {
			var atlas:FlxAtlasFrames = Paths.sparrowAtlas('game/characters/$id/${spriteJson.spriteSheets[i]}');
			combinedAtlas.addAtlas(atlas, false);
		}
		frames = combinedAtlas;
		antialiasing = (!Preferences.data.enableForcedAliasing) ? !(!spriteJson.antialiasing) : false;

		var animationsArray = spriteJson.animations;
		animSoundPaths = new Map<String, Array<String>>();
		if (animationsArray != null && animationsArray.length > 0) {
			for (anim in animationsArray) {
				var animName:String = '' + anim.name;
				var animPrefix:String = '' + anim.prefix + '0'; // Prevent wocky shit from happening
				var animFps:Int = anim.fps;
				var animLoop:Bool = !(!anim.loop);
				var animIndices:Array<Int> = anim.indices;
				if (animIndices != null && animIndices.length > 0) {
					animation.addByIndices(animName, animPrefix, animIndices, "", animFps, animLoop);
				} else {
					animation.addByPrefix(animName, animPrefix, animFps, animLoop);
				}
				if (anim.soundPaths != null && anim.soundPaths.length > 0)
					addSoundPath(animName, anim.soundPaths);
			}
		} else {
			trace('Character $id has no animations');
			animation.addByPrefix('idle0', 'idle0', 24);
		}
		
		trace(animSoundPaths);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (currentPressure <= maxPressure || !disableBellySounds) {
			if (Preferences.data.enableBellyGurgles) {
				if (gurgleThreshold >= -1 && currentPressure >= gurgleThreshold) {
					gurgleTimer -= elapsed;
					if (gurgleTimer < 0) {
						var intensity = Math.min(1, (currentPressure - gurgleThreshold + 1) / (maxPressure - gurgleThreshold + 1));
						gurgleTimer = FlxG.random.float(1.0, 5.0) / intensity;
						SuffState.playSound(GameplayManager.currentFiller.getGurgleSound(), intensity * 0.65,
							FlxG.random.float(0.5, 2.0));
					}
				}
			}
			if (Preferences.data.enableBellyCreaks) {
				if (creakThreshold >= -1 && currentPressure >= creakThreshold) {
					creakTimer -= elapsed;
					if (creakTimer < 0) {
						var intensity = Math.min(1, (currentPressure - creakThreshold + 1) / (maxPressure - creakThreshold + 1));
						creakTimer = FlxG.random.float(1.0, 5.0) / intensity;
						SuffState.playSound(GameplayManager.currentFiller.getCreakSound(), intensity * 0.65,
							FlxG.random.float(0.5, 1.0));
					}
				}
			}
		}
	}

	public function animExists(AnimName:String):Bool {
		return (animation.getByName(AnimName) != null);
	}

	public function addSoundPath(name:String, pathArray:Array<String>) {
		if (pathArray == null || pathArray.length <= 0)
			return;
		if (!animSoundPaths.exists(name))
			animSoundPaths.set(name, []);
		for (path in pathArray) {
			animSoundPaths[name].push(path);
		}
	}

	public function playAnim(AnimName:String, Force:Bool = true, flipX:Bool = false, playSound:Bool = true, Reversed:Bool = false, Frame:Int = 0):Void {
		var usedAnimName:String = joinAnimationName(AnimName);
		if (!animExists(usedAnimName)) {
			trace('Animation [${usedAnimName}] for $id does not exist');
			return;
		}
		animation.getByName(usedAnimName).flipX = flipX;
		animation.play(usedAnimName, Force, Reversed, Frame);

		offset.set(originPosition[0], originPosition[1]);

		if (playSound) {
			var daSoundList:Array<String> = animSoundPaths.get(usedAnimName);
			if (animSoundPaths.exists(usedAnimName)) {
				var daSound = daSoundList[FlxG.random.int(0, daSoundList.length - 1)];
				SuffState.playSound(Paths.sound(daSound));
			}
		}
	}

	public function parseAnimationSuffix() {
		return switch (currentPressure) {
			case(_ > maxPressure) => true:
				if (popped)
					'Null';
				else
					'Overinflated';
			default:
				'' + currentPressure;
		}
	}

	public function getPressurePercentage(multiplied:Bool = false):Float {
		return currentPressure / maxPressure * (multiplied ? 100 : 1);
	}

	function joinAnimationName(AnimName:String, checkForExistance:Bool = true):String {
		var usedAnimName:String = AnimName;
		if (checkForExistance && animExists(AnimName + parseAnimationSuffix()))
			usedAnimName = AnimName + parseAnimationSuffix();
		return usedAnimName;
	}

	public function isEliminated() {
		return currentPressure > maxPressure;
	}

	override function toString():String {
		return 'Character(id: ${id} | ${currentPressure} / ${maxPressure})';
	}
}
