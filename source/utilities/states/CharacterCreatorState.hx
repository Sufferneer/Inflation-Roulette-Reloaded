package utilities.states;

import utilities.typedefs.SpriteProjectMetadata;
import utilities.typedefs.SpriteProjectSpritedata;
import tjson.TJSON as Json;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIInputText;
import ui.addons.SuffUINumericStepper;
import utilities.objects.ExplorerFile;
import utilities.enums.ExplorerFileFileType;
import utilities.objects.ExplorerPathText;
import utilities.enums.CharacterCreatorAnimType;
import ui.addons.SuffUIButton;
import utilities.substates.SpriteBrowseImagePrompt;
import utilities.states.AnimationEditorState;
import utilities.substates.ChoicePrompt;
import utilities.substates.GenericPrompt;
import utilities.substates.ExportingProjectPrompt;
import utilities.substates.ErrorPrompt;
import flixel.addons.ui.FlxUINumericStepper;
import ui.addons.SuffUITabMenu;

class CharacterCreatorState extends UtilitiesBaseMenuState {
	public static final version:String = '0.0.2';

	public static var metadata:SpriteProjectMetadata;
	public static var spriteData:SpriteProjectSpritedata;
	public static var anims:Array<String> = [];

	var defaultFiles = [
		{name: 'idle', type: ExplorerFileFileType.folder, icon: 'animation'},
		{name: 'prepareShoot', type: ExplorerFileFileType.folder, icon: 'animation'},
		{name: 'preShoot', type: ExplorerFileFileType.folder, icon: 'animation'},
		{name: 'shootBlank', type: ExplorerFileFileType.folder, icon: 'animation'},
		{name: 'shootLive', type: ExplorerFileFileType.folder, icon: 'animation'},
		{name: 'pass', type: ExplorerFileFileType.folder, icon: 'animation'},
		{name: 'skill', type: ExplorerFileFileType.folder, icon: 'animation'},
		{name: 'shocked', type: ExplorerFileFileType.folder, icon: 'animation'},
		{name: 'win', type: ExplorerFileFileType.folder, icon: 'animation'},
		{name: 'helpless', type: ExplorerFileFileType.folder, icon: 'animation'},
		{name: 'popped', type: ExplorerFileFileType.file, icon: 'animation'},
		{name: 'introPartOne', type: ExplorerFileFileType.file, icon: 'animation'},
		{name: 'introPartTwo', type: ExplorerFileFileType.file, icon: 'animation'},
		{name: 'scraps', type: ExplorerFileFileType.file, icon: 'scraps'},
		{name: 'cardBG', type: ExplorerFileFileType.file, icon: 'charSelect'},
		{name: 'cardCharIdle', type: ExplorerFileFileType.file, icon: 'charSelect'},
		{name: 'cardCharSelected', type: ExplorerFileFileType.file, icon: 'charSelect'},
		{name: 'bannerAppear', type: ExplorerFileFileType.file, icon: 'charSelect'},
		{name: 'bannerBlink', type: ExplorerFileFileType.file, icon: 'charSelect'}
	];
	var animsType:Map<String, CharacterCreatorAnimType> = [
		'idle' => ALL_STATES,
		'prepareShoot' => ONLY_INFLATED_STATES,
		'preShoot' => ONLY_INFLATED_STATES,
		'shootBlank' => ONLY_INFLATED_STATES,
		'shootLive' => ONLY_INFLATED_STATES,
		'pass' => ONLY_INFLATED_STATES,
		'skill' => ONLY_INFLATED_STATES,
		'shocked' => ONLY_INFLATED_STATES,
		'win' => ONLY_INFLATED_STATES,
		'helpless' => ONLY_DEFEATED_STATES,
		'popped' => NO_STATES,
		'introPartOne' => NO_STATES,
		'introPartTwo' => NO_STATES,
		'scraps' => NO_STATES,
		'cardBG' => NO_STATES,
		'cardCharIdle' => NO_STATES,
		'cardCharSelected' => NO_STATES,
		'bannerAppear' => NO_STATES,
		'bannerBlink' => NO_STATES
	];
	var optionalAnims:Array<String> = [
		'shocked',
		'win',
		'helpless',
		'introPartOne',
		'introPartTwo'
	];

