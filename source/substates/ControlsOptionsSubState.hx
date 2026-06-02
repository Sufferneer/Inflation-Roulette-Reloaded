package substates;

import ui.objects.SuffIconButton;
import flixel.group.FlxSpriteContainer;
import ui.objects.SuffScrollBar;

class ControlsOptionsSubState extends SuffSubState {
	var bg:FlxSprite;
	var controlsGroup:FlxSpriteContainer = new FlxSpriteContainer();
	public static var keyBindButtons:Array<Map<String, SuffButton>> = [];
	var scrollBar:SuffScrollBar;
	public function new() {
		super();

		bg = new FlxSprite().loadGraphic(Paths.image('ui/menus/options/bg'));
		bg.color = 0x303030;
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.updateHitbox();
		add(bg);

		controlsGroup.camera = this.camera;
		add(controlsGroup);

		generateOptions();

		var exitButton = new SuffIconButton(20, 20, 'buttons/exit', null, 2);
		exitButton.x = FlxG.width - exitButton.width - 60;
		exitButton.onClick = function() {
			exitOptionsMenu();
		};
		exitButton.camera = this.camera;
		add(exitButton);

		scrollBar = new SuffScrollBar(0, 0, function(percent:Float) {
			controlsGroup.y = FlxMath.lerp(0, FlxG.height - (controlsGroup.height + 64), percent);
		}, 32, controlsGroup.height + 64);
		scrollBar.x = FlxG.width - scrollBar.width;
		scrollBar.camera = this.camera;
		add(scrollBar);

		camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
	}

	function generateOptions() {
		controlsY = 32;
		controlsGroup.clear();
		keyBindButtons = [
			new Map<String, SuffButton>(),
			new Map<String, SuffButton>()
		];
		addHeading('gameplay');
		addKeybind('shoot');
		addKeybind('exit');
		addKeybind('camera');
		addKeybind('skill1');
		addKeybind('skill2');
		addKeybind('skill3');
		// Unused
		// addKeybind('skill4');
		addKeybind('pause');

		addHeading('ui');
		addKeybind('up');
		addKeybind('left');
		addKeybind('down');
		addKeybind('right');

		addHeading('debug');
		addKeybind('debug1');
		addKeybind('debug2');
		// Unused
		// addKeybind('debug3');
		// addKeybind('debug4');
		// addKeybind('debug5');

		if (controlsGroup.height > FlxG.height) {
			controlMenuMax = controlsGroup.height - FlxG.height + 64;
		}
	}

	var controlsY:Float = 32;
	var controlMenuMax:Float = 0;
	var controlMenuY:Float = 0;

	function addHeading(heading:String) {
		var text:FlxText = new FlxText(0, controlsY, 960, Language.getPhrase('option.controls.$heading'), 64);
		text.alignment = CENTER;
		text.x = (FlxG.width - text.width) / 2;
		controlsGroup.add(text);
		controlsY += text.height + 32;
	}

	function addKeybind(keybind:String) {
		var keybindHeading:FlxText = new FlxText(0, controlsY, 320, Language.getPhrase('option.controls.keybind.$keybind'), 32);
		keybindHeading.alignment = CENTER;
		keybindHeading.x = (FlxG.width - 960) / 2;
		controlsGroup.add(keybindHeading);
		var keyX = keybindHeading.x + keybindHeading.width;
		for (i in 0...2) {
			var what = '';
			var key:Null<FlxKey> = Preferences.keybinds.get(keybind)[i];
			if (key == null) key = FlxKey.NONE;
			if (key != null) what = Utilities.formatKey(key);
			var keybindButton:SuffButton = new SuffButton(keyX, 0, what, 320 - 64, 64, true);
			keybindButton.x += 32;
			keybindButton.y = controlsY + (keybindHeading.height - keybindButton.height) / 2;
			keybindButton.onClick = function () {
				openSubState(new BindingKeyPrompt(keybind, i));
			}
			keyBindButtons[i].set(keybind, keybindButton);
			keyX += 320;
			controlsGroup.add(keybindButton);
		}
		controlsY += keybindHeading.height + 32;
	}

	function exitOptionsMenu() {
		Preferences.savePrefs();
		Preferences.loadPrefs();
		close();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (Controls.justPressed('exit')) {
			exitOptionsMenu();
		}
	}
}
