package objects;

import backend.Gameplay;
import backend.typedefs.CharacterData;
import backend.typedefs.CharacterCosmeticData;
import backend.typedefs.SkillData;
import flixel.graphics.frames.FlxAtlasFrames;
import backend.Skill;
import states.PlayState;
import tjson.TJSON as Json;
import shaders.FlashingShader;
import objects.particles.Swirl;
import shaders.DiscolorationMaskedShader;
import openfl.display.BitmapData;
import objects.particles.Liquid;
import objects.particles.Puff;

class Character extends FlxSprite {
	// Metadata //
	public var id:String = 'unnamed';
	// public var name:String = 'Unnamed';
	// public var description:String = 'No description.';
	public var animSoundPaths:Map<String, Array<String>>;
	public var belchThreshold:Int = 3;
	public var leakThreshold:Int = 4;
	public var navelLeakThreshold:Int = 3;
	public var gurgleThreshold:Int = 2;
	public var creakThreshold:Int = 4;
	public var voicePitch:Float = 1;
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
	public var mask:FlxSprite;

	public var discoloration:DiscolorationMaskedShader;

	var gurgleTimer:Float = 0;
	var belchTimer:Float = 25;
	var leakTimer:Float = 25;
	var creakTimer:Float = 0;
	var navelLeakTimer:Float = 0;
	var swirlSpawnTimer:Float = 0;
	static var timerMultiplier:Float = 0;

