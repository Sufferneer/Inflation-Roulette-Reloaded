package objects;

import backend.GameplayManager;
import backend.typedefs.CharacterData;
import backend.typedefs.CharacterCosmeticData;
import backend.typedefs.SkillData;
import flixel.graphics.frames.FlxAtlasFrames;
import backend.Skill;
import states.PlayState;
import tjson.TJSON as Json;
import shaders.FlashingShader;
import objects.particles.Swirl;

class Character extends FlxSprite {
	// Metadata //
	public var id:String = 'unnamed';
	// public var name:String = 'Unnamed';
	// public var description:String = 'No description.';
	public var animSoundPaths:Map<String, Array<String>>;
	public var belchThreshold:Int = 3;
	public var gurgleThreshold:Int = 2;
	public var creakThreshold:Int = 4;
	public var originPosition:Array<Int> = [0, 0];
	public var poppedCameraOffset:Array<Int> = [0, 0];
	public var cameraOffset:Array<Int> = [0, 0];
	public var headParticlePosition:Array<Int> = [0, 0];
	public var particleOffsets:Map<String, Array<Array<Float>>> = [];
	public var poppingGravityMultiplier:Float = 1.0;
	public var poppingVelocityMultiplier:Array<Float> = [1, 1];
	public var disablePopping:Bool = false;

	// Gameplay Variables //
	public var currentPressure:Int = 0;
	public var maxPressure:Int = 4;
	public var currentConfidence:Int = 0;
	public var maxConfidence:Int = 4;
	public var currentSkills:Array<Skill> = [];
	public var skillUseCount:Int = 0;
	public var canUseSkills:Bool = true;

	public var skills:Array<Skill> = [];

	public var cpuControlled:Bool = true;
	public var cpuKnowsCylinderContents:Bool = false;
	public var cpuSabotageVictim:Bool = false;
	public var cpuSkillMemories:Array<String> = [];
	public var cpuSkillLevel:Int = 1;

	public var boundingBox:FlxRect = new FlxRect(170, 70, 300, 500);
	public var hovered:Bool = false;

	// Modifier-Related Variables //
	public var confidenceChangeOnLiveShot:Int = 1;
	public var confidenceChangeOnBlankShot:Int = 1;

	// Cosmetic Variables //
	public var idleAfterAnimation:Bool = true;
	public var disableBellySounds:Bool = false;

	var gurgleTimer:Float = 0;
	var creakTimer:Float = 0;
	var swirlSpawnTimer:Float = 0;

