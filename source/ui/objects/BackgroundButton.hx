package ui.objects;

class BackgroundButton extends SuffButton {
	var buttonText:FlxText;

	public function new(x:Float, y:Float, text:String = 'extrasMenu.gallery', image:String = 'extras/gallery') {
		var graphic = Paths.getImage('ui/menus/$image');
		var graphicHighlighted = Paths.getImage('ui/menus/${image}Highlighted');
		super(x, y, null, graphic, graphicHighlighted, graphic.width, graphic.height, false);

		buttonText = new FlxText(0, this.height + 8, this.width, Language.getPhrase(text));
		buttonText.setFormat(Paths.getFont('default'), 48, 0xFFFFFFFF, CENTER);
		add(buttonText);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		btnBG.visible = false;
		btnOutline.visible = false;
	}
}
