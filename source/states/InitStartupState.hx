package states;

#if _ALLOW_EASTER_EGGS
import states.easterEggStartups.*;
#end
import states.WarningState;

class InitStartupState extends SuffState {
	override function create() {
		FlxG.mouse.visible = false;

		super.create();

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		new FlxTimer().start(1.5, function(tmr:FlxTimer) {
			#if _ALLOW_EASTER_EGGS
			if (FlxG.save.data != null && FlxG.save.data.easterEggStartup != null)
				startupState = FlxG.save.data.easterEggStartup;
			else {
				FlxG.save.data.easterEggStartup = '';
			}
			#end
			FlxG.save.flush();
			switch (startupState) {
				#if _ALLOW_EASTER_EGGS
				case 'imhighoncrack':
					SuffState.switchState(new ImHighOnCrackStartupState());
				case 'snakemold':
					SuffState.switchState(new SnakeMoldStartupState());
				case 'roomoneohone':
					SuffState.switchState(new RoomOneOhOneStartupState());
				case 'ibeesbees':
					SuffState.switchState(new IBeesBeesStartupState());
				#end
				default:
					SuffState.switchState(new StartupState());
			}
		});
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		FlxG.mouse.visible = false;
	}
}
