package states.debug;

import ui.objects.SuffIconButton;
import objects.Character;
import shaders.DiscolorationMaskedShader;

class DiscolorationTestState extends SuffState {
	var exiting:Bool = false;
	var exitButton:SuffIconButton;

	var character:Character;
	var discolorationShader:DiscolorationMaskedShader;

	override function create() {
		super.create();

		character = new Character('shib', FlxG.width / 2, FlxG.height * 0.75);
		discolorationShader = new DiscolorationMaskedShader([96, 128, 255], character.mask.framePixels);
		character.shader = discolorationShader;
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

		discolorationShader.mask = character.mask.framePixels;

		if (Controls.justPressed('exit')) {
			exitMenu();
		}

		if (Controls.justPressed('left') || Controls.justPressed('right')) {
			if (Controls.justPressed('left'))
				discolorationShader.strength -= 0.1;
			else if (Controls.justPressed('right'))
				discolorationShader.strength += 0.1;
			trace(discolorationShader.strength);
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
