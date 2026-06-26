package states;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.util.FlxGradient;
import states.MainMenuState;
import ui.objects.CreditsSketch;
import ui.objects.GameLogo;
import ui.objects.SuffIconButton;
import ui.objects.SuffScrollBar;

class CreditsState extends SuffState {
	var creditsTxt:Array<Array<Dynamic>> = [
		['', '', 'GAME_LOGO', Std.int(FlxG.height / 4)],
		['Design, Code, Art, Sound, Music', '', 'HEADING'],
		['NicklySuffer', 'nicklysuffer', 'LOGO'],
		['Original Concept', '', 'HEADING'],
		['Snowyboi', '', 'default'],
		['Additional Programmer', '', 'HEADING'],
		['changedinflation.de', '', 'default'],
		['Additional Music', '', 'HEADING'],
		['Ninshot At Dawn', '', 'default'],
		['Additional UI Art', '', 'HEADING'],
		['Globe-Freak', 'globe-freak', 'LOGO'],
		['Bloom', 'bloom', 'LOGO'],
		['Sound Source', '', 'HEADING'],
		['PixelCarnagee\n(OpenNSFW Sound Pack)', '', 'default'],
		['Runey\n(Balloonomatopoeia)', '', 'default'],
		['Developed With', '', 'HEADING'],
		['HaxeFlixel', 'haxeflixel', 'LOGO', Std.int(FlxG.height / 4)],
		[
			'Initially started as a joke, this project has been in continuous development for a while now. I would like to thank my fans for their support throughout the development of this game, as well as Discord members who provided feedback and ideas.',
			'',
			'default',
			Std.int(FlxG.height / 2)
		],
		[
			'Thanks For Playing!',
			'',
			'default',
			-Std.int(FlxG.height / 2)
		]
	];
	var creditsTxtGroup:FlxSpriteGroup = new FlxSpriteGroup();
	var leLineSpace:Int = 0;
	var imageList:Array<String> = [];

	var scrollBar:SuffScrollBar;

	override public function create():Void {
		Paths.clearUnusedMemory();
		Paths.clearStoredMemory();

		super.create();

		Window.setTitle(Language.getPhrase('creditsMenu.windowDisplay'));

		var bg:FlxSprite = new FlxSprite().loadGraphic(FlxGradient.createGradientBitmapData(FlxG.width, FlxG.height, [0xFF794080, 0xFF404080]));
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(64, 64, 128, 128, true, 0x40FFFFFF, 0x0));
		grid.velocity.set(64, 64);
		add(grid);

		var overlay = new FlxBackdrop(Paths.image('ui/transitions/horizontal'), Y);
		overlay.x = -overlay.width / 2 + (FlxG.width - overlay.width) / 2 + 40;
		overlay.velocity.set(0, 32);
		overlay.color = 0xFF0000FF;
		overlay.alpha = 0.25;
		add(overlay);

		SuffState.playMusic('credits');

		for (line in creditsTxt) {
			var leText:FlxSpriteGroup = new FlxSpriteGroup();

			var leCharSpace:Int = 32;
			var size:Int = 48;
			leText.x = 16;
			if (creditsTxt.indexOf(line) != 0) {
				if (line[2] == 'HEADING') {
					leLineSpace += 64;
					leCharSpace = 32;
				}
			}
			leText.y = leLineSpace;
			if (line[3] != null) {
				leLineSpace += line[3];
			}

			var leLogo = new FlxSprite(leCharSpace, 0);
			if (line[1] != '' || line[2] == 'GAME_LOGO' || line[2] == 'NICKLY_SUFFER') {
				var texturePath:String = 'ui/menus/credits/logos/${line[1]}';
				if (line[2] == 'NICKLY_SUFFER') {
					texturePath = 'ui/menus/nicklySufferLogo';
					leLogo.scale.set(8, 8);
				}
				if (line[2] == 'GAME_LOGO') {
					leLogo = new GameLogo(leCharSpace, 0);
				} else {
					leLogo.loadGraphic(Paths.image(texturePath));
					leLogo.updateHitbox();
				}
				leCharSpace += Std.int(leLogo.width + 10);
				leText.add(leLogo);
			}

			var leChar:FlxText = new FlxText(leCharSpace, 0, Std.int(FlxG.width * 0.5));
			if (line[2] != 'LOGO') {
				leChar.text = line[0];
				var leFont:String = line[2];
				var leSize:Int = size;
				var leColor:Int = FlxColor.WHITE;
				if (line[2] == 'HEADING' || line[0].length > 50)
					leSize = 32;
				if (line[2] == 'HEADING') {
					leFont = 'default';
					leColor = FlxColor.YELLOW;
				}
				leChar.setFormat(Paths.font(leFont, false), leSize, leColor);
			}
			if (leLogo.height > leChar.height) {
				leChar.y = (leLogo.height - leChar.height) / 2;
				leLineSpace += Std.int(leLogo.height + 16);
			} else {
				leLineSpace += Std.int(leChar.height + 16);
			}
			leText.add(leChar);

			creditsTxtGroup.add(leText);
		}
		creditsTxtGroup.x += ScreenSafeArea.X;

		var creditsUpperLimit = creditsTxtGroup.members[0].height / 2;
		var creditsLowerLimit = creditsTxtGroup.members[creditsTxtGroup.members.length - 1].height / 2;
		var creditsBounds = creditsTxtGroup.height - creditsUpperLimit + creditsLowerLimit;
		scrollBar = new SuffScrollBar(0, 0, function(percent:Float) {
			creditsTxtGroup.y = FlxMath.lerp(creditsUpperLimit, FlxG.height - (creditsTxtGroup.height + FlxG.height / 2), percent);
		}, FlxG.width / 2, creditsBounds);
		scrollBar.scrollInBG = true;
		scrollBar.scrollMultiplier = -FlxG.height / creditsBounds;
		scrollBar.autoScrollVelocity = 10;
		scrollBar.visible = false;
		add(scrollBar);

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

	var spawnSketchTime:Float = 0;

	override function update(elapsed:Float) {
		super.update(elapsed);

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
