package substates;
import ui.objects.SuffSlider;
import ui.objects.SuffIconButton;
import backend.ScreenSafeArea;

class ScreenSafeAreaSubState extends SuffSubState {
	var bounds:FlxSprite;
	var cornerTopLeft:FlxSprite;
	var cornerTopRight:FlxSprite;
	var cornerBottomLeft:FlxSprite;
	var cornerBottomRight:FlxSprite;
	var slider:SuffSlider;
	var exitButton:SuffIconButton;

	public function new() {
		super();

		Window.setTitle(Language.getPhrase('optionsMenu.windowDisplay'), Language.getPhrase('option.screenSafeArea.name'));

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/menus/options/bg'));
		bg.color = 0x303030;
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.updateHitbox();
		add(bg);

		bounds = new FlxSprite().makeGraphic(FlxG.width, FlxG.height);
		bounds.alpha = 0.25;
		add(bounds);

		cornerTopLeft = new FlxSprite().loadGraphic(Paths.image('ui/menus/options/boundsCorner'));
		add(cornerTopLeft);

		cornerTopRight = new FlxSprite().loadGraphic(Paths.image('ui/menus/options/boundsCorner'));
		cornerTopRight.flipX = true;
		add(cornerTopRight);

		cornerBottomLeft = new FlxSprite().loadGraphic(Paths.image('ui/menus/options/boundsCorner'));
		cornerBottomLeft.flipY = true;
		add(cornerBottomLeft);

		cornerBottomRight = new FlxSprite().loadGraphic(Paths.image('ui/menus/options/boundsCorner'));
		cornerBottomRight.flipX = true;
		cornerBottomRight.flipY = true;
		add(cornerBottomRight);

		var title = new FlxText(0, 0, FlxG.width * 0.5, Language.getPhrase('option.screenSafeArea.name'), 48);
		title.alignment = CENTER;
		title.screenCenter(X);

		var subtitle = new FlxText(0, 0, title.width, Language.getPhrase('option.screenSafeArea.description'), 32);
		subtitle.alignment = CENTER;
		subtitle.screenCenter(X);

		slider = new SuffSlider(0, 0, function(value:Float) {
			updateSafeZone(value);
		}, 0, 1, 0.05, function(value:Float) {
			return '${Math.round(value * 100)}%';
		}, Preferences.data.screenSafeArea, function(value:Float) {
			updateSafeZone(value);
		});
		slider.screenCenter(X);

		title.y = (FlxG.height - (title.height + subtitle.height + 16 + slider.height)) / 2;
		subtitle.y = title.y + title.height + 8;
		slider.y = subtitle.y + subtitle.height + 8;

		add(title);
		add(subtitle);
		add(slider);

		updateSafeZone(Preferences.data.screenSafeArea);

		exitButton = new SuffIconButton(20, 20, 'buttons/exit', null, 2);
		exitButton.x = FlxG.width - exitButton.width - 60;
		exitButton.onClick = function() {
			exit();
		};
		add(exitButton);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Controls.justPressed('exit'))
			exit();
	}

	function updateSafeZone(value:Float) {
		var scale = 1 - value * 0.2;
		bounds.scale.set(scale, scale);
		bounds.updateHitbox();
		bounds.screenCenter();

		cornerTopLeft.setPosition(bounds.x, bounds.y);
		cornerTopRight.setPosition(bounds.x + bounds.width - cornerTopRight.width, bounds.y);
		cornerBottomLeft.setPosition(bounds.x, bounds.y + bounds.height - cornerBottomLeft.height);
		cornerBottomRight.setPosition(bounds.x + bounds.width - cornerBottomRight.width, bounds.y + bounds.height - cornerBottomLeft.height);
	}

	function exit() {
		Preferences.data.screenSafeArea = slider.currentValue;
		Window.setTitle(Language.getPhrase('optionsMenu.windowDisplay'));
		close();
	}
}
