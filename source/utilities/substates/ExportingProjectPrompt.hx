package utilities.substates;

import openfl.display.BitmapData;
import openfl.geom.Point;
import ui.objects.SuffBox;
import utilities.states.CharacterCreatorState;
import utilities.typedefs.SpriteProjectAnimData;
import openfl.display.PNGEncoderOptions;
import tjson.TJSON as Json;
import ui.objects.SuffBar;
import backend.typedefs.CharacterData;
import backend.typedefs.SkillData;
import backend.typedefs.SkillMetadata;
import backend.Skill;
import backend.typedefs.CharacterCosmeticData;
import backend.typedefs.AnimationData;
import backend.typedefs.AddonMetadata;

class ExportingProjectPrompt extends UtilitiesBaseMenuSubState {
	var exportingText:FlxText;
	var curSpriteSheet:Int = 0;
	var curAnim:Int = 0;
	var speen:FlxSprite;
	var bar:SuffBar;
	public static var allAnims:Array<String> = [];
	public static var exportedAnims:Array<String> = [];

	final boxWidth:Int = 720;

	var exportPath:String = Utilities.getExecutablePath(false) + '/export/';

	var characterName:String;
	var characterID:String;
	var characterDescription:String;
	var characterAuthor:String;
	var projectName:String;

	public function new() {
		exportedAnims = [];
		characterName = CharacterCreatorState.metadata.name;
		characterID = Utilities.spaceToDash(characterName).toLowerCase();
		characterDescription = CharacterCreatorState.metadata.description;
		characterAuthor = CharacterCreatorState.metadata.author;
		projectName = characterName + ' - ' + characterAuthor;

		super();
		persistentDraw = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bg.alpha = 0.75;
		add(bg);

		exportingText = new FlxText(0, 0, boxWidth - 64, 32);
		exportingText.text = Language.getPhrase('characterCreator.exporting', ['...']);
		exportingText.alignment = CENTER;

		var exportingDescription = new FlxText(0, 0, exportingText.width, Language.getPhrase('characterCreator.exporting.description'), 32);
		exportingDescription.alignment = CENTER;

		speen = new FlxSprite().loadGraphic(Paths.image('ui/menus/utilities/whatTheFuck'));
		speen.screenCenter(X);

		bar = new SuffBar(0, 0, function () {
			return exportedAnims.length / allAnims.length;
		}, 0, 1, Std.int(boxWidth - 64), 16, 4, 1, 0xFF000000, 0xFFFFFFFF);
		bar.screenCenter(X);

		var box:SuffBox = new SuffBox(0, 0, boxWidth, exportingText.height + exportingDescription.height + speen.height + bar.height + 128);
		box.screenCenter();
		add(box);
		exportingText.setPosition(box.x + 32, box.y + 32);
		exportingDescription.setPosition(box.x + 32, exportingText.y + exportingText.height + 32);
		speen.y = exportingDescription.y + exportingDescription.height + 32;
		bar.y = speen.y + speen.height;
		add(exportingText);
		add(exportingDescription);
		add(speen);
		add(bar);

		var animData:SpriteProjectAnimData = cast Json.parse(File.getContent(UtilitiesBaseMenuState.loadedPath + '/anims/cardCharIdle.json'));
		cardKeyframes += animData.keyframes.length;
		var animData:SpriteProjectAnimData = cast Json.parse(File.getContent(UtilitiesBaseMenuState.loadedPath + '/anims/cardCharSelected.json'));
		cardKeyframes += animData.keyframes.length;
		var animData:SpriteProjectAnimData = cast Json.parse(File.getContent(UtilitiesBaseMenuState.loadedPath + '/anims/bannerAppear.json'));
		bannerKeyframes += animData.keyframes.length;
		var animData:SpriteProjectAnimData = cast Json.parse(File.getContent(UtilitiesBaseMenuState.loadedPath + '/anims/bannerBlink.json'));
		bannerKeyframes += animData.keyframes.length;

		var what = newSpriteSheet(4096, 4096, CharacterCreatorState.spriteData.defaultDimensions[0], CharacterCreatorState.spriteData.defaultDimensions[1]);
		baseBitmap = what[0];
		baseXML = what[1];
		new FlxTimer().start(0.02, function(_) {
			export();
		});
	}

	var cardKeyframes:Int = 0;
	var bannerKeyframes:Int = 0;

