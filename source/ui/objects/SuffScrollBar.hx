package ui.objects;

class SuffScrollBar extends FlxSpriteGroup {
    var bg:FlxSprite;
    var bar:FlxSprite;

    public var scrollWidth:Array<Float> = [];
    public var mouseScrollWidth:Array<Float> = [];
    public var scrollingUsingMouse:Bool = false;
    public var scrollCallback:Float->Void = null;
    public var autoScrollVelocity:Float = 0;
    public var scrollInBG:Bool = false;
    public var scrollMultiplier:Float = 1;
    public var disabled:Bool = false;

    public function reloadDimensions(width:Float = 32, scrollHeight:Float = 1080) {
        bg.makeGraphic(Std.int(width), Std.int(FlxG.height - this.y), 0xFFFFFFFF);
        bg.alpha = 0.375;
        bar.makeGraphic(Std.int(bg.width), Std.int(bg.height / scrollHeight * bg.height), 0xFFFFFFFF);
        bar.alpha = 0.5;
        resetPercent();
    }

	public function new(x:Float = 0, y:Float = 0, scrollCallback:Float->Void = null, width:Float = 32, scrollHeight:Float = 1080, scrollWidth:Array<Float> = null, mouseScrollWidth:Array<Float> = null) {
        super();
        this.scrollCallback = scrollCallback;
        this.scrollWidth = (scrollWidth != null) ? scrollWidth : [-16, 16];
        this.mouseScrollWidth = (mouseScrollWidth != null) ? mouseScrollWidth : [-FlxG.width / 2, FlxG.width / 2];
        bg = new FlxSprite();
        bar = new FlxSprite();
        reloadDimensions(width, scrollHeight);

        add(bg);
        add(bar);

        this.x = x;
        this.y = y;
	}

    public function resetPercent() {
        bar.y = this.y;
        if (scrollCallback != null)
            scrollCallback(0);
    }

    public function updateScrollBar(delta:Float = 0) {
        bar.y = this.y + FlxMath.bound(bar.y + delta, this.y, this.y + bg.height - bar.height);
        if (scrollCallback != null)
            scrollCallback(Utilities.invLerp(this.y, this.y + bg.height - bar.height, bar.y));
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        if (disabled) return;
        if (scrollingUsingMouse) {
            if (FlxG.mouse.pressed) {
                updateScrollBar(FlxG.mouse.deltaScreenY * scrollMultiplier);
            }
            if (FlxG.mouse.released) {
                scrollingUsingMouse = false;
            }
        }
        var mousePos:FlxPoint = FlxG.mouse.getScreenPosition(this.camera);
        if (!scrollingUsingMouse) {
            updateScrollBar(elapsed * autoScrollVelocity);
            if (mousePos.x >= bar.x + scrollWidth[0] && mousePos.x <= bar.x + bar.width + scrollWidth[1]) {
                if ((mousePos.y >= bar.y && mousePos.y <= bar.y + bar.height) || scrollInBG) {
                    if (FlxG.mouse.justPressed)
                        scrollingUsingMouse = true;
                }
            }
            if (FlxG.mouse.wheel != 0) {
                if (mousePos.x >= bar.x + mouseScrollWidth[0] && mousePos.x <= bar.x + bar.width + mouseScrollWidth[1]) {
                    FlxTween.cancelTweensOf(bar, ['y']);
                    FlxTween.tween(bar, {'y': this.y + FlxMath.bound(bar.y - FlxG.mouse.wheel * 48, this.y, this.y + bg.height - bar.height)}, 0.5, {
                        ease: FlxEase.quintOut,
                        onUpdate: function(_) {
                            if (bg != null && bar != null && scrollCallback != null) {
                                try {
                                    scrollCallback(Utilities.invLerp(this.y, this.y + bg.height - bar.height, bar.y));
                                } catch(e:Dynamic) {
                                    
                                }
                            }
                        }
                    });
                }
            }
        }
    }
}
