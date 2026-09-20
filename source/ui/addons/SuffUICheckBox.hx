package ui.addons;

import flixel.addons.ui.FlxUICheckBox;

class SuffUICheckBox extends FlxUICheckBox {
	public function new(X:Float = 0, Y:Float = 0, ?Box:Dynamic, ?Check:Dynamic, ?Label:String, ?LabelW:Int = 256, ?Params:Array<Dynamic>, ?Callback:Void->Void) {
		super(X, Y, Box, Check, Label, LabelW, Params, Callback);
		this.button.label.size = 16;
		this.textX = 4;
		this.textY = -8;
	}
}
