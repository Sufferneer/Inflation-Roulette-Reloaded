package substates;

import backend.Filler;
import backend.Gamemode;
import backend.Gameplay;
import states.CharacterSelectState;
import states.PlayState;
import ui.objects.SuffBox;
import ui.objects.SuffIconButton;
import ui.objects.SuffSlider;
import flixel.group.FlxSpriteContainer.FlxTypedSpriteContainer;
import ui.objects.FillerCard;
import ui.objects.StageMiniCard;

class QuickConfigSubState extends SuffSubState {
	var exitButton:SuffIconButton;
	var confirmButton:SuffButton;

	var fillerCards:FlxTypedSpriteContainer<FillerCard> = new FlxTypedSpriteContainer<FillerCard>();
	var stageCards:FlxTypedSpriteContainer<StageMiniCard> = new FlxTypedSpriteContainer<StageMiniCard>();

	var curFillerPage:Int = 0;
	var maxFillerPage:Int = 0;
	var curStagePage:Int = 0;
	var maxStagePage:Int = 0;

	public function new(quick:Bool = false) {
		super();

		persistentUpdate = false;

		final itemPerPage:Int = 6;

		if (quick) {
			confirmStage(-1);
			confirmFiller(-1);
			goGoGadgetPlayState();
			return;
		}

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.75;
		add(bg);

		add(fillerCards);
		add(stageCards);

		var fillerText:FlxText = new FlxText(0, 20 + ScreenSafeArea.Y, Language.getPhrase('characterSelect.selectFiller'), 32);
		fillerText.screenCenter(X);
		add(fillerText);

		var fillerList = Gameplay.globalFillerList.copy();
		fillerList.push('random');
		maxFillerPage = Std.int(Math.max(0, (fillerList.length - 1) / itemPerPage));
		for (num => fillerID in fillerList) {
			var fillerData = new Filler(fillerID);
			var card:FillerCard = new FillerCard(0, 0, fillerData);
			var itemPage = Std.int(num / itemPerPage);
			card.x = (FlxG.width - Math.min(fillerList.length, itemPerPage) * 150) / 2 + 150 * (num - itemPage * itemPerPage) + itemPage * FlxG.width;
			card.y = fillerText.y + fillerText.height + 20;
			card.onClick = function() {
				confirmFiller(num);
			};
			fillerCards.add(card);
		}
		if (maxFillerPage > 0) {
			var pageWidth = 150 * itemPerPage;
			var leftButton:SuffIconButton = new SuffIconButton(20, 20, 'buttons/left', null, 2);
			leftButton.x = (FlxG.width - pageWidth) / 2 - leftButton.width - 20;
			leftButton.y = (fillerText.y + fillerText.height + 20) + (fillerCards.height - leftButton.height) / 2;
			leftButton.onClick = function() {
				if (curFillerPage <= 0) return;
				curFillerPage--;
				fillerCards.x = -FlxG.width * curFillerPage;
			};
			add(leftButton);

			var rightButton:SuffIconButton = new SuffIconButton(20, 20, 'buttons/right', null, 2);
			rightButton.x = (FlxG.width - pageWidth) / 2 + pageWidth + 20;
			rightButton.y = (fillerText.y + fillerText.height + 20) + (fillerCards.height - rightButton.height) / 2;
			rightButton.onClick = function() {
				if (curFillerPage >= maxFillerPage) return;
				curFillerPage++;
				stageCards.x = -FlxG.width * curFillerPage;
			};
			add(rightButton);
		}

		var stageText:FlxText = new FlxText(0, fillerText.y + fillerText.height + 240, Language.getPhrase('characterSelect.selectStage'), 32);
		stageText.screenCenter(X);
		add(stageText);

		var stageList = Gameplay.globalStageList.copy();
		stageList.push('random');
		maxStagePage = Std.int(Math.max(0, (stageList.length - 1) / itemPerPage));
		for (num => stageID in stageList) {
			var card:StageMiniCard = new StageMiniCard(0, 0, stageID);
			var itemPage = Std.int(num / itemPerPage);
			card.x = (FlxG.width - Math.min(stageList.length, itemPerPage) * 150) / 2 + 150 * (num - itemPage * itemPerPage) + itemPage * FlxG.width;
			card.y = stageText.y + stageText.height + 20;
			card.onClick = function() {
				confirmStage(num);
			};
			stageCards.add(card);
		}

		if (maxStagePage > 0) {
			var leftButton:SuffIconButton = new SuffIconButton(20, 20, 'buttons/left', null, 2);
			var pageWidth = 150 * itemPerPage;
			leftButton.x = (FlxG.width - pageWidth) / 2 - leftButton.width - 20;
			leftButton.y = (stageText.y + stageText.height + 20) + (stageCards.height - leftButton.height) / 2;
			leftButton.onClick = function() {
				if (curStagePage <= 0) return;
				curStagePage--;
				stageCards.x = -FlxG.width * curStagePage;
			};
			add(leftButton);

			var rightButton:SuffIconButton = new SuffIconButton(20, 20, 'buttons/right', null, 2);
			rightButton.x = (FlxG.width - pageWidth) / 2 + pageWidth + 20;
			rightButton.y = (stageText.y + stageText.height + 20) + (stageCards.height - rightButton.height) / 2;
			rightButton.onClick = function() {
				if (curStagePage >= maxStagePage) return;
				curStagePage++;
				stageCards.x = -FlxG.width * curStagePage;
			};
			add(rightButton);
		}

		confirmFiller(fillerList.length - 1);
		confirmStage(stageList.length - 1);

		exitButton = new SuffIconButton(20, 20 + ScreenSafeArea.Y, 'buttons/exit', null, 2);
		exitButton.x = FlxG.width - exitButton.width - 20 - ScreenSafeArea.X;
		exitButton.onClick = function() {
			exitMenu();
		};
		add(exitButton);

		confirmButton = new SuffButton(0, 0, Language.getPhrase('gameOn.text'), 250, 100);
		confirmButton.x = (FlxG.width - confirmButton.width) / 2;
		confirmButton.y = FlxG.height - confirmButton.height - 20 - ScreenSafeArea.Y;
		confirmButton.onClick = function() {
			goGoGadgetPlayState();
		};
		add(confirmButton);
	}

