package utilities.substates;

#if _ALLOW_UTILITIES
import backend.FileDialogHandler;
#end
import flash.net.FileFilter;
import ui.objects.SuffIconButton;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.utils.ByteArray;
import openfl.display.PNGEncoderOptions;
import substates.ErrorPrompt;

class SpriteBrowseImagePrompt extends UtilitiesBaseMenuSubState {
	var exitButton:SuffIconButton;

	public static var instance:SpriteBrowseImagePrompt;

	var loadFileButton:SuffButton;
	var downloadTemplate:SuffButton;
	public static var loadFileFunction:String -> Void;
	var fileDialog:FileDialogHandler = new FileDialogHandler();
	public function new(width:Float, height:Float, template:String = 'silhouette') {
		super();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bg.alpha = 0.5;
		add(bg);

		loadFileButton = new SuffButton(0, 0, Language.getPhrase('utilitiesMenu.browseImage'), 500, 100);
		loadFileButton.screenCenter();
		loadFileButton.onClick = function() {
			fileDialog.open(null, Language.getPhrase('utilitiesMenu.browseImage'), [new FileFilter('PNG', 'png')], function () {
				try {
					var bitmapData:BitmapData = BitmapData.fromFile(fileDialog.path);
					openSubState(new EditImagePrompt(bitmapData, width, height, template));
				} catch(e:Dynamic) {
					openSubState(new ErrorPrompt(e.message));
				}
			});
		}
		loadFileButton.y -= 65;
		add(loadFileButton);

		downloadTemplate = new SuffButton(0, 0, Language.getPhrase('utilitiesMenu.browseImage.downloadTemplate'), 500, 100);
		downloadTemplate.screenCenter();
		downloadTemplate.y += 65;
		downloadTemplate.onClick = function() {
			fileDialog.save(template + '.png', function() {
				var bitmapData:BitmapData = BitmapData.fromFile(Paths.getImagePath('ui/menus/utilities/' + template));
				var bytes:ByteArray = bitmapData.encode(bitmapData.rect, new PNGEncoderOptions());
				File.saveBytes(fileDialog.path.replace('\\', '/'), bytes);
			});
		}
		add(downloadTemplate);

		var text:FlxText = new FlxText(0, 0, Language.getPhrase('utilitiesMenu.browseImage.recommendedSize', [width, height]), 16);
		text.screenCenter();
		text.x = Std.int(text.x);
		text.y = Std.int(text.y);
		add(text);

		exitButton = new SuffIconButton(10, 10, 'buttons/exit', null, 2);
		exitButton.x = FlxG.width - exitButton.width - 10;
		exitButton.onClick = function() {
			leaveMenu();
		}
		add(exitButton);

		instance = this;
	}
}
