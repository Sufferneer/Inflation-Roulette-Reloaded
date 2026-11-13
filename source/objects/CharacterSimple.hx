package objects;

import backend.typedefs.CharacterData;
import backend.typedefs.CharacterCosmeticData;
import flixel.graphics.frames.FlxAtlasFrames;
import tjson.TJSON as Json;
import backend.Gameplay;
import backend.typedefs.CharacterOffsetsData;

class CharacterSimple extends FlxSprite {
	// Metadata //
	public var id:String = 'unnamed';
	public var originPosition:Array<Float> = [0, 0];

	public var animSoundPaths:Map<String, Array<String>>;

	// Gameplay Variables //
	public var currentPressure:Int = 0;
	public var maxPressure:Int = 4;

	public var gurgleThreshold:Int = 2;
	public var creakThreshold:Int = 4;
	public var bounceScale:Float = 0.02;
	public var bounceFrames:Int = 3;
	public var voicePitch:Float = 1;

	// Cosmetic Variables //
	public var idleAfterAnimation:Bool = true;
	public var disableBellySounds:Bool = false;
	public var popped:Bool = false;
	public var bouncyAnims:Map<String, Bool> = [];
	public var autoPitchAnims:Map<String, Bool> = [];
	public var animBounceTween:FlxTween;

	var gurgleTimer:Float = 0;
	var creakTimer:Float = 0;

	public function new(character:String, x:Float = 0, y:Float = 0) {
		super(x, y);

		this.id = character;
		var json:CharacterData = cast Json.parse(Paths.getTextFromFile('data/characters/' + id + '/stats.json'));
		var cosmeticJson:CharacterCosmeticData = cast Json.parse(Paths.getTextFromFile('data/characters/' + id + '/cosmetic.json'));
		var offsetsJson:CharacterOffsetsData = cast Json.parse(Paths.getTextFromFile('data/characters/' + id + '/offsets.json'));

		// name = json.name;
		/*
		if (json.description != null)
			description = json.description;
		*/
		maxPressure = json.maxPressure;
		if (offsetsJson?.originPosition != null)
			originPosition = offsetsJson.originPosition;
		else if (cosmeticJson?.originPosition != null)
			originPosition = cosmeticJson.originPosition;
		gurgleThreshold = cosmeticJson.gurgleThreshold;
		creakThreshold = cosmeticJson.creakThreshold;
		bounceScale = cosmeticJson.bounceScale ?? 0.02;
		bounceFrames = cosmeticJson.bounceFrames ?? 3;
		voicePitch = cosmeticJson.voicePitch ?? 1;

		var combinedAtlas:FlxAtlasFrames = Paths.getSparrowAtlas('game/characters/$id/${cosmeticJson.spriteSheets[0]}');
		for (i in 1...cosmeticJson.spriteSheets.length) {
			var atlas:FlxAtlasFrames = Paths.getSparrowAtlas('game/characters/$id/${cosmeticJson.spriteSheets[i]}');
			combinedAtlas.addAtlas(atlas, false);
		}
		frames = combinedAtlas;
		antialiasing = (!Preferences.data.enableForcedAliasing) ? !(!cosmeticJson.antialiasing) : false;

		var animationsArray = cosmeticJson.animations;
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
					addSoundPath(animName, anim.soundPaths, anim.autoPitch);
				bouncyAnims.set(animName, anim.bouncy ?? false);
			}
		} else {
			trace('Character $id has no animations');
			animation.addByPrefix('idle0', 'idle0', 24);
			bouncyAnims.set('idle0', false);
		}
		
		trace(animSoundPaths);
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		if (currentPressure <= maxPressure || !disableBellySounds) {
			if (Preferences.data.enableBellyGurgles) {
				if (gurgleThreshold >= -1 && currentPressure >= gurgleThreshold) {
					gurgleTimer -= elapsed;
					if (gurgleTimer < 0) {
						var intensity = Math.min(1, (currentPressure - gurgleThreshold + 1) / (maxPressure - gurgleThreshold + 1));
						gurgleTimer = FlxG.random.float(1.0, 5.0) / intensity;
						SuffState.playSound(Gameplay.currentFiller.getGurgleSound(), intensity * 0.65,
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
						SuffState.playSound(Gameplay.currentFiller.getCreakSound(), intensity * 0.65,
							FlxG.random.float(0.5, 1.0));
					}
				}
			}
		}
	}

	public function animExists(AnimName:String):Bool {
		return (animation.getByName(AnimName) != null);
	}

	public function addSoundPath(name:String, pathArray:Array<String>, autoPitch:Bool = true) {
		if (pathArray == null || pathArray.length <= 0)
			return;
		if (!animSoundPaths.exists(name))
			animSoundPaths.set(name, []);
		for (path in pathArray) {
			animSoundPaths[name].push(path);
		}
		autoPitchAnims.set(name, autoPitch);
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
			if (animSoundPaths.exists(usedAnimName)) {
				var daSoundList:Array<String> = animSoundPaths.get(usedAnimName);
				var daSound = daSoundList[FlxG.random.int(0, daSoundList.length - 1)];
				var pitch = autoPitchAnims.get(usedAnimName) ? voicePitch + FlxG.random.float(-0.1, 0.1) : 1;
				SuffState.playSound(Paths.getSound(daSound), 1, pitch);
			}
		}

		if (bouncyAnims.get(usedAnimName) == true) {
			if (animBounceTween != null) animBounceTween.cancel();
			origin.set(originPosition[0], originPosition[1]);
			scale.set(1 + bounceScale * 2, 1 - bounceScale);
			animBounceTween = FlxTween.tween(this, {'scale.x': 1, 'scale.y': 1}, bounceFrames / animation.curAnim.frameRate, {
				ease: function(f:Float) {
					return Std.int(f);
				}
			});
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
