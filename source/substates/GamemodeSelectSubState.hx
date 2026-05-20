package substates;

import states.PlayState;
import backend.CharacterManager;
import backend.Gamemode;
import backend.GameplayManager;
import states.CharacterSelectState;
import ui.objects.SuffBox;
import ui.objects.SuffIconButton;

class GamemodeSelectSubState extends SuffSubState {
	var exitButton:SuffIconButton;
	final buttonMargin:FlxPoint = new FlxPoint(30, 30);
	final buttonPadding:FlxPoint = new FlxPoint(15, 15);

	var grpButtons:FlxTypedContainer<SuffButton> = new FlxTypedContainer<SuffButton>();

	var leaving:Bool = false;

	public function new() {
		super();

		persistentUpdate = false;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		FlxTween.tween(bg, {alpha: 0.5}, 0.5);
		add(bg);

		var box:SuffBox = new SuffBox(0, 0, 720, 560);
		box.screenCenter();
		add(box);

		var boxRect:FlxRect = new FlxRect(box.x, box.y, box.width, box.height);

		add(grpButtons);

		var fileList = Paths.readDirectories('data/gamemodes', 'data/gamemodes/gamemodeList.txt', 'json');

		var buttonCount:FlxPoint = new FlxPoint(2, 3);
		buttonCount.x = Std.int(Math.sqrt(fileList.length));
		buttonCount.y = Math.ceil(fileList.length / buttonCount.x);
		var buttonSize:FlxPoint = new FlxPoint((boxRect.width - buttonMargin.x * 2 - buttonPadding.x * (buttonCount.x - 1)) / buttonCount.x,
			(boxRect.height - buttonMargin.y * 2 - buttonPadding.y * (buttonCount.y - 1)) / buttonCount.y);
		// base size is 48, adjusted to correct to nearest 16.

		for (i => id in fileList) {
			var ID = id.replace('.json', '');
			var leGamemode:Gamemode = new Gamemode(ID);

			var leButton:SuffButton = new SuffButton(0, 0, Language.getPhrase('gamemode.$ID.name'), null, null, buttonSize.x, buttonSize.y);
			leButton.x = boxRect.x + buttonMargin.x + (buttonPadding.x + buttonSize.x) * (i % buttonCount.x);
			leButton.y = boxRect.y + buttonMargin.y + (buttonPadding.y + buttonSize.y) * Std.int(i / buttonCount.x);
			leButton.btnBGColorHovered = leButton.btnBGColorClicked = leGamemode.color;
			leButton.tooltipText = Language.getPhrase('gamemode.$ID.description');
			leButton.onClick = function() {
				goGoGadgetGamemode(leGamemode);
			}
			add(leButton);
		}

		var headingText:FlxText = new FlxText(0, 0, 0, Language.getPhrase('gamemodeSelect.title'), 48);
		var headingTextTargetY:Float = 4;
		headingText.alpha = 0;
		headingText.x = (FlxG.width - headingText.width) / 2;
		headingText.y = -headingText.height;
		FlxTween.tween(headingText, {alpha: 1, y: headingTextTargetY}, 0.75, {
			ease: FlxEase.cubeOut
		});
		add(headingText);

		exitButton = new SuffIconButton(20, 20 + ScreenSafeZone.Y, 'buttons/exit', null, 2);
		exitButton.x = FlxG.width - exitButton.width - 20 - ScreenSafeZone.X;
		exitButton.onClick = function() {
			exitMenu();
		};
		add(exitButton);
	}

	function goGoGadgetGamemode(gamemode:Gamemode) {
		leaving = true;
		switch (gamemode.id) {
			case 'quickPlay':
				GameplayManager.currentGamemode = GameplayManager.defaultGamemode;
				GameplayManager.currentStage = FlxG.random.getObject(GameplayManager.globalStageList);
				CharacterManager.setPlayerCount(GameplayManager.currentGamemode.playerCount);
				var leRandom = [];
				var leCPUControl = [];
				for (num => i in CharacterManager.selectedCharacterList) {
					leRandom.push('random');
					leCPUControl.push(true);
					CharacterManager.cpuLevel[num] = FlxG.random.int(1, 3);
				}
				leCPUControl[0] = false;
				CharacterManager.selectedCharacterList = leRandom;
				CharacterManager.cpuControlled = leCPUControl;
				PlayState.hasSeenStartCutscene = false;
				CharacterManager.parseRandomCharacters();
				openSubState(new GameOnSubState(new PlayState()));
			default:
				GameplayManager.currentGamemode = gamemode;
				CharacterManager.setPlayerCount(GameplayManager.currentGamemode.playerCount);
				SuffState.switchState(new CharacterSelectState());
		}
	}

	function exitMenu() {
		persistentUpdate = true;
		Tooltip.text = '';
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