	function exportSpriteSheet(bitmap:BitmapData, xml:String, directory:String, name:String) {
		var bytes = bitmap.encode(bitmap.rect, new PNGEncoderOptions());
		if (!FileSystem.isDirectory(directory) || !FileSystem.exists(directory)) {
			FileSystem.createDirectory(directory);
		}
		File.saveBytes('$directory/$name.png', bytes);
		if (xml != null) {
			xml += '</TextureAtlas>';
			File.saveContent('$directory/$name.xml', xml);
		}
	}

	var animationDataArray:Array<AnimationData> = [];

	function convertSkillData(skills:Array<String>) {
		var What:Array<SkillData> = [];
		for (skill in skills) {
			var SkillMetadata:SkillMetadata = cast Json.parse(Paths.getTextFromFile('data/skills/' + skill + '.json'));
			var skillData:SkillData = {
				id: skill,
				cost: SkillMetadata.defaultCost
			};
			What.push(skillData);
		}
		return What;
	}

	function generateJsonData() {
		exportingText.text = Language.getPhrase('characterCreator.exporting.generatingCharacterData');
		var stats:CharacterData = {
			id: characterID,
			maxPressure: CharacterCreatorState.spriteData.maxPressure,
			maxConfidence: CharacterCreatorState.spriteData.maxConfidence,
			skills: convertSkillData(CharacterCreatorState.spriteData.skills),
			modifiers: []
		};
		var cosmetic:CharacterCosmeticData = {
			spriteSheets: [for (i in 0...curSpriteSheet) '$i'],
			animations: animationDataArray,
			belchThreshold: Std.int(stats.maxPressure * 0.5),
			gurgleThreshold: Std.int(stats.maxPressure * 0.5),
			creakThreshold: Math.ceil(stats.maxPressure * 0.75),
			antialiasing: false,
			disablePopping: false,
			originPosition: [
				Std.int(CharacterCreatorState.spriteData.defaultDimensions[0] / 2),
				Std.int(CharacterCreatorState.spriteData.defaultDimensions[1] * 0.9)
			],
			cameraOffset: [0, Std.int(CharacterCreatorState.spriteData.defaultDimensions[1] / -2)],
			poppedCameraOffset: [0, Std.int(CharacterCreatorState.spriteData.defaultDimensions[1] * -0.2)],
			headParticlePosition: [0, 0],
			poppingVelocityMultiplier: [1.0, 1.0],
			poppingGravityMultiplier: 1.0
		};

		if (!FileSystem.isDirectory('exports/$projectName/data/characters/$characterID') || !FileSystem.exists('exports/$projectName/data/characters/$characterID'))
			FileSystem.createDirectory('exports/$projectName/data/characters/$characterID');
		File.saveContent('exports/$projectName/data/characters/$characterID/stats.json', haxe.Json.stringify(stats, '\t'));
		File.saveContent('exports/$projectName/data/characters/$characterID/cosmetic.json', haxe.Json.stringify(cosmetic, '\t'));

		new FlxTimer().start(0.02, function(_) {
			generateLangFile();
		});
	}

	function generateLangFile() {
		exportingText.text = Language.getPhrase('characterCreator.exporting.generatingLangFile');
		var langFile:String = '';
		langFile += 'character.$characterID.name = $characterName\n';
		langFile += 'character.$characterID.name.short = ${characterName.split(' ')[0]}\n';
		langFile += 'character.$characterID.description = $characterDescription\n';

		if (!FileSystem.isDirectory('exports/$projectName/lang') || !FileSystem.exists('exports/$projectName/lang'))
			FileSystem.createDirectory('exports/$projectName/lang');
		File.saveContent('exports/$projectName/lang/${Preferences.data.language}.lang', langFile);
		File.saveContent('exports/$projectName/lang/en-us.lang', langFile);

		new FlxTimer().start(0.02, function(_) {
			generateAddonMetadata();
		});
	}

	function generateAddonMetadata() {
		exportingText.text = Language.getPhrase('characterCreator.exporting.generatingAddonMetadata');
		var metadata:AddonMetadata = {
			name: characterName,
			description: characterDescription + '\nCreated by IRR Character Creator',
			authors: [
				[characterAuthor, 'Author']
			],
			color: '#808080'
		};

		if (!FileSystem.isDirectory('exports/$projectName/metadata') || !FileSystem.exists('exports/$projectName/metadata'))
			FileSystem.createDirectory('exports/$projectName/metadata');
		File.saveContent('exports/$projectName/metadata/metadata.json', haxe.Json.stringify(metadata, '\t'));

		new FlxTimer().start(0.02, function(_) {
			sucessfulExport();
		});
	}

