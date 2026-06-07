package utilities.objects;

import utilities.enums.ExplorerFileFileType;

class ExplorerFile extends SuffButton {
	public static final size:Int = 112;
	var fileIcon:FlxSprite;
	var fileNameTxt:FlxText;
	var icon:FlxSprite;
	var hoverBG:FlxSprite;

	public var name:String = 'newFile';
	public var fileType:ExplorerFileFileType;

	public function new(x:Float, y:Float, name:String = 'newFile', fileType:ExplorerFileFileType = file, iconPath:String = null) {
		super(x, y, null, null, null, size, size, false);

		this.name = name;
		this.fileType = fileType;

		hoverBG = new FlxSprite().makeGraphic(size, size, 0xFFFFFFFF);
		hoverBG.alpha = 0.25;
		add(hoverBG);

		fileIcon = new FlxSprite().loadGraphic(Paths.image('ui/menus/utilities/explorer/' + '${fileType}'));
		fileIcon.setGraphicSize(Std.int(size / 235 * fileIcon.width));
		fileIcon.updateHitbox();

		fileNameTxt = new FlxText(0, 0, size, name, 16);
		fileNameTxt.font = Paths.font('small', false);
		fileNameTxt.alignment = CENTER;

		fileIcon.x = (size - fileIcon.width) / 2;
		fileIcon.y = (size - (fileIcon.height + fileNameTxt.height)) / 2;
		fileNameTxt.y = (size - (fileIcon.height + fileNameTxt.height)) / 2 + fileIcon.height;

		icon = new FlxSprite();
		if (iconPath != null && iconPath.length > 0) {
			icon.loadGraphic(Paths.image('ui/menus/utilities/explorer/icons/$iconPath'));
			icon.setGraphicSize(Std.int(size / 235 * icon.width));
			icon.updateHitbox();
		} else
			icon.alpha = 0;
		icon.x = fileIcon.x + (fileIcon.width - icon.width) / 2;
		icon.y = fileIcon.y + (fileIcon.height - icon.height) / 2;

		add(fileIcon);
		add(fileNameTxt);
		add(icon);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		hoverBG.visible = hovered;
	}
}
