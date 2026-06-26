package states.debug;

import ui.objects.SuffIconButton;
import objects.Character;
import shaders.DiscolorationMaskedShader;
import backend.Gameplay;
import backend.Filler;

class DiscolorationTestState extends SuffState {
	var exiting:Bool = false;
	var exitButton:SuffIconButton;

	var character:Character;

	var rubText:FlxText;

	override function create() {
		super.create();

		Gameplay.currentFiller = new Filler('air');

		rubText = new FlxText(0, 0, 0, '', 32);
		add(rubText);

		character = new Character('chester', FlxG.width / 2, FlxG.height * 0.825);
		add(character);

		exitButton = new SuffIconButton(20, 20, 'buttons/exit', null, 2);
		exitButton.x = FlxG.width - exitButton.width - 20;
		exitButton.onClick = function() {
			exitMenu();
		};
		add(exitButton);
	}

	function exitMenu() {
		if (exiting)
			return;
		exiting = true;
		SuffState.switchState(new MainMenuState());
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		rubText.text = '
		rubValue: ${character.rubValue}
		rubDuration: ${character.rubDuration}
		forceExpulsionTimer: ${character.forceExpulsionTimer}
		leakTimer: ${character.leakTimer}
		';

		if (Controls.justPressed('exit')) {
			exitMenu();
		}

		if (Controls.justPressed('left') || Controls.justPressed('right')) {
			if (Controls.justPressed('left'))
				character.discoloration.strength -= 0.1;
			else if (Controls.justPressed('right'))
				character.discoloration.strength += 0.1;
			trace(character.discoloration.strength);
		}

		if (Controls.justPressed('up') || Controls.justPressed('down')) {
			if (Controls.justPressed('up'))
				character.currentPressure += 1;
			else if (Controls.justPressed('down'))
				character.currentPressure -= 1;
			character.playAnim('shocked');
		}
	}
}
