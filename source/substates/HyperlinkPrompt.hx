package substates;

class HyperlinkPrompt extends ChoicePrompt {
	public function new(hyperlink:String, flipChoices:Bool = false) {
		var text:FlxText = new FlxText(hyperlink, 32);
		super(Language.getPhrase('hyperlink.prompt', [hyperlink]), function() {
			Utilities.browserLoad(hyperlink);
		}, Std.int(Math.max(320, text.width + 64)));
		text.destroy();
	}
}
