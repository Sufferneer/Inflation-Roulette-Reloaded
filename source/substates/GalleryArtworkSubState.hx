package substates;

import ui.objects.SuffIconButton;
import ui.objects.GalleryArtwork;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import backend.typedefs.GalleryArtworkMetadata;
import tjson.TJSON as Json;

class GalleryArtworkSubState extends SuffSubState {
	var allowInput:Bool = false;
	var artworkGroup:FlxTypedSpriteGroup<GalleryArtwork> = new FlxTypedSpriteGroup<GalleryArtwork>();
	var envelopeID:String = '';
	var artwork:Array<String> = [];

	var leftButton:SuffIconButton;
	var rightButton:SuffIconButton;
	var exitButton:SuffIconButton;
	var title:FlxText;
	var description:FlxText;

	var curSelected:Int = 0;

	public function new(id:String, artwork:Array<String>) {
		super();

		this.envelopeID = id;
		this.artwork = artwork;
		persistentUpdate = false;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.625;
		add(bg);

		add(artworkGroup);
		for (num => art in artwork) {
			var art:GalleryArtwork = new GalleryArtwork(0, 0, '$id/$art');
			art.x = (FlxG.width - art.width) / 2 + FlxG.width * num;
			art.y = (FlxG.height - (art.height + 64)) / 2;
			artworkGroup.add(art);
		}
		artworkGroup.y = FlxG.height;
		FlxTween.tween(artworkGroup, {y: 0}, 0.25, {
			ease: FlxEase.quintOut
		});

		title = new FlxText(0, 0, FlxG.width * 0.5, '', 32);
		title.font = Paths.font('small', false);
		title.alignment = CENTER;
		title.screenCenter(X);
		add(title);

		description = new FlxText(0, 0, FlxG.width * 0.5, '', 32);
		description.font = Paths.font('small', false);
		description.alignment = JUSTIFY;
		description.screenCenter(X);
		add(description);

		leftButton = new SuffIconButton(20, 20, 'buttons/left', null, 2);
		leftButton.screenCenter();
		leftButton.x = (FlxG.width - leftButton.width) / 2 - FlxG.width * 0.375;
		leftButton.onClick = function() {
			changeSelection(-1);
		};
		add(leftButton);

		rightButton = new SuffIconButton(20, 20, 'buttons/right', null, 2);
		rightButton.screenCenter();
		rightButton.x = (FlxG.width - rightButton.width) / 2 + FlxG.width * 0.375;
		rightButton.onClick = function() {
			changeSelection(1);
		};
		add(rightButton);

		exitButton = new SuffIconButton(20, 20 + ScreenSafeZone.Y, 'buttons/exit', null, 2);
		exitButton.x = FlxG.width - exitButton.width - 20 - ScreenSafeZone.X;
		exitButton.onClick = function() {
			exitMenu();
		};
		add(exitButton);

		allowInput = true;
		changeSelection();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (!allowInput) return;
		if (Controls.justPressed('exit')) {
			exitMenu();
		}
	}

	function changeSelection(delta:Int = 0) {
		curSelected = FlxMath.wrap(curSelected + delta, 0, artworkGroup.members.length - 1);
		artworkGroup.x = curSelected * -FlxG.width;
		FlxTween.cancelTweensOf(artworkGroup);
		var artworkData:GalleryArtworkMetadata = cast Json.parse(Paths.getTextFromFile('data/extras/gallery/art/${envelopeID}/${artwork[curSelected]}.json'));
		description.text = artworkData.description;
		title.text = '(${curSelected + 1} / ${artwork.length})\n' + artworkData.title + ' - ' + artworkData.artist;
		artworkGroup.y = (title.height + description.height) / -4;
		var originalArtworkGroup = artworkGroup.y;
		title.y = Std.int(artworkGroup.members[curSelected].y + artworkGroup.members[curSelected].height);
		// description.updateHitbox();
		description.alignment = description.height <= 32 ? CENTER : JUSTIFY;
		description.y = title.y + title.height;

		artworkGroup.y += 20;
		FlxTween.tween(artworkGroup, {y: originalArtworkGroup}, 0.25, {
			ease: FlxEase.quintOut
		});
	}

	function exitMenu() {
		if (!allowInput) return;
		allowInput = false;
		persistentUpdate = true;
		close();
	}
}