	public static var explorerCurPath = 'root/';

	var UI_box:SuffUITabMenu;
	var explorerPathTxt:ExplorerPathText;
	var explorerPathBar:FlxSprite;
	var explorerDescBar:FlxSprite;
	var explorerDescTxt:FlxText;
	var explorerBG:FlxSprite;
	var explorerFiles:FlxTypedContainer<ExplorerFile> = new FlxTypedContainer<ExplorerFile>();

	public static var instance:CharacterCreatorState;

	override function create() {
		super.create();

		reloadJSONData();
		reloadSkills();
		generateUI();

		instance = this;
	}

	function generateUI() {
		remove(exitButton);
		var tabs = [
			{name: 'Metadata', label: Language.getPhrase('characterCreator.dataType.metadata')},
			{name: 'Spritedata', label: Language.getPhrase('characterCreator.dataType.spriteData')},
		];
		UI_box = new SuffUITabMenu(null, tabs, true);
		UI_box.resize(340, 700);
		UI_box.x = 930;
		UI_box.y = 10;

		generateMetadataUI();
		generateSpritedataUI();
		add(UI_box);

		var exitButton = new SuffUIButton(Language.getPhrase('characterCreator.exit'), function () {
			leaveMenu();
		});
		exitButton.resize(UI_box.width / 2 - 20 - 10, 32);
		exitButton.color = 0xFF2020;
		exitButton.label.color = 0xFFFFFF;
		exitButton.x = UI_box.x + 20;
		exitButton.y = UI_box.y + UI_box.height - exitButton.height - 20;
		add(exitButton);

		var saveButton = new SuffUIButton(Language.getPhrase('characterCreator.save'), function () {
			saveJSONData();
			openSubState(new GenericPrompt('characterCreator.saveSuccessful.prompt'));
		});
		saveButton.resize(exitButton.width, exitButton.height);
		saveButton.x = UI_box.x + 20;
		saveButton.y = exitButton.y - saveButton.height - 10;
		add(saveButton);

		var exportButton = new SuffUIButton(Language.getPhrase('characterCreator.export'), function () {
			openSubState(new ChoicePrompt('characterCreator.confirmExport.prompt', function() {
				initExportShit();
			}, 1100));
		});
		exportButton.resize(UI_box.width / 2 - 20 - 10, 74);
		exportButton.color = 0x20C040;
		exportButton.label.color = 0xFFFFFF;
		exportButton.x = saveButton.x + saveButton.width + 20;
		exportButton.y = UI_box.y + UI_box.height - exportButton.height - 20;
		add(exportButton);

		explorerPathBar = new FlxSprite(10, Main.debugText.visible ? 10 + Main.debugText.height : 10).makeGraphic(910, 32, 0xFF000000);
		explorerPathBar.alpha = 0.625;
		add(explorerPathBar);

		explorerPathTxt = new ExplorerPathText(explorerPathBar.x + 8, explorerPathBar.y + 8);
		explorerPathTxt.onManualUpdatePath = function(path:String) {
			generateExplorer();
		}
		explorerPathTxt.setPath(explorerCurPath);
		add(explorerPathTxt);

		explorerBG = new FlxSprite(explorerPathBar.x, explorerPathBar.y + explorerPathBar.height).makeGraphic(Std.int(explorerPathBar.width), Std.int(700 - explorerPathBar.height * 2 - (Main.debugText.visible ? Main.debugText.height : 0)), 0xFF000000);
		explorerBG.alpha = 0.5;
		add(explorerBG);

		explorerDescBar = new FlxSprite(10, explorerBG.y + explorerBG.height).makeGraphic(Std.int(explorerBG.width), Std.int(explorerPathBar.height), 0xFF000000);
		explorerDescBar.alpha = 0.625;
		add(explorerDescBar);

		explorerDescTxt = new FlxText(explorerDescBar.x + 8, explorerDescBar.y + (explorerDescBar.height - 16) / 2, 0, '', 16);
		add(explorerDescTxt);

		var explorerVersionTxt = new FlxText(0, explorerDescTxt.y, 0, Language.getPhrase('utilitiesMenu.characterCreator') + ' v$version', 16);
		explorerVersionTxt.x = explorerDescBar.x + explorerDescBar.width - explorerVersionTxt.width - 8;
		add(explorerVersionTxt);

		add(explorerFiles);
		generateExplorer();
	}

