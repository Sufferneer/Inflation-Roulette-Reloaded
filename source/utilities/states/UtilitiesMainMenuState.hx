package utilities.states;

import utilities.substates.LoadFilePrompt;
import utilities.substates.LoadDirectoryPrompt;
import utilities.substates.ErrorPrompt;
import utilities.substates.NewSpriteProjectPrompt;
import substates.GenericPrompt;
import ui.objects.SuffIconButton;
import utilities.backend.LangFileConvert;
import openfl.net.FileFilter;

using StringTools;

class UtilitiesMainMenuState extends UtilitiesBaseMenuState {
	final buttons:Array<String> = [
		'characterCreator',
		'stagePreviewer',
		'offsetEditor',
		'langConverter'
	];
	final disabledButtons:Array<String> = [];
	final buttonSpacing:Float = 20;
	public static var initialized:Bool = false;

	override function create() {
		super.create();

		resetTitle();

		for (num => btn in buttons) {
			var button:SuffButton = new SuffButton(0, 0, Language.getPhrase('utilitiesMenu.$btn'), null, null, 550, 100);
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
			FlxG.sound.music.onComplete = function() {
				playRandomMusic();
			};
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
				var save:FlxSave = new FlxSave();
				save.bind('editor', Utilities.getSavePath());
				if (save.data.lastOpenedProject == null)
					save.data.lastOpenedProject = '';
				LoadDirectoryPrompt.loadFileFunction = function(path:String) {
					try {
						if (!FileSystem.exists(path + '/' + 'metadata.json') || !FileSystem.exists(path + '/' + 'spriteData.json'))
							throw {message: 'This folder is not a valid Sprite Project Folder.'};
						save.data.lastOpenedProject = path;
						trace('Opening project: ' + save.data.lastOpenedProject);
						save.flush();
						UtilitiesBaseMenuState.loadedPath = path;
						SuffState.switchState(new CharacterCreatorState());
					} catch(e:Dynamic) {
						openSubState(new ErrorPrompt(e.message));
					}
				}
				LoadDirectoryPrompt.newFileFunction = function() {
					openSubState(new NewSpriteProjectPrompt());
				}
				if (save.data.lastOpenedProject == null || !FileSystem.exists(save.data.lastOpenedProject)) {
					save.data.lastOpenedProject = Utilities.getExecutablePath() + '\\projects\\';
				}
				if (!FileSystem.exists(save.data.lastOpenedProject)) {
					save.data.lastOpenedProject = Utilities.getExecutablePath();
				}
				openSubState(new LoadDirectoryPrompt(save.data.lastOpenedProject));
			case 'stagePreviewer':
				LoadFilePrompt.loadFileFunction = function(path:String) {
					try {
						UtilitiesBaseMenuState.loadedPath = path;
						SuffState.switchState(new StagePreviewerState());
					} catch(e:Dynamic) {
						openSubState(new ErrorPrompt(e.message));
					}
				}
				LoadFilePrompt.newFileFunction = null;
				openSubState(new LoadFilePrompt('${Utilities.getExecutablePath()}\\assets\\data\\stages\\', [new FileFilter('JSON', 'json')]));
			case 'offsetEditor':
				LoadDirectoryPrompt.loadFileFunction = function(path:String) {
					UtilitiesBaseMenuState.loadedPath = path;
					SuffState.switchState(new OffsetEditorState());
				}
				LoadDirectoryPrompt.newFileFunction = null;
				openSubState(new LoadDirectoryPrompt('${Utilities.getExecutablePath()}\\assets\\data\\characters\\goober\\'));
			case 'langConverter':
				Window.setTitle(Language.getPhrase('utilitiesMenu.windowDisplay'), Language.getPhrase('utilitiesMenu.langConverter'));
				LoadFilePrompt.loadFileFunction = function(path:String) {
					try {
						var fullDirectory = path.split('/');
						var lastDirectory = fullDirectory[fullDirectory.length - 1].replace('.lang', '');
						LangFileConvert.langToJson(File.getContent(path), lastDirectory);
						openSubState(new GenericPrompt(Language.getPhrase('langConverter.successPrompt', ['exports/lang/${lastDirectory}.json']), function() {
							resetTitle();
						}));
					} catch(e:Dynamic) {
						openSubState(new ErrorPrompt(e.message));
					}
				}
				LoadFilePrompt.newFileFunction = null;
				openSubState(new LoadFilePrompt('${Utilities.getExecutablePath()}\\assets\\lang\\', [new FileFilter('LANG', 'lang')]));
		}
	}

	function resetTitle() {
		Window.setTitle(Language.getPhrase('utilitiesMenu.windowDisplay'));
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
