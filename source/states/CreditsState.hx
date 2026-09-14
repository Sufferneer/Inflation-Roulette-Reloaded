package states;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.util.FlxGradient;
import states.MainMenuState;
import ui.objects.CreditsSketch;
import ui.objects.GameLogo;
import ui.objects.SuffIconButton;
import ui.objects.SuffScrollBar;
import backend.typedefs.CreditsTextData;
import haxe.Json;
import substates.HyperlinkPrompt;
import shaders.OutlineShader;

class CreditsState extends SuffState {
	var creditsTxt:Array<CreditsTextData> = [];
	var creditsTxtGroup:FlxSpriteGroup = new FlxSpriteGroup();
	var leLineSpace:Int = 0;
	var imageList:Array<String> = [];

	var scrollBar:SuffScrollBar;
	
	var curCreditsArtId:String = '';
	var creditsArt:FlxSprite;

	override public function create():Void {
		Paths.clearUnusedMemory();
		Paths.clearStoredMemory();

		creditsTxt = Json.parse(Paths.getTextFromFile('data/credits.json', false));
		super.create();

		WindowUtil.setTitle(Language.getPhrase('creditsMenu.windowDisplay'));

		var bg:FlxSprite = new FlxSprite().loadGraphic(FlxGradient.createGradientBitmapData(FlxG.width, FlxG.height, [0xFF794080, 0xFF404080]));
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(64, 64, 128, 128, true, 0x40FFFFFF, 0x0));
		grid.velocity.set(64, 64);
		add(grid);

		var overlay = new FlxBackdrop(Paths.getImage('ui/transitions/horizontal'), Y);
		overlay.x = -overlay.width / 2 + (FlxG.width - overlay.width) / 2 + 40;
		overlay.velocity.set(0, 32);
		overlay.color = 0xFF0000FF;
		overlay.alpha = 0.25;
		add(overlay);

		SuffState.playMusic('credits');

		for (index => line in creditsTxt) {
			var leText:FlxSpriteGroup = new FlxSpriteGroup();

			var lineText:String = line.text ?? '';
			var lineGraphicPath:String = line.graphic ?? '';
			var lineType:String = line.type ?? 'default';
			var lineSpacing:Null<Int> = line.spacing;
			var lineLink:String = line.link ?? '';
			var lineArtId:String = line.artId ?? '';

			var leCharSpace:Int = 32;
			var size:Int = 48;
			leText.x = 16;
			if (index != 0) {
				if (lineType == 'HEADING') {
					leLineSpace += 64;
					leCharSpace = 32;
				}
			}
			leText.y = leLineSpace;
			leLineSpace += lineSpacing ?? 0;

			var leLogo = new FlxSprite(leCharSpace, 0);
			if (lineGraphicPath != '' || lineType == 'GAME_LOGO') {
				var texturePath:String = 'ui/menus/credits/logos/$lineGraphicPath';
				if (lineType == 'GAME_LOGO') {
					leLogo = new GameLogo(leCharSpace, 0);
				} else {
					leLogo.loadGraphic(Paths.getImage(texturePath));
					leLogo.updateHitbox();
				}
				leCharSpace += Std.int(leLogo.width + 10);
				leText.add(leLogo);
			}

			var leChar:FlxText = new FlxText(leCharSpace, 0);
			if (lineType != 'LOGO') {
				leChar.text = lineText;
				var leSize:Int = size;
				var leColor:Int = FlxColor.WHITE;
				if (lineType == 'HEADING' || lineText.length > 50)
					leSize = 32;
				if (lineType == 'HEADING')
					leColor = FlxColor.YELLOW;
				if (leChar.width > FlxG.width / 2 - 32)
					leChar.fieldWidth = FlxG.width / 2 - 32;
				leChar.setFormat(Paths.getFont('default', false), leSize, leColor);
			}
			if (leLogo.height > leChar.height) {
				leChar.y = (leLogo.height - leChar.height) / 2;
				leLineSpace += Std.int(leLogo.height + 16);
			} else {
				leLineSpace += Std.int(leChar.height + 16);
			}
			leText.add(leChar);
			
			if (lineLink != '' || lineArtId != '') {
				var leButton:SuffButton = new SuffButton(32, 0, leText.width, leText.height, false);
				if (lineLink != '') {
					var usedString = lineArtId != '' ? lineArtId : lineText;
					leButton.onClick = function() {
						if (curCreditsArtId != usedString)
							loadCreditsArt(usedString); else
							openSubState(new HyperlinkPrompt(lineLink));
					};
				}
				leText.add(leButton);
			}

			creditsTxtGroup.add(leText);
		}
		creditsTxtGroup.x += ScreenSafeArea.X;

