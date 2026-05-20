package ui;

import backend.enums.SuffTransitionStyle;
import ui.objects.SuffTransitionBlock;
import ui.SuffSubState;

class SuffTransition extends SuffSubState {
	public static var finishCallback:Void->Void;
	public static var style:SuffTransitionStyle = DEFAULT;
	public static var showLoadingText:Bool = false;

	private var leTween:FlxTween = null;

	var isTransIn:Bool = false;
	var trans:FlxSpriteGroup = new FlxSpriteGroup();
	var loadingTxt:FlxText;

	var duration:Float = 0;

	static final widthHeightGCF:Int = 80;

	// Tiles
	var blockDuration:Float = 0;
	var transitionProgess:Float = 0;
	var durationPerBlock:Float = 0;
	var curBlock:Int = 0;

	// Fade
	var blackFade:FlxSprite;

	// Intermission
	final bandCount:Int = 12;
	final bandDecayDuration:Float = 60 / 140 / 4 * 6;
	var curBand:Int = 0;

	static final blockSize:Int = 160;

	static final randomLoadingLines:Array<String> = [
		'Loading',
		'Please wait',
		'Please be patient',
		'Setting things up',
		'Tidying furniture',
		'Scavenging weapons',
		'Recasing bullets',
		'Patching abdomens',
		'Interviewing participants',
		'Deflating participants',
		'Preparing refreshments',
		'Spiking refreshments'
	];

	static final randomLoadingLinesRare:Array<String> = [
		'Unloading then reloading everything',
		'Collecting tears',
		'Calling the police',
		'Running the hell machine',
		'Preparing for the DSE',
		'Wasting time',
		'Creating more bugs',
		'Fixing addon support',
		'Dark was the night',
		'Cold was the ground',
		'This game is 10 days overdue'
	];