	var metadataNameInputText:FlxUIInputText;
	var metadataDescInputText:FlxUIInputText;
	var metadataAuthorInputText:FlxUIInputText;
	function generateMetadataUI() {
		var tabGroup = new FlxUI(null, UI_box);
		tabGroup.name = 'Metadata';

		metadataNameInputText = new FlxUIInputText(20, 44, Std.int(UI_box.width - 40), metadata.name, 16);
		tabGroup.add(new FlxText(metadataNameInputText.x, metadataNameInputText.y - 24, 0, Language.getPhrase('characterCreator.parameter.name'), 16));
		tabGroup.add(metadataNameInputText);

		metadataDescInputText = new FlxUIInputText(metadataNameInputText.x, metadataNameInputText.y + 64, Std.int(UI_box.width - 40), metadata.description, 16);
		tabGroup.add(new FlxText(metadataDescInputText.x, metadataDescInputText.y - 24, 0, Language.getPhrase('characterCreator.parameter.description'), 16));
		tabGroup.add(metadataDescInputText);

		metadataAuthorInputText = new FlxUIInputText(metadataDescInputText.x, metadataDescInputText.y + 64, Std.int(UI_box.width - 40), metadata.author, 16);
		tabGroup.add(new FlxText(metadataAuthorInputText.x, metadataAuthorInputText.y - 24, 0, Language.getPhrase('characterCreator.parameter.author'), 16));
		tabGroup.add(metadataAuthorInputText);

		UI_box.addGroup(tabGroup);
	}

	function initExportShit() {
		var leAnims:Array<String> = [];
		var missingAnims:Array<String> = [];
		for (anim in defaultFiles) {
			var name = anim.name;
			if (optionalAnims.contains(name)) {
				switch (animsType.get(anim.name)) {
					case ONLY_DEFEATED_STATES:
						if (FileSystem.exists(getPath() + '/anims/${name}Null.json'))
							leAnims.push(name + 'Null');
						if (FileSystem.exists(getPath() + '/anims/${name}Overinflated.json'))
							leAnims.push(name + 'Overinflated');
					case ONLY_INFLATED_STATES:
						for (i in 0...spriteData.maxPressure + 1) {
							if (FileSystem.exists(getPath() + '/anims/${name}${i}.json'))
								leAnims.push('$name$i');
						}
					case ALL_STATES:
						for (i in 0...spriteData.maxPressure + 1) {
							if (FileSystem.exists(getPath() + '/anims/${name}${i}.json'))
								leAnims.push('$name$i');
						}
						if (FileSystem.exists(getPath() + '/anims/${name}Null.json'))
							leAnims.push(name + 'Null');
						if (FileSystem.exists(getPath() + '/anims/${name}Overinflated.json'))
							leAnims.push(name + 'Overinflated');
					default:
						if (FileSystem.exists(getPath() + '/anims/$name.json'))
							leAnims.push(name);
				}
			} else {
				switch (animsType.get(anim.name)) {
					case ONLY_DEFEATED_STATES:
						if (FileSystem.exists(getPath() + '/anims/${name}Null.json'))
							leAnims.push(name + 'Null');
						else
							missingAnims.push(name + 'Null');
						if (FileSystem.exists(getPath() + '/anims/${name}Overinflated.json'))
							leAnims.push(name + 'Overinflated');
						else
							missingAnims.push(name + 'Overinflated');
					case ONLY_INFLATED_STATES:
						for (i in 0...spriteData.maxPressure + 1) {
							if (FileSystem.exists(getPath() + '/anims/${name}${i}.json'))
								leAnims.push('$name$i');
							else
								missingAnims.push('$name$i');
						}
					case ALL_STATES:
						for (i in 0...spriteData.maxPressure + 1) {
							if (FileSystem.exists(getPath() + '/anims/${name}${i}.json'))
								leAnims.push('$name$i');
							else
								missingAnims.push('$name$i');
						}
						if (FileSystem.exists(getPath() + '/anims/${name}Null.json'))
							leAnims.push(name + 'Null');
						else
							missingAnims.push(name + 'Null');
						if (FileSystem.exists(getPath() + '/anims/${name}Overinflated.json'))
							leAnims.push(name + 'Overinflated');
						else
							missingAnims.push(name + 'Overinflated');
					default:
						if (FileSystem.exists(getPath() + '/anims/$name.json'))
							leAnims.push(name);
						else
							missingAnims.push(name);
				}
			}
		}
		if (missingAnims.length > 10) {
			missingAnims.resize(10);
			missingAnims.push(Language.getPhrase('characterCreator.exporting.missingAnimations.extend'));
		}
		if (missingAnims.length == 0) {
			ExportingProjectPrompt.allAnims = leAnims;
			openSubState(new ExportingProjectPrompt());
		} else {
			trace(missingAnims);
			openSubState(new ErrorPrompt(Language.getPhrase('characterCreator.exporting.missingAnimations', [missingAnims.join(', ')])));
		}
	}

