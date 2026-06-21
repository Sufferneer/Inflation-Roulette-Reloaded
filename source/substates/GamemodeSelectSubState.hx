package substates;

import states.PlayState;
import backend.Gameplay;
import backend.Gamemode;
import backend.Gameplay;
import states.CharacterSelectState;
import ui.objects.SuffBox;
import ui.objects.SuffIconButton;
import ui.objects.SuffSlider;
import backend.Filler;

class GamemodeSelectSubState extends SuffSubState {
	var exitButton:SuffIconButton;
	final buttonMargin:FlxPoint = new FlxPoint(30, 30);
	final buttonPadding:FlxPoint = new FlxPoint(15, 15);

	var gameModeArt:FlxSprite;
	var light:FlxSprite;
	var lightColorTween:FlxTween;
	var playerCountSlider:SuffSlider;

	var grpButtons:FlxTypedContainer<SuffButton> = new FlxTypedContainer<SuffButton>();

	var leaving:Bool = false;

	public function new() {
		super();

		Window.setTitle(Language.getPhrase('gamemodeSelect.windowDisplay'));

		persistentUpdate = false;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		FlxTween.tween(bg, {alpha: 0.75}, 0.5);
		add(bg);

		light = new FlxSprite().loadGraphic(Paths.image('game/selectLight'));
		light.scale.set(FlxG.width, 1);
		light.color = 0x20000000;
		light.alpha = 0.25;
		light.updateHitbox();
		light.y = FlxG.height - light.height;
		add(light);

		gameModeArt = new FlxSprite();
		gameModeArt.visible = false;
		add(gameModeArt);

		var box:SuffBox = new SuffBox(40 + ScreenSafeArea.X, 80 + ScreenSafeArea.Y, FlxG.width / 2 - 40 - ScreenSafeArea.X, FlxG.height - 120 - ScreenSafeArea.Y * 2 - 96);
		add(box);

		playerCountSlider = new SuffSlider(20, 20, function(value:Float) {}, 2, 6, 1, function(value:Float) {
			return Language.getPhrase('gamemodeSelect.setting.format', [Language.getPhrase('gamemodeSelect.playerCount'), Std.int(value)]);
		}, 4);

		playerCountSlider.x = box.x + (box.width - playerCountSlider.width) / 2;
		playerCountSlider.y = FlxG.height - playerCountSlider.height - 20;

		add(playerCountSlider);

		// var boxRect:FlxRect = new FlxRect(box.x, box.y, box.width, box.height);

		add(grpButtons);

		var fileList = Paths.readDirectories('data/gamemodes', 'data/gamemodes/gamemodeList.txt', 'json');

		var buttonCount:FlxPoint = new FlxPoint(1, 3);
		if (fileList.length > 4)
			buttonCount.x = 2;
		buttonCount.y = Math.ceil(fileList.length / buttonCount.x);
		var buttonSize:FlxPoint = new FlxPoint((box.width - buttonMargin.x * 2 - buttonPadding.x * (buttonCount.x - 1)) / buttonCount.x,
			(box.height - buttonMargin.y * 2 - buttonPadding.y * (buttonCount.y - 1)) / buttonCount.y);
		// base size is 48, adjusted to correct to nearest 16.

		for (i => id in fileList) {
			var ID = id.replace('.json', '');
			var leGamemode:Gamemode = new Gamemode(ID);

			var leButton:SuffButton = new SuffButton(0, 0, Language.getPhrase('gamemode.$ID.name'), null, null, buttonSize.x, buttonSize.y);
			leButton.x = box.x + buttonMargin.x + (buttonPadding.x + buttonSize.x) * (i % buttonCount.x);
			leButton.y = box.y + buttonMargin.y + (buttonPadding.y + buttonSize.y) * Std.int(i / buttonCount.x);
			leButton.btnBGColorHovered = leButton.btnBGColorClicked = leGamemode.color;
			leButton.tooltipText = Language.getPhrase('gamemode.$ID.description');
			leButton.onHover = function() {
				switchGameModeArt(leGamemode);
			};
			leButton.onClick = function() {
				goGoGadgetGamemode(leGamemode);
			}
			add(leButton);
		}

		var headingText:FlxText = new FlxText(ScreenSafeArea.X, ScreenSafeArea.Y, 0, Language.getPhrase('gamemodeSelect.title'), 48);
		var headingTextTargetY:Float = 4;
		headingText.alpha = 0;
		headingText.x = box.x + (box.width - headingText.width) / 2;
		headingText.y = -headingText.height;
		FlxTween.tween(headingText, {alpha: 1, y: headingTextTargetY}, 0.75, {
			ease: FlxEase.cubeOut
		});
		add(headingText);

		exitButton = new SuffIconButton(20, 20 + ScreenSafeArea.Y, 'buttons/exit', null, 2);
		exitButton.x = FlxG.width - exitButton.width - 20 - ScreenSafeArea.X;
		exitButton.onClick = function() {
			exitMenu();
		};
		add(exitButton);
	}

