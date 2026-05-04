package;

import flixel.FlxGame;
import flixel.FlxState;
import openfl.Lib;
import ui.objects.DebugText;
import openfl.display.Sprite;
import openfl.events.Event;
import lime.app.Application;
import states.PreloadState;
// crash handler stuff
#if _ALLOW_CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import openfl.utils.Assets;

#end

#if linux
import openfl.utils.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
#end

class Main extends Sprite {
	var game = {
		width: 1280, // WINDOW width
		height: 720, // WINDOW height
		initialState: PreloadState, // initial game state
		zoom: -1.0, // game state bounds
		framerate: 60, // default framerate
		skipSplash: true, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};

	public static var debugText:DebugText;

	public static var mainClassState:Class<FlxState> = PreloadState;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void {
		Lib.current.addChild(new Main());
	}

	public function new() {
		super();

		if (stage != null) {
			init();
		} else {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void {
		if (hasEventListener(Event.ADDED_TO_STAGE)) {
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}
		setupGame();
	}

	private function setupGame():Void {
		#if linux
		FlxG.stage.window.setIcon(Assets.getBitmapData('iconLinux').image);
		#end
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (game.zoom == -1.0) {
			var ratioX:Float = stageWidth / game.width;
			var ratioY:Float = stageHeight / game.height;
			game.zoom = Math.min(ratioX, ratioY);
			game.width = Math.ceil(stageWidth / game.zoom);
			game.height = Math.ceil(stageHeight / game.zoom);
		}

		FlxTransitionableState.skipNextTransOut = true;

		addChild(new FlxGame(game.width, game.height, game.initialState, game.framerate, game.framerate,
			game.skipSplash, game.startFullscreen));

		#if !mobile
		debugText = new DebugText(0, 0, 0xFFFFFF);
		addChild(debugText);
		Lib.current.stage.align = "tl";

		debugText.alpha = 0.5;
		#end

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [FlxKey.TAB];

		#if html5
		FlxG.autoPause = false;
		#end

		#if _ALLOW_CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end

		// shader coords fix
		FlxG.signals.gameResized.add(function(w, h) {
			if (FlxG.cameras != null) {
				for (cam in FlxG.cameras.list) {
					@:privateAccess
					if (cam != null && cam.filters != null)
						resetSpriteCache(cam.flashSprite);
				}
			}

			if (FlxG.game != null)
				resetSpriteCache(FlxG.game);
		});
	}

	static function resetSpriteCache(sprite:Sprite):Void {
		@:privateAccess {
			sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}

	#if _ALLOW_CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void {
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();
		var errMsgTitle:Array<String> = [
			"don't feel bad; you have a fine job tossing your little balls around",
			"this is very sad gold <:(",
			"bro are you trying to make them bigger or something",
			"kusmek??? is that you???",
			"bro there's kids around youtube stop recording",
			"WAIT!! THAT'S NOT AN INTENDED FEATURE!! :broken_heart: :skull:"
		];

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + FlxG.stage.application.meta.get('file') + "_" + dateNow + ".txt";

		for (stackItem in callStack) {
			switch (stackItem) {
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error;
		#if _OFFICIAL_BUILD
		errMsg += "\n\nPlease report this error to the GitHub page: https://github.com/Sufferneer/Inflation-Roulette";
		#end

		#if desktop
		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");
		File.saveContent(path, errMsg + "\n");
		#end

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg + '\n\n', errMsgTitle[FlxG.random.int(0, errMsgTitle.length - 1)]);
		Sys.exit(1);
	}
	#end
}
