package states;

#if _ALLOW_EASTER_EGGS
import states.easterEggStartups.*;
#end
import states.WarningState;
import backend.AndroidUtil;

class AndroidPermissionsState extends SuffState {
	var askingForPermissions:Bool = true;
	var bg:FlxSprite;
	var title:FlxText;
	var description:FlxText;
	var acceptButton:SuffButton;
	var declineButton:SuffButton;
	public static var deniedPermissions:Bool = false;
	override function create() {
		super.create();

		Window.setTitle(Language.getPhrase('androidPermissionsMenu.windowDisplay'));

		bg = new FlxSprite();
		bg.loadGraphic(Paths.image('ui/menus/android/permissionsRequired'));

		title = new FlxText(0, 0, FlxG.width * 0.4, Language.getPhrase('androidPermissionsMenu.permissionsRequired'), 48);
		description = new FlxText(0, 0, title.width, Language.getPhrase('androidPermissionsMenu.description'), 32);
		acceptButton = new SuffButton(0, 0, Language.getPhrase('menu.accept'), title.width, 100);
		acceptButton.onClick = function() {
			AndroidUtil.requestAllFilesPermission();
		}
		declineButton = new SuffButton(0, 0, Language.getPhrase('androidPermissionsMenu.playWithoutAddons'), title.width, 100);
		declineButton.onClick = function() {
			deniedPermissions = true;
			acceptButton.disabled = true;
			declineButton.disabled = true;
			FlxG.camera.fade(0xFF000000, 1, function() {
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				SuffState.switchState(new InitStartupState());
			});
		}
		// Troll
		acceptButton.btnBGColor = acceptButton.btnBGColorClicked = acceptButton.btnBGColorHovered = acceptButton.btnBGColorDisabled = declineButton.btnBGColor = declineButton.btnBGColorClicked = declineButton.btnBGColorHovered = declineButton.btnBGColorDisabled = 0xFF000000;
		acceptButton.btnOutlineColor = acceptButton.btnOutlineColorClicked = acceptButton.btnOutlineColorHovered = acceptButton.btnOutlineColorDisabled = 0xFFFFFFFF;
		declineButton.btnOutlineColor = declineButton.btnOutlineColorClicked = declineButton.btnOutlineColorHovered = declineButton.btnOutlineColorDisabled = declineButton.btnTextColor = declineButton.btnTextColorClicked = declineButton.btnTextColorHovered = declineButton.btnTextColorDisabled = 0xFFA0A0A0;

		bg.x = Std.int((FlxG.width / 2 - bg.width) / 2);
		bg.y = Std.int((FlxG.height - bg.height) / 2);

		title.x = description.x = acceptButton.x = declineButton.x = Std.int(FlxG.width / 2 + (FlxG.width / 2 - title.width) / 2);
		title.y = Std.int((FlxG.height - (title.height + description.height + 20 + acceptButton.height + 10 + declineButton.height)) / 2);
		description.y = title.y + title.height;
		acceptButton.y = description.y + description.height + 20;
		declineButton.y = acceptButton.y + acceptButton.height + 10;
		add(bg);
		add(title);
		add(description);
		add(acceptButton);
		add(declineButton);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (askingForPermissions == true && AndroidUtil.checkAllFilesPermission()) {
			askingForPermissions = false;
			bg.loadGraphic(Paths.image('ui/menus/android/permissionsGranted'));
			title.text = Language.getPhrase('androidPermissionsMenu.permissionsGranted');
			title.y = Std.int((FlxG.height - title.height) / 1.75);
			description.destroy();
			acceptButton.destroy();
			declineButton.destroy();
			SuffState.playUISound(Paths.sound('game/confetti'));
			SuffState.playMusic('win');
			new FlxTimer().start(3, function(_) {
				FlxG.sound.music.stop();
				SuffState.playUISound(Paths.sound('void'), 1, 0.8909);
				FlxG.camera.fade(0xFF000000, 2, function() {
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					SuffState.switchState(new PreloadState());
				});
			});
		}
	}
}
