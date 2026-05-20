package utilities.states;

import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import ui.objects.SuffIconButton;
import utilities.substates.SpriteBrowseImagePrompt;
import utilities.objects.FrameTimeBar;
import openfl.utils.ByteArray;
import ui.addons.SuffUIButton;
import utilities.typedefs.SpriteProjectAnimData;
import openfl.display.PNGEncoderOptions;
import ui.addons.SuffUINumericStepper;
import utilities.substates.ChoicePrompt;
import utilities.states.CharacterCreatorState;
import flixel.addons.ui.FlxUIInputText;
import substates.GenericPrompt;
import haxe.Exception;
import utilities.substates.ErrorPrompt;
import flixel.addons.ui.FlxUINumericStepper;

class AnimationEditorState extends UtilitiesBaseMenuState {
	public static var frames:Array<FlxGraphic> = [null];
	public static var curFrame = 0;
	static var anim:FlxSprite;
	static final animHeight = 540;
	static final sideBarWidth = 80;
	static final frameHeight = 32;
	static final frameWidth = 12;
	var playing(default, set):Bool = false;

	var playButton:SuffIconButton;
	var prevFrameButton:SuffIconButton;
	var nextFrameButton:SuffIconButton;
	var firstFrameButton:SuffIconButton;
	var lastFrameButton:SuffIconButton;
	static var framePointer:FlxSprite;
	var frameLeftBar:FlxSprite;
	var frameRightBar:FlxSprite;
	var frameTimeBar:FrameTimeBar;

	static var frameGroup:FlxSpriteGroup = new FlxSpriteGroup();

	public static var animName:String = '';
	public static var framerate:Int = 24;
	public static var template:String = 'silhouette';
	public static var animIsNew:Bool = false;

	function saveAnimData() {
		try {
			var leKeyframes:Array<Int> = [];
			for (num => graphic in frames) {
				if (graphic != null) {
					var daBitmap = graphic.bitmap;
					var bytes:ByteArray = daBitmap.encode(daBitmap.rect, new PNGEncoderOptions());
					var dir = UtilitiesBaseMenuState.loadedPath + '/sprites/${animName}';
					if (!FileSystem.exists(dir))
						FileSystem.createDirectory(dir);
					File.saveBytes('$dir/$num.png', bytes);
					leKeyframes.push(num);
				}
			}

			var json = {
				framerate: AnimationEditorState.framerate,
				numFrames: frames.length,
				keyframes: leKeyframes
			}
			File.saveContent(UtilitiesBaseMenuState.loadedPath + '/anims/${animName}.json', haxe.Json.stringify(json, '\t'));
			openSubState(new GenericPrompt('animationCreator.saveSuccessful.prompt'));
		} catch(e:Dynamic) {
			openSubState(new ErrorPrompt(e.message));
		}
	}