	public function new(character:String, x:Float = 0, y:Float = 0) {
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
		maxConfidence = json.maxConfidence;
		belchThreshold = spriteJson.belchThreshold;
		gurgleThreshold = spriteJson.gurgleThreshold;
		creakThreshold = spriteJson.creakThreshold;
		if (spriteJson.originPosition != null)
			originPosition = spriteJson.originPosition;
		if (spriteJson.poppedCameraOffset != null)
			poppedCameraOffset = spriteJson.poppedCameraOffset;
		if (spriteJson.cameraOffset != null)
			cameraOffset = spriteJson.cameraOffset;
		if (spriteJson.particleOffsets == null) {
			spriteJson.particleOffsets = {
				over: [
					[0, -480],
					[0, -480],
					[0, -480],
					[0, -480],
					[0, -480],
					[-160, -180],
					[-100, -460]
				],
				mouth: [
					[0, -410],
					[0, -410],
					[0, -410],
					[0, -420],
					[0, -440],
					[-100, -140],
					[-80, -420]
				],
				navel: [
					[10, -290],
					[40, -285],
					[70, -280],
					[100, -275],
					[130, -270],
					[40, -160],
					[150, -220]
				],
				gunShoot: [
					[0, -380],
					[0, -380],
					[0, -380],
					[0, -420],
					[0, -420],
					[0, 0],
					[0, 0]
				],
				gunSkill: [
					[0, -320],
					[0, -320],
					[0, -360],
					[0, -400],
					[0, -400],
					[0, 0],
					[0, 0]
				]
			};
		}
		particleOffsets.set('over', spriteJson.particleOffsets.over);
		particleOffsets.set('mouth', spriteJson.particleOffsets.mouth);
		particleOffsets.set('navel', spriteJson.particleOffsets.navel);
		particleOffsets.set('gunShoot', spriteJson.particleOffsets.gunShoot);
		particleOffsets.set('gunSkill', spriteJson.particleOffsets.gunSkill);
		if (spriteJson.poppingVelocityMultiplier != null)
			poppingVelocityMultiplier = spriteJson.poppingVelocityMultiplier;
		disablePopping = !(!spriteJson.disablePopping);
		poppingGravityMultiplier = spriteJson.poppingGravityMultiplier;

		var skillsArray:Array<SkillData> = json.skills;
		if (skillsArray != null && skillsArray.length > 0) {
			for (skill in skillsArray) {
				if (skills.length < 3) {
					var skillID:String = '' + skill.id;
					var skillCost:Int = skill.cost;
					skills.push(new Skill(skillID, skillCost, 1));
					currentSkills.push(new Skill(skillID, skillCost, GameplayManager.currentGamemode.skillsCostMultiplier));
				}
			}
		}

		var combinedAtlas:FlxAtlasFrames = Paths.sparrowAtlas('game/characters/$id/${spriteJson.spriteSheets[0]}');
		for (i in 1...spriteJson.spriteSheets.length) {
			var atlas:FlxAtlasFrames = Paths.sparrowAtlas('game/characters/$id/${spriteJson.spriteSheets[i]}');
			combinedAtlas.addAtlas(atlas, false);
		}
		super(x, y);
		frames = combinedAtlas;
		antialiasing = (!Preferences.data.enableForcedAliasing) ? !(!spriteJson.antialiasing) : false;

		if (Preferences.data.enableGLSL) {
			
		}

		animSoundPaths = new Map<String, Array<String>>();

		var animationsArray = spriteJson.animations;
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
		playAnim('idle');
		boundingBox = new FlxRect((width - 250) / 2, 70, 250, 500);
		animation.onFinish.add(function(animName:String) {
			if (idleAfterAnimation && !animName.startsWith('idle'))
				playAnim('idle' + parseAnimationSuffix());
			else if (animExists(animName + '-loop') && !idleAfterAnimation)
				playAnim(animName + '-loop', false, false);
		});
		
		trace(animSoundPaths);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (currentPressure <= maxPressure || !disableBellySounds) {
			if (Preferences.data.enableBellyGurgles) {
				if (gurgleThreshold > -1 && currentPressure >= gurgleThreshold) {
					gurgleTimer -= elapsed;
					if (gurgleTimer < 0) {
						var intensity = Math.min(1, (currentPressure - gurgleThreshold + 1) / (maxPressure - gurgleThreshold + 1));
						gurgleTimer = FlxG.random.float(1.0, 5.0) / intensity;
						SuffState.playSound(Paths.soundRandom('game/belly/gurgles/gurgle', 1, Constants.GURGLES_SAMPLE_COUNT), intensity * 0.65,
							FlxG.random.float(0.5, 2.0));
					}
				}
			}
			if (Preferences.data.enableBellyCreaks) {
				if (creakThreshold > -1 && currentPressure >= creakThreshold) {
					creakTimer -= elapsed;
					if (creakTimer < 0) {
						var intensity = Math.min(1, (currentPressure - creakThreshold + 1) / (maxPressure - creakThreshold + 1));
						creakTimer = FlxG.random.float(1.0, 5.0) / intensity;
						SuffState.playSound(Paths.soundRandom('game/belly/creaks/creak', 1, Constants.CREAKS_SAMPLE_COUNT), intensity * 0.65,
							FlxG.random.float(0.5, 1.0));
					}
				}
			}
		}
		if (!canUseSkills) {
			swirlSpawnTimer -= elapsed;
			if (swirlSpawnTimer <= 0) {
				var offsets = getParticleOffset('over');
				FlxG.state.add(new Swirl(this.x + offsets.x + FlxG.random.float(-1, 1) * this.width / 5, this.y + offsets.y + FlxG.random.float() * this.height / 5, 0xFFC040FF));
				swirlSpawnTimer = FlxG.random.float();
			}
		}
	}