		var creditsUpperLimit = (FlxG.height - creditsTxtGroup.members[0].height) / 2;
		var creditsLowerLimit = FlxG.height - creditsTxtGroup.height - (FlxG.height - creditsTxtGroup.members[creditsTxtGroup.members.length - 1].height) / 2;
		scrollBar = new SuffScrollBar(0, 0, function(percent:Float) {
			creditsTxtGroup.y = FlxMath.lerp(creditsUpperLimit, creditsLowerLimit, percent);
		}, FlxG.width / 2, creditsLowerLimit - creditsUpperLimit);
		scrollBar.scrollInBG = true;
		scrollBar.scrollMultiplier = FlxG.height / (creditsLowerLimit - creditsUpperLimit);
		scrollBar.autoScrollVelocity = 10;
		scrollBar.visible = false;
		add(scrollBar);

		creditsArt = new FlxSprite();
		if (Preferences.data.enableGLSL) {
			var outlineShader = new OutlineShader(0xFFFFFFFF, 5);
			outlineShader.lineBoil = true;
			outlineShader.lineBoilStep = 6;
			creditsArt.shader = outlineShader;
		}
		creditsArt.visible = false;
		add(creditsArt);

		add(creditsTxtGroup);

		var exitButton = new SuffIconButton(20, 20 + ScreenSafeArea.Y, 'buttons/exit', null, 2);
		exitButton.x = FlxG.width - exitButton.width - 20 - ScreenSafeArea.X;
		exitButton.onClick = function() {
			exitMenu();
		};
		add(exitButton);

		imageList = Paths.readDirectories('images/ui/menus/credits/sketches', 'images/ui/menus/credits/sketches/sketchesList.txt', 'png');
	}

	function exitMenu() {
		SuffState.playMusic('mainMenu');
		SuffState.switchState(new MainMenuState());
	}
	
	var creditsArtTimer:FlxTimer;
	
	function loadCreditsArt(artId:String = 'nicklysuffer') {
		if (curCreditsArtId == artId)
			return;
		curCreditsArtId = artId;
		FlxTween.cancelTweensOf(creditsArt);
		if (creditsArtTimer != null)
			creditsArtTimer.cancel();
		if (artId == '') {
			FlxTween.tween(creditsArt, {x: FlxG.width}, 0.5, {
				ease: FlxEase.cubeIn
			});
			return;
		}
		var graphic = Paths.getImage('ui/menus/credits/art/$artId');
		if (graphic == null) graphic = Paths.getImage('ui/menus/credits/art/empty');
		creditsArt.loadGraphic(graphic);
		creditsArt.scale.set(0.8, 0.8);
		creditsArt.updateHitbox();
		creditsArt.x = FlxG.width / 2 / Math.sqrt(creditsArt.scale.x) + (FlxG.width / 2 * Math.sqrt(creditsArt.scale.x) - creditsArt.width) / 2;
		creditsArt.y = FlxG.height - creditsArt.height + 50;
		creditsArt.visible = true;
		FlxTween.tween(creditsArt, {y: FlxG.height - creditsArt.height}, 0.5, {
			ease: FlxEase.cubeOut
		});

		creditsArtTimer = new FlxTimer().start(8, function(_) loadCreditsArt(''));
	}

	var spawnSketchTime:Float = 0;

	public override function update(elapsed:Float) {
		super.update(elapsed);
		
		if (creditsArt.shader != null) {
			var outlineShader:OutlineShader = cast creditsArt.shader;
			outlineShader.update(elapsed);
		}

		if (spawnSketchTime <= 0) {
			insert(members.indexOf(creditsTxtGroup) - 1, new CreditsSketch(imageList[FlxG.random.int(0, imageList.length - 1)]));
			spawnSketchTime = FlxG.random.float() * 0.25;
		} else {
			spawnSketchTime -= elapsed;
		}

		if (Controls.justPressed('exit')) {
			exitMenu();
		}
	}
}
