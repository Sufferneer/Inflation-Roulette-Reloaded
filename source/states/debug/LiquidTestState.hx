package states.debug;

import objects.Character;
import shaders.DiscolorationMaskedShader;
import ui.objects.SuffIconButton;
import objects.particles.Liquid;
import backend.Gameplay;
import backend.Filler;

class LiquidTestState extends SuffState {
	var exiting:Bool = false;
	var exitButton:SuffIconButton;

	var floor:FlxSprite;
	var character:Character;

	override function create() {
		super.create();

		Gameplay.currentFiller = new Filler('asimo');

		floor = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
		floor.y = FlxG.height * 7 / 8;
		add(floor);

		character = new Character('goober', 160, floor.y);
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

		if (FlxG.mouse.justPressed) {
			for (i in 0...20) {
				var liquidVelocity = FlxPoint.get(FlxG.mouse.x, (FlxG.mouse.y - FlxG.height / 2) * 5);
				liquidVelocity.add(FlxG.random.int(-100, 100), FlxG.random.int(-100, 100));
				var position = character.getParticleOffset('mouth').add(character.x, character.y);
				var liquid = new Liquid(position.x, position.y, floor.y);
				liquid.velocity.set(liquidVelocity.x, liquidVelocity.y);
				liquid.color = 0xFF503080;
				add(liquid);
			}
		}

		if (Controls.justPressed('up') || Controls.justPressed('down')) {
			if (Controls.justPressed('up'))
				character.currentPressure ++;
			else if (Controls.justPressed('down'))
				character.currentPressure --;
			character.playAnim('shocked');
		}
	}
}
