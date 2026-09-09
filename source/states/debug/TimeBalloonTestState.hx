package states.debug;

import ui.objects.SuffIconButton;
import ui.objects.TimeBalloon;

class TimeBalloonTestState extends SuffState {
	var exiting:Bool = false;
	var exitButton:SuffIconButton;
	
	var timeBalloon:TimeBalloon;

	public override function create() {
		super.create();

		timeBalloon = new TimeBalloon();
		timeBalloon.maxTime = timeBalloon.timeRemaining = 120;
		timeBalloon.screenCenter();
		add(timeBalloon);

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

	public override function update(elapsed:Float) {
		super.update(elapsed);

		timeBalloon.timeRemaining -= elapsed;
		if (Controls.pressed('up')) {
			timeBalloon.timeRemaining += elapsed * 10;
		} else if (Controls.pressed('down')) {
			timeBalloon.timeRemaining -= elapsed * 10;
		}
		if (Controls.justPressed('exit')) {
			exitMenu();
		}
	}
}