	function switchGameModeArt(gamemode:Gamemode) {
		FlxTween.cancelTweensOf(gameModeArt);
		gameModeArt.loadGraphic(Paths.image('ui/menus/mainMenu/gameModes/${gamemode.id}'));
		gameModeArt.visible = true;
		gameModeArt.x = FlxG.width - gameModeArt.width * (7 / 8);
		gameModeArt.y = FlxG.height - gameModeArt.height;
		FlxTween.tween(gameModeArt, {x: FlxG.width - gameModeArt.width}, 1, {ease: FlxEase.expoOut});

		var leColor = gamemode.color;
		leColor.alphaFloat = 0.25;
		if (lightColorTween != null)
			lightColorTween.cancel();
		lightColorTween = FlxTween.color(light, 1, light.color, leColor);
	}

	function goGoGadgetGamemode(gamemode:Gamemode) {
		leaving = true;
		Gameplay.setPlayerCount(Std.int(playerCountSlider.currentValue));
		switch (gamemode.id) {
			case 'quickPlay':
				Gameplay.currentGamemode = Gameplay.defaultGamemode;
				Gameplay.currentStage = FlxG.random.getObject(Gameplay.globalStageList);
				Gameplay.currentFiller = new Filler(FlxG.random.getObject(Gameplay.globalFillerList));
				// Gameplay.setPlayerCount(Gameplay.currentGamemode.playerCount);
				var leRandom = [];
				var leCPUControl = [];
				for (num => i in Gameplay.selectedCharacterList) {
					leRandom.push('random');
					leCPUControl.push(true);
					Gameplay.cpuLevel[num] = FlxG.random.int(Constants.CPU_SKILL_LIMIT[0], Constants.CPU_SKILL_LIMIT[1]);
				}
				leCPUControl[FlxG.random.int(0, leCPUControl.length - 1)] = false;
				Gameplay.selectedCharacterList = leRandom;
				Gameplay.cpuControlled = leCPUControl;
				PlayState.hasSeenStartCutscene = false;
				Gameplay.parseRandomCharacters();
				trace('Current characters: ', Gameplay.selectedCharacterList);
				trace('Current CPU level: ', Gameplay.cpuLevel);
				trace('Current stage: ', Gameplay.currentStage);
				trace('Current filler: ', Gameplay.currentFiller.id);
				openSubState(new GameOnSubState(new PlayState()));
			default:
				Gameplay.currentGamemode = gamemode;
				// Gameplay.setPlayerCount(Gameplay.currentGamemode.playerCount);
				SuffState.switchState(new CharacterSelectState());
		}
		trace('Current gamemode: ', Gameplay.currentGamemode);
	}

	function exitMenu() {
		persistentUpdate = true;
		Tooltip.text = '';
		Window.setTitle(Language.getPhrase('mainMenu.windowDisplay'));
		close();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (!leaving) {
			if (Controls.justPressed('exit')) {
				exitMenu();
			}
		}
	}
}