	var spriteDataMaxPressureStepper:SuffUINumericStepper;
	var spriteDataMaxConfidenceStepper:SuffUINumericStepper;
	var spriteDataDefaultFramerateStepper:SuffUINumericStepper;
	var spriteDataSkillsInputText:FlxUIInputText;
	var spriteDataReloadSkillsButton:SuffUIButton;
	function generateSpritedataUI() {
		var tabGroup = new FlxUI(null, UI_box);
		tabGroup.name = 'Spritedata';

		spriteDataDefaultFramerateStepper = new SuffUINumericStepper(20, 44, 1, spriteData.defaultFramerate, 1, 30);
		tabGroup.add(new FlxText(spriteDataDefaultFramerateStepper.x, spriteDataDefaultFramerateStepper.y - 24, 0, Language.getPhrase('characterCreator.parameter.defaultFramerate'), 16));
		tabGroup.add(spriteDataDefaultFramerateStepper);

		spriteDataMaxConfidenceStepper = new SuffUINumericStepper(20, spriteDataDefaultFramerateStepper.y + 72, 1, spriteData.maxConfidence, 1, 6);
		tabGroup.add(new FlxText(20, spriteDataMaxConfidenceStepper.y - 24, 0, Language.getPhrase('characterCreator.parameter.maxConfidence'), 16));
		tabGroup.add(spriteDataMaxConfidenceStepper);

		spriteDataMaxPressureStepper = new SuffUINumericStepper(20, spriteDataMaxConfidenceStepper.y + 72, 1, spriteData.maxPressure, 1, 9);
		tabGroup.add(new FlxText(20, spriteDataMaxPressureStepper.y - 24, 0, Language.getPhrase('characterCreator.parameter.maxPressure'), 16));
		tabGroup.add(spriteDataMaxPressureStepper);

		spriteDataSkillsInputText = new FlxUIInputText(20, spriteDataMaxPressureStepper.y + 72 + 16, Std.int(UI_box.width - 40), spriteData.skills.join(','), 16);
		tabGroup.add(new FlxText(20, spriteDataSkillsInputText.y - 24 - 16, 0, Language.getPhrase('characterCreator.parameter.skills') + '\n' + Language.getPhrase('characterCreator.parameter.skills.description'), 16));
		tabGroup.add(spriteDataSkillsInputText);

		spriteDataReloadSkillsButton = new SuffUIButton(20, spriteDataSkillsInputText.y + 32, Language.getPhrase('characterCreator.reloadSkills'), function() {
			spriteData.skills = spriteDataSkillsInputText.text.split(',').map(item -> item.trim());
			reloadSkills();
			generateExplorer();
		});
		spriteDataReloadSkillsButton.resize(128, 32);
		tabGroup.add(spriteDataReloadSkillsButton);

		UI_box.addGroup(tabGroup);
	}