	function trimAnimationName(AnimName:String) {
		var leAnim = AnimName;
		for (i in 0...maxPressure + 1) {
			leAnim = leAnim.replace('' + i, '');
		}
		leAnim = leAnim.replace('Null', '');
		leAnim = leAnim.replace('Overinflated', '');
		return leAnim;
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

	public function animExists(AnimName:String):Bool {
		return (animation.getByName(AnimName) != null);
	}

	public function playAnim(AnimName:String, BackToIdle:Bool = true, Force:Bool = true, flipX:Bool = false, playSound:Bool = true, Reversed:Bool = false,
			Frame:Int = 0):Void {
		var usedAnimName:String = joinAnimationName(AnimName);
		if (!animExists(usedAnimName)) {
			trace('Animation [${usedAnimName}] for $id does not exist');
			return;
		}
		animation.getByName(usedAnimName).flipX = flipX;
		animation.play(usedAnimName, Force, Reversed, Frame);

		if (Force)
			idleAfterAnimation = BackToIdle;

		offset.set(originPosition[0], originPosition[1]);

		if (playSound) {
			if (animSoundPaths.exists(usedAnimName)) {
				var daSoundList:Array<String> = animSoundPaths.get(usedAnimName);
				var daSound = daSoundList[FlxG.random.int(0, daSoundList.length - 1)];
				SuffState.playSound(Paths.sound(daSound));
			}
		}
		
		// trace(id, usedAnimName);
	}
	
	public function getParticleOffset(position:String = 'over'):FlxPoint {
		if (!particleOffsets.exists(position))
			return FlxPoint.get(0, 0);
		var offsetArray = particleOffsets.get(position);
		if (currentPressure > maxPressure) {
			var index = (PlayState.currentSessionEnablePopping && !disablePopping) ? (offsetArray.length - 1) : (offsetArray.length - 2);
			return FlxPoint.get(offsetArray[index][0] * (this.flipX ? -1 : 1), offsetArray[index][1]);
		} else {
			return FlxPoint.get(offsetArray[currentPressure][0] * (this.flipX ? -1 : 1), offsetArray[currentPressure][1]);
		}
		return FlxPoint.get(0, 0);
	}

	public function parseAnimationSuffix() {
		return switch (currentPressure) {
			case(_ > maxPressure) => true:
				if (PlayState.currentSessionEnablePopping && !disablePopping) 'Null'; else 'Overinflated';
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

	public function getCurAnimLength():Float {
		return getAnimLength(animation.curAnim.name);
	}

	public function getAnimLength(AnimName:String):Float {
		var usedAnimName:String = joinAnimationName(AnimName);
		var leAnim = animation.getByName(usedAnimName);
		return leAnim != null ? (leAnim.frames.length - 1) / leAnim.frameRate : 0;
	}

	public function mouseOverlapsBoundingBox() {
		return FlxG.mouse.x >= this.x - this.offset.x + boundingBox.x && FlxG.mouse.x <= this.x - this.offset.x + boundingBox.x + boundingBox.width && FlxG.mouse.y >= this.y - this.offset.y + boundingBox.y && FlxG.mouse.y <= this.y - this.offset.y + boundingBox.y + boundingBox.height;
	}

	public function isEliminated() {
		return currentPressure > maxPressure;
	}

	override function toString():String {
		return 'Character(id: ${id} | P:${currentPressure} / ${maxPressure} | C:${currentConfidence} / ${maxConfidence})';
	}
}
