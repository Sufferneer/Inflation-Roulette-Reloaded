package states;

import backend.CharacterManager;
import backend.typedefs.CharacterData;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.effects.FlxFlicker;
import flixel.util.FlxGradient;
import states.MainMenuState;
import states.PlayState;
import substates.GameOnSubState;
import tjson.TJSON as Json;
import ui.objects.CharacterBanner;
import ui.objects.CharacterCard;
import ui.objects.CharacterSelectText;
import ui.objects.ReadySign;
import ui.objects.SuffBoolean;
import ui.objects.SuffSlider;
import ui.objects.SuffIconButton;
import backend.Gameplay;
import shaders.DissolveShader;
import ui.objects.StageCard;
import ui.objects.FillerCard;
import backend.Filler;

enum CharacterSelectStatus {
	CHARACTER_SELECT;
	FILLER_SELECT;
	STAGE_SELECT;
	PLAYER_SETTINGS;
}

class CharacterSelectState extends SuffState {
	var curPlayer:Int = 0;
	var curPage:Int = 0;
	var lastPage:Int = 0;
	var maxNumberInRow:Int = 0;
	var playerPages:Array<Int> = [];

	static final margin:Int = 50;
	public static final cardOccupicationHeight:Float = 0.35;

	var sectionWidth:Int = Math.ceil(FlxG.width / CharacterManager.selectedCharacterList.length);
	var optionY:Array<Float> = [16, 16, 16, 16, 16, 16, 16, 16];

	var initialCardY:Float = 0;
	var initialDescriptionY:Float = 0;
	final shadowCount:Int = 6;
	var status:CharacterSelectStatus = CHARACTER_SELECT;
	var isExiting:Bool = false;

	var fillerLeft:FlxBackdrop;
	var fillerRight:FlxBackdrop;
	var grid:FlxBackdrop;
	var stageGroup:FlxSpriteGroup;
	var stageShaderMap:Array<DissolveShader> = [];
	var bg2:FlxSprite;
	var playerOutline:FlxSprite;
	var playerOutlineShadows:FlxTypedContainer<FlxSprite> = new FlxTypedContainer<FlxSprite>();
	var description:CharacterSelectText;
	var bannerGroup:FlxTypedSpriteGroup<CharacterBanner> = new FlxTypedSpriteGroup<CharacterBanner>();
	var stageSelectGroup:FlxSpriteGroup = new FlxSpriteGroup();
	var playerSettingGroup:FlxSpriteGroup = new FlxSpriteGroup();
	var cantEarnAchievementsTxt:FlxText;
	var canEarnAchievements:Bool = true;
	var marginLeft:FlxSpriteGroup = new FlxSpriteGroup();
	var marginRight:FlxSpriteGroup = new FlxSpriteGroup();
	var leftButton:SuffButton;
	var rightButton:SuffButton;
	var readySign:ReadySign;
	var selectCharacterTxt:FlxText;

	var stages:Array<String> = [];
	var leftStageButton:SuffIconButton;
	var curStage:Int = 0;
	var rightStageButton:SuffIconButton;

	var cardGroup:FlxTypedSpriteGroup<CharacterCard> = new FlxTypedSpriteGroup<CharacterCard>();
	var fillerGroup:FlxTypedSpriteGroup<FillerCard> = new FlxTypedSpriteGroup<FillerCard>();