	function reloadSkills() {
		defaultFiles = [
			{name: 'idle', type: ExplorerFileFileType.folder, icon: 'animation'},
			{name: 'prepareShoot', type: ExplorerFileFileType.folder, icon: 'animation'},
			{name: 'preShoot', type: ExplorerFileFileType.folder, icon: 'animation'},
			{name: 'shootBlank', type: ExplorerFileFileType.folder, icon: 'animation'},
			{name: 'shootLive', type: ExplorerFileFileType.folder, icon: 'animation'},
			{name: 'pass', type: ExplorerFileFileType.folder, icon: 'animation'},
			{name: 'skill', type: ExplorerFileFileType.folder, icon: 'animation'},
			{name: 'shocked', type: ExplorerFileFileType.folder, icon: 'animation'},
			{name: 'win', type: ExplorerFileFileType.folder, icon: 'animation'},
			{name: 'helpless', type: ExplorerFileFileType.folder, icon: 'animation'},
			{name: 'popped', type: ExplorerFileFileType.file, icon: 'animation'},
			{name: 'introPartOne', type: ExplorerFileFileType.file, icon: 'animation'},
			{name: 'introPartTwo', type: ExplorerFileFileType.file, icon: 'animation'},
			{name: 'scraps', type: ExplorerFileFileType.file, icon: 'scraps'},
			{name: 'cardBG', type: ExplorerFileFileType.file, icon: 'charSelect'},
			{name: 'cardCharIdle', type: ExplorerFileFileType.file, icon: 'charSelect'},
			{name: 'cardCharSelected', type: ExplorerFileFileType.file, icon: 'charSelect'},
			{name: 'bannerAppear', type: ExplorerFileFileType.file, icon: 'charSelect'},
			{name: 'bannerBlink', type: ExplorerFileFileType.file, icon: 'charSelect'}
		];
		animsType = [
			'idle' => ALL_STATES,
			'prepareShoot' => ONLY_INFLATED_STATES,
			'preShoot' => ONLY_INFLATED_STATES,
			'shootBlank' => ONLY_INFLATED_STATES,
			'shootLive' => ONLY_INFLATED_STATES,
			'pass' => ONLY_INFLATED_STATES,
			'skill' => ONLY_INFLATED_STATES,
			'shocked' => ONLY_INFLATED_STATES,
			'win' => ONLY_INFLATED_STATES,
			'helpless' => ONLY_DEFEATED_STATES,
			'popped' => NO_STATES,
			'introPartOne' => NO_STATES,
			'introPartTwo' => NO_STATES,
			'scraps' => NO_STATES,
			'cardBG' => NO_STATES,
			'cardCharIdle' => NO_STATES,
			'cardCharSelected' => NO_STATES,
			'bannerAppear' => NO_STATES,
			'bannerBlink' => NO_STATES
		];
		optionalAnims = [
			'shocked',
			'win',
			'helpless',
			'introPartOne',
			'introPartTwo'
		];
		for (i in spriteData.skills) {
			i = Utilities.capitalize(i);
			defaultFiles.insert(7, {name: 'skill' + i, type: ExplorerFileFileType.folder, icon: 'animation'});
			animsType.set('skill' + i, ONLY_INFLATED_STATES);
			optionalAnims.push('skill' + i);
		}
	}

