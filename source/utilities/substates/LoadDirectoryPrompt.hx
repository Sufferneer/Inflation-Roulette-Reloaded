package utilities.substates;

#if _ALLOW_UTILITIES
import backend.FileDialogHandler;
#end

class LoadDirectoryPrompt extends UtilitiesBaseMenuSubState {
	var loadFileButton:SuffButton;
	public static var loadFileFunction:String -> Void;
	var newFileButton:SuffButton;
	public static var newFileFunction:Void -> Void;
	var fileDialog:FileDialogHandler = new FileDialogHandler();
	public function new(defaultPath:String = '', title:String = 'utilitiesMenu.loadDirectory') {
		super();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bg.alpha = 0.5;
		add(bg);

		loadFileButton = new SuffButton(0, 0, Language.getPhrase('utilitiesMenu.loadDirectory'), 400, 100);
		loadFileButton.screenCenter();
		loadFileButton.onClick = function() {
			try {
				fileDialog.openDirectory(defaultPath, Language.getPhrase(title), function () {
					var filePath:String = fileDialog.path.replace('\\', '/');
					loadFileFunction(filePath);
				});
			} catch(e:Dynamic) {
				openSubState(new ErrorPrompt(e));
			}
		}
		add(loadFileButton);

		if (newFileFunction != null) {
			newFileButton = new SuffButton(0, 0, Language.getPhrase('utilitiesMenu.newDirectory'), 400, 100);
			newFileButton.screenCenter();
			newFileButton.onClick = function() {
				try {
					newFileFunction();
				} catch(e:Dynamic) {
					openSubState(new ErrorPrompt(e));
				}
			}
			add(newFileButton);

			loadFileButton.y -= 60;
			newFileButton.y += 60;
		}
	}
}