	override function create() {
		super.create();

		Window.setTitle(Language.getPhrase('characterSelect.windowDisplay'));

		var characterList = CharacterManager.globalCharacterList.copy();
		if (characterList.length >= 3) {
			characterList.push('random');
		}

		var fillerList = Gameplay.globalFillerList.copy();
		if (fillerList.length >= 3) {
			fillerList.push('random');
		}

		stageGroup = new FlxSpriteGroup();
		add(stageGroup);
		add(bannerGroup);
		CharacterBanner.precacheBanners();
		for (i in 0...CharacterManager.selectedCharacterList.length) {
			var banner = new CharacterBanner(i);
			banner.onClick = function() {
				if (!leftButton.disabled)
					setPlayer(i);
			}
			bannerGroup.add(banner);

			CharacterManager.selectedCharacterList[i] = '';

			playerPages.push(curPage);
		}
		bannerGroup.x = (FlxG.width - bannerGroup.width) / 2;

		grid = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x20FFFFFF, 0x0));
		grid.velocity.set(160, 160);
		add(grid);

		if (bannerGroup.x > 0) {
			fillerLeft = new FlxBackdrop(Paths.image('ui/menus/filler'), Y);
			var leScale = Math.max(1, (FlxG.width - bannerGroup.width) / 2 / fillerLeft.width);
			fillerLeft.scale.set(leScale, leScale);
			fillerLeft.updateHitbox();
			fillerLeft.x = bannerGroup.x - fillerLeft.width;
			fillerLeft.velocity.y = 40;
			add(fillerLeft);

			fillerRight = new FlxBackdrop(Paths.image('ui/menus/filler'), Y);
			var leScale = Math.max(1, (FlxG.width - bannerGroup.width) / 2 / fillerRight.width);
			fillerRight.scale.set(leScale, leScale);
			fillerRight.updateHitbox();
			fillerRight.x = bannerGroup.x + bannerGroup.width;
			fillerRight.velocity.y = -40;
			add(fillerRight);
		}

		selectCharacterTxt = new FlxText(0, 0, 0, Language.getPhrase('characterSelect.selectCharacter'));
		selectCharacterTxt.setFormat(Paths.font('default'), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.SHADOW, 0x80000000);
		selectCharacterTxt.borderSize = 4;
		selectCharacterTxt.screenCenter();
		selectCharacterTxt.y = FlxG.height * (1 - cardOccupicationHeight) - selectCharacterTxt.height;
		add(selectCharacterTxt);

		add(playerOutlineShadows);

		var firstBanner = bannerGroup.members[0];
		playerOutline = new FlxSprite().loadGraphic(Utilities.makeBorder(Std.int(firstBanner.width), Std.int(firstBanner.height), 10,
			0xFFFFFFFF));
		playerOutline.x = firstBanner.x;
		add(playerOutline);

		for (i in 0...shadowCount) {
			var shadow = new FlxSprite(playerOutline.x, playerOutline.y).loadGraphic(playerOutline.graphic);
			shadow.alpha = (shadowCount - i - 1) / shadowCount;
			playerOutlineShadows.add(shadow);
		}

		bg2 = new FlxSprite(0, FlxG.height * (1 - cardOccupicationHeight)).makeGraphic(FlxG.width, Math.ceil(FlxG.height), 0xFF000000);
		add(bg2);

		add(cardGroup);
		add(fillerGroup);

		var leScale = 1;
		var calculatedWidth = Constants.CHARACTER_CARD_DIMENSIONS[0];
		maxNumberInRow = findMaximumCardsPerRow();

		var fadeWidth:Int = 16;

		var innerMarginLeft = new FlxSprite().makeGraphic(Std.int((FlxG.width - maxNumberInRow * calculatedWidth) / 2 - fadeWidth),
			Std.int(FlxG.height * cardOccupicationHeight), 0xFF000000);

		var innerMarginRight = new FlxSprite(fadeWidth,
			0).makeGraphic(Std.int((FlxG.width - maxNumberInRow * calculatedWidth) / 2 - fadeWidth), Std.int(FlxG.height * cardOccupicationHeight + 100), 0xFF000000);

		description = new CharacterSelectText(0, 0, null);
		description.y = FlxG.height - description.height;
		initialDescriptionY = description.y;

		add(description);
		add(marginLeft);
		add(marginRight);

		marginLeft.add(innerMarginLeft);
		marginRight.add(innerMarginRight);

		var color1:FlxColor = 0xFF000000;
		var color2:FlxColor = 0x0;

		var fadeLeft = new FlxSprite(marginLeft.width,
			0).loadGraphic(FlxGradient.createGradientBitmapData(fadeWidth, Std.int(marginLeft.height), [color1, color2], 1, 0));
		marginLeft.add(fadeLeft);

		var fadeRight = new FlxSprite().loadGraphic(FlxGradient.createGradientBitmapData(fadeWidth, Std.int(marginRight.height), [color1, color2], 1, 180));
		marginRight.add(fadeRight);

		marginLeft.y = marginRight.y = FlxG.height * (1 - cardOccupicationHeight);
		marginRight.x = FlxG.width - marginRight.width;

		add(stageSelectGroup);
		stages = Gameplay.globalStageList.copy();
		stages.push('random');
		// trace(stages);
		for (num => i in stages) {
			var stage:StageCard = new StageCard(0, 0, i);
			stage.onClick = function() {
				confirmStage(i);
			}
			stage.x = (FlxG.width - stage.width) / 2 + FlxG.width * num;

			var stageName = new FlxText(0, 0, 0, Language.getPhrase('stage.$i.name'), 48);
			stageName.x = stage.x + (stage.width - stageName.width) / 2;
			stageName.y = stage.y + stage.height + 8;
			stageSelectGroup.add(stage);
			stageSelectGroup.add(stageName);
		}

		leftStageButton = new SuffIconButton(0, 0, 'buttons/left', 2);
		leftStageButton.onClick = function() {
			changeStage(-1);
		}
		leftStageButton.x = (FlxG.width - leftStageButton.width) / 2 - 232;
		leftStageButton.y = FlxG.height;

		rightStageButton = new SuffIconButton(0, 0, 'buttons/right', 2);
		rightStageButton.onClick = function() {
			changeStage(1);
		}
		rightStageButton.x = (FlxG.width - leftStageButton.width) / 2 + 232;
		rightStageButton.y = FlxG.height;

		add(leftStageButton);
		add(rightStageButton);
		stageSelectGroup.y = FlxG.height;

		var save = new FlxSave();
		save.bind('preferences', Utilities.getSavePath());
		var CPUControlled:String = save.data.characterCPUControlled ?? '01111111';
		var SkillLevel:String = save.data.characterSkillLevel ?? '22222222';
		for (i in 0...CharacterManager.selectedCharacterList.length) {
			var int = CPUControlled.charAt(i);
			if (int.length <= 0)
				if (i == 0) int = '0'; else int = '1';
			CharacterManager.cpuControlled[i] = Std.parseInt(int) == 1;
			var int = SkillLevel.charAt(i);
			if (int.length <= 0) int = '2';
			CharacterManager.cpuLevel[i] = Std.parseInt(int);
		}

		canEarnAchievements = ([for (i in CharacterManager.cpuControlled) if (!i) i].length == 1);

		add(playerSettingGroup);
		for (i in 0...CharacterManager.selectedCharacterList.length) {
			addBooleanOption(i, Language.getPhrase('characterSelect.option.cpuControlled'), function(val:Bool) {
				CharacterManager.cpuControlled[i] = val;
				canEarnAchievements = ([for (i in CharacterManager.cpuControlled) if (!i) i].length == 1);
				cantEarnAchievementsTxt.visible = !canEarnAchievements;
			}, CharacterManager.cpuControlled[i]);

			addSliderOption(i, Language.getPhrase('characterSelect.option.skillLevel'), function(val:Float) {
				CharacterManager.cpuLevel[i] = Std.int(val);
			}, Constants.CPU_SKILL_LIMIT[0], Constants.CPU_SKILL_LIMIT[1], 1, function(val:Float) {
				return Language.getPhrase('characterSelect.option.skillLevel.' + Std.int(val), [], '${Std.int(val)}');
			}, CharacterManager.cpuLevel[i]);
		}
		cantEarnAchievementsTxt = new FlxText(Language.getPhrase('characterSelect.cantEarnAchievements'), 32);
		cantEarnAchievementsTxt.screenCenter();
		cantEarnAchievementsTxt.color = 0xFF808080;
		cantEarnAchievementsTxt.y = FlxG.height - cantEarnAchievementsTxt.height - 4;
		cantEarnAchievementsTxt.visible = false;
		add(cantEarnAchievementsTxt);
		playerSettingGroup.y = FlxG.height;

		var calculatedHeight = Constants.CHARACTER_CARD_DIMENSIONS[1] * leScale;
		lastPage = Std.int(((characterList.length - 1) * calculatedWidth) / (FlxG.width - marginLeft.width - marginRight.width));
		initialCardY = FlxG.height * (1 - cardOccupicationHeight) + (FlxG.height * cardOccupicationHeight - description.height - calculatedHeight) / 2;
		for (i in 0...characterList.length) {
			var leChar:CharacterData = {
				id: 'random',
				// name: '???',
				// description: 'Not sure who to choose? Let the game decide!',
				skills: [],
				maxPressure: 0,
				maxConfidence: 0
			};
			if (characterList[i] != 'random')
				leChar = cast Json.parse(Paths.getTextFromFile('data/characters/' + characterList[i] + '/stats.json'));
			leChar.id = characterList[i];

			var card = new CharacterCard(0, 0, leChar);
			card.setScale(leScale, leScale);
			card.x = (FlxG.width - maxNumberInRow * calculatedWidth) / 2 + calculatedWidth * i;
			if (lastPage == 0) {
				card.x = (FlxG.width - characterList.length * calculatedWidth) / 2 + calculatedWidth * i;
			}
			card.y = initialCardY;
			card.onIdle = function() {
				card.playAnim('selected', true, true);
			}
			card.onHover = function() {
				card.playAnim('selected', true);
				changeDescription(leChar);
			};
			card.onClick = function() {
				card.designatedPlayer = curPlayer;
				confirmCharacter(card.characterData.id, i);
				card.holdAnim = true;
			};
			cardGroup.add(card);
		}
		for (i => fillerID in fillerList) {
			var fillerData = new Filler(fillerID);
			var card:FillerCard = new FillerCard(0, 0, fillerData);
			card.x = (FlxG.width - maxNumberInRow * calculatedWidth) / 2 + calculatedWidth * i;
			if (lastPage == 0) {
				card.x = (FlxG.width - fillerList.length * calculatedWidth) / 2 + calculatedWidth * i;
			}
			card.y = initialCardY;
			card.onHover = function() {
				changeDescription(null, 'filler.$fillerID.description');
			};
			card.onClick = function() {
				confirmFiller(i);
			};
			fillerGroup.add(card);
		}
		fillerGroup.y = FlxG.height;

		leftButton = new SuffButton(0, 0, null, Paths.image('ui/icons/buttons/left'), null, 100, 100);
		leftButton.x = marginLeft.x + marginLeft.width - leftButton.width - 32;
		leftButton.y = marginLeft.y + (FlxG.height * cardOccupicationHeight - leftButton.height) / 2;
		leftButton.onClick = function() {
			changePage(-1);
		};
		leftButton.visible = lastPage > 0;
		add(leftButton);

		rightButton = new SuffButton(0, 0, null, Paths.image('ui/icons/buttons/right'), null, 100, 100);
		rightButton.x = marginRight.x + 32;
		rightButton.y = leftButton.y;
		rightButton.onClick = function() {
			changePage(1);
		};
		rightButton.visible = lastPage > 0;
		add(rightButton);

		var exitButton = new SuffIconButton(20, 20, 'buttons/exit', null, 2);
		exitButton.x = FlxG.width - exitButton.width - 20 - ScreenSafeArea.X;
		exitButton.y = FlxG.height - exitButton.height - 20 - ScreenSafeArea.Y;
		exitButton.scrollFactor.set();
		exitButton.onClick = function() {
			exitFunction();
		};
		add(exitButton);

		readySign = new ReadySign();
		readySign.onClick = function() {
			proceedToPlayState();
		};
		add(readySign);

		changeDescription(null);
		changePage();

		SuffState.playMusic('characterSelect', 1, true);
	}

	function addBooleanOption(i:Int, name:String, callback:Bool->Void, defaultValue:Bool) {
		var option:SuffBoolean = new SuffBoolean(0, optionY[i], callback, defaultValue);

		var text:FlxText = new FlxText(0, optionY[i], 0, name);
		text.setFormat(Paths.font('default'), 32, FlxColor.WHITE, LEFT);

		text.x = sectionWidth * i + (sectionWidth - (text.width + 8 + option.width)) / 2;
		text.y = optionY[i] + (option.height - text.height) / 2;
		option.x = sectionWidth * i + (sectionWidth - (text.width + 8 + option.width)) / 2 + (text.width + 8);

		optionY[i] += (Math.max(option.height, text.height) + 16);

		playerSettingGroup.add(option);
		playerSettingGroup.add(text);
	}

	function addSliderOption(i:Int, name:String, callback:Float->Void, rangeMin:Float, rangeMax:Float, step:Float, displayFunction:Float->String,
			defaultValue:Float) {
		var option:SuffSlider = new SuffSlider(sectionWidth * i + (sectionWidth - 256) / 2, optionY[i], callback, rangeMin, rangeMax, step,
			displayFunction, defaultValue);

		var text:FlxText = new FlxText(0, optionY[i], 0, name);
		text.setFormat(Paths.font('default'), 32, FlxColor.WHITE, LEFT);

		text.x = sectionWidth * i + (sectionWidth - (text.width)) / 2;
		option.x = sectionWidth * i + (sectionWidth - (option.width)) / 2;
		option.y += text.height;

		optionY[i] += (Math.max(option.height, text.height) + 16);

		playerSettingGroup.add(option);
		playerSettingGroup.add(text);
	}

	function changeDescription(char:CharacterData, ?overlay:String) {
		if (cardTweens.get('NOSKIP_description') != null)
			cardTweens.get('NOSKIP_description').cancel();

		description.reloadText(char, overlay);
		description.x = marginRight.x + marginRight.width / 2;
		description.y = initialDescriptionY;
		description.alpha = 1;

		allowMoveDescription = description.width > (FlxG.width - marginLeft.width - marginRight.width);
		resetDescriptionX(allowMoveDescription);
		moveDescription(1);
	}

	function resetDescriptionX(leftAlignment:Bool = true) {
		if (leftAlignment) {
			description.x = marginLeft.x + marginLeft.width;
		} else {
			description.screenCenter(X);
		}
	}

	function moveDescription(direction:Int = 0, delay:Float = 1.0) {
		descriptionVel = 0;
		if (descriptionTimer != null)
			descriptionTimer.cancel();
		descriptionTimer = new FlxTimer().start(delay, function(_) {
			if (direction == 1) {
				descriptionVel = 32 * 4 * -1;
			} else {
				cardTweens.set('NOSKIP_description', FlxTween.tween(description, {y: FlxG.height + 16}, 0.5, {
					ease: FlxEase.quadIn,
					onComplete: function(_) {
						resetDescriptionX(true);
						cardTweens.set('NOSKIP_description', FlxTween.tween(description, {y: initialDescriptionY}, 0.5, {
							startDelay: 0.25,
							ease: FlxEase.quadOut,
							onComplete: function(_) {
								moveDescription(1);
							}
						}));
					}
				}));
			}
		});
	}

	var descriptionTimer:FlxTimer;
	var allowMoveDescription:Bool = false;
	var descriptionVel:Float = 0;

	var allowSelectionTimer:FlxTimer;

	function changePage(change:Int = 0) {
		curPage += change;
		if (curPage < 0) {
			curPage = lastPage;
		} else if (curPage > lastPage) {
			curPage = 0;
		}
		for (card in cardGroup.members) {
			card.disabled = true;
		}
		if (allowSelectionTimer != null)
			allowSelectionTimer.cancel();
		allowSelectionTimer = new FlxTimer().start(FlxG.elapsed * 10, function(_) {
			for (card in cardGroup.members) {
				var leIndex:Int = cardGroup.members.indexOf(card);
				card.disabled = !(leIndex >= curPage * maxNumberInRow && leIndex < (curPage + 1) * maxNumberInRow);
			}
		});
	}

	function exitFunction() {
		if (status == PLAYER_SETTINGS)
			moveOnToStageSelect();
		else if (status == STAGE_SELECT)
			moveOnToFillerSelect();
		else if (status == FILLER_SELECT) {
			changePlayer();
		}
		else
			backToMainMenu();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (!isExiting) {
			if (status == CHARACTER_SELECT) {
				if (Controls.justPressed('left')) {
					changePage(-1);
				} else if (Controls.justPressed('right')) {
					changePage(1);
				}
			}
			if (Controls.justPressed('exit')) {
				exitFunction();
			}
		}

		cardGroup.x = FlxMath.lerp(cardGroup.x, -curPage * (FlxG.width - marginRight.width - marginLeft.width), elapsed * 10);

		if (allowMoveDescription) {
			var predictedX = description.x + descriptionVel * elapsed;
			if (predictedX > marginLeft.x + marginLeft.width) {
				moveDescription(1);
			} else if (predictedX < marginRight.x - description.width) {
				moveDescription(-1);
			} else {
				description.x += descriptionVel * elapsed;
			}
		}
		for (stage in stageShaderMap) {
			if (stage != null) {
				stage.update(elapsed);
			}
		}
	}

	function backToMainMenu() {
		SuffState.playMusic('mainMenu');
		SuffState.switchState(new MainMenuState());
	}

	var cardTweens:Map<String, FlxTween> = new Map<String, FlxTween>();

	function cancelAllTweens() {
		for (tag => twn in cardTweens) {
			if (cardTweens.get(tag) != null && !tag.startsWith('NOSKIP_')) {
				cardTweens.get(tag).cancel();
				cardTweens.remove(tag);
			}
		}
	}

	function confirmCharacter(character:String = 'random', index:Int = 0) {
		CharacterManager.selectedCharacterList[curPlayer] = character;
		cancelAllTweens();
		FlxTween.cancelTweensOf(description);
		leftButton.disabled = true;
		rightButton.disabled = true;
		leftButton.alpha = 0;
		rightButton.alpha = 0;
		description.alpha = 0;
		if (Preferences.data.enablePhotosensitiveMode)
			grid.velocity.set(640, 640);
		else
			grid.velocity.set(1280, 1280);
		playerPages[curPlayer] = curPage;
		bannerGroup.members[curPlayer].setCharacter(character);
		for (card in cardGroup) {
			card.disabled = true;
			var leIndex:Int = cardGroup.members.indexOf(card);
			if (leIndex != index) {
				cardTweens.set(leIndex + '', FlxTween.tween(card, {y: FlxG.height}, 0.5, {
					ease: FlxEase.quintOut
				}));
			} else {
				// Technically disable flickering if photosensitive mode is on
				FlxFlicker.flicker(card, 1, (!Preferences.data.enablePhotosensitiveMode ? FlxG.elapsed : 1), true, true, function(_) {
					var index:Int = curPlayer;
					for (i in 0...CharacterManager.selectedCharacterList.length) {
						index = (index + 1) % CharacterManager.selectedCharacterList.length;
						if (CharacterManager.selectedCharacterList[index] == '') {
							break;
						}
					}
					if (curPlayer != index) {
						setPlayer(index);
					} else {
						moveOnToFillerSelect();
					}
				});
			}
		}
	}

	function moveOnToFillerSelect() {
		status = FILLER_SELECT;
		playerOutline.visible = false;
		selectCharacterTxt.text = Language.getPhrase('characterSelect.selectFiller');
		selectCharacterTxt.screenCenter(X);
		for (outline in playerOutlineShadows) {
			outline.visible = false;
		}
		for (banner in bannerGroup) {
			banner.undissolve();
			banner.disabled = true;
		}
		for (card in cardGroup) {
			card.visible = false;
		}
		for (stage in stageSelectGroup) {
			if (Std.isOfType(stage, StageCard)) {
				var wha:StageCard = cast stage;
				wha.disabled = true;
			}
		}
		for (i => filler in fillerGroup.members) {
			filler.visible = true;
			filler.disabled = false;
			cardTweens.set(i + '', FlxTween.tween(filler, {y: initialCardY}, 0.5, {
				ease: FlxEase.quintOut
			}));
		}
		cardTweens.set('grid', FlxTween.tween(grid, {'alpha': 1}, 1, {ease: FlxEase.quadInOut}));
		cardTweens.set('gridVel', FlxTween.tween(grid.velocity, {x: 80, y: 80}, 0.5, {ease: FlxEase.quadInOut}));
		cardTweens.set('leftButton', FlxTween.tween(leftButton, {alpha: 1}, 0.25));
		cardTweens.set('rightButton', FlxTween.tween(rightButton, {alpha: 1}, 0.25));
		cardTweens.set('fillerGroup', FlxTween.tween(fillerGroup, {y: 0}, 0.75, {ease: FlxEase.quintOut}));
		cardTweens.set('stageSelectGroup', FlxTween.tween(stageSelectGroup, {y: FlxG.height}, 0.75, {ease: FlxEase.quintOut}));
		cardTweens.set('leftStageButton', FlxTween.tween(leftStageButton, {y: FlxG.height}, 0.75, {ease: FlxEase.quintOut}));
		cardTweens.set('rightStageButton', FlxTween.tween(rightStageButton, {y: FlxG.height}, 0.75, {ease: FlxEase.quintOut}));
		cardTweens.set('bg2', FlxTween.tween(bg2, {y: FlxG.height * (1 - cardOccupicationHeight)}, 0.5, {ease: FlxEase.quintOut, onUpdate: function(_) {
			selectCharacterTxt.y = bg2.y - selectCharacterTxt.height;
		}}));
		cardTweens.set('playerSettingGroup', FlxTween.tween(playerSettingGroup, {y: FlxG.height}, 0.75, {ease: FlxEase.quintOut}));
		cardTweens.set('description', FlxTween.tween(description, {alpha: 1}, 0.75, {ease: FlxEase.quintOut}));
		leftButton.disabled = false;
		rightButton.disabled = false;

		changeDescription(null, 'stage.${stages[curStage]}.description');
		changeStage();
	}

	function moveOnToStageSelect() {
		if (status == PLAYER_SETTINGS) {
			readySign.moveSign(true);
		}
		status = STAGE_SELECT;
		playerOutline.visible = false;
		cantEarnAchievementsTxt.visible = false;
		selectCharacterTxt.visible = true;
		selectCharacterTxt.text = Language.getPhrase('characterSelect.selectStage');
		selectCharacterTxt.screenCenter(X);
		if (fillerLeft != null) {
			FlxTween.cancelTweensOf(fillerLeft, ['x']);
			FlxTween.tween(fillerLeft, {x: -fillerLeft.width}, 1, {ease: FlxEase.cubeInOut});
		}
		if (fillerRight != null) {
			FlxTween.cancelTweensOf(fillerRight, ['x']);
			FlxTween.tween(fillerRight, {x: FlxG.width}, 1, {ease: FlxEase.cubeInOut});
		}
		for (outline in playerOutlineShadows) {
			outline.visible = false;
		}
		for (banner in bannerGroup) {
			banner.dissolve();
			banner.disabled = true;
		}
		for (card in cardGroup) {
			card.visible = false;
		}
		for (stage in stageSelectGroup) {
			if (Std.isOfType(stage, StageCard)) {
				var wha:StageCard = cast stage;
				wha.disabled = false;
			}
		}
		cardTweens.set('gridVel', FlxTween.tween(grid, {'alpha': 0}, 1, {ease: FlxEase.quadInOut}));
		cardTweens.set('bg2', FlxTween.tween(bg2, {y: FlxG.height * 0.5}, 0.5, {ease: FlxEase.quintOut}));
		cardTweens.set('selectCharacterTxt', FlxTween.tween(selectCharacterTxt, {y: FlxG.height * 0.5 - selectCharacterTxt.height}, 0.5, {ease: FlxEase.quintOut}));
		cardTweens.set('stageSelectGroup', FlxTween.tween(stageSelectGroup, {y: FlxG.height * 0.5 + (FlxG.height * 0.5 - stageSelectGroup.height) / 2}, 0.75, {ease: FlxEase.quintOut}));
		cardTweens.set('leftStageButton', FlxTween.tween(leftStageButton, {y: FlxG.height * 0.5 + (stageSelectGroup.height - leftStageButton.height) / 2}, 0.75, {ease: FlxEase.quintOut}));
		cardTweens.set('rightStageButton', FlxTween.tween(rightStageButton, {y: FlxG.height * 0.5 + (stageSelectGroup.height - rightStageButton.height) / 2}, 0.75, {ease: FlxEase.quintOut}));
		cardTweens.set('playerSettingGroup', FlxTween.tween(playerSettingGroup, {y: FlxG.height}, 0.75, {ease: FlxEase.quintOut}));
		cardTweens.set('description', FlxTween.tween(description, {alpha: 1}, 0.75, {ease: FlxEase.quintOut}));
		leftStageButton.disabled = false;
		rightStageButton.disabled = false;

		changeDescription(null, 'stage.${stages[curStage]}.description');
		changeStage();
	}

	function changeStage(delta:Int = 0) {
		curStage = FlxMath.wrap(curStage + delta, 0, stages.length - 1);
		var stageID = stages[curStage];
		var stage = new FlxSprite();
		stage.loadGraphic(Paths.image('ui/menus/characterSelect/stages/blurred/' + stageID));
		stage.setGraphicSize(FlxG.width);
		stage.updateHitbox();
		stage.antialiasing = !Preferences.data.enableForcedAliasing;
		stage.y = (FlxG.height / 2 - stage.height) / 2;
		stageGroup.add(stage);
		if (stageGroup.members.length > 10) {
			stageShaderMap.shift();
			stageGroup.members.shift();
		}
		if (Preferences.data.enableGLSL) {
			var what = new DissolveShader();
			stageShaderMap.push(what);
			stage.shader = what;
			what.time = 1.0;
			what.undissolve();
		}
		stageSelectGroup.x = -FlxG.width * curStage;
		FlxTween.cancelTweensOf(stageSelectGroup, ['offset.y']);
		stageSelectGroup.offset.y = -8;
		FlxTween.tween(stageSelectGroup, {'offset.y': 0}, 1 / 12, {
			ease: function(t:Float) return Std.int(t)
		});

		changeDescription(null, 'stage.$stageID.description');
	}

	function confirmStage(stage:String) {
		for (stage in stageSelectGroup) {
			if (Std.isOfType(stage, StageCard)) {
				var wha:StageCard = cast stage;
				wha.disabled = true;
			}
		}
		Gameplay.currentStage = stage;
		leftStageButton.disabled = true;
		rightStageButton.disabled = true;
		cardTweens.set('leftStageButton', FlxTween.tween(leftStageButton, {y: FlxG.height}, 0.75, {ease: FlxEase.quintOut}));
		cardTweens.set('rightStageButton', FlxTween.tween(rightStageButton, {y: FlxG.height}, 0.75, {ease: FlxEase.quintOut}));
		cardTweens.set('description', FlxTween.tween(description, {alpha: 0}, 0.25, {ease: FlxEase.quintOut}));
		selectCharacterTxt.visible = false;
		if (!Preferences.data.enablePhotosensitiveMode) {
			FlxFlicker.flicker(stageSelectGroup, 1, FlxG.elapsed, function(_) {
				moveOnToPlayerSettings();
			});
		} else {
			new FlxTimer().start(1, function(_) {
				moveOnToPlayerSettings();
			});
		}
	}

	function confirmFiller(fillerIndex:Int) {
		for (fillerCard in fillerGroup) {
			fillerCard.disabled = true;
		}
		var fillerID = fillerGroup.members[fillerIndex].filler.id;
		if (fillerID != 'random')
			Gameplay.currentFiller = new Filler(fillerID);
		else
			Gameplay.currentFiller = new Filler(FlxG.random.getObject(Gameplay.globalFillerList));
		if (fillerLeft != null) {
			FlxTween.cancelTweensOf(fillerLeft, ['x']);
			FlxTween.tween(fillerLeft, {x: bannerGroup.x - fillerLeft.width}, 1, {ease: FlxEase.cubeInOut});
		}
		if (fillerRight != null) {
			FlxTween.cancelTweensOf(fillerRight, ['x']);
			FlxTween.tween(fillerRight, {x: bannerGroup.x + bannerGroup.width}, 1, {ease: FlxEase.cubeInOut});
		}
		leftButton.disabled = true;
		rightButton.disabled = true;
		cardTweens.set('leftStageButton', FlxTween.tween(leftButton, {y: FlxG.height}, 0.75, {ease: FlxEase.quintOut}));
		cardTweens.set('rightStageButton', FlxTween.tween(rightButton, {y: FlxG.height}, 0.75, {ease: FlxEase.quintOut}));
		cardTweens.set('description', FlxTween.tween(description, {alpha: 0}, 0.25, {ease: FlxEase.quintOut}));
		selectCharacterTxt.visible = false;
		for (leIndex => filler in fillerGroup.members) {
			filler.disabled = true;
			if (leIndex != fillerIndex) {
				cardTweens.set(leIndex + '', FlxTween.tween(filler, {y: FlxG.height}, 0.5, {
					ease: FlxEase.quintOut
				}));
			} else {
				// Technically disable flickering if photosensitive mode is on
				FlxFlicker.flicker(filler, 1, (!Preferences.data.enablePhotosensitiveMode ? FlxG.elapsed : 1), false, true, function(_) {
					moveOnToStageSelect();
				});
			}
		}
		trace('Current filler', Gameplay.currentFiller);
	}

	function moveOnToPlayerSettings() {
		status = PLAYER_SETTINGS;
		playerOutline.visible = false;
		cantEarnAchievementsTxt.visible = !canEarnAchievements;
		for (outline in playerOutlineShadows) {
			outline.visible = false;
		}
		for (banner in bannerGroup) {
			banner.disabled = true;
		}
		for (card in cardGroup) {
			var leIndex:Int = cardGroup.members.indexOf(card);
			card.visible = false;
		}
		cardTweens.set('stageSelectGroup', FlxTween.tween(stageSelectGroup, {y: FlxG.height}, 0.75, {ease: FlxEase.quintOut}));
		cardTweens.set('leftStageButton', FlxTween.tween(leftStageButton, {y: FlxG.height}, 0.75, {ease: FlxEase.quintOut}));
		cardTweens.set('rightStageButton', FlxTween.tween(rightStageButton, {y: FlxG.height}, 0.75, {ease: FlxEase.quintOut}));
		cardTweens.set('bg2', FlxTween.tween(bg2, {y: FlxG.height * 0.5}, 0.5, {ease: FlxEase.quintOut}));
		cardTweens.set('playerSettingGroup', FlxTween.tween(playerSettingGroup, {y: FlxG.height * 0.5}, 0.75, {ease: FlxEase.quintOut}));

		readySign.moveSign(false);
	}

	function setPlayer(val:Int) {
		changePlayer(val - curPlayer);
	}

	function changePlayer(change:Int = 0) {
		status = CHARACTER_SELECT;
		playerOutline.visible = true;
		selectCharacterTxt.text = Language.getPhrase('characterSelect.selectCharacter');
		selectCharacterTxt.screenCenter(X);

		for (outline in playerOutlineShadows) {
			outline.visible = true;
		}
		for (banner in bannerGroup) {
			banner.disabled = false;
		}
		selectCharacterTxt.visible = true;

		curPlayer += change;
		curPage = playerPages[curPlayer];
		cardGroup.x = -curPage * (FlxG.width - marginRight.width - marginLeft.width);
		cancelAllTweens();
		cardTweens.set('selectCharacterTxt', FlxTween.tween(selectCharacterTxt, {y: bannerGroup.height - selectCharacterTxt.height}, 0.5, {ease: FlxEase.quintOut}));
		cardTweens.set('gridVel', FlxTween.tween(grid, {'alpha': 1}, 1, {ease: FlxEase.quadInOut}));
		cardTweens.set('fillerGroup', FlxTween.tween(fillerGroup, {y: FlxG.height}, 0.75, {ease: FlxEase.quintOut}));
		cardTweens.set('stageSelectGroup', FlxTween.tween(stageSelectGroup, {y: FlxG.height}, 0.75, {ease: FlxEase.quintOut}));
		cardTweens.set('leftStageButton', FlxTween.tween(leftStageButton, {y: FlxG.height}, 0.75, {ease: FlxEase.quintOut}));
		cardTweens.set('rightStageButton', FlxTween.tween(rightStageButton, {y: FlxG.height}, 0.75, {ease: FlxEase.quintOut}));
		cardTweens.set('leftButton', FlxTween.tween(leftButton, {alpha: 1}, 0.25));
		cardTweens.set('rightButton', FlxTween.tween(rightButton, {alpha: 1}, 0.25));
		cardTweens.set('NOSKIP_description', FlxTween.tween(description, {alpha: 1}, 0.5));
		cardTweens.set('NOSKIP_playerOutline', FlxTween.tween(playerOutline, {x: bannerGroup.members[curPlayer].x}, 0.5, {ease: FlxEase.quintOut}));
		for (item in playerOutlineShadows) {
			var leIndex:Int = playerOutlineShadows.members.indexOf(item);
			cardTweens.set('NOSKIP_playerOutline' + leIndex,
				FlxTween.tween(item, {x: bannerGroup.members[curPlayer].x}, 0.5, {startDelay: leIndex * 0.05, ease: FlxEase.quintOut}));
		}
		cardTweens.set('gridVel', FlxTween.tween(grid.velocity, {x: 160, y: 160}, 0.5, {ease: FlxEase.quadInOut}));
		cardTweens.set('bg2', FlxTween.tween(bg2, {y: FlxG.height * (1 - cardOccupicationHeight)}, 0.5, {ease: FlxEase.quintOut}));
		cardTweens.set('playerSettingGroup', FlxTween.tween(playerSettingGroup, {y: FlxG.height}, 0.75, {ease: FlxEase.quintOut}));
		for (card in cardGroup) {
			var leIndex:Int = cardGroup.members.indexOf(card);
			if (card.holdAnim) {
				card.onIdle();
				card.holdAnim = false;
			}
			card.visible = true;
			card.disabled = false;
			cardTweens.set(leIndex + '', FlxTween.tween(card, {y: initialCardY}, 0.5, {
				ease: FlxEase.quintOut
			}));
		}
		changePage();
		leftButton.disabled = false;
		rightButton.disabled = false;
	}

	function findMaximumCardsPerRow() {
		return Std.int(FlxMath.bound((FlxG.width - margin * 2) / (Constants.CHARACTER_CARD_DIMENSIONS[0]), 1, 6));
	}

	function proceedToPlayState() {
		Achievements.enabled = canEarnAchievements;
		var characterCPUControlled = '';
		for (i in CharacterManager.cpuControlled) {
			characterCPUControlled += i ? '1' : '0';
		}
		var save:FlxSave = new FlxSave();
		save.bind('preferences', Utilities.getSavePath());
		save.data.characterCPUControlled = characterCPUControlled;
		var characterSkillLevel = '';
		for (i in CharacterManager.cpuLevel) {
			characterSkillLevel += i;
		}
		if (Gameplay.currentStage == 'random') {
			Gameplay.currentStage = FlxG.random.getObject(Gameplay.globalStageList);
		}
		save.data.characterSkillLevel = characterSkillLevel;
		save.flush();
		isExiting = true;
		readySign.moveSign(true);
		PlayState.hasSeenStartCutscene = false;
		CharacterManager.parseRandomCharacters();
		openSubState(new GameOnSubState(new PlayState()));
	}
}
