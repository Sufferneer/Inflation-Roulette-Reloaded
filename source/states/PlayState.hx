package states;

import ui.objects.GameIcon;
import backend.Gameplay;
import backend.enums.RoundRandomStatus;
import backend.enums.SuffTransitionStyle;
import objects.Character;
import objects.particleEmitters.ConfettiEmitter;
import objects.particleEmitters.ScrapEmitter;
import backend.Skill;
import substates.PauseSubState;
import ui.objects.SkillCard;
import ui.objects.SuffBar;
import ui.objects.SuffIconButton;
import objects.Stage;
import backend.ScoringUtil;
import objects.particles.SkillIndicator;
import ui.objects.RevealBullet;
import shaders.GaussianBlurShader;
import objects.particles.Bloosh;
import objects.particleEmitters.PopEmitter;
import objects.particles.BulletShell;
import objects.particles.PlayerIndicator;
import backend.RecordingUtil;
import objects.particles.Liquid;
import objects.particles.Stain;
import objects.NPC;

class PlayState extends SuffState {
	public var characterGroup:FlxTypedContainer<Character> = new FlxTypedContainer<Character>();
	public var particleGroup:FlxTypedContainer<FlxObject> = new FlxTypedContainer<FlxObject>();
	public var npcGroup:FlxTypedContainer<NPC> = new FlxTypedContainer<NPC>();

	var letterboxTop:FlxSprite;
	var letterboxBottom:FlxSprite;
	var letterboxDisplayed:Bool = false;

	public var pumpGun:FlxSprite;
	var selectLight:FlxSprite;
	var pumpGunY:Float = 0;
	var pumpGunXDestinations:Array<Float> = [];

	var uiBGTop:FlxSprite;
	var uiBGBottom:FlxSprite;
	var uiBGGroup:FlxSpriteGroup = new FlxSpriteGroup();
	var revealCylinderContents:Bool = false;
	var uiRevealGroup:FlxSpriteGroup = new FlxSpriteGroup();
	var skillsText:FlxText;
	var skillsIcon:GameIcon;
	var skillCardsGroup:FlxTypedSpriteGroup<SkillCard> = new FlxTypedSpriteGroup<SkillCard>();

	static var skillCardsGroupPaddingX:Float = 10;
	static var skillCardsGroupPaddingY:Float = 50;

	var selectTargetText:FlxText;

	var shootButton:SuffButton;

	var pressureBar:SuffBar;
	final pressureBarColors:Array<FlxColor> = [0xFF404060, 0xFFFFFFFF];
	var pressureIcon:GameIcon;
	var pressureText:FlxText;
	var confidenceIcon:GameIcon;
	var confidenceBar:SuffBar;
	final confidenceBarColors:Array<FlxColor> = [0xFF4A4399, 0xFF7970FF];
	var confidenceText:FlxText;
	var pauseButton:SuffIconButton;
	var cameraFocusButton:SuffIconButton;
	var skillCancelButton:SuffIconButton;
	
	var dangerVignette:FlxSprite;

	var gaussianBlurShader:GaussianBlurShader = new GaussianBlurShader(20);

	// Game Logic
	var currentTurnIndex:Int = 0;
	var winnerIndex:Null<Int> = null;
	public var canUseSkillKeybinds:Bool = false;

	var cylinderContent:Array<Bool> = []; // True: Live, False: Blank
	var liveRoundDamage:Float = 1;
	// This array is only used when cylinderTrueRandomness is true.
	var roundRandomStatuses:Array<RoundRandomStatus> = [POSSIBLE];

	public static var hasSeenStartCutscene = false;

	public var canPause = true;
	public var isPaused = false;
	public var isEnding = false;
	var isSelectingPlayer(default, set):Bool = false;

	public static var gameTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public static var gameTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();

	// cameras
	var camFollow:FlxObject;
	var camFollowZoom:Float = 0.8;
	var isManuallyFocusingStage:Bool = false;

	public var camGame:FlxCamera;
	public var camEffects:FlxCamera;
	public var camHUD:FlxCamera;
	public var camOther:FlxCamera;

	// backend shit
	public static var instance:PlayState;

	public static var currentSessionEnablePopping:Bool = true;

	// Achievement shit
	var pressurizeStreak:Array<Int> = [];
	var lastPressurizeUserIndex:Int = -1;

	public var stage:Stage;

