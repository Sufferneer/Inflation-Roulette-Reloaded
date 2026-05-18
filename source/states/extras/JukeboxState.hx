package states.extras;

import ui.objects.SuffIconButton;
import ui.objects.JukeboxRecord;
import ui.objects.JukeboxBar;
import flixel.group.FlxContainer.FlxTypedContainer;

class JukeboxState extends SuffState {
	var allowInput:Bool = false;

	var curPage:Int = 0;
	var maxPage:Int = 0;

	var bg:FlxSprite;
	var bgScale:FlxPoint;
	var albumText:FlxTypedContainer<FlxBackdrop> = new FlxTypedContainer<FlxBackdrop>();
	var barGroup:FlxTypedContainer<JukeboxBar> = new FlxTypedContainer<JukeboxBar>();
	var record:JukeboxRecord;
	var leftButton:SuffIconButton;
	var rightButton:SuffIconButton;
	var exitButton:SuffIconButton;

	override function create() {
		super.create();

		bg = new FlxSprite().loadGraphic(Paths.image('ui/menus/extras/jukebox/bg'));
		bg.origin.x = 0;
		bg.origin.y = bg.height / 2;
		bg.screenCenter();
		bgScale.set(FlxG.width / Constants.ORIGINAL_FLXG_WIDTH, FlxG.height / Constants.ORIGINAL_FLXG_HEIGHT);
		add(bg);

		add(albumText);
		for (i in 0...Math.ceil(FlxG.height / 64)) {
			var text = new FlxBackdrop(null, X, 64, 0);
			text.y = i * 64;
			text.velocity.x = 64 * (i % 2 == 0 ? -1 : 1);
			albumText.add(text);
		}

		record = new JukeboxRecord(FlxG.width, 0);
		record.x = (FlxG.width - record.width) / 2;
		record.y = -record.height;
		add(record);
		FlxTween.tween(record, {y: record.height * -0.525}, 1, {
			ease: FlxEase.quintOut
		});

		add(barGroup);
		var list:Array<String> = Utilities.textFileToArray('data/extras/jukebox/musicList.txt');
		for (num => item in list) {
			Paths.music(item);
			var bar:JukeboxBar = new JukeboxBar(0, FlxG.height, item);
			bar.x = (FlxG.width - bar.width) / 2;
			barGroup.add(bar);
		}
		curPage = list.indexOf(SuffState.currentMusicName);
		maxPage = list.length - 1;
		changePage();
		bg.color = FlxColor.fromString(barGroup.members[curPage].album.color);
		changeAlbumText(barGroup.members[curPage].album.name);

		leftButton = new SuffIconButton(20, 20, 'buttons/left', null, 2);
		leftButton.x = (FlxG.width - 600) / 2 + 20;
		leftButton.y = FlxG.height - leftButton.height - 20;
		leftButton.onClick = function() {
			changePage(-1);
		};
		add(leftButton);

		rightButton = new SuffIconButton(20, 20, 'buttons/right', null, 2);
		rightButton.x = (FlxG.width + 600) / 2 - rightButton.width - 20;
		rightButton.y = FlxG.height - leftButton.height - 20;
		rightButton.onClick = function() {
			changePage(1);
		};
		add(rightButton);

		exitButton = new SuffIconButton(20, 20 + ScreenSafeZone.Y, 'buttons/exit', null, 2);
		exitButton.x = FlxG.width - exitButton.width - 20 - ScreenSafeZone.X;
		exitButton.onClick = function() {
			exitMenu();
		};
		add(exitButton);

		allowInput = true;
	}

	function changeAlbumText(text:String = '') {
		var leText = new FlxText(0, 0, 0, text, 64);
		leText.font = Paths.font('default', false);
		leText.color = 0xFFFFFFFF;
		for (item in albumText) {
			item.loadGraphic(leText.graphic);
			item.alpha = 0.125;
		}
	}

	function changePage(delta:Int = 0) {
		curPage = FlxMath.wrap(curPage + delta, 0, maxPage);

		for (num => bar in barGroup.members) {
			FlxTween.cancelTweensOf(bar);
			FlxTween.tween(bar, {
				x: (FlxG.width - bar.width) / 2 + (num - curPage) * 597,
				y: FlxG.height - bar.height - 130 + (num - curPage == 0 ? 0 : 100)
			}, 0.75, {
				ease: FlxEase.quintOut
			});
			if (num == curPage) {
				bar.resetTextPanning();
				if (record.album != bar.music.album) {
					record.album = bar.music.album;
					FlxTween.cancelTweensOf(bg);
					FlxTween.color(bg, 0.5, bg.color, FlxColor.fromString(bar.album.color));
					changeAlbumText(bar.album.name);
				}
				SuffState.playMusic(bar.musicID, 1, false);
			} else {
				bar.initTextPanning();
			}
			record.angle = 0;
		}
	}

	function exitMenu() {
		if (!allowInput) return;
		allowInput = false;
		SuffState.switchState(new MainMenuState());
	}

	var bgShadowTick:Float = 0;
	final bgShadowSpawnTick:Float = 0.5;

	override function update(elapsed:Float) {
		super.update(elapsed);

		bgShadowTick += elapsed;
		if (bgShadowTick >= bgShadowSpawnTick) {
			bgShadowTick = 0;
			var bgShadow = new FlxSprite(bg.x, bg.y).loadGraphic(Paths.image('ui/menus/extras/jukebox/bg'));
			bgShadow.origin.x = bg.origin.x;
			bgShadow.origin.y = bg.origin.y;
			bgShadow.scale.x = bg.scale.x;
			bgShadow.scale.y = bg.scale.y;
			bgShadow.color = bg.color;
			bgShadow.alpha = 0;
			members.insert(members.indexOf(bg) + 1, bgShadow);
			FlxTween.tween(bgShadow, {'scale.x': bgShadow.scale.x * 1.5, 'scale.y': bgShadow.scale.y * 1.5, alpha: 0.25}, 2, {
				onComplete: function(_) {
					FlxTween.tween(bgShadow, {'scale.x': bgShadow.scale.x * 1.5, 'scale.y': bgShadow.scale.y * 1.5, alpha: 0}, 2, {
						onComplete: function(_) {
							bgShadow.destroy();
						}
					});
				}
			});
		}

		var leScale = Math.pow(Math.sin(SuffState.timePassedOnState * 0.25), 2);
		bg.scale.set(bgScale.x + 0.5 * leScale, bgScale.y + 0.5 * leScale);
		bg.alpha = 0.75 + leScale * 0.25;

		record.angle = (FlxG.sound.music.time - FlxG.sound.music.loopTime) / 1000 / (60 / SuffState.currentMusicBPM) * 45;

		if (allowInput && Controls.justPressed('exit')) {
			if (Controls.justPressed('left')) {
				changePage(-1);
			} else if (Controls.justPressed('right')) {
				changePage(1);
			} else if (Controls.justPressed('exit')) {
				exitMenu();
			}
		}
	}
}