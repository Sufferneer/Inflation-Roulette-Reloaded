package utilities.substates;

import ui.objects.SuffIconButton;
import flixel.addons.ui.FlxUIInputText;
import ui.addons.SuffUINumericStepper;
import ui.addons.SuffUIButton;
import haxe.Json;
import utilities.states.CharacterCreatorState;

class NewSpriteProjectPrompt extends UtilitiesBaseMenuSubState {
	var exitButton:SuffIconButton;
	var name:FlxUIInputText;
	var author:FlxUIInputText;
	var framerate:SuffUINumericStepper;
	var dimensionX:SuffUINumericStepper;
	var dimensionY:SuffUINumericStepper;
	var maxPressure:SuffUINumericStepper;
	var skills:FlxUIInputText;

	var confirmButton:SuffUIButton;

	public function new() {
		super();
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bg.alpha = 0.5;
		add(bg);

		var title:FlxText = new FlxText(0, 0, 0, Language.getPhrase('characterCreator.newCharacter.title'), 48);
		title.screenCenter(X);
		add(title);

		var text:FlxText = new FlxText(96, 96, 0, Language.getPhrase('characterCreator.parameter.name'), 32);
		add(text);
		name = new FlxUIInputText(text.x + text.width + 32, text.y, 320, Language.getPhrase('utilitiesMenu.placeholder'), 32);
		add(name);

		var save:FlxSave = new FlxSave();
		save.bind('editor', Utilities.getSavePath());
		if (save.data.defaultAuthorName == null) {
			save.data.defaultAuthorName = Utilities.getUsername();
		}

		var text:FlxText = new FlxText(text.x, text.y + text.height + 32, 0, Language.getPhrase('characterCreator.parameter.author'), 32);
		add(text);
		author = new FlxUIInputText(text.x + text.width + 32, text.y, 320, FlxG.save.data.defaultAuthorName, 32);
		add(author);

		var text:FlxText = new FlxText(text.x, text.y + text.height + 32, 0, Language.getPhrase('characterCreator.parameter.defaultFramerate'), 32);
		add(text);
		framerate = new SuffUINumericStepper(text.x + text.width + 32, text.y, 1, 24, 1, 30, 0, 32);
		add(framerate);

		var text:FlxText = new FlxText(text.x, text.y + text.height + 32, 0, Language.getPhrase('characterCreator.parameter.defaultDimensions'), 32);
		add(text);
		dimensionX = new SuffUINumericStepper(text.x + text.width + 32, text.y, 80, 640, 80, 1280, 0, 32);
		add(dimensionX);
		dimensionY = new SuffUINumericStepper(dimensionX.x + dimensionX.width, dimensionX.y, 80, 640, 80, 1280, 0, 32);
		add(dimensionY);
		var text:FlxText = new FlxText(text.x, text.y + text.height, 640, Language.getPhrase('characterCreator.newCharacter.unchangeableParameter'), 16);
		add(text);

		var text:FlxText = new FlxText(text.x, text.y + text.height + 32, 0, Language.getPhrase('characterCreator.parameter.maxPressure'), 32);
		add(text);
		maxPressure = new SuffUINumericStepper(text.x + text.width + 32, text.y, 1, 4, 1, 9, 0, 32);
		add(maxPressure);

		var text:FlxText = new FlxText(text.x, text.y + text.height + 32, 0, Language.getPhrase('characterCreator.parameter.skills'), 32);
		add(text);
		skills = new FlxUIInputText(text.x + text.width + 32, text.y, 480, 'reload,sabotage', 32);
		add(skills);
		var text:FlxText = new FlxText(text.x, text.y + text.height, 0, Language.getPhrase('characterCreator.parameter.skills.description'), 32);
		add(text);

		confirmButton = new SuffUIButton(text.x, text.y + text.height + 32, Language.getPhrase('characterCreator.newCharacter.create'), function() {
			attemptToCreateCharacter();
		});
		confirmButton.setLabelFormat(32, 0x333333);
		confirmButton.resize(384, 64);
		add(confirmButton);

		exitButton = new SuffIconButton(10, 10, 'buttons/exit', null, 2);
		exitButton.x = FlxG.width - exitButton.width - 10;
		exitButton.y = FlxG.height - exitButton.height - 10;
		exitButton.onClick = function() {
			leaveMenu();
		}
		add(exitButton);
	}

	function attemptToCreateCharacter() {
		if (!FileSystem.exists('projects/${name.text}')) {
			createCharacter();
		} else {
			openSubState(new ErrorPrompt('characterCreator.newCharacter.alreadyExists.prompt'));
		}
	}

	function createCharacter() {
		try {
			if (!FileSystem.exists('projects') || !FileSystem.isDirectory('projects/')) {
				FileSystem.createDirectory('projects');
			}
			var projectName:String = name.text + ' - ' + author.text;
			var save:FlxSave = new FlxSave();
			save.bind('editor', Utilities.getSavePath());
			save.data.defaultAuthorName = author.text;
			FileSystem.createDirectory('projects/$projectName');
			FileSystem.createDirectory('projects/$projectName/anims');
			FileSystem.createDirectory('projects/$projectName/sprites');
			var metadata = {
				name: name.text,
				author: author.text
			};
			File.saveContent('projects/$projectName/metadata.json', Json.stringify(metadata, '\t'));
			var spriteData = {
				defaultDimensions: [Std.int(dimensionX.value), Std.int(dimensionY.value)],
				defaultFramerate: Std.int(framerate.value),
				maxPressure: Std.int(maxPressure.value),
				skills: skills.text.split(',').map(item -> item.trim()),
				originPosition: [320, 560],
				particleOffsets: []
			};
			File.saveContent('projects/$projectName/spriteData.json', Json.stringify(spriteData, '\t'));

			var path = '${Utilities.getExecutablePath()}\\projects\\$projectName';
			save.data.lastOpenedProject = path;
			trace('Opening project: ' + FlxG.save.data.lastOpenedProject);
			save.flush();
			UtilitiesBaseMenuState.loadedPath = path;
			SuffState.switchState(new CharacterCreatorState());
		} catch(e:Dynamic) {
			openSubState(new ErrorPrompt(e));
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
