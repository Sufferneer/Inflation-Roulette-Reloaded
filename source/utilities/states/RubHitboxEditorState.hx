package utilities.states;

import backend.FileDialogHandler;
import backend.typedefs.CharacterOffsetsData;
import objects.Character;
import ui.objects.SuffIconButton;
import ui.objects.SuffMarker;
import ui.objects.SuffSlider;
import substates.ChoicePrompt;
import backend.typedefs.CharacterHitboxData;
import backend.typedefs.CharacterBoxData;
import flixel.util.FlxSpriteUtil;
using StringTools;

class RubHitboxEditorState extends UtilitiesBaseMenuState {
	var character:Character;
	var rubHitboxData:Array<CharacterBoxData> = [];
	var currentPressure:Int = 0;
	var offsetTxt:FlxText;
	var hitbox:FlxSprite;
	override public function create() {
		WindowUtil.setTitle(Language.getPhrase('utilitiesMenu.windowDisplay'), Language.getPhrase('utilitiesMenu.rubHitboxEditor'));
		super.create();
		remove(exitButton);

		var lePath = UtilitiesBaseMenuState.loadedPath.split('/');
		var charId = lePath[lePath.length - 1];
		trace(charId);
		character = new Character(charId);
		character.originPosition = [0, 0];
		character.offset.set(character.originPosition[0], character.originPosition[1]);
		character.screenCenter();
		add(character);

		hitbox = new FlxSprite().loadGraphic(Paths.getImage('debug/circle512'));
		add(hitbox);

		rubHitboxData = character.rubHitboxes.copy();
		if (rubHitboxData == null) {
			trace('Hitbox data for character $charId not found. Using chester\'s');
			rubHitboxData = new Character('chester').rubHitboxes;
			rubHitboxData.resize(character.maxPressure + 1);
		}

		var leftBorder:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width / 2 - character.width / 2), FlxG.height, 0xFF000000);
		leftBorder.alpha = 0.5;

		var rightBorder:FlxSprite = new FlxSprite(leftBorder.width + character.width, 0).makeGraphic(Std.int(FlxG.width / 2 - character.width / 2), FlxG.height, 0xFF000000);
		rightBorder.alpha = 0.5;

		var upBorder:FlxSprite = new FlxSprite(leftBorder.width, 0).makeGraphic(Std.int(character.width), Std.int(FlxG.height / 2 - character.height / 2), 0xFF000000);
		upBorder.alpha = 0.5;

		var downBorder:FlxSprite = new FlxSprite(leftBorder.width, upBorder.height + character.height).makeGraphic(Std.int(character.width), Std.int(FlxG.height / 2 - character.height / 2), 0xFF000000);
		downBorder.alpha = 0.5;

		add(character);
		add(leftBorder);
		add(rightBorder);
		add(upBorder);
		add(downBorder);

		var actualExitButton:SuffIconButton = new SuffIconButton(10, 10, 'buttons/exit', 2);
		actualExitButton.x = FlxG.width - actualExitButton.width - 10;
		actualExitButton.y = FlxG.height - actualExitButton.height - 10;
		actualExitButton.onClick = function() {
			leaveMenu();
		}
		add(actualExitButton);

		var saveButton = new SuffIconButton(exitButton.x - exitButton.width - 10, exitButton.y, 'buttons/save', 2);
		saveButton.onClick = function() {
			var fileDialog = new FileDialogHandler();
			var offsetData:CharacterHitboxData = {
				rubHitboxes: rubHitboxData
			};
			fileDialog.save('hitbox.json', haxe.Json.stringify(offsetData, '\t'));
		}
		add(saveButton);

		updateHitbox();

		var helpTitle:FlxText = new FlxText(32, 32, leftBorder.width - 64, Language.getPhrase('rubHitboxEditor.title'), 32);
		add(helpTitle);
		var helpDesc:FlxText = new FlxText(32, helpTitle.y + helpTitle.height, leftBorder.width - 40, Language.getPhrase('rubHitboxEditor.description'), 16);
		add(helpDesc);
		var pressureSlider = new SuffSlider(helpDesc.x, helpDesc.y + helpDesc.height, function(val:Float) {
			currentPressure = Std.int(val);
			reloadSprite();
			updateHitbox();
			updateValues();
		}, 0, character.maxPressure + 1, 1, function(val:Float) {
			return Language.getPhrase("stats.pressure." + parseAnimationSuffix(Std.int(val)), [], Std.int(val) + '');
		});
		add(pressureSlider);

		offsetTxt = new FlxText(32, 32, leftBorder.width - 64, '[0, 0]', 32);
		offsetTxt.y = FlxG.height - offsetTxt.height - 32;
		add(offsetTxt);

		updateValues();

		FlxTween.color(hitbox, 1, 0x80FFFF00, 0x80FF00FF, {
			type: PINGPONG
		});
	}

	public override function leaveMenu() {
		openSubState(new ChoicePrompt('rubHitboxEditor.exit.prompt', function() {
			SuffState.switchState(new UtilitiesMainMenuState());
		}, function() {

		}));
	}

	function parseAnimationSuffix(value:Int):String {
		if (value == character.maxPressure + 1)
			return 'Overinflated';
		return value + '';
	}

	function reloadSprite() {
		var animName = 'idle' + parseAnimationSuffix(currentPressure);
		character.playAnim(animName, false, true);
		character.offset.set(0, 0);
		character.animation.pause();
	}

	override function update(elapsed:Float) {
		var stepSize:Int = 1;
		if (FlxG.keys.anyPressed([SHIFT, CONTROL])) stepSize = 10;
		if (FlxG.keys.justPressed.LEFT) {
			moveHitbox(-1 * stepSize, 0);
		} else if (FlxG.keys.justPressed.RIGHT) {
			moveHitbox(1 * stepSize, 0);
		}
		if (FlxG.keys.justPressed.UP) {
			moveHitbox(0, -1 * stepSize);
		} else if (FlxG.keys.justPressed.DOWN) {
			moveHitbox(0, 1 * stepSize);
		}
		if (FlxG.keys.justPressed.A) {
			scaleHitbox(-1 * stepSize, 0);
		} else if (FlxG.keys.justPressed.D) {
			scaleHitbox(1 * stepSize, 0);
		}
		if (FlxG.keys.justPressed.S) {
			scaleHitbox(0, -1 * stepSize);
		} else if (FlxG.keys.justPressed.W) {
			scaleHitbox(0, 1 * stepSize);
		}
		super.update(elapsed);
	}

	function moveHitbox(deltaX:Int = 0, deltaY:Int = 0) {
		rubHitboxData[currentPressure].position[0] += deltaX;
		rubHitboxData[currentPressure].position[1] += deltaY;
		updateHitbox();
		updateValues();
	}

	function scaleHitbox(deltaX:Int = 0, deltaY:Int = 0) {
		rubHitboxData[currentPressure].size[0] += deltaX;
		rubHitboxData[currentPressure].size[1] += deltaY;
		updateHitbox();
		updateValues();
	}

	function updateHitbox() {
		var curRubHitboxData = rubHitboxData[currentPressure];
		hitbox.setGraphicSize(Std.int(curRubHitboxData.size[0]), Std.int(curRubHitboxData.size[1]));
		hitbox.updateHitbox();
		hitbox.setPosition(character.x + curRubHitboxData.position[0], character.y + curRubHitboxData.position[1]);
	}

	function updateValues() {
		offsetTxt.text = Language.getPhrase('rubHitboxEditor.position') + '\n[${hitbox.x - character.x}, ${hitbox.y - character.y}]\n' + Language.getPhrase('rubHitboxEditor.size') + '\n[${hitbox.width}, ${hitbox.height}]';
		offsetTxt.y = FlxG.height - offsetTxt.height - 32;
	}
}
