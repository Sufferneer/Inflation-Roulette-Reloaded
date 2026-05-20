package ui.objects;

import backend.typedefs.AddonMetadata;

class AddonMenuItem extends SuffButton {
	public static final spacing:Int = 10;
	public static final iconSize:Int = 128;
	public static var defaultWidth:Int = 500;
	public static var defaultHeight:Int = 0;

	var bg:FlxSprite;
	var modName:FlxText;
	var modDesc:FlxText;
	var icon:FlxSprite;

	public var addon:AddonMetadata;

	public function new(x:Float, y:Float, folder:String, leAddon:AddonMetadata) {
		super(x, y, null, null, null, defaultWidth, defaultHeight, false);
		this.addon = leAddon;

		bg = new FlxSprite(spacing, spacing).makeGraphic(defaultWidth - spacing * 2, defaultHeight - spacing, 0xFFFFFFFF);
		bg.alpha = 0.5;

		var path:String = Paths.addons('$folder/metadata/pack.png');
		if (!FileSystem.exists(path)) {
			path = Paths.getImagePath('ui/menus/addons/defaultIcon');
		}
		var leIconImage = Paths.cacheBitmap(path);
		var iconOffset:Float = (bg.height - iconSize) / 2;
		icon = new FlxSprite(spacing + iconOffset, spacing + iconOffset).loadGraphic(leIconImage);
		icon.setGraphicSize(iconSize, iconSize);
		icon.updateHitbox();

		var textOffset:Float = iconOffset + icon.width + 16;
		modName = new FlxText(textOffset, iconOffset, 0, addon.name);
		modName.setFormat(Paths.font('default', false), 48);
		
		var leScale:Float = (bg.width - iconOffset - textOffset) / (modName.width);
		if (leScale < 1) {
			modName.scale.set(leScale, 1);
			modName.updateHitbox();
		}

		var modDescY = iconOffset + modName.height;
		modDesc = new FlxText(textOffset, modDescY, defaultWidth - textOffset - iconOffset, addon.description);
		modDesc.alpha = 0.5;
		modDesc.setFormat(Paths.font('default', false), 16);

		var leScale:Float = (defaultHeight - modDescY - iconOffset) / modDesc.height;
		if (leScale < 1) {
			modDesc.scale.set(1, leScale);
			modDesc.updateHitbox();
		}
		
		if (modName.scale.x >= 1 && modDesc.scale.y >= 1) {
			modName.y = (bg.height - modName.height - modDesc.height) / 2;
			modDesc.y = modName.y + modName.height;
		}

		add(bg);
		add(icon);
		add(modName);
		add(modDesc);

		this.onHover = function() {
			bg.color = 0x808000;
		}
		this.onIdle = function() {
			bg.color = 0x000000;
		}
		this.onIdle();
	}
}
