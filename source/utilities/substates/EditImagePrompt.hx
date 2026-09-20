package utilities.substates;

import utilities.objects.TemplateImage;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import flash.net.FileFilter;
#if _ALLOW_UTILITIES
import backend.FileDialogHandler;
#end
import openfl.geom.Rectangle;
import openfl.geom.Point;
import utilities.states.AnimationEditorState;

class EditImagePrompt extends UtilitiesBaseMenuSubState {
	var sprite:FlxSprite;
	var leWidth:Float = 640;
	var leHeight:Float = 640;
	var silhouette:TemplateImage;
	var offsetTxt:FlxText;
	var offset:FlxPoint = FlxPoint.get(0, 0);
	public function new(bitmapData:BitmapData, width:Float = 640, height:Float = 640, template:String = 'silhouette') {
		super();

		leWidth = width;
		leHeight = height;

		if (bitmapData.width == width && bitmapData.height == height)
			doTheEvilStuff(bitmapData);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
		bg.alpha = 0.25;
		add(bg);

		var leftBorder:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width / 2 - width / 2), FlxG.height, 0xFF000000);
		leftBorder.alpha = 0.5;

		var rightBorder:FlxSprite = new FlxSprite(leftBorder.width + width, 0).makeGraphic(Std.int(FlxG.width / 2 - width / 2), FlxG.height, 0xFF000000);
		rightBorder.alpha = 0.5;

		var upBorder:FlxSprite = new FlxSprite(leftBorder.width, 0).makeGraphic(Std.int(width), Std.int(FlxG.height / 2 - height / 2), 0xFF000000);
		upBorder.alpha = 0.5;

		var downBorder:FlxSprite = new FlxSprite(leftBorder.width, upBorder.height + height).makeGraphic(Std.int(width), Std.int(FlxG.height / 2 - height / 2), 0xFF000000);
		downBorder.alpha = 0.5;

		silhouette = new TemplateImage(0, 0, width, height, template);
		silhouette.screenCenter(X);
		silhouette.y = downBorder.y - silhouette.height;
		silhouette.alpha = 0.25;

		sprite = new FlxSprite();

		add(sprite);
		add(silhouette);
		add(leftBorder);
		add(rightBorder);
		add(upBorder);
		add(downBorder);

		var loadFileButton = new SuffButton(rightBorder.x + 32, rightBorder.y + 32, Language.getPhrase('utilitiesMenu.browseImage'), rightBorder.width - 64, 80);
		loadFileButton.btnTextSize = 32;
		loadFileButton.onClick = function() {
			var fileDialog:FileDialogHandler = new FileDialogHandler();
			fileDialog.open(null, Language.getPhrase('utilitiesMenu.browseImage'), [new FileFilter('PNG', 'png'), new FileFilter('TGA', 'tga')], function () {
				var bitmapData:BitmapData = BitmapData.fromFile(fileDialog.path);
				loadSprite(bitmapData);
			});
		}
		add(loadFileButton);

		var confirmButton = new SuffButton(rightBorder.x + 32, 0, Language.getPhrase('menu.confirm'), rightBorder.width - 64, 80);
		confirmButton.y = rightBorder.y + rightBorder.height - confirmButton.height - 32;
		confirmButton.btnTextSize = 32;
		confirmButton.onClick = function() {
			doTheEvilStuff();
		}
		add(confirmButton);

		var helpTitle:FlxText = new FlxText(32, 32, leftBorder.width - 64, Language.getPhrase('utilitiesMenu.browseImage.adjustOffsets.title'), 32);
		add(helpTitle);
		var helpDesc:FlxText = new FlxText(32, helpTitle.y + helpTitle.height, leftBorder.width - 40, Language.getPhrase('utilitiesMenu.browseImage.adjustOffsets.description'), 16);
		add(helpDesc);
		offsetTxt = new FlxText(32, 32, leftBorder.width - 64, '[0, 0]', 32);
		offsetTxt.y = FlxG.height - offsetTxt.height - 32;
		add(offsetTxt);

		loadSprite(bitmapData);
	}

	function loadSprite(bitmap:BitmapData) {
		sprite.loadGraphic(FlxGraphic.fromBitmapData(bitmap));
		sprite.x = Std.int(silhouette.x + (silhouette.width - sprite.width) / 2);
		sprite.y = Std.int(silhouette.y + (silhouette.height - sprite.height));
		updateOffsets();
	}

	function doTheEvilStuff(?bitmap:BitmapData = null) {
		var importedB = bitmap != null ? bitmap : sprite.graphic.bitmap;
		var leBitmap:BitmapData = new BitmapData(Std.int(leWidth), Std.int(leHeight), true, 0x00000000);
		leBitmap.copyPixels(importedB, new Rectangle(0, 0, Std.int(importedB.width), Std.int(importedB.height)), new Point(offset.x, offset.y));
		var finishedBitmap:BitmapData = leBitmap.clone();
		if (Main.mainClassState != AnimationEditorState) {
			AnimationEditorState.importBitmap(finishedBitmap);
			SuffState.switchState(new AnimationEditorState());
		} else {
			AnimationEditorState.importBitmap(finishedBitmap);
			SpriteBrowseImagePrompt.instance.close();
			close();
		}
	}

	var isGrabbingSprite:Bool = false;

	override function update(elapsed:Float) {
		var stepSize:Int = 1;
		if (FlxG.keys.anyPressed([SHIFT, CONTROL])) stepSize = 10;
		if (Controls.justPressed('left')) {
			moveSprite(-1 * stepSize, 0);
		} else if (Controls.justPressed('right')) {
			moveSprite(1 * stepSize, 0);
		}
		if (Controls.justPressed('up')) {
			moveSprite(0, -1 * stepSize);
		} else if (Controls.justPressed('down')) {
			moveSprite(0, 1 * stepSize);
		}
		if (FlxG.mouse.overlaps(sprite) && FlxG.mouse.justPressed && !isGrabbingSprite) {
			isGrabbingSprite = true;
		}
		if (isGrabbingSprite) {
			sprite.x += FlxG.mouse.deltaScreenX;
			sprite.y += FlxG.mouse.deltaScreenY;
			updateOffsets();
		}
		if (FlxG.mouse.justReleased && isGrabbingSprite) isGrabbingSprite = false;
		super.update(elapsed);
	}

	function moveSprite(deltaX:Int = 0, deltaY:Int = 0) {
		sprite.x = Std.int(sprite.x + deltaX);
		sprite.y = Std.int(sprite.y + deltaY);
		updateOffsets();
	}

	function updateOffsets() {
		offset.x = sprite.x - silhouette.x;
		offset.y = sprite.y - silhouette.y;
		offsetTxt.text = '[${offset.x}, ${offset.y}]';
	}
}