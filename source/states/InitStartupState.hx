package states;

#if _ALLOW_EASTER_EGGS
import states.easterEggStartups.*;
#end
import states.WarningState;

class InitStartupState extends SuffState {
	override function create() {
		// CursorHandler.cursorVisible = false;

		super.create();

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		new FlxTimer().start(1.5, function(tmr:FlxTimer) {
			#if _ALLOW_EASTER_EGGS
			var startupState = '';
			if (FlxG.save.data != null && FlxG.save.data.acknowledgedTermsOfService != null && FlxG.save.data.termsOfService != null)
				startupState = FlxG.save.data.easterEggStartup;
			else {
				FlxG.save.data.easterEggStartup = '';
				FlxG.save.flush();
				SuffState.switchState(new WarningState());
			}
			switch (startupState) {
				case 'imhighoncrack':
					SuffState.switchState(new ImHighOnCrackStartupState());
				case 'blueberryhelium':
					SuffState.switchState(new BlueberryHeliumStartupState());
				case 'roomoneohone':
					SuffState.switchState(new RoomOneOhOneStartupState());
				case 'ibeesbees':
					SuffState.switchState(new IBeesBeesStartupState());
				default:
					SuffState.switchState(new StartupState());
			}
			#else
			SuffState.switchState(new StartupState());
			#end
		});
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		// CursorHandler.cursorVisible = false;
	}
}
