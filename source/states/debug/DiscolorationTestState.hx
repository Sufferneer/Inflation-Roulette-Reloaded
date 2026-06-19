package states.debug;

import ui.objects.SuffIconButton;
import objects.Character;
import shaders.DiscolorationMaskedShader;

class DiscolorationTestState extends SuffState {
	var exiting:Bool = false;
	var exitButton:SuffIconButton;

	var character:Character;

	override function create() {
		super.create();

		character = new Character('shib', FlxG.width / 2, FlxG.height * 0.825);
		character.discoloration = new DiscolorationMaskedShader([96, 128, 255]);
		character.discoloration.destabilization = [0, 0, 0];
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