	function parseAnimData() {
		frames = [];
		var rawJson = File.getContent(UtilitiesBaseMenuState.loadedPath + '/anims/${animName}.json');
		var json:SpriteProjectAnimData = cast haxe.Json.parse(rawJson);
		framerate = json.framerate;
		for (i in 0...json.numFrames) {
			if (json.keyframes.contains(i)) {
				var bitmapData:BitmapData = BitmapData.fromFile(UtilitiesBaseMenuState.loadedPath + '/sprites/${animName}/$i.png');
				var leGraphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmapData);
				leGraphic.persist = true;
				leGraphic.destroyOnNoUse = false;
				frames[i] = leGraphic;
			} else {
				frames[i] = null;
			}
		}
		characterSize.x = frames[0].width;
		characterSize.y = frames[0].height;
	}

	override function create() {
		super.create();

		remove(exitButton);

		if (!animIsNew) {
			parseAnimData();
		}

		var bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bg.alpha = 0.5;
		add(bg);

		anim = new FlxSprite();
		playFrame(0);
		add(anim);

		var emptyBar:FlxSprite = new FlxSprite(960, 0).makeGraphic(320, animHeight, 0xFF808080);
		add(emptyBar);

		var playBar:FlxSprite = new FlxSprite(0, animHeight).makeGraphic(FlxG.width, 32, 0xFF606060);
		add(playBar);

		var frameBG:FlxSprite = new FlxSprite(0, playBar.y + playBar.height).makeGraphic(FlxG.width, (FlxG.height - animHeight) - 32, 0xFF404040);
		add(frameBG);

		frameLeftBar = new FlxSprite(0, playBar.y + playBar.height).makeGraphic(sideBarWidth, Std.int(frameBG.height), 0xFF202020);

		frameRightBar = new FlxSprite(FlxG.width - sideBarWidth, playBar.y + playBar.height).makeGraphic(sideBarWidth, Std.int(frameBG.height), 0xFF202020);

		playButton = new SuffIconButton(0, 0, 'utilities/play', 'utilities/playHighlighted', false);
		playButton.x = (playBar.width - playButton.width) / 2;
		playButton.y = playBar.y;
		playButton.onClick = function() {
			togglePlaying();
		}
		add(playButton);

		prevFrameButton = new SuffIconButton(0, 0, 'utilities/prevFrame', 'utilities/prevFrameHighlighted', false);
		prevFrameButton.x = playButton.x - prevFrameButton.width;
		prevFrameButton.y = playBar.y;
		prevFrameButton.onClick = function() {
			playing = false;
			prevFrame();
		}
		add(prevFrameButton);

		nextFrameButton = new SuffIconButton(0, 0, 'utilities/nextFrame', 'utilities/nextFrameHighlighted', false);
		nextFrameButton.x = playButton.x + nextFrameButton.width;
		nextFrameButton.y = playBar.y;
		nextFrameButton.onClick = function() {
			playing = false;
			nextFrame();
		}
		add(nextFrameButton);

		firstFrameButton = new SuffIconButton(0, 0, 'utilities/firstFrame', 'utilities/firstFrameHighlighted', false);
		firstFrameButton.x = prevFrameButton.x - firstFrameButton.width;
		firstFrameButton.y = playBar.y;
		firstFrameButton.onClick = function() {
			playing = false;
			firstFrame();
		}
		add(firstFrameButton);

		lastFrameButton = new SuffIconButton(0, 0, 'utilities/lastFrame', 'utilities/lastFrameHighlighted', false);
		lastFrameButton.x = nextFrameButton.x + nextFrameButton.width;
		lastFrameButton.y = playBar.y;
		lastFrameButton.onClick = function() {
			playing = false;
			lastFrame();
		}
		add(lastFrameButton);

		framePointer = new FlxSprite().loadGraphic(Paths.image('ui/menus/utilities/animation/framePointer'));
		framePointer.x = frameLeftBar.width;
		framePointer.y = frameBG.y;
		framePointer.offset.x = framePointer.width / 2;
		framePointer.active = false;

		frameTimeBar = new FrameTimeBar(frameLeftBar.x + frameLeftBar.width, 0, framerate);
		frameTimeBar.y = FlxG.height - frameTimeBar.height;

		var frameBar = new FlxSprite(0, framePointer.y + framePointer.height - frameHeight).makeGraphic(FlxG.width, frameHeight, 0xFF303030);
		add(frameBar);
		frameGroup = new FlxSpriteGroup();
		add(frameGroup);
		frameGroup.x = frameLeftBar.x + frameLeftBar.width;
		frameGroup.y = frameBar.y;
		renderFrameGroup();
		snapFramePointer();
		add(frameTimeBar);
		add(frameLeftBar);
		add(frameRightBar);
		add(framePointer);

		var extendKeyframeButton = new SuffIconButton(0, 0, 'utilities/extendKeyframe', 'utilities/extendKeyframeHighlighted', false);
		extendKeyframeButton.x = frameLeftBar.x;
		extendKeyframeButton.y = frameLeftBar.y;
		extendKeyframeButton.onClick = function() {
			extendFrame(curFrame, 1);
		}
		add(extendKeyframeButton);

		var deleteKeyframeButton = new SuffIconButton(0, 0, 'utilities/deleteKeyframe', 'utilities/deleteKeyframeHighlighted', false);
		deleteKeyframeButton.x = extendKeyframeButton.x + extendKeyframeButton.width;
		deleteKeyframeButton.y = extendKeyframeButton.y;
		deleteKeyframeButton.onClick = function() {
			deleteFrame(curFrame);
		}
		add(deleteKeyframeButton);

		var addKeyframeButton = new SuffIconButton(0, 0, 'utilities/addKeyframe', 'utilities/addKeyframeHighlighted', false);
		addKeyframeButton.x = extendKeyframeButton.x;
		addKeyframeButton.y = extendKeyframeButton.y + extendKeyframeButton.height;
		addKeyframeButton.onClick = function() {
			openSubState(new SpriteBrowseImagePrompt(Std.int(characterSize.x), Std.int(characterSize.y), template));
		}
		add(addKeyframeButton);

		var animNameText = new FlxText(emptyBar.x + 16, emptyBar.y + 16, emptyBar.width - 32, animName, 32);
		add(animNameText);

		var framerateText = new FlxText(animNameText.x, animNameText.y + animNameText.height + 16, 0, Language.getPhrase('characterCreator.parameter.framerate'), 16);
		add(framerateText);

		framerateStepper = new SuffUINumericStepper(framerateText.x, framerateText.y + framerateText.height + 8, 1, framerate, 1, 30);
		add(framerateStepper);

		var saveButton:SuffUIButton = new SuffUIButton(framerateStepper.x, framerateStepper.y + framerateStepper.height + 16, Language.getPhrase('animationCreator.save'), function() {
			saveAnimData();
		});
		saveButton.resize(emptyBar.width - 32, 48);
		add(saveButton);

		var exitButton:SuffUIButton = new SuffUIButton(saveButton.x, 0, Language.getPhrase('animationCreator.exit'), function() {
			leaveMenu();
		});
		exitButton.color = 0xFF2020;
		exitButton.label.color = 0xFFFFFF;
		exitButton.resize(emptyBar.width - 32, 48);
		exitButton.y = emptyBar.height - saveButton.height - 16;
		add(exitButton);
	}

	var framerateStepper:SuffUINumericStepper;

	static function renderFrameGroup() {
		if (frameGroup != null)
			frameGroup.clear();
		for (i in 0...frames.length) {
			var frame:FlxSprite = new FlxSprite();
			if (frames[i] != null) {
				frame.loadGraphic(Paths.image('ui/menus/utilities/animation/keyframe'));
			} else {
				frame.loadGraphic(Paths.image('ui/menus/utilities/animation/frame'));
			}
			frame.x = i * frame.width;
			frameGroup.add(frame);
		}
	}

	public override function leaveMenu() {
		openSubState(new ChoicePrompt('animationCreator.exit.prompt', function() {
			frameGroup = new FlxSpriteGroup();
			anim = null;
			SuffState.switchState(new CharacterCreatorState());
		}, function() {

		}));
	}

	static var characterSize = new FlxPoint();

	public static function importBitmap(bitmap:BitmapData) {
		var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false);
		newGraphic.persist = true;
		newGraphic.destroyOnNoUse = false;
		characterSize.set(newGraphic.width, newGraphic.height);
		frames[curFrame] = newGraphic;
		renderFrameGroup();
		if (anim != null)
			playFrame(curFrame);
		if (framePointer != null && frameGroup != null)
			snapFramePointer();
	}

	function changeCurFrame(deltaFrame:Int = 0, wrap:Bool = false) {
		curFrame += deltaFrame;
		boundCurFrame(wrap);
		snapFramePointer();
		playFrame(curFrame);
	}

	function boundCurFrame(wrap:Bool = false) {
		if (!wrap)
			curFrame = Std.int(FlxMath.bound(curFrame, 0, frames.length - 1));
		else
			curFrame = FlxMath.wrap(curFrame, 0, frames.length - 1);
	}

	function deleteFrame(position:Int = 0) {
		if (frames.length <= 1) return;
		if (frames[position] == null) {
			frames.splice(position, 1);
			curFrame--;
		} else {
			if (position + 1 < frames.length && frames[position + 1] == null) {
				frames.splice(position + 1, 1);
			} else {
				frames.splice(position, 1);
				curFrame--;
			}
		}
		playFrame(curFrame);
		renderFrameGroup();
		moveFrameGroup(frameWidth);
		snapFramePointer();
	}

	function extendFrame(position:Int = 0, deltaFrame:Int = 0) {
		frames.insert(position + deltaFrame, null);
		curFrame += deltaFrame;
		playFrame(curFrame);
		renderFrameGroup();
		moveFrameGroup(-frameWidth);
		snapFramePointer();
	}

	static function playFrame(frame:Int = 0) {
		var leFrame:Int = frame;
		while (frames[leFrame] == null && leFrame > 0) {
			leFrame--;
		}
		anim.loadGraphic(frames[leFrame]);
		if (anim.height > animHeight)
			anim.setGraphicSize(Std.int(animHeight / anim.height * anim.width));
		anim.updateHitbox();
		anim.x = (960 - anim.width) / 2;
		anim.y = animHeight - anim.height;
	}

	static function snapFramePointer() {
		var leMember = frameGroup.members[curFrame];
		if (leMember != null) {
			framePointer.x = leMember.x + leMember.width / 2;
		} else {
			curFrame = 0;
			framePointer.x = frameGroup.members[0].x + frameGroup.members[0].width / 2;
			playFrame(curFrame);
		}
	}

	function moveFrameGroup(delta:Float = 0) {
		setFrameGroupX(frameGroup.x + delta);
	}

	function setFrameGroupX(value:Float = 0) {
		if (frameGroup.width <= FlxG.width - frameLeftBar.width - frameRightBar.width) {
			return;
		}
		frameGroup.x = value;
		frameGroup.x = FlxMath.bound(frameGroup.x, FlxG.width - frameLeftBar.width - frameGroup.width, frameLeftBar.x + frameLeftBar.width);
		frameTimeBar.x = frameGroup.x;
	}

	var charlieKirk:Float = 0;

	override function update(elapsed:Float) {
		if (playing) {
			charlieKirk += elapsed;
			if (charlieKirk >= 1 / framerate) {
				charlieKirk = 0;
				changeCurFrame(1, true);
				if (framePointer.x > frameRightBar.x) {
					var leWidth = (FlxG.width - frameLeftBar.width - frameRightBar.width);
					moveFrameGroup(-leWidth * Math.ceil((framePointer.x - leWidth) / leWidth));
					snapFramePointer();
				} else if (curFrame == 0) {
					setFrameGroupX(frameLeftBar.width);
					snapFramePointer();
				}
			}
		} else {
			if (Math.abs(FlxG.mouse.x - framePointer.x) <= framePointer.width && Math.abs(FlxG.mouse.y - framePointer.y) <= framePointer.height / 2 + 8 && FlxG.mouse.justPressed) {
				framePointer.active = true;
			}
			if (framePointer.active) {
				framePointer.x = FlxMath.bound(framePointer.x + FlxG.mouse.deltaScreenX, frameLeftBar.x + frameLeftBar.width, frameRightBar.x);
				if (frameGroup.width > FlxG.width - frameLeftBar.width - frameRightBar.width) {
					if (framePointer.x == frameRightBar.x) {
						moveFrameGroup(-(Math.max(0, FlxG.mouse.x - frameRightBar.x) / 10 + 40 * elapsed));
					} else if (framePointer.x == frameLeftBar.x + frameLeftBar.width) {
						moveFrameGroup(Math.max(0, frameLeftBar.x + frameLeftBar.width - FlxG.mouse.x) / 10 + 40 * elapsed);
					}
				}
			}
			if (FlxG.mouse.justReleased && framePointer.active) {
				framePointer.active = false;
				var leThing:Int = Math.round((framePointer.x - frameGroup.x - framePointer.width / 2) / framePointer.width);
				curFrame = leThing;
				boundCurFrame();
				playFrame(curFrame);
				snapFramePointer();
			}
		}
		if (FlxG.keys.justPressed.SPACE) {
			togglePlaying();
		} else if (FlxG.keys.anyJustPressed([LEFT, Q, A, COMMA])) {
			prevFrame();
		} else if (FlxG.keys.anyJustPressed([RIGHT, E, D, PERIOD])) {
			nextFrame();
		} else if (FlxG.keys.anyJustPressed([HOME])) {
			firstFrame();
		} else if (FlxG.keys.anyJustPressed([END])) {
			lastFrame();
		}
		super.update(elapsed);
	}

	public override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>) {
		if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is SuffUINumericStepper)) {
			if (sender == framerateStepper) {
				framerate = Std.int(framerateStepper.value);
				frameTimeBar.updateFramerate(framerate);
			}
		}
	}

	function firstFrame() {
		curFrame = 0;
		frameGroup.x = frameLeftBar.width;
		snapFramePointer();
		playFrame(curFrame);
	}

	function lastFrame() {
		curFrame = frames.length - 1;
		if (frameGroup.width > FlxG.width - frameLeftBar.width - frameGroup.width)
			frameGroup.x = FlxG.width - frameLeftBar.width - frameGroup.width;
		snapFramePointer();
		playFrame(curFrame);
	}

	function prevFrame() {
		changeCurFrame(-1);
		if (framePointer.x < frameLeftBar.width)
			moveFrameGroup(frameWidth);
		snapFramePointer();
	}

	function nextFrame() {
		changeCurFrame(1);
		if (framePointer.x > frameRightBar.x)
			moveFrameGroup(-frameWidth);
		snapFramePointer();
	}

	function set_playing(value:Bool):Bool {
		playing = value;
		var graphic:FlxGraphic = value ? Paths.image('ui/icons/utilities/pause') : Paths.image('ui/icons/utilities/play');
		playButton.switchIconImage(graphic);
		return value;
	}

	function togglePlaying() {
		playing = !playing;
	}
}
