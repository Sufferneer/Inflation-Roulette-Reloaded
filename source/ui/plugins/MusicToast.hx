package ui.plugins;

import backend.typedefs.MusicMetadata;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxContainer.FlxTypedContainer;

class MusicToast extends FlxTypedContainer<FlxBasic> {
	public static var instance:Null<MusicToast> = null;

	public var musicToast:FlxSpriteGroup = new FlxSpriteGroup();
	public var record:FlxSpriteGroup = new FlxSpriteGroup();

	var bg:FlxSprite;
	// var nowPlayingText:FlxText;
	var songTitleText:FlxText;
	var recordBG:FlxSprite;
	var recordCover:FlxSprite;

	var songBPM:Float = 100;

	static final paddingX:Float = 10;
	static final paddingY:Float = 5;

	var totalElasped:Float = 0;

	public var leScale:Float = 1.2;

	public static var enabled:Bool = false;

	static final startDelay:Float = 0;
	static final moveInDuration:Float = 0.75;
	static final holdDuration:Float = 4;
	static final moveOutDuration:Float = 0.75;

	public function new() {
		super();

		FlxGraphic.defaultPersist = true;

		add(musicToast);
		musicToast.scrollFactor.set();

		bg = new FlxSprite().makeGraphic(1, 50, FlxColor.BLACK, 'plugins/musicToast/bg');
		bg.alpha = 0.75;
		bg.scrollFactor.set();
		musicToast.add(bg);

		// nowPlayingText = new FlxText(paddingX, paddingY, 0, '');
		// nowPlayingText.setFormat(Paths.font('default'), 16, FlxColor.WHITE, LEFT);
		// nowPlayingText.scrollFactor.set();
		// musicToast.add(nowPlayingText);

		songTitleText = new FlxText(paddingX, bg.height - paddingY, 0, '');
		songTitleText.y = Std.int((bg.height - songTitleText.height) / 2);
		songTitleText.setFormat(Paths.font('default', false), 16, FlxColor.WHITE, LEFT);
		songTitleText.scrollFactor.set();
		musicToast.add(songTitleText);

		musicToast.add(record);

		recordBG = new FlxSprite().loadGraphic(Paths.image('ui/musicToast/record'));

		bg.makeGraphic(Std.int(songTitleText.width + recordBG.width / 2 + paddingX), 50, FlxColor.BLACK);
		recordBG.scrollFactor.set();
		record.add(recordBG);

		recordCover = new FlxSprite().loadGraphic(Paths.image('ui/musicToast/covers/nicklysuffer'));
		recordCover.scrollFactor.set();
		record.add(recordCover);

		FlxGraphic.defaultPersist = false;
	}

	public static function initialize() {
		FlxG.plugins.drawOnTop = true;
		instance = new MusicToast();
		FlxG.plugins.add(instance);

		instance.musicToast.x = -FlxG.width;
	}

	public static function play(songMetadata:MusicMetadata) {
		if (instance == null || !Preferences.data.showMusicToast || Preferences.data.musicVolume <= 0 || songMetadata == null) {
			return;
		}
		var songTitle = songMetadata.name;
		var songAuthor = songMetadata.author;
		instance.songBPM = songMetadata.bpm;

		instance.songTitleText.text = '$songTitle - $songAuthor';

		instance.recordBG.loadGraphic(Paths.image('ui/musicToast/record'));
		instance.recordCover.loadGraphic(Paths.image('ui/musicToast/covers/${songAuthor.toLowerCase().replace(' ', '_')}'));

		instance.bg.makeGraphic(Std.int(instance.songTitleText.width + paddingX + instance.recordBG.width / 2 + paddingX), 50, FlxColor.BLACK);

		instance.record.angle = 0;
		instance.record.x = instance.musicToast.x + instance.bg.width - instance.record.width / 2;
		instance.record.y = instance.musicToast.y + (instance.bg.height - instance.record.height) / 2;

		instance.musicToast.x = -instance.musicToast.width;
		instance.musicToast.y = FlxG.height * 0.6 - (instance.bg.height - instance.recordBG.height) / 2 + instance.bg.height / 2;

		instance.totalElasped = 0;
		enabled = true;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (instance != null) {
			instance.record.angle += elapsed * 360 / (60 / songBPM * 2);
			instance.musicToast.camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
		}
		if (enabled && instance.totalElasped < 6) {
			instance.totalElasped += elapsed;
			if (instance.totalElasped >= startDelay && instance.totalElasped <= startDelay + moveInDuration) {
				instance.musicToast.x = -instance.musicToast.width
					+ instance.musicToast.width * FlxEase.quadOut((instance.totalElasped - startDelay) / moveInDuration);
			} else if (instance.totalElasped > startDelay + moveInDuration
				&& instance.totalElasped <= startDelay + moveInDuration + holdDuration) {
				instance.musicToast.x = 0;
			} else if (instance.totalElasped > startDelay + moveInDuration + holdDuration
				&& instance.totalElasped <= startDelay
					+ moveInDuration
					+ holdDuration
					+ moveOutDuration
					+ 0.25) {
				instance.musicToast.x = -instance.musicToast.width * FlxEase.quadIn((instance.totalElasped - startDelay - moveInDuration - holdDuration) / moveOutDuration);
			}
		}
		if (FlxG.mouse.overlaps(instance.record, instance.musicToast.camera) && FlxG.mouse.justPressed) {
			instance.leScale += 0.2;
			SuffState.playUISound(Paths.sound('ui/dong'));
			instance.totalElasped = Math.max(startDelay + moveInDuration, instance.totalElasped - 0.25);
		}
		instance.record.scale.set(instance.leScale, instance.leScale);
		instance.leScale = FlxMath.lerp(leScale, 1, elapsed * 14);
	}
}
