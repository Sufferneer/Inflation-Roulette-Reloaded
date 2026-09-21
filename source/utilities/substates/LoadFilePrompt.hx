package utilities.substates;

#if _ALLOW_UTILITIES
import backend.FileDialogHandler;
import openfl.net.FileFilter;
import substates.ErrorPrompt;
#end
import substates.ErrorPrompt;

class LoadFilePrompt extends UtilitiesBaseMenuSubState {
	#if _ALLOW_UTILITIES
	var loadFileButton:SuffButton;
	public static var loadFileFunction:String -> Void;
	var newFileButton:SuffButton;
	public static var newFileFunction:Void -> Void;
	var fileDialog:FileDialogHandler = new FileDialogHandler();
	public function new(defaultPath:String = '', fileFilter:Array<FileFilter> = null, title:String = 'utilitiesMenu.loadFile') {
		super();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bg.alpha = 0.5;
		add(bg);

		var daFileFilter:Array<FileFilter> = [new FileFilter('JSON', 'json')];
		if (fileFilter != null)
			daFileFilter = fileFilter;
		
		#if !windows
		defaultPath = defaultPath.replace('\\', '/');
		#else
		defaultPath = defaultPath.replace('/', '\\');
		#end

		loadFileButton = new SuffButton(0, 0, Language.getPhrase('utilitiesMenu.loadFile'), 400, 100);
		loadFileButton.screenCenter();
		if (loadFileFunction != null && newFileFunction != null)
			loadFileButton.y -= 60;
		loadFileButton.onClick = function() {
			try {
				fileDialog.open(defaultPath, Language.getPhrase(title), daFileFilter, function () {
					var filePath:String = fileDialog.path.replace('\\', '/');
					loadFileFunction(filePath);
				});
			} catch(e:Dynamic) {
				openSubState(new ErrorPrompt(e));
			}
		}
		if (loadFileFunction != null)
			add(loadFileButton);

		newFileButton = new SuffButton(0, 0, Language.getPhrase('utilitiesMenu.newFile'), 400, 100);
		newFileButton.screenCenter();
		if (loadFileFunction != null && newFileFunction != null)
			newFileButton.y += 60;
		newFileButton.onClick = function() {
			try {
				newFileFunction();
			} catch(e:Dynamic) {
				openSubState(new ErrorPrompt(e));
			}
		}
		if (newFileFunction != null)
			add(newFileButton);
	}
	#end
}
