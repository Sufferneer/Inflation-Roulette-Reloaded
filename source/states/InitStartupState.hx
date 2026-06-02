package states;

import states.WarningState;
#if _ALLOW_EASTER_EGGS
import states.easterEggStartups.*;
#end
#if android
import backend.AndroidUtils;
import states.AndroidPermissionsState;
import backend.Addons.Addons.pushGlobalAddons;
import backend.Addons;
#end

class InitStartupState extends SuffState {
	override function create() {
		// CursorHandler.cursorVisible = false;

		super.create();

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		if (FlxG.save.data.acknowledgedTermsOfService == null || FlxG.save.data.termsOfService == null)
			SuffState.switchState(new WarningState());
		new FlxTimer().start(1.5, function(tmr:FlxTimer) {
			var startupState = '';
			#if (_ALLOW_ADDONS && android)
			if (!AndroidUtils.checkAllFilesPermission() && !AndroidPermissionsState.deniedPermissions) {
				SuffState.switchState(new AndroidPermissionsState());
				return;
			}
			#end
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
				case 'blueberryhelium':
					SuffState.switchState(new BlueberryHeliumStartupState());
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

		// CursorHandler.cursorVisible = false;
	}
}