	public function new(duration:Float, isTransIn:Bool) {
		super();

		this.isTransIn = isTransIn;
		this.duration = duration;

		trans.scrollFactor.set();
		add(trans);

		switch (style) {
			case DEFAULT:
				var tran:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/transitions/default'));
				tran.setGraphicSize(Std.int(tran.width * FlxG.width / 1280), Std.int(tran.height * FlxG.height / 720));
				tran.updateHitbox();
				tran.color = 0xFF000000;
				trans.add(tran);
			case TILES:
				var imageList = Paths.readDirectories('images/ui/transitions/tiles', 'images/ui/transitions/tiles/tileList.txt', 'png');

				for (h in 0...Math.ceil(FlxG.height / blockSize) + 1) {
					for (w in 0...Math.ceil(FlxG.width / blockSize) + 1) {
						var tran:SuffTransitionBlock = new SuffTransitionBlock(w * blockSize,
							h * blockSize, imageList[FlxG.random.int(0, imageList.length - 1)], blockSize,
							(w + h) % 2 == 0 ? 0xFF202020 : 0xFF404040);
						tran.x += (FlxG.width - blockSize * Math.ceil(FlxG.width / blockSize)) / 2;
						tran.y += (FlxG.height - blockSize * Math.ceil(FlxG.height / blockSize)) / 2;
						tran.visible = isTransIn;
						trans.add(tran);
					}
				}
			case FADE:
			// No
			case INTERMISSION:
				if (FlxG.sound.music != null) {
					SuffState.playMusic('null');
					FlxG.sound.music.stop();
					FlxG.sound.music = null;
				}
				var what:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFF0040);
				what.alpha = 0.25;
				what.visible = !isTransIn;
				members.insert(members.indexOf(trans) - 1, what);

				for (i in 0...bandCount) {
					var band:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, Std.int(FlxG.height / bandCount), 0xFF000000);
					band.y += band.height * i;
					band.visible = isTransIn;
					trans.add(band);
				}
		}

		var leText = '';
		if (FlxG.random.bool(25)) {
			leText = randomLoadingLinesRare[FlxG.random.int(0, randomLoadingLinesRare.length - 1)];
		} else {
			leText = randomLoadingLines[FlxG.random.int(0, randomLoadingLines.length - 1)];
		}

		loadingTxt = new FlxText(0, 0, FlxG.width / 2, leText.toUpperCase() + '...');
		loadingTxt.setFormat(Paths.font('default'), 72, FlxColor.WHITE);
		loadingTxt.setPosition(72, FlxG.height - 72 - loadingTxt.height);
		add(loadingTxt);
		loadingTxt.visible = false;

		runTransition(isTransIn, style, showLoadingText);

		camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
	}

	function runTransition(transIn:Bool, style:SuffTransitionStyle = DEFAULT, showLoadingText:Bool = false) {
		switch (style) {
			case DEFAULT:
				if (!transIn) {
					trans.y = -trans.height;
					FlxTween.tween(trans, {y: -widthHeightGCF}, duration, {
						onComplete: function(twn:FlxTween) {
							startLoading(showLoadingText);
						},
						ease: FlxEase.quadIn
					});
				} else {
					endLoading();
					trans.y = -widthHeightGCF;
					leTween = FlxTween.tween(trans, {y: FlxG.height}, duration, {
						onComplete: function(twn:FlxTween) {
							this.close();
						},
						ease: FlxEase.quadOut
					});
				}
			case TILES:
				var usedDuration:Float = duration * 5;
				durationPerBlock = usedDuration / (trans.members.length - 1);
				if (!transIn) {
					FlxTween.num(0, 1, usedDuration, {
						onComplete: function(_) {
							startLoading(showLoadingText);
						}
					}, function(value:Float) {
						transitionProgess = value;
					});
				} else {
					endLoading();
					FlxTween.num(0, 1, usedDuration, {
						onComplete: function(_) {
							close();
						}
					}, function(value:Float) {
						transitionProgess = value;
					});
				}
			case FADE:
				if (!transIn) {
					FlxG.camera.fade(0xFF000000, duration * 1.5, function() {
						startLoading(showLoadingText);
					});
				} else {
					endLoading();
					FlxG.camera.fade(0xFF000000, duration * 1.5, true, function() {
						close();
					});
				}
			case INTERMISSION:
				if (!transIn) {
					SuffState.playUISound(Paths.sound('ui/mainMenu/easterEgg'));
					new FlxTimer().start(0.625, function(_) {
						FlxTween.num(0, 1, bandDecayDuration, {
							onComplete: function(_) {
								startLoading(false);
							}
						}, function(value:Float) {
							transitionProgess = value;
						});
					});
				} else {
					close();
				}
		}
	}

	function updateTransition(elapsed:Float, style:SuffTransitionStyle = DEFAULT) {
		switch (style) {
			default:
				// Nothing to update, yet
			case TILES:
				blockDuration += elapsed;
				if (blockDuration >= durationPerBlock) {
					for (_ in 0...Math.ceil(blockDuration / durationPerBlock)) {
						if (curBlock < trans.members.length) {
							trans.members[curBlock].visible = !isTransIn;
							curBlock++;
							SuffState.playUISound(Paths.soundRandom('ui/transition/pop', 1, 5), FlxG.random.float(0.25, 0.75), FlxG.random.float(2, 3));
						}
					}
					blockDuration = 0;
				}
			case INTERMISSION:
				for (num => item in trans.members) {
					item.visible = transitionProgess > num / bandCount;
				}
		}
	}

	function startLoading(showText:Bool = true) {
		// CursorHandler.cursorVisible = false;
		Paths.clearUnusedMemory();
		if (finishCallback != null) {
			loadingTxt.visible = showText;
			finishCallback();
		}
	}

	function endLoading() {
		// CursorHandler.cursorVisible = true;
		loadingTxt.visible = false;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		updateTransition(elapsed, style);
	}
}
