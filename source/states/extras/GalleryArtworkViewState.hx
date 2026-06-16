package states.extras;

import ui.objects.SuffIconButton;
import flixel.addons.display.FlxGridOverlay;

class GalleryArtworkViewState extends SuffState {
	var allowInput:Bool = false;

	var art:FlxSprite;
	var zoomIn:SuffIconButton;
	var zoomOut:SuffIconButton;
	var zoomReset:SuffIconButton;
	var exitButton:SuffIconButton;
	var infoText:FlxText;

	var camGame:FlxCamera;
	var camHUD:FlxCamera;

	var cameraPos:FlxObject = new FlxObject(FlxG.width / 2, FlxG.height / 2);
	var minZoom:Float = 0;
	var maxZoom:Float = 0;
	final ZOOM_SNAPPING:Float = 0.125;

	public static var path:String = '';

	override function create() {
		camGame = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		camHUD = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		camGame.bgColor = 0xFF000000;
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		super.create();

		FlxG.camera.follow(cameraPos);

		art = new FlxSprite(0, FlxG.height).loadGraphic(Paths.image('ui/menus/extras/gallery/images/$path'));
		art.x = (FlxG.width - art.width) / 2;
		FlxTween.tween(art, {y: Std.int((FlxG.height - art.height) / 2)}, 0.5, {ease: FlxEase.quintOut});
		var curZoom = Math.min((FlxG.width - 320) / art.width, (FlxG.height - 180) / art.height);
		minZoom = Math.ceil(Math.min(180 / art.width, 180 / art.height) / ZOOM_SNAPPING) * ZOOM_SNAPPING;
		maxZoom = 4;
		if (curZoom > 1) {
			curZoom = Std.int(curZoom);
			maxZoom = Std.int(Math.min(FlxG.width / art.width, FlxG.height / art.height)) + 3;
			minZoom = 1;
		}
		curZoom = Math.round(curZoom / ZOOM_SNAPPING) * ZOOM_SNAPPING;
		FlxG.camera.zoom = curZoom;

		var gridSize = 40;
		var grid = new FlxBackdrop(FlxGridOverlay.createGrid(gridSize, gridSize, gridSize * 2, gridSize * 2, true, 0xFFC0C0C0, 0xFF909090));
		grid.velocity.set(-64 / curZoom, -64 / curZoom);

		add(grid);
		add(art);

		infoText = new FlxText(0, 0, 0, '100%', 32);
		infoText.alignment = RIGHT;
		infoText.setBorderStyle(OUTLINE, 0xFF000000, 2);
		infoText.camera = camHUD;
		add(infoText);

		zoomIn = new SuffIconButton(20 + ScreenSafeArea.X, 20, 'buttons/zoomIn', null, 1);
		zoomIn.y = FlxG.height - zoomIn.height - 20 - ScreenSafeArea.Y;
		zoomIn.camera = camHUD;
		zoomIn.onClick = function() {
			changeZoom(0.1);
		};
		add(zoomIn);

		zoomOut = new SuffIconButton(zoomIn.x + zoomIn.width + 10, 20, 'buttons/zoomOut', null, 1);
		zoomOut.y = zoomIn.y;
		zoomOut.camera = camHUD;
		zoomOut.onClick = function() {
			changeZoom(-0.1);
		};
		add(zoomOut);

		zoomReset = new SuffIconButton(zoomOut.x + zoomOut.width + 10, 20, 'buttons/zoomReset', null, 1);
		zoomReset.y = zoomOut.y;
		zoomReset.camera = camHUD;
		zoomReset.onClick = function() {
			cameraPos.x = FlxG.width / 2;
			cameraPos.y = FlxG.height / 2;
			FlxG.camera.zoom = Math.max(1, Math.min((FlxG.width - 320) / art.width, (FlxG.height - 180) / art.height));
			if (FlxG.camera.zoom > 1) FlxG.camera.zoom = Std.int(FlxG.camera.zoom);
			updateCameraPos();
			updateInfoText();
		};
		add(zoomReset);

		exitButton = new SuffIconButton(20, 20 + ScreenSafeArea.Y, 'buttons/exit', null, 2);
		exitButton.x = FlxG.width - exitButton.width - 20 - ScreenSafeArea.X;
		exitButton.camera = camHUD;
		exitButton.onClick = function() {
			exitMenu();
		};
		add(exitButton);

		allowInput = true;

		changeZoom();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (!allowInput) return;
		if (Controls.justPressed('exit')) {
			exitMenu();
		}
		if (panning) {
			if (FlxG.mouse.pressed) {
				var deltaX:Float = FlxG.mouse.deltaScreenX;
				var deltaY:Float = FlxG.mouse.deltaScreenY;
				cameraPos.x = Std.int(cameraPos.x - deltaX);
				cameraPos.y = Std.int(cameraPos.y - deltaY);
				updateCameraPos();
				updateInfoText();
			}
			if (FlxG.mouse.released)
				panning = false;
		} else {
			if (FlxG.mouse.justPressed)
				panning = true;
		}
		if (FlxG.mouse.wheel != 0) {
			changeZoom(FlxG.mouse.wheel * 0.1);
		}
	}

	var panning:Bool = false;

	function updateCameraPos() {
		cameraPos.x = FlxMath.bound(cameraPos.x, (FlxG.width - art.width) / 2, (FlxG.width + art.width) / 2);
		cameraPos.y = FlxMath.bound(cameraPos.y, (FlxG.height - art.height) / 2, (FlxG.height + art.height) / 2);
	}

	function updateInfoText() {
		var camX = Std.int(FlxMath.lerp(0, art.width - 1, (cameraPos.x - (FlxG.width - art.width) / 2) / art.width));
		var camY = Std.int(FlxMath.lerp(0, art.height - 1, (cameraPos.y - (FlxG.height - art.height) / 2) / art.height));
		infoText.text = '[${camX}, ${camY}]\n${Std.int(FlxG.camera.zoom * 100)}%';
		infoText.x = FlxG.width - infoText.width - 20 - ScreenSafeArea.X;
		infoText.y = FlxG.height - infoText.height - 20 - ScreenSafeArea.Y;
	}

	function changeZoom(delta:Float = 0) {
		FlxG.camera.zoom = FlxMath.bound(FlxG.camera.zoom + delta * (maxZoom - minZoom), minZoom, maxZoom);
		updateInfoText();
		// trace(FlxG.camera.zoom);
	}

	function exitMenu() {
		if (!allowInput) return;
		SuffState.switchState(new GalleryEntryState());
	}
}
