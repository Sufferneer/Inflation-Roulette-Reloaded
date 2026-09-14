package objects;

import backend.Gameplay;
import backend.typedefs.CharacterData;
import backend.typedefs.CharacterCosmeticData;
import backend.typedefs.SkillData;
import flixel.graphics.frames.FlxAtlasFrames;
import backend.Skill;
import states.PlayState;
import tjson.TJSON as Json;
import objects.particles.Swirl;
import shaders.DiscolorationShader;
import objects.particles.Liquid;
import objects.particles.Puff;
import backend.typedefs.CharacterOffsetsData;
import backend.typedefs.CharacterBoxData;
import flixel.util.FlxSpriteUtil;
import objects.particles.HoseboundChain;
import backend.typedefs.CharacterHitboxData;

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
	public var originPosition:Array<Float> = [0, 0];
	public var poppedCameraOffset:Array<Float> = [0, 0];
	public var cameraOffset:Array<Float> = [0, 0];
	public var headParticlePosition:Array<Float> = [0, 0];
	public var particleOffsets:Map<String, Array<Array<Float>>> = [];
	public var poppingGravityMultiplier:Float = 1.0;
	public var poppingVelocityMultiplier:Array<Float> = [1, 1];
	public var disablePopping:Bool = false;
	public var bounceScale:Float = 0.02;
	public var bounceFrames:Int = 3;

	// Gameplay Variables //
	public var currentPressure(default, set):Float = 0;
	public var maxPressure:Int = 4;
	public var currentConfidence:Int = 0;
	public var maxConfidence:Int = 4;
	public var currentSkills:Array<Skill> = [];
	public var skillUseCount:Int = 0;
	public var canUseSkills:Bool = true;
	public var denialCount:Int = 0;
	public var hoseboundIndices:Array<Int> = [];

	public var skills:Array<Skill> = [];

	public var cpuControlled:Bool = true;
	public var cpuKnowsCylinderContents:Bool = false;
	public var cpuSabotageVictim:Bool = false;
	public var cpuSkillMemories:Array<String> = [];
	public var cpuSkillLevel:Int = 1;
	public var rubHitboxes:Array<CharacterBoxData> = [];
	
	public var timeRemaining:Float = -1;

	public var boundingBox:FlxRect = new FlxRect(170, 70, 200, 500);
	public var hovered:Bool = false;
	public var onIdle:Bool = true;

	// Modifier-Related Variables //
	public var confidenceChangeOnLiveShot:Int = 1;
	public var confidenceChangeOnBlankShot:Int = 1;

	// Cosmetic Variables //
	public var idleAfterAnimation:Bool = true;
	public var disableBellySounds:Bool = false;
	public var maskFrames:Map<String, Int> = null;
	public var animToMask:Map<String, String> = [];

	public var rubHitbox:FlxSprite;
	public var bouncyAnims:Map<String, Bool> = [];
	public var autoPitchAnims:Map<String, Bool> = [];
	public var animBounceTween:FlxTween;

	public var discoloration:DiscolorationShader;
	// VORE IN IRR REAL??
	public var stomachNpcContents:Array<String> = [];

	public var gurgleTimer:Float = 0;
	public var belchTimer:Float = 25;
	public var leakTimer:Float = 25;
	public var creakTimer:Float = 0;
	var navelLeakTimer:Float = 0;
	var swirlSpawnTimer:Float = 0;
	var stumbleTimer:Float = 0;
	var ejectTimer:Float = 10;
	var originalPosition:FlxPoint;

	public var cursorOnBelly:Bool = false;
	public var rubValue:Float = 0;
	public var rubDuration:Float = 0;
	public var rubbedComfortably:Bool = false;
	public var forceExpulsionTimer:Float = 0;
	var rubSoundTimer:Float = 0;

	static var timerMultiplier:Float = 1;

	static final missingAnimReplace:Map<String, String> = [
		'rubbed' => 'win',
		'shocked' => 'preWin',
		'belch' => 'shocked',
		'leak' => 'shocked'
	];
	static final idleAnimations:Array<String> = ['idle', 'rubbed', 'win'];

	public function new(character:String, x:Float = 0, y:Float = 0) {
		this.id = character;
		timerMultiplier = Preferences.data.decreaseSounds ? 3 : 1;
		var json:CharacterData = cast Json.parse(Paths.getTextFromFile('data/characters/' + id + '/stats.json')) ?? null;
		var spriteJson:CharacterCosmeticData = cast Json.parse(Paths.getTextFromFile('data/characters/' + id + '/cosmetic.json')) ?? null;
		var offsetsJson:CharacterOffsetsData = cast Json.parse(Paths.getTextFromFile('data/characters/' + id + '/offsets.json')) ?? null;
		var hitboxJson:CharacterHitboxData = cast Json.parse(Paths.getTextFromFile('data/characters/' + id + '/hitbox.json')) ?? null;

		// name = json.name;
		/*
		if (json.description != null)
			description = json.description;
		*/
		maxPressure = json?.maxPressure ?? 4;
		maxConfidence = json?.maxConfidence ?? 4;
		belchThreshold = spriteJson?.belchThreshold ?? 3;
		leakThreshold = spriteJson?.leakThreshold ?? 4;
		navelLeakThreshold = spriteJson?.navelLeakThreshold ?? 3;
		gurgleThreshold = spriteJson?.gurgleThreshold ?? 3;
		creakThreshold = spriteJson?.creakThreshold ?? 4;
		voicePitch = spriteJson?.voicePitch ?? 4;
		if (offsetsJson?.originPosition != null)
			originPosition = offsetsJson.originPosition;
		if (offsetsJson?.poppedCameraOffset != null)
			poppedCameraOffset = offsetsJson.poppedCameraOffset;
		if (offsetsJson?.cameraOffset != null)
			cameraOffset = offsetsJson.cameraOffset;
		if (offsetsJson?.particleOffsets == null) {
			offsetsJson.particleOffsets = {
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
		particleOffsets.set('overhead', offsetsJson.particleOffsets.overhead);
		particleOffsets.set('mouth', offsetsJson.particleOffsets.mouth);
		particleOffsets.set('navel', offsetsJson.particleOffsets.navel);
		particleOffsets.set('gunShoot', offsetsJson.particleOffsets.gunShoot);
		particleOffsets.set('gunSkill', offsetsJson.particleOffsets.gunSkill);
		if (spriteJson.poppingVelocityMultiplier != null)
			poppingVelocityMultiplier = spriteJson.poppingVelocityMultiplier;
		disablePopping = spriteJson.disablePopping ?? false;
		poppingGravityMultiplier = spriteJson.poppingGravityMultiplier;
		bounceScale = spriteJson.bounceScale ?? 0.02;
		bounceFrames = spriteJson.bounceFrames ?? 3;

		var hitboxes:Array<CharacterBoxData> = cast hitboxJson?.rubHitboxes;
		if (hitboxes == null || hitboxes.length <= 0) {
			for (i in 0...maxPressure + 1) {
				var rubHitbox:CharacterBoxData = {
					position: [260, 290],
					size: [160, 160]
				};
				this.rubHitboxes.push(rubHitbox);
			}
		} else {
			for (hitboxData in hitboxes) {
				this.rubHitboxes.push(hitboxData);
			}	
		}
		trace(rubHitboxes);

		if (Preferences.data.enableBellyRubbing) {
			rubHitbox = new FlxSprite();
		}

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

		if (Preferences.data.enableDiscoloration && Preferences.data.enableGLSL && Gameplay.currentFiller.tintColor != null) {
			var leColor = Gameplay.currentFiller.tintColor;
			discoloration = new DiscolorationShader(leColor);
			this.shader = discoloration;
			trace('Discoloration shader created for $id with color $leColor');
		}


		var combinedAtlas:FlxAtlasFrames = Paths.getSparrowAtlas('game/characters/$id/${spriteJson.spriteSheets[0]}');
		if (!Preferences.data.decreaseDetail && discoloration != null) {
			maskFrames = [];
			discoloration.initMask(0, Paths.getImage('game/characters/$id/mask/${spriteJson.spriteSheets[0]}').bitmap);
			maskFrames.set(spriteJson.spriteSheets[0], 0);
			for (frame in combinedAtlas.frames) {
				if (!frame.name.endsWith('0000')) continue;
				animToMask.set(frame.name.replace('0000', ''), spriteJson.spriteSheets[0]);
			}
		}
		for (i in 1...spriteJson.spriteSheets.length) {
			var atlas:FlxAtlasFrames = Paths.getSparrowAtlas('game/characters/$id/${spriteJson.spriteSheets[i]}');
			combinedAtlas.addAtlas(atlas, false);
			if (maskFrames != null) {
				var maskAtlas = Paths.getSparrowAtlas('game/characters/$id/mask/${spriteJson.spriteSheets[i]}');
				for (frame in maskAtlas.frames) {
					if (!frame.name.endsWith('0000')) continue;
					animToMask.set(frame.name.replace('0000', ''), spriteJson.spriteSheets[i]);
				}
				discoloration.initMask(i, maskAtlas.parent.bitmap);
				maskFrames.set(spriteJson.spriteSheets[i], i);
			}
		}

		super(x, y);
		frames = combinedAtlas;
		antialiasing = (!Preferences.data.enableForcedAliasing) ? !(!spriteJson.antialiasing) : false;

		animSoundPaths = new Map<String, Array<String>>();

		var animationsArray = spriteJson.animations;
		if (animationsArray != null && animationsArray.length > 0) {
			for (anim in animationsArray) {
				var animName:String = anim.name;
				var animPrefix:String = anim.prefix; // Prevent wocky shit from happening
				var animFps:Int = anim.fps ?? 24;
				var animLoop:Bool = anim.loop ?? true;
				var animIndices:Array<Int> = anim.indices ?? [];
				if (animIndices != null && animIndices.length > 0) {
					animation.addByIndices(animName, animPrefix + '0', animIndices, "", animFps, animLoop);
				} else {
					animation.addByPrefix(animName, animPrefix + '0', animFps, animLoop);
				}
				if (!animToMask.exists(animName) && animToMask.exists(animPrefix))
					animToMask.set(animName, animToMask.get(animPrefix));
				if (anim.soundPaths != null && anim.soundPaths.length > 0)
					addSoundPath(animName, anim.soundPaths, anim.autoPitch ?? true);
				bouncyAnims.set(animName, anim.bouncy ?? false);
			}
		} else {
			trace('Character $id has no animations');
			animation.addByPrefix('idle0', 'idle0', 24);
			bouncyAnims.set('idle0', false);
		}

		animation.onFrameChange.add(function(animName:String, frameNumber:Int, frameIndex:Int) {
			if (discoloration == null) return;
			if (maskFrames == null) {
				discoloration.useMask = false;
				return;
			} else
				discoloration.useMask = true;
			discoloration.setMask(maskFrames.get(animToMask.get(animName)));
			discoloration.setFrameBounds(
				frame.uv.left,
				frame.uv.top,
				frame.uv.right,
				frame.uv.bottom
			);
		});

		playAnim('idle');
		currentPressure = 0;

		boundingBox = new FlxRect((width - 200) / 2, 70, 200, 500);
		animation.onFinish.add(function(animName:String) {
			var trimmed = trimAnimationName(animName);
			// trace(trimmed + '-loop' + parseAnimationSuffix());
			if (idleAfterAnimation && !trimmed.startsWith('idle'))
				playAnim('idle');
			else if ((animExists(trimmed + '-loop') || animExists(trimmed + '-loop' + parseAnimationSuffix())) && !idleAfterAnimation)
				playAnim(trimmed + '-loop', false, false);
		});
		
		trace(animSoundPaths);

		originalPosition = FlxPoint.get(this.x, this.y);

		if (rubHitbox != null)
			FlxG.state.add(rubHitbox);

		updateRubHitbox();
	}

	public var discolorationIntensity(default, set):Float = 0;

	function set_discolorationIntensity(value:Float):Float {
		return discolorationIntensity = FlxMath.bound(value, 0, 1);
	}

	function set_currentPressure(value:Float):Float {
		currentPressure = value;
		updateRubHitbox();
		return value;
	}

	public override function update(elapsed:Float) {
		if (discoloration != null) {
			if (currentPressure > 0 && currentPressure <= maxPressure) {
				// trace(discoloration.intensity);
				discolorationIntensity += 0.01 * elapsed * getPressurePercentage();
				discolorationIntensity = FlxMath.bound(discolorationIntensity, 0, 1);
				discoloration.intensity = FlxMath.lerp(discoloration.intensity, discolorationIntensity, elapsed / 4);
			}
		}

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
						navelLeakTimer = 0.2 / intensity;

						var liquidVelocity = getParticleVelocity(64 * intensity, 0, 64);
						var position = getParticleOffset('navel').add(x, y);
						var liquid = new Liquid(position.x, position.y, PlayState?.instance?.stage?.data?.characterY ?? 690);
						liquid.velocity.set(liquidVelocity.x, liquidVelocity.y);
						liquid.color = Gameplay.currentFiller.liquidColor;
						if (PlayState?.instance != null) {
							PlayState.instance.particleGroup.add(liquid);
						} else {
							FlxG.state.add(liquid);
						}
					}
				}
			}
			if (Preferences.data.enableBelching && Gameplay.currentFiller.belches != null) {
				if (belchThreshold > -1 && currentPressure >= belchThreshold) {
					if (onIdle)
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
							var liquid = new Puff(position.x, position.y, PlayState?.instance?.stage?.data?.characterY ?? 690);
							liquid.velocity.set(liquidVelocity.x, liquidVelocity.y);
							liquid.color = Gameplay.currentFiller.gasColor;
							if (PlayState?.instance != null) {
								PlayState.instance.particleGroup.add(liquid);
							} else {
								FlxG.state.add(liquid);
							}
						}
					}
				}
			}
			if (Preferences.data.enableOralLeaking && Gameplay.currentFiller.leaks != null) {
				if (leakThreshold > -1 && currentPressure >= leakThreshold) {
					if (onIdle)
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
							var liquid = new Liquid(position.x, position.y, PlayState?.instance?.stage?.data?.characterY ?? 690);
							liquid.velocity.set(liquidVelocity.x, liquidVelocity.y);
							liquid.color = Gameplay.currentFiller.liquidColor;
							if (PlayState?.instance != null) {
								PlayState.instance.particleGroup.add(liquid);
							} else {
								FlxG.state.add(liquid);
							}
						}
					}
				}
			}
		}
		if (stomachNpcContents.length > 0 && Gameplay.currentFiller.stumbleForce != 0 && !isEliminated()) {
			if (stumbleTimer < 0) {
				var intensity = Math.min(1, Math.pow(stomachNpcContents.length / maxPressure, 2));
				stumbleTimer = FlxG.random.float(0.2, 0.5) / intensity;
				this.velocity.x = Gameplay.currentFiller.stumbleForce * 20 * intensity * FlxG.random.int(-1, 1, [0]);
				if (this.x + this.velocity.x * 0.1 > originalPosition.x + 40 || this.x + this.velocity.x * 0.1 < originalPosition.x - 40)
					this.velocity.x *= -1;
				FlxTween.tween(this.velocity, {x: 0}, 0.1);
			} else {
				stumbleTimer -= elapsed;
			}
		}
		if (isEliminated() && stomachNpcContents.length > 0 && !Preferences.data.decreaseDetail) {
			if (ejectTimer < 0) {
				ejectTimer = FlxG.random.float(8, 16);
				var npcID:String = stomachNpcContents.shift();
				if (npcID != null) {
					var particleOffset = getParticleOffset(Gameplay.currentFiller.npcSpawnLocationOnOverinflate).add(this.x, this.y);
					SuffState.playSound(Paths.getSoundRandom('game/inflation/universal/hiccups/hiccup', 1, 5), 0.5,
					voicePitch + FlxG.random.float(-0.025, 0.025));
					playAnim('helpless', true, true, false, false);
					var npc = new NPC(npcID, particleOffset.x, particleOffset.y, this.id);
					npc.velocity.set(FlxG.random.float(160, 320), FlxG.random.float(-160, 0));
					if (flipX)
						npc.velocity.x *= -1;
					npc.transmutateThreshold = maxPressure + 1;
					if (PlayState.instance != null)
						PlayState.instance.npcGroup.add(npc);
					else
						FlxG.state.add(npc);
				}
			} else {
				ejectTimer -= elapsed;
			}
		}
		if (!canUseSkills || hoseboundIndices.length > 0) {
			swirlSpawnTimer -= elapsed;
		}
		if (swirlSpawnTimer < 0) {
			var offsets = getParticleOffset('overhead');
			var particleX = this.x + offsets.x + FlxG.random.float(-1, 1) * this.width / 5;
			var particleY = this.y + offsets.y + FlxG.random.float() * this.height / 5;
			if (!canUseSkills) {
				PlayState.instance.particleGroup.add(new Swirl(particleX, particleY, 0xFFC040FF));
			} else if (hoseboundIndices.length > 0) {
				PlayState.instance.particleGroup.add(new HoseboundChain(particleX, particleY, FlxG.random.getObject(hoseboundIndices)));
			}
			swirlSpawnTimer = FlxG.random.float();
		}

		if (rubHitbox != null) {
			cursorOnBelly = mouseOverlapsRubHitbox() && onIdle && currentPressure > 0;
			if (onIdle && currentPressure > 0) {
				if (cursorOnBelly) {
					if (FlxG.mouse.pressed) {
						rubDuration += elapsed;
						var mouseVel = Math.sqrt(FlxG.mouse.deltaX * FlxG.mouse.deltaX + FlxG.mouse.deltaY * FlxG.mouse.deltaY);
						if (mouseVel > 10 && rubSoundTimer <= 0) {
							SuffState.playSound(Paths.getSoundRandom('game/inflation/universal/rubs/rub', 1, 6), elapsed * 6 * (mouseVel / 10), 0.75);
							rubSoundTimer = !Preferences.data.decreaseSounds ? 0.25 : 0.5;
						}
						// You have to be gentle with it
						var strength = FlxMath.roundDecimal(1 / (1 + 0.002 * Math.pow(mouseVel - 10, 4)) * 10, 1);
						if (rubValue < 4)
							rubValue += elapsed * strength * 0.5;
						if (rubValue > 3) {
							if (!rubbedComfortably)
								rubbedComfortably = true;
							if (!animation.curAnim.name.startsWith(substituteAnim('rubbed')))
								playAnim('rubbed', false);
						}
					} else if (FlxG.mouse.justReleased && forceExpulsionTimer <= 0 && rubDuration <= 0.1) {
						if (currentPressure >= leakThreshold) {
							leakTimer = -1;
							forceExpulsionTimer = 1;
						}
						if (currentPressure >= belchThreshold) {
							belchTimer = -1;
							forceExpulsionTimer = 1;
						}
					}
				}
				if (!cursorOnBelly || !FlxG.mouse.pressed) {
					rubDuration = 0;
					if (rubValue > 0)
						rubValue -= elapsed * 2;
					if (rubValue <= 0 && rubbedComfortably) {
						rubbedComfortably = false;
						playAnim('idle', true, true);
					}
				}
			}
			if (forceExpulsionTimer > 0)
				forceExpulsionTimer -= elapsed;
			if (rubSoundTimer > 0)
				rubSoundTimer -= elapsed;
		}
	}

	public function updateRubHitbox() {
		if (rubHitbox == null || this.offset == null)
			return;
		var rubHitboxData:CharacterBoxData = rubHitboxes[Std.int(FlxMath.bound(currentPressure, 0, maxPressure + 1))];
		var flippedOffsets:Bool = false;
		if (this.flipX)
			flippedOffsets = !flippedOffsets;
		if (this?.animation?.curAnim?.flipX ?? false)
			flippedOffsets = !flippedOffsets;
		rubHitbox.makeGraphic(rubHitboxData.size[0], rubHitboxData.size[1], 0x00000000);
		FlxSpriteUtil.drawEllipse(rubHitbox, 0, 0, rubHitboxData.size[0], rubHitboxData.size[1], 0xFFFFFFFF);
		rubHitbox.updateHitbox();
		if (flippedOffsets)
			rubHitbox.x = this.x - this.offset.x + this.width - rubHitbox.width - rubHitboxData.position[0];
		else
			rubHitbox.x = this.x - this.offset.x + rubHitboxData.position[0];
		rubHitbox.y = this.y - this.offset.y + rubHitboxData.position[1];
		rubHitbox.alpha = 1 / 255;
	}

	inline function substituteAnim(key:String):String {
		if (animExists(key + parseAnimationSuffix()) || animExists(key))
			return key;
		return missingAnimReplace.get(key) ?? key;
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
		leAnim = leAnim.replace('' + currentPressure, '');
		leAnim = leAnim.replace('Null', '');
		leAnim = leAnim.replace('Overinflated', '');
		return leAnim;
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

	public function animExists(AnimName:String):Bool {
		return (animation.getByName(AnimName) != null);
	}

	public function playAnim(AnimName:String, BackToIdle:Bool = true, Force:Bool = true, flipX:Bool = false, playSound:Bool = true, Reversed:Bool = false,
			Frame:Int = 0):Void {
		var usedAnimName:String = joinAnimationName(AnimName);
		var trimmedAnimName:String = trimAnimationName(AnimName);
		if (!animExists(usedAnimName)) {
			if (missingAnimReplace.exists(trimmedAnimName)) {
				usedAnimName = joinAnimationName(substituteAnim(AnimName));
				if (!animExists(usedAnimName)) {
					trace('Animation [${usedAnimName}] for $id does not exist, no replacements exist, skipping');
					return;
				}
				trace('Animation [${AnimName}] for $id does not exist, using [$usedAnimName] instead');
			} else {
				trace('Animation [${usedAnimName}] for $id does not exist, no replacements exist, skipping');
				return;
			}
		}
		this.onIdle = idleAnimations.contains(trimmedAnimName.replace('-loop', '')) && !usedAnimName.endsWith('Null');
		// trace('$id, trimmed: $trimmedAnimName, used: $usedAnimName');
		if (animation.getByName(usedAnimName) != null)
			animation.getByName(usedAnimName).flipX = flipX;
		animation.play(usedAnimName, Force, Reversed, Frame);

		if (Force)
			idleAfterAnimation = BackToIdle;

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

		updateRubHitbox();
	}
	
	public function getParticleOffset(position:String = 'overhead'):FlxPoint {
		var vel = FlxPoint.get(0, 0);
		if (!particleOffsets.exists(position))
			return vel;
		var offsetArray = particleOffsets.get(position);
		if (isEliminated()) {
			var index = offsetArray.length - 1;
			if ((PlayState?.currentSessionEnablePopping ?? Preferences.data.enablePopping) && !disablePopping)
				index = offsetArray.length - 2;
			vel.set(offsetArray[index][0], offsetArray[index][1]);
		} else {
			vel.set(offsetArray[Std.int(currentPressure)][0], offsetArray[Std.int(currentPressure)][1]);
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
				if ((PlayState?.currentSessionEnablePopping ?? Preferences.data.enablePopping) && !disablePopping)
					'Null';
				else
					'Overinflated';
			default:
				'' + Std.int(currentPressure);
		}
	}

	inline public function getPressurePercentage(multiplied:Bool = false):Float {
		return currentPressure / maxPressure * (multiplied ? 100 : 1);
	}

	function joinAnimationName(AnimName:String, checkForExistence:Bool = true):String {
		var usedAnimName:String = AnimName;
		if (checkForExistence && animExists(AnimName + parseAnimationSuffix()))
			usedAnimName = AnimName + parseAnimationSuffix();
		return usedAnimName;
	}

	inline public function getCurAnimLength():Float {
		return getAnimLength(animation.curAnim.name);
	}

	inline public function getAnimLength(AnimName:String):Float {
		var usedAnimName:String = joinAnimationName(AnimName);
		var leAnim = animation.getByName(usedAnimName);
		return leAnim != null ? (leAnim.frames.length - 1) / leAnim.frameRate : 0;
	}

	inline public function mouseOverlapsBoundingBox() {
		return FlxG.mouse.x >= this.x - this.offset.x + boundingBox.x && FlxG.mouse.x <= this.x - this.offset.x + boundingBox.x + boundingBox.width && FlxG.mouse.y >= this.y - this.offset.y + boundingBox.y && FlxG.mouse.y <= this.y - this.offset.y + boundingBox.y + boundingBox.height;
	}

	inline public function mouseOverlapsRubHitbox() {
		return rubHitbox?.pixelsOverlapPoint(FlxG.mouse.getWorldPosition(), 0x01, FlxG.camera) ?? false;
	}

	inline public function isEliminated() {
		return currentPressure > maxPressure;
	}

	public override function toString():String {
		return 'Character(id: ${id} | P:${currentPressure} / ${maxPressure} | C:${currentConfidence} / ${maxConfidence})';
	}
}