	function confirmFiller(index:Int = 0) {
		var fillerData:Filler = new Filler('random');
		if (index != -1)
			fillerData = fillerCards.members[index].filler;
		if (fillerData.id != 'random')
			Gameplay.currentFiller = fillerData;
		else
			Gameplay.currentFiller = new Filler(FlxG.random.getObject(Gameplay.globalFillerList));
		for (num => fillerCard in fillerCards.members)
			fillerCard.alwaysHighlighted = num == index;
	}

	function confirmStage(index:Int = 0) {
		var stageID:String = 'random';
		if (index != -1)
			stageID = stageCards.members[index].stage;
		if (stageID != 'random')
			Gameplay.currentStage = stageID;
		else
			Gameplay.currentStage = FlxG.random.getObject(Gameplay.globalStageList);
		for (num => stageCard in stageCards.members)
			stageCard.alwaysHighlighted = num == index;
	}

	function goGoGadgetPlayState() {
		leaving = true;
		Gameplay.currentGamemode = Gameplay.defaultGamemode;
		var leRandom = [];
		var leCPUControl = [];
		for (num => i in Gameplay.currentCharacterList) {
			leRandom.push('random');
			leCPUControl.push(true);
			Gameplay.cpuLevel[num] = FlxG.random.int(Constants.CPU_SKILL_LIMIT[0], Constants.CPU_SKILL_LIMIT[1]);
		}
		leCPUControl[FlxG.random.int(0, leCPUControl.length - 1)] = false;
		Gameplay.currentCharacterList = leRandom;
		Gameplay.cpuControlled = leCPUControl;
		Gameplay.parseRandomCharacters();
		trace('Current characters: ', Gameplay.currentCharacterList);
		trace('Current CPU level: ', Gameplay.cpuLevel);
		// Gameplay.currentStage = FlxG.random.getObject(Gameplay.globalStageList);
		// Gameplay.currentFiller = new Filler(FlxG.random.getObject(Gameplay.globalFillerList));
		PlayState.hasSeenStartCutscene = false;
		trace('Current stage: ', Gameplay.currentStage);
		trace('Current filler: ', Gameplay.currentFiller.id);
		openSubState(new GameOnSubState(new PlayState()));
	}

	var leaving:Bool = false;

	function exitMenu() {
		if (leaving) return;
		close();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Controls.justPressed('exit')) {
			exitMenu();
		}
	}
}
