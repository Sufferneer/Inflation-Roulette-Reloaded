package utilities.states;

import utilities.substates.LoadFilePrompt;
import utilities.substates.LoadDirectoryPrompt;
import utilities.substates.ErrorPrompt;
import utilities.substates.NewSpriteProjectPrompt;
import substates.GenericPrompt;
import ui.objects.SuffIconButton;

class UtilitiesMainMenuState extends UtilitiesBaseMenuState {
	final buttons:Array<String> = [
		'characterCreator',
		'stageEditor'
	];
	final disabledButtons:Array<String> = [];
	final buttonSpacing:Float = 20;
	public static var initialized:Bool = false;

	override function create() {
		super.create();

		for (num => btn in buttons) {
			var button:SuffButton = new SuffButton(0, 0, Language.getPhrase('utilitiesMenu.$btn'), null, null, 500, 100);
			button.screenCenter(X);
			button.y = (FlxG.height - (button.height * buttons.length + buttonSpacing * (buttons.length - 1))) / 2 + (button.height + buttonSpacing) * num;
			button.disabled = disabledButtons.contains(btn);
			button.onClick = function () {
				buttonFunctions(btn);
			}
			add(button);
		}

		if (!initialized) {
			initialized = true;
			if (FlxG.save.data.hasOpenedUtilitiesMenu == null) {
				FlxG.save.data.hasOpenedUtilitiesMenu = true;
				openWarningPrompt();
			}
			playRandomMusic();
		}

		var warningButton:SuffIconButton = new SuffIconButton(10, 10, 'buttons/warning', 2);
		warningButton.y = FlxG.height - warningButton.height - 10;
		warningButton.onClick = function() {
			openWarningPrompt();
		}
		add(warningButton);
	}

	function openWarningPrompt() {
		openSubState(new GenericPrompt('utilitiesMenu.firstStartup.prompt', 960));
	}

	function buttonFunctions(name:String) {
		switch (name) {
			case 'characterCreator':
				LoadDirectoryPrompt.loadFileFunction = function(path:String) {
					try {
						if (!FileSystem.exists(path + '/' + 'metadata.json') || !FileSystem.exists(path + '/' + 'spriteData.json'))
							throw {message: 'This folder is not a valid Sprite Project Folder.'};
						FlxG.save.data.lastOpenedProject = path;
						trace('Opening project: ' + FlxG.save.data.lastOpenedProject);
						FlxG.save.flush();
						UtilitiesBaseMenuState.loadedPath = path;
						SuffState.switchState(new CharacterCreatorState());
					} catch(e:Dynamic) {
						openSubState(new ErrorPrompt(e.message));
					}
				}
				LoadDirectoryPrompt.newFileFunction = function() {
					openSubState(new NewSpriteProjectPrompt());
				}
				var what = FlxG.save.data.lastOpenedProject;
				if (FlxG.save.data.lastOpenedProject == null || !FileSystem.exists(what)) {
					FlxG.save.data.lastOpenedProject = Utilities.getExecutablePath() + '\\projects\\';
				}
				if (!FileSystem.exists(what)) {
					FlxG.save.data.lastOpenedProject = Utilities.getExecutablePath();
				}
				openSubState(new LoadDirectoryPrompt(FlxG.save.data.lastOpenedProject));
			case 'stageEditor':
				LoadFilePrompt.loadFileFunction = function(path:String) {
					try {
						UtilitiesBaseMenuState.loadedPath = path;
						SuffState.switchState(new StageEditorState());
					} catch(e:Dynamic) {
						openSubState(new ErrorPrompt(e.message));
					}
				}
				LoadFilePrompt.newFileFunction = null;
				openSubState(new LoadFilePrompt('${Utilities.getExecutablePath()}\\assets\\data\\stages\\'));
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