	public function generateExplorer() {
		var num = 0;
		final iconsPerRow = 7;
		explorerFiles.clear();
		var leFiles = defaultFiles.copy();
		if (explorerCurPath != 'root/') {
			leFiles = [];
			var anim:String = explorerPathTxt.getLastPath();
			if (animsType.get(anim) == ONLY_INFLATED_STATES || animsType.get(anim) == ALL_STATES) {
				leFiles = [for (i in 0...spriteData.maxPressure + 1) {name: anim + i, type: ExplorerFileFileType.file, icon: 'animation'}];
			}
			if (animsType.get(anim) == ONLY_DEFEATED_STATES || animsType.get(anim) == ALL_STATES) {
				leFiles.push({name: anim + 'Null', type: ExplorerFileFileType.file, icon: 'animation'});
				leFiles.push({name: anim + 'Overinflated', type: ExplorerFileFileType.file, icon: 'animation'});
			}
		}
		for (leFolder in leFiles) {
			var leType:ExplorerFileFileType = leFolder.type;
			var template:String = 'silhouette';
			var leDefaultDimensions:Array<Int> = [];
			switch (leFolder.name) {
				case 'scraps':
					leDefaultDimensions = [180, 180];
					template = 'scrap';
				case 'cardBG':
					leDefaultDimensions = [140, 190];
					template = 'characterSelectCardBG';
				case 'cardCharIdle' | 'cardCharSelected':
					leDefaultDimensions = [140, 190];
					template = 'characterSelectCardCharacter';
				case 'bannerAppear' | 'bannerBlink':
					leDefaultDimensions = [320, 468];
					template = 'characterSelectBanner';
				default:
					leDefaultDimensions = [spriteData.defaultDimensions[0], spriteData.defaultDimensions[1]];
			}
			if (leType == file && !FileSystem.exists(getPath() + '/anims/${leFolder.name}.json')) {
				leType = emptyFile;
			}
			var icon = new ExplorerFile(explorerBG.x + (num % iconsPerRow) * ExplorerFile.size, explorerBG.y + Math.floor(num / iconsPerRow) * ExplorerFile.size, leFolder.name, leType, leFolder.icon);
			icon.tooltipText = Language.getPhrase('characterCreator.explorer.description.${leFolder.name}', [], '');
			icon.onClick = function() {
				switch (icon.fileType) {
					case folder:
						explorerCurPath = explorerCurPath + '${icon.name}/';
						explorerPathTxt.setPath(explorerCurPath);
						generateExplorer();
					case emptyFile:
						AnimationEditorState.frames = [null];
						AnimationEditorState.curFrame = 0;
						AnimationEditorState.animName = leFolder.name;
						AnimationEditorState.framerate = spriteData.defaultFramerate;
						AnimationEditorState.template = template;
						AnimationEditorState.animIsNew = true;
						openSubState(new SpriteBrowseImagePrompt(leDefaultDimensions[0], leDefaultDimensions[1], template));
					case file:
						AnimationEditorState.animName = leFolder.name;
						AnimationEditorState.curFrame = 0;
						AnimationEditorState.template = template;
						AnimationEditorState.animIsNew = false;
						SuffState.switchState(new AnimationEditorState());
				}
			}
			explorerFiles.add(icon);
			num++;
		}
		reloadExplorerDesc();
	}

	function reloadExplorerDesc() {
		explorerDescTxt.text = Language.getPhrase('characterCreator.explorer.description.' + explorerPathTxt.getLastPath(), [], '');
	}

	function reloadJSONData() {
		metadata = Json.parse(File.getContent(getPath() + '/metadata.json'));
		spriteData = Json.parse(File.getContent(getPath() + '/spriteData.json'));
	}

	function saveJSONData() {
		File.saveContent(UtilitiesBaseMenuState.loadedPath + '/metadata.json', haxe.Json.stringify(metadata, '\t'));
		File.saveContent(UtilitiesBaseMenuState.loadedPath + '/spriteData.json', haxe.Json.stringify(spriteData, '\t'));
	}

	private function getPath() {
		return UtilitiesBaseMenuState.loadedPath;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}

	public override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>) {
		if (id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText)) {
			if (sender == metadataNameInputText) {
				metadata.name = metadataNameInputText.text;
			} else if (sender == metadataDescInputText) {
				metadata.description = metadataDescInputText.text;
			} else if (sender == metadataAuthorInputText) {
				metadata.author = metadataAuthorInputText.text;
			}
		} else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is SuffUINumericStepper)) {
			if (sender == spriteDataDefaultFramerateStepper) {
				spriteData.defaultFramerate = Std.int(spriteDataDefaultFramerateStepper.value);
			} else if (sender == spriteDataMaxPressureStepper) {
				spriteData.maxPressure = Std.int(spriteDataMaxPressureStepper.value);
			} else if (sender == spriteDataMaxConfidenceStepper) {
				spriteData.maxConfidence = Std.int(spriteDataMaxConfidenceStepper.value);
			}
		}
	}

	public override function leaveMenu() {
		openSubState(new ChoicePrompt('characterCreator.exit.prompt', function() {
			SuffState.switchState(new UtilitiesMainMenuState());
		}));
	}
}