	override public function create() {
		RecordingUtil.checkIfRecording();

		Paths.clearStoredMemory();

		liveRoundDamage = Gameplay.currentGamemode.cylinderInitialDamage;

		camGame = new FlxCamera();
		camEffects = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camEffects.bgColor.alpha = 0;
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		skillCardsGroupPaddingX = 10 + ScreenSafeArea.X;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camEffects, false);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);
		camHUD.visible = !Preferences.data.hideHUD;

		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		// Recursively cache NPC sprites
		// Nvm this shit doesnt work
		/*
		var loadedNpcs:Array<NPC> = [];
		if (Gameplay.currentFiller.npcOnPop != '') {
			var firstNpc:NPC = new NPC(Gameplay.currentFiller.npcOnPop);
			loadedNpcs.push(firstNpc);
			while (firstNpc.mergedNpc != '') {
				firstNpc = new NPC(firstNpc.mergedNpc);
				loadedNpcs.push(firstNpc);
			}
		}
		// Bye bye NPCs
		for (npc in loadedNpcs) {
			npc.active = false;
			loadedNpcs.remove(npc);
		}
		 */

		super.create();

		instance = this;

		stage = new Stage(Gameplay.currentStage);

		currentSessionEnablePopping = Preferences.data.enablePopping;

		currentTurnIndex = 0;

		camFollow = new FlxObject(FlxG.width / 2, FlxG.height / 2, 1, 1);
		FlxG.camera.follow(camFollow, LOCKON);
		FlxG.camera.followLerp = 0.1 * Preferences.data.cameraSpeed;
		FlxG.camera.setScrollBoundsRect(stage.data.cameraBounds[0], stage.data.cameraBounds[1], stage.data.cameraBounds[2], stage.data.cameraBounds[3]);

		reloadCylinder(Gameplay.currentGamemode.cylinderLiveCount);

		pumpGun = new FlxSprite().loadGraphic(Paths.image('game/pumpGun'));

		characterGroup = new FlxTypedContainer<Character>();
		add(characterGroup);
		particleGroup = new FlxTypedContainer<FlxObject>();
		add(particleGroup);
		npcGroup = new FlxTypedContainer<NPC>();
		add(npcGroup);
		for (i in 0...Gameplay.selectedCharacterList.length) {
			pressurizeStreak.push(0);
			var leX:Int = Std.int(FlxMath.lerp(FlxG.width / 2 + stage.data.characterX[0], FlxG.width / 2 + stage.data.characterX[1], i / (Gameplay.selectedCharacterList.length - 1)));
			var char:Character = new Character(Gameplay.selectedCharacterList[i], leX, stage.data.characterY);
			if (i >= Std.int(Gameplay.selectedCharacterList.length / 2)) {
				char.flipX = true;
			}
			char.playAnim('idle' + char.currentPressure);

			char.cpuControlled = Gameplay.cpuControlled[i];
			char.cpuSkillLevel = Gameplay.cpuLevel[i];

			pumpGunXDestinations.push(char.x - pumpGun.width / 2);

			characterGroup.add(char);
			trace('char $i pos:', char.x, char.y);
		}

		// skillsFixedPool or skillsRandomPool is not empty
		if (Gameplay.currentGamemode.skillsFixedPool.length + Gameplay.currentGamemode.skillsRandomPool.length > 0) {
			for (char in characterGroup) {
				char.currentSkills = [];
			}
			giveSkillsToAllPlayers(1);
		}

		pumpGun.x = pumpGunXDestinations[currentTurnIndex];

		pumpGunY = stage.data.gunY;
		pumpGun.y = pumpGunY;
		pumpGun.scrollFactor.set(stage.data.gunScrollFactor[0], stage.data.gunScrollFactor[1]);
		add(pumpGun);

		if (!hasSeenStartCutscene && FlxG.random.bool(1 / 64 * 100)) {
			Achievements.advanceProgress('findCameraman', [true]);

			var cobalt:FlxSprite = new FlxSprite();
			cobalt.frames = Paths.sparrowAtlas('game/cobalt');
			cobalt.animation.addByPrefix('appear', 'appear', 24, false);
			cobalt.animation.play('appear');
			cobalt.x = FlxG.width - cobalt.width;
			cobalt.y = FlxG.height - cobalt.height;
			cobalt.animation.onFrameChange.add(function(animName, frameNumber, frameIndex) {
				if (frameNumber == 4 || frameNumber == 10) SuffState.playSound(Paths.sound('game/glassTap'));
			});
			cobalt.animation.onFinish.add(function(_) {
				cobalt.destroy();
				new FlxTimer().start(0.1, function(timer) {
					var defaultCamX = camFollow.x;
					var defaultCamY = camFollow.y;
					camFollow.x += FlxG.random.int(-1, 1) * 2;
					camFollow.y -= FlxG.random.int(-1, 1) * 2;
					if (timer.loopsLeft == 0) {
						camFollow.x = defaultCamX;
						camFollow.y = defaultCamY;
					}
				}, 10);
			});
			if (Preferences.data.enableGLSL) {
				cobalt.shader = new GaussianBlurShader(16, 0.5);
				cobalt.scale.set(1.1, 1.1);
				cobalt.antialiasing = !Preferences.data.enableForcedAliasing;
			} else
				cobalt.color = 0xFF808080;
			cobalt.camera = camEffects;
			add(cobalt);
		}

		stage.load();

		selectLight = new FlxSprite();
		selectLight.loadGraphic(Paths.image('game/selectLight'));
		#if _ALLOW_EASTER_EGGS
		if (FlxG.random.bool(1 / 128 * 100))
			selectLight.loadGraphic(Paths.image('game/selectLightAlt'));
		#end
		selectLight.visible = false;
		members.insert(members.indexOf(characterGroup), selectLight);

		// UI Stuff//
		if (!Preferences.data.decreaseDetail) {
			dangerVignette = new FlxSprite().loadGraphic(Paths.image('ui/vignette'));
			dangerVignette.setGraphicSize(FlxG.width + 20, FlxG.height + 20);
			dangerVignette.updateHitbox();
			dangerVignette.screenCenter();
			dangerVignette.color = 0xC00060;
			dangerVignette.alpha = 0;
			dangerVignette.camera = camHUD;
			add(dangerVignette);
		}
		
		letterboxTop = new FlxSprite().makeGraphic(FlxG.width + 50, Constants.LETTERBOX_HEIGHT, FlxColor.BLACK);
		letterboxTop.camera = camOther;
		letterboxTop.y = -letterboxTop.height;
		add(letterboxTop);

		letterboxBottom = new FlxSprite().makeGraphic(Std.int(letterboxTop.width), Std.int(letterboxTop.height), FlxColor.BLACK);
		letterboxBottom.camera = camOther;
		letterboxBottom.y = FlxG.height;
		add(letterboxBottom);

		selectTargetText = new FlxText(Language.getPhrase('game.selectTarget'), 48);
		selectTargetText.setBorderStyle(OUTLINE, 0xFF000000, 3.25);
		selectTargetText.x = Std.int((FlxG.width - selectTargetText.width) / 2);
		selectTargetText.y = -selectTargetText.height;
		selectTargetText.camera = camHUD;
		add(selectTargetText);

		uiBGGroup.camera = camHUD;
		add(uiBGGroup);

		uiRevealGroup.camera = camHUD;
		add(uiRevealGroup);

		uiBGTop = new FlxSprite().makeGraphic(Std.int(skillCardsGroupPaddingX + 480 + 10), FlxG.height, FlxColor.BLACK);
		uiBGTop.alpha = 0.25;
		uiBGGroup.add(uiBGTop);

		uiBGBottom = new FlxSprite().makeGraphic(500, FlxG.height, FlxColor.WHITE);
		uiBGBottom.alpha = 0.25;
		uiBGGroup.add(uiBGBottom);

		skillsText = new FlxText(0, 0, 0, Language.getPhrase('stats.skills').toUpperCase());
		skillsText.setFormat(Paths.font('default'), 32, FlxColor.WHITE);
		skillsText.x = uiBGTop.width - skillsText.width;
		uiBGGroup.add(skillsText);

		skillsIcon = new GameIcon(0, 0, 'stats/skill', 32);
		skillsIcon.x = skillsText.x - skillsIcon.width - 4;
		skillsIcon.y = skillsText.y + (skillsText.height - skillsIcon.height) / 2;
		uiBGGroup.add(skillsIcon);

		pressureIcon = new GameIcon(ScreenSafeArea.X, 0, 'stats/pressure', 32);

		pressureText = new FlxText(pressureIcon.x + pressureIcon.width + 4, 0, 0, '');
		pressureText.setFormat(Paths.font('default'), 32, pressureBarColors[0]);
		uiBGGroup.add(pressureIcon);
		uiBGGroup.add(pressureText);

		pressureIcon.color = pressureText.color;

		pressureBar = new SuffBar(0, 0, function() return 0, 0, 1, Std.int(uiBGTop.width), 20, 4, 1, pressureBarColors[0], pressureBarColors[1]);
		uiBGGroup.add(pressureBar);

		confidenceBar = new SuffBar(0, 0, function() return 0, 0, 1, Std.int(uiBGTop.width), 20, 4, 1, confidenceBarColors[0], confidenceBarColors[1]);
		uiBGGroup.add(confidenceBar);

		confidenceIcon = new GameIcon(ScreenSafeArea.X, 0, 'stats/confidence', 32);

		confidenceText = new FlxText(confidenceIcon.x + confidenceIcon.width + 4, 0, 0, '');
		confidenceText.setFormat(Paths.font('default'), 32, confidenceBarColors[0]);
		uiBGGroup.add(confidenceIcon);
		uiBGGroup.add(confidenceText);

		confidenceIcon.color = confidenceText.color;

		skillCardsGroup.y = skillCardsGroupPaddingY;
		skillCardsGroup.camera = camHUD;
		add(skillCardsGroup);

		var shootButtonImage = Paths.image('ui/icons/buttons/shoot');
		var shootButtonHighlightedImage = Paths.image('ui/icons/buttons/shootHighlighted');
		shootButton = new SuffButton(0, 0, null, shootButtonImage, shootButtonHighlightedImage, shootButtonImage.width, shootButtonImage.height, false);
		shootButton.y = FlxG.height - shootButton.height - ScreenSafeArea.Y;
		shootButton.camera = camHUD;
		shootButton.onClick = function() {
			deployGun(currentTurnIndex, function() return getPlayer(currentTurnIndex).getPressurePercentage());
		}
		add(shootButton);

		pauseButton = new SuffIconButton(20, 20 + ScreenSafeArea.Y, 'buttons/pause', null, 2);
		pauseButton.x = FlxG.width - pauseButton.width - 20 - ScreenSafeArea.X;
		pauseButton.camera = camHUD;
		pauseButton.onClick = function() {
			pauseGame();
			openSubState(new PauseSubState());
		};
		add(pauseButton);

		cameraFocusButton = new SuffIconButton(20, 20, 'buttons/camera', null, 2);
		cameraFocusButton.x = FlxG.width - cameraFocusButton.width - 20 - ScreenSafeArea.X;
		cameraFocusButton.y = FlxG.height - cameraFocusButton.height - 20 - ScreenSafeArea.Y;
		cameraFocusButton.camera = camHUD;
		cameraFocusButton.onClick = function() {
			toggleCameraFocus();
		};
		add(cameraFocusButton);

		skillCancelButton = new SuffIconButton(20, 20, 'buttons/exit', null, 2);
		skillCancelButton.visible = false;
		skillCancelButton.x = cameraFocusButton.x;
		skillCancelButton.y = cameraFocusButton.y;
		skillCancelButton.camera = camHUD;
		skillCancelButton.onClick = function() {
			cancelOffensiveSkill();
		};
		add(skillCancelButton);
		
		var humanPlayer:Int = 0;
		var humanPlayerCount = [for (i in Gameplay.cpuControlled) if (!i) i].length;
		for (num => i in Gameplay.cpuControlled) {
			if (i) continue;
			var player = getPlayer(num);
			var offset = player.getParticleOffset('overhead');
			members.insert(members.indexOf(characterGroup) + 1, new PlayerIndicator(player.x + offset.x, player.y + offset.y, humanPlayer, humanPlayerCount == 1));
			humanPlayer ++;
		}
		toggleCameraFocusButton(!getPlayer(currentTurnIndex).cpuControlled);

		reloadRevealUI();

		focusCameraOnPlayer(currentTurnIndex);
		if (!hasSeenStartCutscene) {
			playStartCutscene();
			hasSeenStartCutscene = true;
		} else {
			finishStartCutscene();
		}

		setWindowTitle();

		Paths.clearUnusedMemory();
	}

	public function setWindowTitle() {
		Window.setTitle(Language.getPhrase('game.windowDisplay', [Language.getPhrase('gameType.' + (Gameplay.isMultiplayer() ? 'multiplayer' : 'singleplayer')), characterGroup.members.length]));
	}

	private function set_isSelectingPlayer(value:Bool):Bool {
		isSelectingPlayer = value;
		skillCancelButton.visible = value;
		if (!value) selectLight.visible = false;
		toggleCameraFocusButton(!value);
		doTween('selectTargetText', FlxTween.tween(selectTargetText, {y: value ? 0 : -selectTargetText.height}, 0.75, {
			ease: FlxEase.backOut
		}));
		return value;
	}

	public function deployGun(playerIndex:Int, delay:Void -> Float = null) {
		// Delay is a function for dynamic value update via calculation
		var usedDelay = delay;
		if (delay == null)
			usedDelay = function() return 0;
		togglePlayerUI(false);
		toggleCameraFocusButton(false);
		toggleLetterbox(true);
		var character = getPlayer(playerIndex);
		character.playAnim('preShoot', false);
		doTimer('playerShoot', new FlxTimer().start(character.getAnimLength('preShoot') + usedDelay(), function(_:FlxTimer) {
			if (!Preferences.data.decreaseDetail) {
				var bulletShell = new BulletShell(character.x + character.getParticleOffset('gunShoot').x, character.y + character.getParticleOffset('gunShoot').y, stage.data.characterY, cylinderContent[0]);
				particleGroup.add(bulletShell);
				if (cylinderContent[0] && !cylinderContent.contains(true)) {
					for (i in 1...cylinderContent.length) {
						var bulletShell = new BulletShell(character.x + character.getParticleOffset('gunShoot').x, character.y + character.getParticleOffset('gunShoot').y, stage.data.characterY, false);
						particleGroup.add(bulletShell);
					}
				}
			}
			shoot(playerIndex);
		}));
	}

	function toggleCameraFocusButton(show:Bool = false) {
		cameraFocusButton.disabled = !show;
		FlxTween.cancelTweensOf(cameraFocusButton, ['alpha']);
		FlxTween.tween(cameraFocusButton, {alpha: show ? 1 : 0}, 0.25);
	}

	function reloadPlayerUI(playerIndex:Int) {
		for (skillCard in skillCardsGroup) {
			skillCard.kill();
			skillCard.destroy();
		}
		skillCardsGroup.clear();

		// Dummy skill card to fix issue regarding tween issues after switching from a player with no skill.
		var skillCard:SkillCard = new SkillCard(0, 0, new Skill('reload'));
		skillCard.visible = false;
		skillCardsGroup.add(skillCard);

		var skills:Array<Skill> = getPlayer(playerIndex).currentSkills;
		skillsText.visible = skillsIcon.visible = (skills.length > 0);
		for (i in 0...skills.length) {
			var leSkill = skills[i];
			var skillCard:SkillCard = new SkillCard(0, i * 110, leSkill);
			skillCard.onClick = function() {
				activateSkill(currentTurnIndex, i);
			}
			skillCardsGroup.add(skillCard);
		}
		updateSkillAvailability(playerIndex);

		uiBGTop.setGraphicSize(Std.int(uiBGTop.width), Std.int(skillCardsGroupPaddingY + skillCardsGroup.height + 10));
		uiBGTop.updateHitbox();
		uiBGBottom.y = pressureIcon.y = uiBGTop.height;
		pressureText.y = pressureIcon.y + (pressureIcon.height - pressureText.height) / 2;
		pressureBar.y = pressureIcon.y + pressureIcon.height;
		uiBGBottom.setGraphicSize(Std.int(uiBGTop.width), Std.int(FlxG.height - uiBGTop.height));
		uiBGBottom.updateHitbox();

		pressureBar.segments = Std.int(Math.max(1, getPlayer(playerIndex).maxPressure));
		pressureBar.valueFunction = function() {
			return getPlayer(playerIndex).currentPressure;
		}
		pressureBar.setBounds(0, getPlayer(playerIndex).maxPressure);

		confidenceBar.y = pressureBar.y + pressureBar.height;
		confidenceIcon.y = confidenceBar.y + confidenceBar.height;
		confidenceText.y = confidenceIcon.y + (confidenceIcon.height - confidenceText.height) / 2;

		updateUIText(playerIndex);

		confidenceBar.segments = Std.int(Math.max(1, getPlayer(playerIndex).maxConfidence));
		confidenceBar.valueFunction = function() {
			return getPlayer(playerIndex).currentConfidence;
		}
		confidenceBar.setBounds(0, getPlayer(playerIndex).maxConfidence);
	}

	function updateUIText(playerIndex:Int) {
		pressureText.text = getPlayer(playerIndex).currentPressure + ' / ' + getPlayer(playerIndex).maxPressure;
		confidenceText.text = getPlayer(playerIndex).currentConfidence + ' / ' + getPlayer(playerIndex).maxConfidence;
	}

	function updateSkillAvailability(playerIndex:Int) {
		for (skillCard in skillCardsGroup) {
			var disabled:Bool = getPlayer(playerIndex).currentConfidence < skillCard.skill.cost || !getPlayer(playerIndex).canUseSkills;
			if (disabled) {
				skillCard.notEnoughConfidence = true;
			} else {
				skillCard.notEnoughConfidence = false;
			}
		}
		updateUIText(playerIndex);
	}

	function animAllCharacters(animation:String, maxDelay:Float = 0.5, snapBackToIdle:Bool = true) {
		for (character in characterGroup) {
			new FlxTimer().start(FlxG.random.float() * maxDelay, function(_:FlxTimer) {
				character.playAnim(animation, snapBackToIdle);
			});
		}
	}

	function getMaximumAnimLength(animName:String) {
		var maxLength:Float = 0;
		for (character in characterGroup) {
			var length:Float = character.getAnimLength(animName);
			if (length > maxLength) {
				maxLength = length;
			}
		}
		return maxLength;
	}

	function playGunContactSound(glassVolume:Float = 0) {
		SuffState.playSound(Paths.soundRandom('game/weapon', 1, 3));
		if (glassVolume <= 0) return;
		SuffState.playSound(Paths.sound('game/glassTap'), glassVolume);
	}

	function togglePauseFunctionality(enable:Bool = true) {
		canPause = enable;
		pauseButton.disabled = !enable;
	}

	function playStartCutscene() {
		togglePauseFunctionality(false);
		togglePlayerUI(false);
		cameraFocusButton.visible = false;
		toggleLetterbox(true);
		doTween('camHUD', FlxTween.tween(camHUD, {alpha: 0}, 0.5));
		focusCameraOnStage();
		SuffState.playMusic('cutscene', 0);
		FlxG.sound.music.fadeIn(1, 0, Preferences.data.musicVolume);
		pumpGun.y = -1000;

		// I am sorry future me
		animAllCharacters('introPartOne', 1, false); // All characters play their first intro animation
		new FlxTimer().start(1.5 + getMaximumAnimLength('introPartOne'), function(_:FlxTimer) { // First intro animation delay + 1.5 seconds
			FlxTween.tween(pumpGun, {y: pumpGunY}, 0.5, { // Gun lands on table
				onComplete: function(_:FlxTween) {
					animAllCharacters('introPartTwo', 0.5, true); // All characters play their second intro animation
					new FlxTimer().start(1.5 + getMaximumAnimLength('introPartTwo'), function(_:FlxTimer) {
						finishStartCutscene();
					});
					playGunContactSound(1); // Gun bounces on table
					FlxTween.tween(pumpGun, {y: pumpGunY - 50}, 0.25, {
						ease: FlxEase.quadOut, onComplete: function(_:FlxTween) { // Gun lands on table 2nd time
							FlxTween.tween(pumpGun, {y: pumpGunY}, 0.25, {
								ease: FlxEase.quadIn, onComplete: function(_:FlxTween) { // Gun bounces on table 2nd time
									playGunContactSound(0.5);
									FlxTween.tween(pumpGun, {y: pumpGunY - 10}, 0.125, {
										ease: FlxEase.quadOut, onComplete: function(_:FlxTween) { // Gun lands on table FINAL TIME
											FlxTween.tween(pumpGun, {y: pumpGunY}, 0.125, {
												ease: FlxEase.quadIn, onComplete: function(_:FlxTween) {
													playGunContactSound(0.25);
												}
											});
										}
									});
								}
							});
						}
					});
				}
			});
		});
	}

	function finishStartCutscene() {
		togglePauseFunctionality(true);
		toggleLetterbox(false);
		cameraFocusButton.visible = true;
		canUseSkillKeybinds = true;
		SuffState.playMusic(stage.data.music, 1, true);

		doTween('camHUD', FlxTween.tween(camHUD, {alpha: 1}, 0.5));

		changeTurn();
		if (getPlayer(currentTurnIndex).cpuControlled) {
			startCPUAction();
		}
	}

	function reloadCylinder(liveRounds:Int = 1) {
		cylinderContent = [];
		var liveRoundsInserted:Int = 0;
		for (i in 0...Gameplay.currentGamemode.cylinderSize) {
			cylinderContent.push(false);
		}
		while (liveRoundsInserted < Math.min(Gameplay.currentGamemode.cylinderSize, liveRounds)) {
			var leIndex = FlxG.random.int(0, Gameplay.currentGamemode.cylinderSize - 1);
			if (cylinderContent[leIndex] != true) {
				cylinderContent[leIndex] = true;
				liveRoundsInserted++;
			}
		}
		for (num => char in characterGroup)
			char.cpuKnowsCylinderContents = false;
		trace(cylinderContent);
	}

	function getPlayer(index:Int) {
		return characterGroup.members[index];
	}

	var luckyPolarize:Bool = false;
	var playerUsedPolarize:Bool = false;

	public function activateSkill(playerIndex:Int, skillIndex:Int) {
		var skill = getPlayer(playerIndex).currentSkills[skillIndex];
		if (skill == null) {
			trace('Skill does not exist for Player ${playerIndex + 1}');
			return;
		}
		if (getPlayer(playerIndex).currentConfidence < skill.cost) {
			trace('Not enough confidence for Player ${playerIndex + 1}');
			return;
		}

		canUseSkillKeybinds = false;
		togglePlayerUI(false);
		toggleCameraFocusButton(false);
		if (skill.offensive) {
			chooseForOffensiveSkill(playerIndex, skillIndex);
			return;
		}

		var animName:String = 'skill' + Utilities.capitalize(skill.id);
		var actualAnimName:String = animName + getPlayer(playerIndex).parseAnimationSuffix();
		var soundName:String = animName;
		if (getPlayer(playerIndex).animExists(actualAnimName)) {
			// Do nothing
		} else if (getPlayer(playerIndex).animExists(animName)) {
			actualAnimName = animName;
		} else {
			actualAnimName = 'skill';
		}
		getPlayer(playerIndex).playAnim(actualAnimName);
		var offsets = getPlayer(playerIndex).getParticleOffset('overhead');
		members.insert(members.indexOf(getPlayer(playerIndex)), new SkillIndicator(getPlayer(playerIndex).x + offsets.x, getPlayer(playerIndex).y + offsets.y, skill.id));

		switch (skill.id) {
			case 'reload':
				if (!Preferences.data.decreaseDetail) {
					for (i in 0...cylinderContent.length) {
						var bulletShell = new BulletShell(getPlayer(playerIndex).x + getPlayer(playerIndex).getParticleOffset('gunSkill').x, getPlayer(playerIndex).y + getPlayer(playerIndex).getParticleOffset('gunSkill').y, stage.data.characterY, cylinderContent[i]);
						particleGroup.add(bulletShell);
					}
				}
				reloadCylinder(Gameplay.currentGamemode.cylinderLiveCount);
			case 'sabotage':
				cylinderContent[0] = false;
				if (cylinderContent.length > 1) {
					cylinderContent[1] = true;
				} else {
					cylinderContent.push(true);
				}
				if (Gameplay.currentGamemode.cylinderTrueRandomness) {
					roundRandomStatuses[0] = IMPOSSIBLE;
					if (roundRandomStatuses.length > 1) {
						roundRandomStatuses[1] = GUARANTEED;
					} else {
						roundRandomStatuses.push(GUARANTEED);
					}
				}
				if (!Gameplay.cpuControlled[playerIndex])
					Achievements.advanceProgress('sabotages', [1]);
				for (i in 0...characterGroup.members.length) {
					if (!getPlayer((playerIndex + 1) % characterGroup.members.length).isEliminated()) {
						getPlayer((playerIndex + 1) % characterGroup.members.length).cpuSabotageVictim = true;
						break;
					}
				}
			case 'pressurize':
				liveRoundDamage *= 2;
				lastPressurizeUserIndex = playerIndex;
				pressurizeStreak[playerIndex]++;
				if (pressurizeStreak[playerIndex] >= 2 && !Gameplay.cpuControlled[playerIndex])
					Achievements.advanceProgress('doublePressurize', [true]);
			case 'polarize':
				cylinderContent[0] = !cylinderContent[0];
				if (!getPlayer(playerIndex).cpuControlled) {
					playerUsedPolarize = true;
					if (!cylinderContent[0] && cylinderContent.length >= Gameplay.currentGamemode.cylinderSize && !Gameplay.currentGamemode.cylinderTrueRandomness)
						luckyPolarize = true;
				}
			case 'deflate':
				getPlayer(playerIndex).currentPressure -= 1;
				if (getPlayer(playerIndex).currentPressure < 0) {
					getPlayer(playerIndex).currentPressure = 0;
				}
			case 'reveal':
				getPlayer(playerIndex).cpuKnowsCylinderContents = true;
				revealCylinderContents = true;
		}

		getPlayer(playerIndex).currentConfidence -= skill.cost;
		getPlayer(playerIndex).skillUseCount++;
		if (Gameplay.currentGamemode.skillsTangible) {
			getPlayer(playerIndex).currentSkills.remove(skill);
		}

		toggleLetterbox(true);
		// trace(getPlayer(playerIndex).animSoundPaths[soundName]);
		if (getPlayer(playerIndex).animSoundPaths[soundName] == null || getPlayer(playerIndex).animSoundPaths[soundName].length <= 0) {
			if (Paths.fileExists(Paths.getSoundPath('game/skills/' + soundName), SOUND)) {
				SuffState.playSound(Paths.sound('game/skills/' + soundName));
			}
		}
		doTimer('reenablePlayerUI', new FlxTimer().start(getPlayer(playerIndex).getCurAnimLength(), function(_:FlxTimer) {
			getPlayer(playerIndex).playAnim('prepareShoot', false);
			reloadPlayerUI(playerIndex);
			togglePlayerUI((currentTurnIndex == playerIndex && !getPlayer(playerIndex).cpuControlled));
			if (currentTurnIndex == playerIndex) {
				updateSkillAvailability(playerIndex);
			}
			if (!getPlayer(playerIndex).cpuControlled) {
				toggleLetterbox(false);
				toggleCameraFocusButton(true);
			}
			canUseSkillKeybinds = !getPlayer(currentTurnIndex).cpuControlled;
		}));
	}

	public function activateOffensiveSkill(attackerIndex:Int, skillIndex:Int, victimIndex:Int) {
		var skill = getPlayer(attackerIndex).currentSkills[skillIndex];
		trace(attackerIndex, skill, victimIndex);
		if (skill == null) {
			trace('Skill does not exist for Player ${attackerIndex + 1}');
			return;
		}
		getPlayer(attackerIndex).currentConfidence -= skill.cost;
		getPlayer(attackerIndex).skillUseCount++;
		if (Gameplay.currentGamemode.skillsTangible) {
			getPlayer(attackerIndex).currentSkills.remove(skill);
		}

		isSelectingPlayer = false;
		toggleCameraFocusButton(false);
		focusCameraOnPlayer(attackerIndex);

		doTimer('offensiveSkillRegister', new FlxTimer().start(0.625, function(_) {
			switch (skill.id) {
				case 'assault':
					if (!cylinderContent[0]) {
						getPlayer(victimIndex).currentConfidence += 2;
						if (getPlayer(victimIndex).currentConfidence > getPlayer(victimIndex).maxConfidence)
							getPlayer(victimIndex).currentConfidence = getPlayer(victimIndex).maxConfidence;
					}
					if (!Preferences.data.decreaseDetail) {
						var bulletShell = new BulletShell(getPlayer(attackerIndex).x + getPlayer(attackerIndex).getParticleOffset('gunSkill').x, getPlayer(attackerIndex).y + getPlayer(attackerIndex).getParticleOffset('gunSkill').y, stage.data.characterY, cylinderContent[0]);
						particleGroup.add(bulletShell);
					}
					if (!getPlayer(attackerIndex).cpuControlled) {
						Achievements.advanceProgress('liveShots', [1]);
						if (getPlayer(victimIndex).currentPressure + liveRoundDamage > getPlayer(victimIndex).maxConfidence)
							Achievements.advanceProgress('eliminateByAssault', [true]);
					}
					shoot(victimIndex, false);
					pumpGun.visible = false;
					var flipX:Bool = (attackerIndex - victimIndex) < 0;
					if (getPlayer(victimIndex).flipX) flipX = !flipX;
					getPlayer(victimIndex).playAnim('shocked', true, true, flipX);
				case 'amnesia':
					getPlayer(victimIndex).playAnim('amnesic', true, true);
					getPlayer(victimIndex).canUseSkills = false;
					doTimer('reenablePlayerUI', new FlxTimer().start(1.5, function(_:FlxTimer) {
						changeTurn();
						canUseSkillKeybinds = !getPlayer(attackerIndex).cpuControlled;
					}));
			}
			focusCameraOnPlayer(victimIndex);
		}));

		var animName:String = 'skill' + Utilities.capitalize(skill.id);
		var actualAnimName:String = animName + getPlayer(attackerIndex).parseAnimationSuffix();
		var soundName:String = animName;
		if (getPlayer(attackerIndex).animExists(actualAnimName)) {
			// Do nothing
		} else if (getPlayer(attackerIndex).animExists(animName)) {
			actualAnimName = animName;
		} else {
			actualAnimName = 'skill';
		}
		var flipX:Bool = (attackerIndex - victimIndex) > 0;
		if (getPlayer(attackerIndex).flipX) flipX = !flipX;
		getPlayer(attackerIndex).playAnim(actualAnimName, false, true, flipX);
		var offsets = getPlayer(attackerIndex).getParticleOffset('overhead');
		members.insert(members.indexOf(getPlayer(attackerIndex)), new SkillIndicator(getPlayer(attackerIndex).x + offsets.x, getPlayer(attackerIndex).y + offsets.y, skill.id));

		toggleLetterbox(true);
		if (getPlayer(attackerIndex).animSoundPaths[soundName] == null || getPlayer(attackerIndex).animSoundPaths[soundName].length <= 0) {
			if (Paths.fileExists(Paths.getSoundPath('game/skills/' + soundName), SOUND)) {
				SuffState.playSound(Paths.sound('game/skills/' + soundName));
			}
		}
	}

	public var offensiveSkillAttacker:Int = 0;
	public var offensiveSkillIndex:Int = 0;

	public function chooseForOffensiveSkill(playerIndex:Int, skillIndex:Int) {
		offensiveSkillAttacker = playerIndex;
		offensiveSkillIndex = skillIndex;
		isSelectingPlayer = true;
		focusCameraOnStage();
	}

	public function cancelOffensiveSkill() {
		isSelectingPlayer = false;
		canUseSkillKeybinds = true;
		togglePlayerUI((currentTurnIndex == offensiveSkillAttacker && !Gameplay.cpuControlled[currentTurnIndex]));
		if (currentTurnIndex == offensiveSkillAttacker) {
			toggleCameraFocusButton(true);
		}
		focusCameraOnPlayer(currentTurnIndex);
	}

	public function shoot(playerIndex:Int, passToPlayer:Bool = true) {
		var dealDamage:Bool = false;
		if (!Gameplay.currentGamemode.cylinderTrueRandomness)
			dealDamage = cylinderContent[0]; else {
			switch (roundRandomStatuses[0]) {
				case GUARANTEED:
					dealDamage = true;
				case IMPOSSIBLE:
					dealDamage = false;
				default:
					dealDamage = FlxG.random.bool((Gameplay.currentGamemode.cylinderLiveCount / Gameplay.currentGamemode.cylinderSize) * 100);
			}
			roundRandomStatuses.shift();
			if (roundRandomStatuses.length <= 0)
				roundRandomStatuses = [POSSIBLE];
		}
		var playerAnimName:String = 'idle';

		SuffState.playSound(Paths.sound('game/shoot'));
		if (dealDamage) {
			playerAnimName = 'shootLive';
		} else {
			playerAnimName = 'shootBlank';
		}
		getPlayer(playerIndex).playAnim(playerAnimName, false);
		if (getPlayer(playerIndex).currentPressure >= getPlayer(playerIndex).maxPressure) {
			FlxG.sound.music.pause();
		}
		if (dealDamage) {
			if (!getPlayer(playerIndex).cpuControlled)
				Achievements.advanceProgress('liveShots', [1]);
			SuffState.playSound(Paths.sound('game/shootLive'));
			getPlayer(playerIndex).currentPressure += 1;
			getPlayer(playerIndex).currentConfidence += getPlayer(playerIndex).confidenceChangeOnLiveShot;
			if (liveRoundDamage > 1) {
				liveRoundDamage = Std.int(liveRoundDamage);
				liveRoundDamage -= 1;
				if (!getPlayer(playerIndex).isEliminated()) {
					doTimer('morePressure', new FlxTimer().start(0.75, function(_) {
						for (i in 0...pressurizeStreak.length)
							pressurizeStreak[i] = 0;
						if (lastPressurizeUserIndex == playerIndex && !getPlayer(playerIndex).cpuControlled)
							Achievements.advanceProgress('pressurizeYourself', [true]);
						shoot(playerIndex, passToPlayer);
					}));
				} else {
					liveRoundDamage = Gameplay.currentGamemode.cylinderInitialDamage;
					cylinderContent.shift();
					checkToReloadCylinder();
					if (Gameplay.currentGamemode.skillsFixedPool.length + Gameplay.currentGamemode.skillsRandomPool.length > 0) {
						giveSkillsToAllPlayers(Gameplay.currentGamemode.skillsReplenishCountOnLive);
					}
				}
			} else {
				cylinderContent.shift();
				checkToReloadCylinder();
				if (Gameplay.currentGamemode.skillsFixedPool.length + Gameplay.currentGamemode.skillsRandomPool.length > 0) {
					giveSkillsToAllPlayers(Gameplay.currentGamemode.skillsReplenishCountOnLive);
				}
			}

			liveRoundDamage += Gameplay.currentGamemode.cylinderDamageChangeOnLive;

			var percent = getPlayer(playerIndex).getPressurePercentage();
			var fwoompSuffix:String = percent >= 0.5 ? 'Large' : 'Small';
			SuffState.playSound(Paths.soundRandom('game/inflation/universal/fwoomps/fwoomp' + fwoompSuffix, 1, Constants.FWOOMPS_SAMPLE_COUNT), 0.75, 0.5);
			if (Preferences.data.enableBellyCreaks) {
				SuffState.playSound(Gameplay.currentFiller.getCreakSound(), percent, percent * 1.5 + 1);
			}

			screenShake(0.01, 0.1);
		} else {
			getPlayer(playerIndex).currentConfidence += getPlayer(playerIndex).confidenceChangeOnBlankShot;
			cylinderContent.shift();
			checkToReloadCylinder();
			if (Gameplay.currentGamemode.skillsFixedPool.length + Gameplay.currentGamemode.skillsRandomPool.length > 0) {
				giveSkillsToAllPlayers(Gameplay.currentGamemode.skillsReplenishCountOnBlank);
			}
			liveRoundDamage += Gameplay.currentGamemode.cylinderDamageChangeOnBlank;
		}
		trace(cylinderContent);

		if (passToPlayer) {
			getPlayer(playerIndex).currentConfidence = Std.int(FlxMath.bound(getPlayer(playerIndex).currentConfidence, 0, getPlayer(playerIndex).maxConfidence));
			getPlayer(playerIndex).cpuSabotageVictim = false;
			doTimer('playerChangeTurn', new FlxTimer().start(getPlayer(playerIndex).getCurAnimLength(), function(_:FlxTimer) {
				if (getPlayer(playerIndex).currentPressure > getPlayer(playerIndex).maxPressure) {
					eliminatePlayer(playerIndex, 1);
					if (revealCylinderContents && playerUsedPolarize)
						Achievements.advanceProgress('intentionalLoseByPolarize', [true]);
				} else {
					FlxG.sound.music.resume();
					changeTurn(1);
				}
				playerUsedPolarize = false;
				revealCylinderContents = false;
			}));
		} else {
			getPlayer(playerIndex).playAnim('shocked', true, true);
			if (getPlayer(playerIndex).currentPressure > getPlayer(playerIndex).maxPressure) {
				eliminatePlayer(playerIndex, 0);
			} else {
				doTimer('resumeMusic', new FlxTimer().start(1.0, function(_) {
					FlxG.sound.music.resume();
					changeTurn(0);
				}));
			}
		}

		if (luckyPolarize) {
			Achievements.advanceProgress('rarePolarizeSuccess', [true]);
		}
		luckyPolarize = false;
	}

	function checkToReloadCylinder() {
		if ((!cylinderContent.contains(true) && Gameplay.currentGamemode.cylinderReloadOnNoLives) || cylinderContent.length <= 0) {
			reloadCylinder(Gameplay.currentGamemode.cylinderLiveCount);
		}
	}

	function screenShake(intensity:Float = 0.02, duration:Float = 0.25) {
		if (Preferences.data.cameraEffectIntensity <= 0)
			return;
		FlxG.camera.shake(intensity * Preferences.data.cameraEffectIntensity, duration);
	}

	function screenFlash(color:FlxColor = 0xFFFFFFFF, duration:Float = 0.25) {
		if (Preferences.data.enablePhotosensitiveMode)
			return;
		FlxG.camera.flash(color, duration, true);
	}

	function giveSkillsToAllPlayers(count:Int = 1) {
		var leArray = (Gameplay.currentGamemode.skillsRandomPool.length > 0) ? Gameplay.currentGamemode.skillsRandomPool : Gameplay.currentGamemode.skillsFixedPool;
		var leCount = (Gameplay.currentGamemode.skillsRandomPool.length > 0) ? count : leArray.length;
		for (char in characterGroup) {
			if (Gameplay.currentGamemode.skillsFixedPool.length > 0)
				char.currentSkills = [];
			for (i in 0...leCount) {
				var skillName = '';
				if (Gameplay.currentGamemode.skillsRandomPool.length > 0)
					skillName = Gameplay.currentGamemode.skillsRandomPool[FlxG.random.int(0, Gameplay.currentGamemode.skillsRandomPool.length - 1)]; else if (Gameplay.currentGamemode.skillsFixedPool.length > 0)
					skillName = leArray[i];
				char.currentSkills.push(new Skill(skillName, null, Gameplay.currentGamemode.skillsCostMultiplier));
			}
			if (char.currentSkills.length > 3)
				char.currentSkills.shift(); // Maximum of three skills
		}
	}

	function eliminatePlayer(playerIndex:Int, turnChangeAfterwards:Int = 0) {
		getPlayer(playerIndex).currentPressure = getPlayer(playerIndex).maxPressure + 1;
		isEnding = evaluateEnding(); // Check if remaining players are eliminated
		playGunContactSound();
		pumpGun.visible = true;
		if (currentSessionEnablePopping && !getPlayer(playerIndex).disablePopping) { // Pop player instead
			getPlayer(playerIndex).playAnim('popped', false);
			var character = getPlayer(playerIndex);
			particleGroup.add(new Bloosh(character.x, character.y - character.height / 2));
			if (!Preferences.data.decreaseDetail) {
				particleGroup.add(new ScrapEmitter(character.x, character.y - character.width / 2, character.id, stage.data.characterY, character.maxPressure));

				var particleMultiplier:Float = 1;
				if (Gameplay.currentFiller.particleType == Liquid) {
					if (!Preferences.data.decreaseDetail) {
						for (i in 0...FlxG.random.int(6, 9)) {
							var stain = new Stain(FlxG.random.float(0, FlxG.width), FlxG.random.float(0, FlxG.height), Gameplay.currentFiller.particleColor);
							stain.camera = camEffects;
							particleGroup.add(stain);
						}
					}
					particleMultiplier = 3;
				}
				particleGroup.add(new PopEmitter(character.x, character.y - character.height / 2, stage.data.characterY, Gameplay.currentFiller.particleType, particleMultiplier, Gameplay.currentFiller.particleColor));
				if (!Preferences.data.decreaseDetail) {
					var npcCount = FlxG.random.int(Gameplay.currentFiller.npcCountOnPop[0], Gameplay.currentFiller.npcCountOnPop[1]);
					for (i in 0...npcCount) {
						var npc:NPC = new NPC(Gameplay.currentFiller.npcOnPop, character.x, character.y - character.height / 2, character.id);
						npc.transmutateThreshold = npcCount;
						npc.velocity.set(
							FlxG.random.float(-640, 640),
							FlxG.random.float(-640, 0)
						);
						npcGroup.add(npc);
					}
				}
			}
			SuffState.playSound(Gameplay.currentFiller.getBurstSound());
			getPlayer(playerIndex).disableBellySounds = true;
			screenShake(0.03, 0.5);
			screenFlash();
			getPlayer(playerIndex).acceleration.y = 4800 * getPlayer(playerIndex).poppingGravityMultiplier;
			getPlayer(playerIndex).velocity.x += 320 * (playerIndex >= characterGroup.members.length / 2 ? 1 : -1) * getPlayer(playerIndex)
			.poppingVelocityMultiplier[0] / Gameplay.currentFiller.gravityMultiplier;
			getPlayer(playerIndex).velocity.y = -1200 * getPlayer(playerIndex).poppingVelocityMultiplier[1];
		} else {
			getPlayer(playerIndex).playAnim('idle');
		}

		if (!isEnding) {
			FlxG.sound.music.resume();
			doTween('aTweenButItsATimerLol', FlxTween.tween(camGame, {alpha: 1}, ((currentSessionEnablePopping && !getPlayer(playerIndex).disablePopping) ? 2.5 : 1), {
				onUpdate: function(_:FlxTween) {
					focusCameraOnPlayer(playerIndex);
				}, onComplete: function(_:FlxTween) {
					changeTurn(turnChangeAfterwards);
				}
			}));
		} else {
			doTween('camHUD', FlxTween.tween(camHUD, {alpha: 0}, 0.5));
			doTween('winningTimer', FlxTween.tween(camGame, {alpha: 1}, 1.5, {
				onUpdate: function(_:FlxTween) {
					focusCameraOnPlayer(playerIndex);
				}, onComplete: function(_:FlxTween) {
					playEndCutscene();
				}
			}));
		}

		if (dangerVignette != null) {
			FlxTween.cancelTweensOf(dangerVignette);
			dangerVignette.alpha = 0;
		}
	}

	function playEndCutscene() {
		focusCameraOnStage();
		cameraFocusButton.visible = false;

		var allHumanPlayers:Bool = true;
		var humansThatUsedSkills:Int = 0;
		var allCpuAtHighestLevel:Bool = true;
		for (num => char in characterGroup) {
			if (char.cpuControlled) {
				allHumanPlayers = false;
				if (char.cpuSkillLevel < Constants.CPU_SKILL_LIMIT[1])
					allCpuAtHighestLevel = false;
				continue;
			}
			if (char.skillUseCount > 0)
				humansThatUsedSkills++;
			if (char.getPressurePercentage() > 1) {
				continue;
			}

			Achievements.advanceProgress('firstWin', [true]);
			Achievements.advanceProgress('allGameModeWins', [Gameplay.currentGamemode.id]);
			Achievements.advanceProgress('allCharacterWins', [char.id]);
			Achievements.advanceProgress('allFillerWins', [Gameplay.currentFiller.id]);
			if (char.getPressurePercentage() <= 0)
				Achievements.advanceProgress('noPressureWin', [true]); else if (char.getPressurePercentage() == 1)
				Achievements.advanceProgress('fullPressureWin', [true]);
			if (allCpuAtHighestLevel)
				Achievements.advanceProgress('winAgainstStrategicCPUs', [true]);
			if (characterGroup.members.length == 2)
				Achievements.advanceProgress('twoPlayers', [true]);
			else if (characterGroup.members.length == 6)
				Achievements.advanceProgress('sixPlayers', [true]);

			if (allHumanPlayers && humansThatUsedSkills == 1) {
				Achievements.advanceProgress('winByYourself', [true]);
			}
		}

		doTimer('confettiTimer', new FlxTimer().start(0.5, function(_:FlxTimer) {
			getPlayer(winnerIndex).playAnim('shocked', false);
			SuffState.playSound(Paths.sound('game/confetti'));
			members.insert(members.indexOf(characterGroup), new ConfettiEmitter(getPlayer(winnerIndex).x - FlxG.width / 2.5, getPlayer(winnerIndex).y - getPlayer(winnerIndex).height, 30, stage.data.characterY));
			members.insert(members.indexOf(characterGroup), new ConfettiEmitter(getPlayer(winnerIndex).x + FlxG.width / 2.5, getPlayer(winnerIndex).y - getPlayer(winnerIndex).height, 150, stage.data.characterY));
			doTimer('winAnim', new FlxTimer().start(0.5 + getPlayer(winnerIndex).getCurAnimLength(), function(_:FlxTimer) {
				SuffState.playMusic('win', 1, true);
				getPlayer(winnerIndex).playAnim('win', false);
				doTimer('finishCutscene', new FlxTimer().start(Math.max(4.5, getPlayer(currentTurnIndex).getCurAnimLength()), function(_:FlxTimer) {
					finishEndCutscene();
				}));
			}));
		}));
	}

	function finishEndCutscene() {
		SuffState.playMusic('null');
		ResultsState.data = ScoringUtil.judgeGame(characterGroup.members);
		FlxTransitionableState.skipNextTransOut = true;
		SuffState.switchState(new ResultsState(), FADE);
	}

	function changeTurnNumber(change:Int = 0) {
		currentTurnIndex = (currentTurnIndex + change) % Gameplay.selectedCharacterList.length;
	}

	function changeTurn(change:Int = 0, slient:Bool = false) {
		var PrevTurn:Int = currentTurnIndex;
		var flipX:Bool = PrevTurn >= Std.int(Gameplay.selectedCharacterList.length / 2) && PrevTurn != Gameplay.selectedCharacterList.length - 1;
		changeTurnNumber(change);
		getPlayer(PrevTurn).canUseSkills = true;
		if (!(Preferences.data.skipEliminatedPlayers && getPlayer(PrevTurn).isEliminated())) {
			focusCameraOnPlayer(PrevTurn);
			getPlayer(PrevTurn).playAnim('pass', true, true, flipX);
		}
		if (!pumpGun.visible)
			playGunContactSound();
		reloadPlayerUI(currentTurnIndex);
		if (change != 0) {
			pumpGun.visible = true;
			doTween('pumpGunPass', FlxTween.tween(pumpGun, {x: pumpGunXDestinations[currentTurnIndex]}, 0.5, {
				startDelay: (!(Preferences.data.skipEliminatedPlayers && getPlayer(currentTurnIndex).isEliminated()) ? 0.5 : 0), ease: FlxEase.quadOut, onStart: function(_:FlxTween) {
					if (!slient)
						SuffState.playSound(Paths.sound('game/weaponSlide'));
					if (!(Preferences.data.skipEliminatedPlayers && getPlayer(currentTurnIndex).isEliminated()))
						focusCameraOnPlayer(currentTurnIndex); else
						changeTurn(change, true);
				}, onComplete: function(_:FlxTween) {
					if (!getPlayer(currentTurnIndex).isEliminated()) {
						getPlayer(currentTurnIndex).playAnim('prepareShoot', false);
						playGunContactSound();
						pumpGun.visible = false;
						canUseSkillKeybinds = !getPlayer(currentTurnIndex).cpuControlled;
						togglePlayerUI(!getPlayer(currentTurnIndex).cpuControlled);
						toggleLetterbox(getPlayer(currentTurnIndex).cpuControlled);
						if (getPlayer(currentTurnIndex).cpuControlled) {
							startCPUAction();
						} else {
							toggleCameraFocusButton(true);
						}
					} else {
						doTimer('helplessPreAnim', new FlxTimer().start(0.5, function(_:FlxTimer) {
							getPlayer(currentTurnIndex).playAnim('helpless', true);
							doTimer('helplessAnim', new FlxTimer().start(getPlayer(currentTurnIndex).getCurAnimLength(), function(_:FlxTimer) {
								changeTurn(change);
							}));
						}));
					}
				}
			}));
		} else {
			getPlayer(currentTurnIndex).playAnim('prepareShoot', false);
			pumpGun.visible = false;
			togglePlayerUI(!Gameplay.cpuControlled[currentTurnIndex]);
			toggleLetterbox(Gameplay.cpuControlled[currentTurnIndex]);
		}
	}

	function startCPUAction() {
		trace(getPlayer(currentTurnIndex));
		new FlxTimer().start(FlxG.random.float() + 0.5, function(timer:FlxTimer) {
			evaluateCPUActions(currentTurnIndex);
		});
	}

	function evaluateCPUActions(charIndex:Int) {
		if (isEnding) return;
		var char = getPlayer(charIndex);
		if (char.cpuSkillLevel <= 1 || !char.canUseSkills) {
			trace('CPU cannot use skills');
			deployGun(currentTurnIndex, function() return getPlayer(currentTurnIndex).getPressurePercentage());
			return;
		}
		var currentRoundIsLive:Bool = false;
		var actionName:String = 'deployGun';
		var index:String = '';
		var target:String = '';
		for (num => i in cylinderContent) {
			if (i && num % characterGroup.members.length == 0)
				currentRoundIsLive = true;
		}
		for (skillIndex => skill in char.currentSkills) {
			if (char.cpuSkillMemories.contains(skill.id) && skill.cpuUseOnce) continue;
			if (char.currentConfidence - skill.cost < 0) {
				trace('Not enough confidence for ${skill.id}');
				continue;
			}
			var wantSkillChance:Float = Math.pow(char.getPressurePercentage(false), 0.5);
			if (char.cpuSkillLevel >= 3) {
				wantSkillChance += 1 / cylinderContent.length;
			} else if (char.cpuSkillLevel >= 2) {
				wantSkillChance += 1 / cylinderContent.length * 0.5;
			}
			if (!skill.offensive)
				wantSkillChance *= 1.25;
			if (char.cpuKnowsCylinderContents || char.cpuSabotageVictim) {
				if (currentRoundIsLive) {
					if (skill.id == 'sabotage' || skill.id == 'polarize' || skill.id == 'reload' || skill.id == 'assault')
						wantSkillChance = 1;
				} else {
					if (skill.id == 'pressurize' || skill.id == 'assault' || skill.id == 'reload')
						wantSkillChance = 0;
				}
			} else {
				if (skill.id == 'polarize') wantSkillChance = 0;
			}
			if (char.currentPressure > 0 && skill.id == 'deflate') {
				if (char.cpuSkillLevel >= 3) wantSkillChance = 1;
				else if (char.cpuSkillLevel >= 2) wantSkillChance += char.getPressurePercentage() * 0.5;
			}
			if (skill.cpuConservePreferred)
				wantSkillChance = wantSkillChance * wantSkillChance;
			wantSkillChance = Math.min(1, wantSkillChance);
			if (!FlxG.random.bool(wantSkillChance * 100)) {
				trace('Does not want to use ${skill.id} yet');
				continue;
			};

			actionName = 'activateSkill';

			index = '$skillIndex';
			if (skill.offensive) {
				actionName = 'activateOffensiveSkill';
				if (char.cpuSkillLevel >= 3) {
					target = '';
					var maxPressureIndex:Int = FlxMath.wrap(charIndex + 1, 0, characterGroup.members.length - 1);
					while (getPlayer(maxPressureIndex).isEliminated())
						maxPressureIndex = FlxMath.wrap(maxPressureIndex + 1, 0, characterGroup.members.length - 1);
					for (i in 2...characterGroup.members.length) {
						var targetIndex:Int = FlxMath.wrap(charIndex + i, 0, characterGroup.members.length - 1);
						if (getPlayer(targetIndex).isEliminated() || targetIndex == charIndex) continue;
						if (getPlayer(targetIndex).currentPressure > getPlayer(maxPressureIndex).currentPressure) {
							maxPressureIndex = targetIndex;
						}
					}
					if (maxPressureIndex == charIndex) continue;
					target = '|$maxPressureIndex';
				} else {
					var tar:Int = FlxG.random.int(0, characterGroup.members.length - 1, [charIndex]);
					while (getPlayer(tar).isEliminated()) {
						tar = FlxG.random.int(0, characterGroup.members.length - 1, [charIndex]);
					}
					target = '|$tar';
				}
			}
			break;
		}

		var actions = '$actionName|$index${target}';
		trace(actions);
		var params = actions.split('|');
		switch (params[0]) {
			default:
				getPlayer(charIndex).cpuSkillMemories = [];
				deployGun(charIndex, function() return getPlayer(charIndex).getPressurePercentage());
			case 'activateSkill':
				var skill:Skill = getPlayer(charIndex).currentSkills[Std.parseInt(params[1])];
				getPlayer(charIndex).cpuSkillMemories.push(skill.id);
				activateSkill(charIndex, Std.parseInt(params[1]));
				doTimer('cpuAction', new FlxTimer().start(FlxG.random.float() + 0.5 + getPlayer(charIndex).getCurAnimLength(), function(_) {
					evaluateCPUActions(charIndex);
				}));
			case 'activateOffensiveSkill':
				var skill:Skill = getPlayer(charIndex).currentSkills[Std.parseInt(params[1])];
				getPlayer(charIndex).cpuSkillMemories.push(skill.id);
				activateOffensiveSkill(charIndex, Std.parseInt(params[1]), Std.parseInt(params[2]));
				doTimer('cpuAction', new FlxTimer().start(FlxG.random.float() + 1.5 + getPlayer(charIndex).getCurAnimLength(), function(_) {
					evaluateCPUActions(charIndex);
				}));
		}
	}

	function focusCameraOnPlayer(playerIndex:Int) {
		var characterCameraOffset:Array<Float> = getPlayer(playerIndex).cameraOffset;
		if (getPlayer(playerIndex).isEliminated() && (currentSessionEnablePopping && !getPlayer(playerIndex).disablePopping))
			characterCameraOffset = getPlayer(playerIndex).poppedCameraOffset;

		camFollow.x = getPlayer(playerIndex).x + characterCameraOffset[0];
		camFollow.y = getPlayer(playerIndex).y + characterCameraOffset[1];
		camFollowZoom = stage.data.characterCameraZoom;

		if (dangerVignette != null) {
			FlxTween.cancelTweensOf(dangerVignette);
			if (getPlayer(playerIndex).getPressurePercentage() == 1) {
				FlxTween.tween(dangerVignette, {alpha: 1}, 4);
			} else {
				FlxTween.tween(dangerVignette, {alpha: 0}, 1);
			}
		}
	}

	function focusCameraOnStage() {
		camFollow.x = FlxG.width / 2;
		camFollow.y = FlxG.height / 2;
		camFollowZoom = stage.data.stageCameraZoom;

		if (dangerVignette != null) {
			FlxTween.cancelTweensOf(dangerVignette);
			FlxTween.tween(dangerVignette, {alpha: 0}, 0.5);
		}
	}

	function doTween(tag:String, tween:FlxTween) {
		if (gameTweens.exists(tag)) {
			gameTweens.get(tag).cancel();
			gameTweens.get(tag).destroy();
			gameTweens.remove(tag);
		}
		gameTweens.set(tag, tween);
	}

	function doTimer(tag:String, timer:FlxTimer) {
		if (gameTimers.exists(tag)) {
			gameTimers.get(tag).cancel();
			gameTimers.get(tag).destroy();
			gameTimers.remove(tag);
		}
		gameTimers.set(tag, timer);
	}

	function toggleLetterbox(moveIn:Bool = true) {
		var reallyMoveIn:Bool = moveIn;
		if (!Preferences.data.enableLetterbox)
			reallyMoveIn = false;
		letterboxDisplayed = reallyMoveIn;
		if (reallyMoveIn) {
			doTween('letterboxTopTween', FlxTween.tween(letterboxTop, {y: 0}, 1, {
				ease: FlxEase.cubeOut, onUpdate: function(_:FlxTween) {
					pauseButton.y = letterboxTop.y + letterboxTop.height + 20 + ScreenSafeArea.Y;
				}
			}));
			doTween('letterboxBottomTween', FlxTween.tween(letterboxBottom, {y: FlxG.height - letterboxBottom.height}, 1, {
				ease: FlxEase.cubeOut, onUpdate: function(_) {
					cameraFocusButton.y = letterboxBottom.y - cameraFocusButton.height - 20;
				}
			}));
		} else {
			doTween('letterboxTopTween', FlxTween.tween(letterboxTop, {y: -letterboxTop.height}, 1, {
				ease: FlxEase.cubeOut, onUpdate: function(_:FlxTween) {
					pauseButton.y = letterboxTop.y + letterboxTop.height + 20 + ScreenSafeArea.Y;
				}
			}));
			doTween('letterboxBottomTween', FlxTween.tween(letterboxBottom, {y: FlxG.height}, 1, {
				ease: FlxEase.cubeOut, onUpdate: function(_) {
					cameraFocusButton.y = letterboxBottom.y - cameraFocusButton.height - 20;
				}
			}));
		}
	}

	function togglePlayerUI(moveIn:Bool = false) {
		shootButton.disabled = !moveIn;
		canUseSkillKeybinds = moveIn;
		if (!moveIn) {
			for (skillCard in skillCardsGroup) {
				skillCard.disabled = false;
			}
		}
		reloadRevealUI();
		if (moveIn) {
			doTween('shootButtonMoveTween', FlxTween.tween(shootButton, {x: ScreenSafeArea.X}, 0.5, {ease: FlxEase.cubeOut}));
			doTween('skillCardsGroupMoveTween', FlxTween.tween(skillCardsGroup, {x: skillCardsGroupPaddingX}, 0.5, {ease: FlxEase.cubeOut}));
			doTween('uiBGGroupMoveTween', FlxTween.tween(uiBGGroup, {x: 0}, 0.25, {ease: FlxEase.cubeOut}));
			doTween('uiRevealGroupMoveTween', FlxTween.tween(uiRevealGroup, {x: ScreenSafeArea.X + shootButton.width}, 0.325, {ease: FlxEase.cubeOut}));
		} else {
			doTween('shootButtonMoveTween', FlxTween.tween(shootButton, {x: -shootButton.width}, 0.5, {ease: FlxEase.cubeOut}));
			doTween('skillCardsGroupMoveTween', FlxTween.tween(skillCardsGroup, {x: -skillCardsGroup.width}, 0.5, {ease: FlxEase.cubeOut}));
			doTween('uiBGGroupMoveTween', FlxTween.tween(uiBGGroup, {x: -uiBGGroup.width}, 0.25, {ease: FlxEase.cubeOut}));
			doTween('uiRevealGroupMoveTween', FlxTween.tween(uiRevealGroup, {x: -uiRevealGroup.width}, 0.325, {ease: FlxEase.cubeOut}));
		}
	}

	function reloadRevealUI() {
		uiRevealGroup.clear();
		uiRevealGroup.visible = revealCylinderContents && !getPlayer(currentTurnIndex).cpuControlled;
		if (!revealCylinderContents) return;
		var arrow:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/bulletArrow'));
		for (num => state in cylinderContent) {
			var bullet = new RevealBullet(0, 0, state);
			bullet.x = num * bullet.width;
			bullet.y = arrow.height;
			uiRevealGroup.add(bullet);
		}
		uiRevealGroup.add(arrow);
		uiRevealGroup.y = shootButton.y + (shootButton.height - uiRevealGroup.height) * 0.75;
	}

	function toggleCameraFocus() {
		isManuallyFocusingStage = !isManuallyFocusingStage;
		if (isManuallyFocusingStage) {
			focusCameraOnStage();
			togglePlayerUI(false);
		} else {
			focusCameraOnPlayer(currentTurnIndex);
			togglePlayerUI(true);
		}
		updateSkillAvailability(currentTurnIndex);
	}

	function evaluateEnding() {
		var aliveCharCount:Int = 0;
		var aliveCharIndex:Int = 0;
		for (char in characterGroup) {
			if (!char.isEliminated()) {
				aliveCharCount++;
				aliveCharIndex = characterGroup.members.indexOf(char);
			}
		}
		if (aliveCharCount <= 1) {
			winnerIndex = aliveCharIndex;
			togglePauseFunctionality(false);
		}
		return (aliveCharCount <= 1);
	}

	public function pauseGame() {
		if (!canPause)
			return;
		persistentUpdate = false;
		isPaused = true;
		toggleMonochrome(true);
		FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if (!tmr.finished)
			tmr.active = false);
		FlxTween.globalManager.forEach(function(twn:FlxTween) if (!twn.finished)
			twn.active = false);
	}

	public function resumeGame() {
		persistentUpdate = true;
		isPaused = false;
		toggleMonochrome(false);
		FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if (!tmr.finished)
			tmr.active = true);
		FlxTween.globalManager.forEach(function(twn:FlxTween) if (!twn.finished)
			twn.active = true);

		setWindowTitle();

		super.closeSubState();
	}

	public function restartGame() {
		persistentUpdate = true;
		isPaused = false;
		toggleMonochrome(false);
		FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if (!tmr.finished)
			tmr.cancel());
		FlxTween.globalManager.forEach(function(twn:FlxTween) if (!twn.finished)
			twn.cancel());

		setWindowTitle();

		currentTurnIndex = 0;
		reloadCylinder(Gameplay.currentGamemode.cylinderLiveCount);
		currentSessionEnablePopping = Preferences.data.enablePopping;

		for (npc in npcGroup) {
			if (npc != null)
				npc.destroy();
		}
		npcGroup.clear();

		for (effect in particleGroup) {
			if (effect != null)
				effect.destroy();
		}
		particleGroup.clear();

		pressurizeStreak = [];
		lastPressurizeUserIndex = -1;
		for (num => char in characterGroup) {
			pressurizeStreak.push(0);
			var leX:Int = Std.int(FlxMath.lerp(FlxG.width / 2 + stage.data.characterX[0], FlxG.width / 2 + stage.data.characterX[1], num / (characterGroup.members.length - 1)));
			char.x = leX;
			char.y = stage.data.characterY;
			char.currentPressure = 0;
			char.currentConfidence = 0;
			char.playAnim('idle' + char.currentPressure);
		}

		pumpGun.x = pumpGunXDestinations[currentTurnIndex];

		if (Gameplay.currentGamemode.skillsFixedPool.length + Gameplay.currentGamemode.skillsRandomPool.length > 0) {
			for (char in characterGroup) {
				char.currentSkills = [];
			}
			giveSkillsToAllPlayers(1);
		}

		toggleCameraFocusButton(!getPlayer(currentTurnIndex).cpuControlled);
		reloadRevealUI();
		focusCameraOnPlayer(currentTurnIndex);

		finishStartCutscene();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		pressureBar.updateBar();
		confidenceBar.updateBar();

		if (!isPaused) {
			FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, camFollowZoom, FlxMath.bound(elapsed * 5, 0, 1));

			if (Controls.justPressed('shoot') && !Gameplay.cpuControlled[currentTurnIndex] && !shootButton.disabled) {
				deployGun(currentTurnIndex, function() return getPlayer(currentTurnIndex).getPressurePercentage());
			}

			if (canUseSkillKeybinds) {
				for (num => skillCard in skillCardsGroup.members) {
					if (Controls.justPressed('skill${num + 1}')) {
						activateSkill(currentTurnIndex, num);
					}
				}
			}

			if (Preferences.data.enableDebugKeybinds) {
				if (Controls.justPressed('debug1')) {
					Achievements.enabled = false;
					getPlayer(currentTurnIndex).currentConfidence += 1;
					updateSkillAvailability(currentTurnIndex);
				}
				if (Controls.justPressed('debug2')) {
					Achievements.enabled = false;
					shoot(currentTurnIndex);
				}
			}

			if (isSelectingPlayer) {
				if (Controls.justPressed('exit'))
					cancelOffensiveSkill();
				for (num => player in characterGroup) {
					if (num != offensiveSkillAttacker && !player.isEliminated() && player.mouseOverlapsBoundingBox()) {
						if (!player.hovered) {
							player.hovered = true;
							selectLight.scale.x = 1;
							selectLight.scale.y = player.height / 256;
							selectLight.updateHitbox();
							selectLight.x = player.x - selectLight.width / 2;
							selectLight.scale.x = 1 / selectLight.width;
							selectLight.y = player.y - selectLight.height;
							selectLight.visible = true;
							doTween('selectLight', FlxTween.tween(selectLight, {'scale.x': player.width * 0.4 / selectLight.width}, 0.5, {ease: FlxEase.cubeOut}));
						}
						if (FlxG.mouse.justPressed && player.hovered) {
							activateOffensiveSkill(offensiveSkillAttacker, offensiveSkillIndex, num);
							break;
						}
					} else if (player.hovered) {
						player.hovered = false;
					}
				}
			} else {
				if (Controls.justPressed('camera') && !cameraFocusButton.disabled)
					toggleCameraFocus();
				else if (Controls.justPressed('pause') && canPause) {
					pauseGame();
					openSubState(new PauseSubState());
				}
			}

			var switchCursor:Bool = false;
			for (player in characterGroup) {
				if (player.cursorOnBelly)
					switchCursor = false;
				if (player.velocity.x != 0 && player.velocity.y != 0) {
					if (player.x + player.velocity.x * elapsed < stage.data.cameraBounds[0] || player.x + player.velocity.x * elapsed > stage.data.cameraBounds[2] - Math.abs(stage.data.cameraBounds[0])) {
						player.velocity.x *= -1;
						player.x = player.x + player.velocity.x * elapsed;
					}
					if (player.y + player.velocity.y * elapsed > stage.data.characterY) {
						player.velocity.y *= -0.5;
						player.y = stage.data.characterY + player.velocity.y * elapsed;
						player.velocity.x *= 0.5;
						player.playAnim('idleNull', false);
						if (Math.abs(player.velocity.y) < 100) {
							player.velocity.x = 0;
							player.velocity.y = 0;
							player.acceleration.y = 0;
						}
					}
				}
			}
			CursorHandler.setCursorStyle((switchCursor ? 'rub' : 'default'));
		}
	}
}