	public function new(character:String, x:Float = 0, y:Float = 0) {
		this.id = character;
		timerMultiplier = Preferences.data.decreaseSounds ? 3 : 1;
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
		belchThreshold = spriteJson.belchThreshold ?? 3;
		leakThreshold = spriteJson.belchThreshold ?? 4;
		navelLeakThreshold = spriteJson.navelLeakThreshold ?? 3;
		gurgleThreshold = spriteJson.gurgleThreshold ?? 3;
		creakThreshold = spriteJson.creakThreshold ?? 4;
		voicePitch = spriteJson.voicePitch ?? 4;
		if (spriteJson.originPosition != null)
			originPosition = spriteJson.originPosition;
		if (spriteJson.poppedCameraOffset != null)
			poppedCameraOffset = spriteJson.poppedCameraOffset;
		if (spriteJson.cameraOffset != null)
			cameraOffset = spriteJson.cameraOffset;
		if (spriteJson.particleOffsets == null) {
			spriteJson.particleOffsets = {
				overhead: [
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
		particleOffsets.set('overhead', spriteJson.particleOffsets.overhead);
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
					currentSkills.push(new Skill(skillID, skillCost, Gameplay.currentGamemode.skillsCostMultiplier));
				}
			}
		}

		var combinedAtlas:FlxAtlasFrames = Paths.sparrowAtlas('game/characters/$id/${spriteJson.spriteSheets[0]}');
		var combinedMaskAtlas:FlxAtlasFrames = Paths.sparrowAtlas('game/characters/$id/mask/${spriteJson.spriteSheets[0]}');
		for (i in 1...spriteJson.spriteSheets.length) {
			var atlas:FlxAtlasFrames = Paths.sparrowAtlas('game/characters/$id/${spriteJson.spriteSheets[i]}');
			combinedAtlas.addAtlas(atlas, false);
			var maskAtlas:FlxAtlasFrames = Paths.sparrowAtlas('game/characters/$id/mask/${spriteJson.spriteSheets[i]}');
			combinedMaskAtlas.addAtlas(maskAtlas, false);
		}

		if (Preferences.data.enableDiscoloration && Preferences.data.enableGLSL && Gameplay.currentFiller.tintColor != null) {
			var leColor = Gameplay.currentFiller.tintColor;
			var leDestabilization:Array<Float> = Gameplay.currentFiller.destabilizationFactor;
			discoloration = new DiscolorationMaskedShader([leColor.red, leColor.green, leColor.blue]);
			discoloration.destabilization = leDestabilization;
			this.shader = discoloration;
			trace('Discoloration shader created for $id with color $leColor');
		}

		mask = new FlxSprite();
		mask.frames = combinedMaskAtlas;
		super(x, y);
		frames = combinedAtlas;
		antialiasing = (!Preferences.data.enableForcedAliasing) ? !(!spriteJson.antialiasing) : false;

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
					mask.animation.addByIndices(animName, animPrefix, animIndices, "", animFps, animLoop);
				} else {
					animation.addByPrefix(animName, animPrefix, animFps, animLoop);
					mask.animation.addByPrefix(animName, animPrefix, animFps, animLoop);
				}
				if (anim.soundPaths != null && anim.soundPaths.length > 0)
					addSoundPath(animName, anim.soundPaths);
			}
		} else {
			trace('Character $id has no animations');
			animation.addByPrefix('idle0', 'idle0', 24);
		}
		playAnim('idle');
		boundingBox = new FlxRect((width - 200) / 2, 70, 200, 500);
		animation.onFinish.add(function(animName:String) {
			if (idleAfterAnimation && !animName.startsWith('idle'))
				playAnim('idle' + parseAnimationSuffix());
			else if (animExists(animName + '-loop') && !idleAfterAnimation)
				playAnim(animName + '-loop', false, false);
		});
		
		trace(animSoundPaths);
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		if (currentPressure <= maxPressure || !disableBellySounds) {
			if (Preferences.data.enableBellyGurgles && Gameplay.currentFiller.gurgles != null) {
				if (gurgleThreshold > -1 && currentPressure >= gurgleThreshold) {
					gurgleTimer -= elapsed;
					if (gurgleTimer < 0) {
						var intensity = Math.min(1, (currentPressure - gurgleThreshold + 1) / (maxPressure - gurgleThreshold + 1));
						var sound = Gameplay.currentFiller.getGurgleSound();
						SuffState.playSound(sound, intensity * 0.65,
							FlxG.random.float(0.5, 2.0));
						gurgleTimer = sound.length / 1000 + FlxG.random.float(-2.0, 5.0) / intensity * timerMultiplier;
					}
				}
			}
			if (Preferences.data.enableBellyCreaks && Gameplay.currentFiller.creaks != null) {
				if (creakThreshold > -1 && currentPressure >= creakThreshold) {
					creakTimer -= elapsed;
					if (creakTimer < 0) {
						var intensity = Math.min(1, (currentPressure - creakThreshold + 1) / (maxPressure - creakThreshold + 1));
						var sound = Gameplay.currentFiller.getCreakSound();
						SuffState.playSound(sound, intensity * 0.65,
						FlxG.random.float(0.5, 1.0));
						creakTimer = sound.length / 1000 + FlxG.random.float(-2.0, 5.0) / intensity * timerMultiplier;
					}
				}
			}
			if (Preferences.data.enableNavelLeaking && Gameplay.currentFiller.navelLeaks) {
				if (navelLeakThreshold > -1 && currentPressure >= navelLeakThreshold) {
					navelLeakTimer -= elapsed;
					if (navelLeakTimer < 0) {
						var intensity = Math.min(1, (currentPressure - navelLeakThreshold + 1) / (maxPressure - navelLeakThreshold + 1));
						navelLeakTimer = 0.05 / intensity;

						var liquidVelocity = getParticleVelocity(64 * intensity, 0, 64);
						var position = getParticleOffset('navel').add(x, y);
						var liquid = new Liquid(position.x, position.y, PlayState?.instance?.stage?.data?.characterY);
						liquid.velocity.set(liquidVelocity.x, liquidVelocity.y);
						liquid.color = Gameplay.currentFiller.liquidColor;
						if (PlayState?.instance != null) {
							FlxG.state.insert(PlayState.instance.members.indexOf(PlayState.instance.characterGroup) + 1, liquid);
						} else {
							FlxG.state.add(liquid);
						}
					}
				}
			}
			if (animation.curAnim.name.startsWith('idle')) {
				if (Preferences.data.enableBelching && Gameplay.currentFiller.belches != null) {
					if (belchThreshold > -1 && currentPressure >= belchThreshold) {
						belchTimer -= elapsed;
						if (belchTimer < 0) {
							var intensity = Math.min(1, (currentPressure - belchThreshold + 1) / (maxPressure - belchThreshold + 1));
							belchTimer = FlxG.random.float(15, 25) / intensity;
							SuffState.playSound(Gameplay.currentFiller.getBelchSound(), intensity * 0.65,
							voicePitch + FlxG.random.float(-0.025, 0.025));
							playAnim('belch');

							for (i in 0...Math.ceil(10 * intensity)) {
								var liquidVelocity = getParticleVelocity(400 * intensity, 100, 200);
								var position = getParticleOffset('mouth').add(x, y);
								var liquid = new Puff(position.x, position.y, PlayState?.instance?.stage?.data?.characterY);
								liquid.velocity.set(liquidVelocity.x, liquidVelocity.y);
								liquid.color = Gameplay.currentFiller.gasColor;
								if (PlayState?.instance != null) {
									FlxG.state.insert(PlayState.instance.members.indexOf(PlayState.instance.characterGroup) + 1, liquid);
								} else {
									FlxG.state.add(liquid);
								}
							}
						}
					}
				}
				if (Preferences.data.enableOralLeaking && Gameplay.currentFiller.leaks != null) {
					if (leakThreshold > -1 && currentPressure >= leakThreshold) {
						leakTimer -= elapsed;
						if (leakTimer < 0) {
							var intensity = Math.min(1, (currentPressure - leakThreshold + 1) / (maxPressure - leakThreshold + 1));
							leakTimer = FlxG.random.float(15, 25) / intensity;
							SuffState.playSound(Gameplay.currentFiller.getLeakSound(), intensity * 0.65,
							voicePitch + FlxG.random.float(-0.025, 0.025));
							playAnim('leak');

							for (i in 0...Math.ceil(20 * intensity)) {
								var liquidVelocity = getParticleVelocity(100 * intensity, -10, 100);
								var position = getParticleOffset('mouth').add(x, y);
								var liquid = new Liquid(position.x, position.y, PlayState?.instance?.stage?.data?.characterY);
								liquid.velocity.set(liquidVelocity.x, liquidVelocity.y);
								liquid.color = Gameplay.currentFiller.liquidColor;
								if (PlayState?.instance != null) {
									FlxG.state.insert(PlayState.instance.members.indexOf(PlayState.instance.characterGroup) + 1, liquid);
								} else {
									FlxG.state.add(liquid);
								}
							}
						}
					}
				}
			}
		}
		if (!canUseSkills) {
			swirlSpawnTimer -= elapsed;
			if (swirlSpawnTimer <= 0) {
				var offsets = getParticleOffset('overhead');
				FlxG.state.add(new Swirl(this.x + offsets.x + FlxG.random.float(-1, 1) * this.width / 5, this.y + offsets.y + FlxG.random.float() * this.height / 5, 0xFFC040FF));
				swirlSpawnTimer = FlxG.random.float();
			}
		}
		if (mask != null) {
			mask.animation.play(
				this.animation.curAnim.name,
				true,
				false,
				this.animation.curAnim.curFrame
			);
			mask.animation.curAnim.flipX = this.animation.curAnim.flipX;
		}

		if (discoloration != null) {
			discoloration.setMask(mask.frame.parent.bitmap);
			if (currentPressure > 0) {
				// trace(discoloration.strength);
				discoloration.strength += 0.02 * elapsed * getPressurePercentage();
			}
		}
	}

	public function getParticleVelocity(x:Float, y:Float, random:Int = 0):FlxPoint {
		var vel = FlxPoint.get(x, y);
		if (flipX)
			vel.x *= -1;
		if (animation.curAnim.flipX)
			vel.x *= -1;
		if (random != 0)
			vel.add(FlxG.random.int(-random, random), FlxG.random.int(-random, random));
		return vel;
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
				SuffState.playSound(Paths.sound(daSound), 1, voicePitch + FlxG.random.float(-0.1, 0.1));
			}
		}
		
		// trace(id, usedAnimName);
	}
	
	public function getParticleOffset(position:String = 'overhead'):FlxPoint {
		var vel = FlxPoint.get(0, 0);
		if (!particleOffsets.exists(position))
			return vel;
		var offsetArray = particleOffsets.get(position);
		if (currentPressure > maxPressure) {
			var index = (PlayState.currentSessionEnablePopping && !disablePopping) ? (offsetArray.length - 1) : (offsetArray.length - 2);
			vel.set(offsetArray[index][0], offsetArray[index][1]);
		} else {
			vel.set(offsetArray[currentPressure][0], offsetArray[currentPressure][1]);
		}
		if (flipX)
			vel.x *= -1;
		if (animation.curAnim.flipX)
			vel.x *= -1;
		return vel;
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