	function insertLineInXML(xml:String, name:String, frame:Int, x:Float, y:Float, width:Int, height:Int) {
		var frame:String = '$frame'.lpad('0', 4);
		xml += '\t<SubTexture name="${name}${frame}" x="${Std.int(x)}" y="${Std.int(y)}" width="${width}" height="${height}"/>\n';
		return xml;
	}

	function newSpriteSheet(width:Int = 4096, height:Int = 4096, spriteWidth:Int = 640, spriteHeight:Int = 640):Array<Dynamic> {
		var bitmap = new BitmapData(width, height, true, 0x00000000);
		var xml = '<?xml version="1.0" encoding="utf-8"?>\n<TextureAtlas imagePath="$curSpriteSheet.png">\n\t<!-- Created with IRR Character Creator version 1.0.0 -->\n';
		baseBitmapSpritesLeft = Std.int(width / spriteWidth) * Std.int(height / spriteHeight);
		return [bitmap, xml];
	}
	var baseBitmapSpritesLeft = 36;
	var baseBitmap:BitmapData;
	var baseXML:String = '';
	var basePointer:Point = new Point(0, 0);

	var secBitmap:BitmapData;
	var secXML:String = '';
	var secPointer:Point = new Point(0, 0);

	function export() {
		if (curAnim == allAnims.length) {
			new FlxTimer().start(0.02, function(_) {
				exportSpriteSheet(baseBitmap, baseXML, 'exports/$projectName/images/game/characters/$characterID', '$curSpriteSheet');
				curSpriteSheet++;
				generateJsonData();
			});
			return;
		}
		var exportingAnim = allAnims[curAnim];
		exportingText.text = Language.getPhrase('characterCreator.exporting', [exportingAnim]);
		var animData:SpriteProjectAnimData = cast Json.parse(File.getContent(UtilitiesBaseMenuState.loadedPath + '/anims/$exportingAnim.json'));
		
		switch (exportingAnim) {
			case 'scraps':
				var pointer:Point = new Point(0, 0);
				var what = newSpriteSheet(180 * animData.numFrames, 180, 180, 180);
				var base:BitmapData = what[0];
				for (i in 0...animData.numFrames) {
					var sprite:BitmapData = BitmapData.fromFile(UtilitiesBaseMenuState.loadedPath + '/sprites/$exportingAnim/$i.png');
					base.copyPixels(sprite, sprite.rect, pointer);
					pointer.x += sprite.width;
				}
				exportSpriteSheet(base, null, 'exports/$projectName/images/game/particles/scraps', '$characterID');
			case 'cardBG':
				var what = newSpriteSheet(150, 200, 150, 200);
				var base:BitmapData = what[0];
				var sprite:BitmapData = BitmapData.fromFile(UtilitiesBaseMenuState.loadedPath + '/sprites/$exportingAnim/0.png');
				base.copyPixels(sprite, sprite.rect, new Point(5, 5));
				exportSpriteSheet(base, null, 'exports/$projectName/images/ui/menus/characterSelect/cards/$characterID', 'bg');
			case 'cardCharIdle':
				secPointer.x = 5;
				secPointer.y = 5;
				var leAnimName:String = 'idle';
				var what = newSpriteSheet(150 * cardKeyframes, 200, 150, 200);
				secBitmap = what[0];
				secXML = what[1];
				for (i in 0...animData.numFrames) {
					secXML = insertLineInXML(secXML, leAnimName, i, secPointer.x - 5, secPointer.y - 5, 150, 200);
					if (animData.keyframes.contains(i)) {
						var sprite:BitmapData = BitmapData.fromFile(UtilitiesBaseMenuState.loadedPath + '/sprites/$exportingAnim/$i.png');
						secBitmap.copyPixels(sprite, sprite.rect, secPointer);
						secPointer.x += 150;
					}
				}
			case 'cardCharSelected':
				var leAnimName:String = 'selected';
				for (i in 0...animData.numFrames) {
					secXML = insertLineInXML(secXML, leAnimName, i, secPointer.x - 5, secPointer.y - 5, 150, 200);
					if (animData.keyframes.contains(i)) {
						var sprite:BitmapData = BitmapData.fromFile(UtilitiesBaseMenuState.loadedPath + '/sprites/$exportingAnim/$i.png');
						secBitmap.copyPixels(sprite, sprite.rect, secPointer);
						secPointer.x += 150;
					}
				}
				exportSpriteSheet(secBitmap, secXML, 'exports/$projectName/images/ui/menus/characterSelect/cards/$characterID', 'character');
			case 'bannerAppear':
				secPointer.x = 0;
				secPointer.y = 0;
				var leAnimName:String = 'start';
				var what = newSpriteSheet(320 * bannerKeyframes, 468, 320, 468);
				secBitmap = what[0];
				secXML = what[1];
				for (i in 0...animData.numFrames) {
					secXML = insertLineInXML(secXML, leAnimName, i, secPointer.x, secPointer.y, 320, 468);
					if (animData.keyframes.contains(i)) {
						var sprite:BitmapData = BitmapData.fromFile(UtilitiesBaseMenuState.loadedPath + '/sprites/$exportingAnim/$i.png');
						secBitmap.copyPixels(sprite, sprite.rect, secPointer);
						secPointer.x += 320;
					}
				}
			case 'bannerBlink':
				var leAnimName:String = 'idle';
				for (i in 0...animData.numFrames) {
					secXML = insertLineInXML(secXML, leAnimName, i, secPointer.x, secPointer.y, 320, 468);
					if (animData.keyframes.contains(i)) {
						var sprite:BitmapData = BitmapData.fromFile(UtilitiesBaseMenuState.loadedPath + '/sprites/$exportingAnim/$i.png');
						secBitmap.copyPixels(sprite, sprite.rect, secPointer);
						secPointer.x += 320;
					}
				}
				exportSpriteSheet(secBitmap, secXML, 'exports/$projectName/images/ui/menus/characterSelect/banners', '$characterID');
			default:
				var sprite:BitmapData = BitmapData.fromFile(UtilitiesBaseMenuState.loadedPath + '/sprites/$exportingAnim/0.png');
				var prevKeyframe:Int = -1;
				for (i in 0...animData.numFrames) {
					trace(exportingAnim, i);
					if (baseBitmapSpritesLeft - animData.keyframes.length < 0) {
						exportSpriteSheet(baseBitmap, baseXML, 'exports/$projectName/images/game/characters/$characterID', '$curSpriteSheet');
						trace(exportingAnim, 'new spritesheet!!!');
						curSpriteSheet++;
						var what = newSpriteSheet(4096, 4096, CharacterCreatorState.spriteData.defaultDimensions[0], CharacterCreatorState.spriteData.defaultDimensions[1]);
						baseBitmap = what[0];
						baseXML = what[1];
						basePointer.x = 0;
						basePointer.y = 0;
					}
					if (animData.keyframes.contains(i)) {
						trace(exportingAnim, 'export keyframe');
						if (prevKeyframe != i) {
							prevKeyframe = i;
							basePointer.x += sprite.width;
							if (basePointer.x > baseBitmap.width - sprite.width) {
								basePointer.x = 0;
								basePointer.y += sprite.height;
							}
							if (basePointer.y > baseBitmap.height - sprite.height) {
								exportSpriteSheet(baseBitmap, baseXML, 'exports/$projectName/images/game/characters/$characterID', '$curSpriteSheet');
								trace(exportingAnim, 'new spritesheet!!!');
								curSpriteSheet++;
								var what = newSpriteSheet(4096, 4096, CharacterCreatorState.spriteData.defaultDimensions[0], CharacterCreatorState.spriteData.defaultDimensions[1]);
								baseBitmap = what[0];
								baseXML = what[1];
								basePointer.x = 0;
								basePointer.y = 0;
							}
							sprite = BitmapData.fromFile(UtilitiesBaseMenuState.loadedPath + '/sprites/$exportingAnim/$i.png');
							baseBitmapSpritesLeft--;
						}
					}
					baseBitmap.copyPixels(sprite, sprite.rect, basePointer);
					// Yeah it copies every frame but it works
					baseXML = insertLineInXML(baseXML, exportingAnim, i, basePointer.x, basePointer.y, sprite.width, sprite.height);
				}
				var exportedAnimData:AnimationData = {
					name: exportingAnim,
					prefix: exportingAnim,
					fps: animData.framerate,
					indices: [],
					loop: false,
					soundPaths: []
				};
				animationDataArray.push(exportedAnimData);
		}
		exportedAnims.push(exportingAnim);
		bar.updateBar();
		curAnim++;
		new FlxTimer().start(FlxG.elapsed, function(_) {
			export();
		});
	}

	function sucessfulExport() {
		openSubState(new GenericPrompt(Language.getPhrase('characterCreator.exportSuccessful.prompt', [exportPath + '/' + projectName]), function() {
			close();
		}));
	}

	override function update(elapsed:Float) {
		speen.angle += 720 * elapsed;
		super.update(elapsed);
	}
}
