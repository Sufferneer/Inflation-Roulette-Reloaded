package substates;

class BindingKeyPrompt extends SuffSubState {
	var title:FlxText;
	var subtitle:FlxText;
	var keyName:FlxText;

	var keybind:String = '';
	var keybindIndex:Int = 0;

	public function new(keybind:String, index:Int = 0) {
		super();
		
		this.keybind = keybind;
		this.keybindIndex = index;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bg.alpha = 0.625;
		add(bg);

		var promptBG = new FlxSprite().loadGraphic(Paths.image('ui/menus/options/box'));
		promptBG.color = 0x606060;
		promptBG.alpha = 0.75;
		promptBG.setGraphicSize(FlxG.width / 1280 * 800, FlxG.height / 720 * 500);
		promptBG.updateHitbox();
		promptBG.antialiasing = !Preferences.data.enableForcedAliasing;
		promptBG.screenCenter();
		promptBG.scrollFactor.set();
		add(promptBG);

		title = new FlxText(0, promptBG.y + 32, promptBG.width - 64, Language.getPhrase('option.controls.bindingKey.title', [Language.getPhrase('option.controls.keybind.$keybind'), Language.getPhrase('option.controls.bindingKey.bindType.$keybindIndex')]), 48);
		title.alignment = CENTER;
		title.screenCenter(X);
		title.scrollFactor.set();

		subtitle = new FlxText(0, title.y + title.height, title.width, Language.getPhrase('option.controls.bindingKey.subtitle'), 32);
		subtitle.visible = false;
		subtitle.alignment = CENTER;
		subtitle.screenCenter(X);
		subtitle.scrollFactor.set();

		keyName = new FlxText(0, 0, subtitle.width, Utilities.formatKey(Preferences.keybinds.get(keybind)[keybindIndex]), 64);
		keyName.alignment = CENTER;
		keyName.scrollFactor.set();
		keyName.screenCenter();
		add(keyName);

		var bindButton:SuffButton = new SuffButton(0, 0, Language.getPhrase('option.controls.bindingKey.bind'), 240, 96);
		bindButton.btnTextSize = 48;
		bindButton.x = promptBG.x + 32;
		bindButton.y = promptBG.y + promptBG.height - bindButton.height - 32;
		bindButton.onClick = function() {
			bindingKey = true;
		};
		add(bindButton);

		keyName.y = subtitle.y + (bindButton.y - subtitle.y - keyName.height) / 2;

		var unbindButton:SuffButton = new SuffButton(0, 0, Language.getPhrase('option.controls.bindingKey.remove'), bindButton.width, bindButton.height);
		unbindButton.btnTextSize = bindButton.btnTextSize;
		unbindButton.screenCenter(X);
		unbindButton.y = promptBG.y + promptBG.height - unbindButton.height - 32;
		unbindButton.onClick = function() {
			removeKey();
		};
		add(unbindButton);

		var exitButton:SuffButton = new SuffButton(0, subtitle.y + subtitle.height + 64, Language.getPhrase('menu.exit'), unbindButton.width, unbindButton.height);
		exitButton.btnTextSize = bindButton.btnTextSize;
		exitButton.x = promptBG.x + promptBG.width - exitButton.width - 32;
		exitButton.y = unbindButton.y;
		exitButton.onClick = function() {
			close();
		};
		add(exitButton);
		
		add(title);
		add(subtitle);
	}
	
	var bindingKey(default, set):Bool = false;
	
	function set_bindingKey(value:Bool = false) {
		bindingKey = value;
		subtitle.visible = bindingKey;
		return value;
	}
	
	function updateKeyButton() {
		var leButton:SuffButton = ControlsOptionsSubState.keyBindButtons[keybindIndex].get(keybind);
		leButton.btnTextTxt = keyName.text;
	}

	function bindKey(inputKeybind:FlxKey){
		var array = Preferences.keybinds.get(keybind);
		array[keybindIndex] = inputKeybind;

		keyName.text = Utilities.formatKey(inputKeybind);

		bindingKey = false;
		updateKeyButton();

		SuffState.playUISound(Paths.sound('ui/typeEnter'));
	}

	function removeKey(){
		var array = Preferences.keybinds.get(keybind);
		array[keybindIndex] = FlxKey.NONE;

		keyName.text = Utilities.formatKey(FlxKey.NONE);

		bindingKey = false;
		updateKeyButton();

		SuffState.playUISound(Paths.sound('ui/type_1'));
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (bindingKey) {
			if (FlxG.keys.justPressed.ANY) {
				bindKey(FlxG.keys.firstJustPressed());
			}
		} else {
			if (Controls.justPressed('exit'))
				close();	
		}
	}
}
