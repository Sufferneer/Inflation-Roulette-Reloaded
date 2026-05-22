package ui.objects;

import openfl.geom.Rectangle;
import flixel.graphics.FlxGraphic;
import flixel.addons.ui.FlxUI9SliceSprite;

/**
 * Custon button object used in UIs.
 */
class SuffButton extends FlxSpriteGroup {
	public var disabled(default, set):Bool = false;
	public var visibleBG:Bool = true;
	public var hovered:Bool = false;
	public var clicked:Bool = false;
	public var onIdle:Void->Void = null;
	public var onHover:Void->Void = null;
	public var onClick:Void->Void = null;

	public var btnTextTxt(default, set):String = '';
	public var btnTextColor(default, set):FlxColor = 0xFFFFFFFF;
	public var btnTextColorHovered:FlxColor = 0xFFFFFFFF;
	public var btnTextColorClicked:FlxColor = 0xFFFFFFFF;
	public var btnTextColorDisabled:FlxColor = 0xFF808080;
	public var btnTextSize(default, set):Int = 48;
	public var btnTextAlpha(default, set):Float = 1;
	public var btnTextFontPath(default, set):String = Paths.font('default');

	public var btnBGColor(default, set):FlxColor = 0xFF0F4894;
	public var btnBGColorHovered:FlxColor = 0xFF4F9BFF;
	public var btnBGColorClicked:FlxColor = 0xFF006EFF;
	public var btnBGColorDisabled:FlxColor = 0xFF3F5B7F;
	public var btnBGAlpha(default, set):Float = 1;

	public var btnOutlineColor(default, set):FlxColor = 0xFF008FB5;
	public var btnOutlineColorHovered:FlxColor = 0xFF008FB5;
	public var btnOutlineColorClicked:FlxColor = 0xFFFFFFFF;
	public var btnOutlineColorDisabled:FlxColor = 0xFF008FB5;
	public var btnOutlineAlpha(default, set):Float = 1;

	public var clickSound:String = 'ui/buttonClick';
	public var releaseSound:String = 'ui/buttonRelease';
	public var hoverSound:String = 'ui/buttonHover';

	public var btnBG:FlxUI9SliceSprite;
	public var btnOutline:FlxUI9SliceSprite;
	public var btnText:FlxText;
	public var btnIcon:FlxSprite = null;

	public var btnIconImage:FlxGraphic = null;
	public var btnIconImageHovered:FlxGraphic = null;

	public var tooltipText:String = '';

	var btnBGScaleTween:FlxTween;
	var btnOutlineScaleTween:FlxTween;
	var btnBGColorTween:FlxTween;
	var btnOutlineColorTween:FlxTween;
	var btnTextColorTween:FlxTween;
	var btnScaleTweens:Array<FlxTween> = [];

	static final iconPadding:Int = 0;
	static final bgScale:Int = 2;

	/**
	 * @param x The X position of the button.
	 * @param y The Y position of the button.
	 * @param text The text displayed on the button. Set to `null` to hide.
	 * @param img The image displayed on the button. Set to `null` to hide.
	 * @param imgHovered The image displayed on the button when hovered. Set to `null` to use `img`.
	 * @param width The hitbox width of the button.
	 * @param height The hitbox height of the button.
	 * @param visibleBG Whether the default button background is visible or not.
	 */
	public function new(x:Float, y:Float, ?text:String = null, ?img:FlxGraphic = null, ?imgHovered:FlxGraphic = null, ?width:Float = 300, ?height:Float = 100,
			visibleBG:Bool = true) {
		super();

		var leWidth = Std.int(width);
		var leHeight = Std.int(height);

		var btnBGRect = new Rectangle(0, 0, leWidth / bgScale, leHeight / bgScale);
		var nineSlice = [20, 10, 44, 22];

		btnBG = new FlxUI9SliceSprite(0, 0, Paths.getImagePath('ui/boxes/boxBase'), btnBGRect, nineSlice, 0x11);
		btnBG.setGraphicSize(Std.int(leWidth), Std.int(leHeight));
		btnBG.updateHitbox();
		btnBG.color = btnBGColor;
		btnBG.alpha = btnBGAlpha;
		btnBG.visible = visibleBG;
		add(btnBG);

		btnOutline = new FlxUI9SliceSprite(0, 0, Paths.getImagePath('ui/boxes/boxOutline'), btnBGRect, nineSlice, 0x11);
		btnOutline.setGraphicSize(Std.int(leWidth), Std.int(leHeight));
		btnOutline.updateHitbox();
		btnOutline.color = btnOutlineColor;
		btnOutline.alpha = btnOutlineAlpha;
		btnOutline.visible = visibleBG;
		add(btnOutline);

		this.visibleBG = visibleBG;

		if (text != null) {
			btnText = new FlxText(0, 0, 0, text);
			btnText.setFormat(btnTextFontPath, btnTextSize, 0xFFFFFFFF, CENTER);
			while ((btnText.width > (btnBG.width - btnTextSize * 2 / 3.5) || btnText.height > (btnBG.height - btnTextSize * 2 / 3)) && btnTextSize > 16) {
				btnTextSize -= 1;
				btnText.size = btnTextSize;
			}
			btnText.y = (btnBG.height - btnText.height) / 2;
			btnText.alpha = btnTextAlpha;
			add(btnText);
		}
		if (img != null) {
			btnIconImage = img;
			if (imgHovered != null) {
				btnIconImageHovered = imgHovered;
			} else {
				btnIconImageHovered = btnIconImage;
			}
			btnIcon = new FlxSprite(0, 0);
			switchIconImage(btnIconImage);
			add(btnIcon);
		}
		centerStuffOnBG();

		camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];

		this.x = x;
		this.y = y;
	}

	function centerStuffOnBG() {
		var textWidth = ((btnText != null && btnText.text.length > 0) ? btnText.width : 0);
		var iconWidth = (btnIcon != null ? btnIcon.width : 0);
		var finalWidth = textWidth + iconWidth;
		if (btnText != null) {
			btnText.x = Std.int(btnBG.x + (btnBG.width - finalWidth) / 2 + iconWidth);
			btnText.y = Std.int(btnBG.y + (btnBG.height - btnText.height) / 2);
		}
		if (btnIcon != null) {
			btnIcon.x = Std.int(btnBG.x + (btnBG.width - finalWidth) / 2 - textWidth);
			btnIcon.y = Std.int(btnBG.y + (btnBG.height - btnIcon.height) / 2);
		}
	}

	private function set_disabled(value:Bool):Bool {
		disabled = value;
		btnBG.color = !value ? btnBGColor : btnBGColorDisabled;
		btnOutline.color = !value ? btnOutlineColor : btnOutlineColorDisabled;
		if (btnText != null)
			btnText.color = !value ? btnTextColor : btnTextColorDisabled;
		return value;
	}

	private function set_btnTextTxt(value:String):String {
		btnTextTxt = value;
		if (btnText != null)
			btnText.text = btnTextTxt;
		centerStuffOnBG();
		return btnTextTxt;
	}

	private function set_btnTextColor(value:FlxColor):FlxColor {
		btnTextColor = value;
		if (btnText != null)
			btnText.color = btnTextColor;
		if (btnIcon != null)
			btnIcon.color = btnTextColor;
		return btnTextColor;
	}

	private function set_btnTextAlpha(value:Float):Float {
		btnTextAlpha = value;
		if (btnText != null)
			btnText.alpha = btnTextAlpha;
		if (btnIcon != null)
			btnIcon.alpha = btnTextAlpha;
		return btnTextAlpha;
	}

	private function set_btnTextSize(value:Int):Int {
		btnTextSize = value;
		if (btnText != null) {
			btnText.size = btnTextSize;
			btnText.updateHitbox();
		}
		centerStuffOnBG();
		return btnTextSize;
	}

	private function set_btnTextFontPath(value:String):String {
		btnTextFontPath = value;
		if (btnText != null) {
			btnText.font = btnTextFontPath;
			btnText.updateHitbox();
		}
		centerStuffOnBG();
		return btnTextFontPath;
	}

	private function set_btnBGAlpha(value:Float):Float {
		btnBGAlpha = value;
		btnBG.alpha = btnBGAlpha;
		return btnBGAlpha;
	}

	private function set_btnBGColor(value:FlxColor):FlxColor {
		btnBGColor = value;
		btnBG.color = btnBGColor;
		return btnBGColor;
	}

	private function set_btnOutlineAlpha(value:Float):Float {
		btnOutlineAlpha = value;
		btnOutline.alpha = btnOutlineAlpha;
		return btnOutlineAlpha;
	}

	private function set_btnOutlineColor(value:FlxColor):FlxColor {
		btnOutlineColor = value;
		btnOutline.color = btnOutlineColor;
		return btnOutlineColor;
	}

	override function update(elapsed:Float) {
		if (FlxG.mouse.overlaps(btnBG, this.camera) && visible) {
			if (!hovered) {
				hoverButton();
				if (!disabled && onHover != null)
					onHover();
				hovered = true;
			}
			if (hovered) {
				if (Tooltip.text == '')
					Tooltip.text = tooltipText;
				if (!disabled && FlxG.mouse.pressed) {
					if (!clicked)
						clickButton();
					clicked = true;
				}
			}
			if (FlxG.mouse.justReleased && clicked) {
				if (Tooltip.text != '')
					Tooltip.text = '';
				if (!disabled && onClick != null)
					onClick();
				if (releaseSound != '')
					SuffState.playUISound(Paths.sound(releaseSound));
				idleButton();
				clicked = false;
			}
		} else {
			if (hovered) {
				clicked = false;
				idleButton();
				if (onIdle != null)
					onIdle();
				hovered = false;
			}
		}
		
		btnBG.visible = visibleBG && this.visible;
		btnOutline.visible = visibleBG && this.visible;

		super.update(elapsed);
	}

	function hoverButton() {
		if (disabled)
			return;
		if (btnBGScaleTween != null)
			btnBGScaleTween.cancel();
		btnBGScaleTween = FlxTween.tween(btnBG.scale, {x: bgScale * 1.1, y: bgScale * 1.1}, 0.15);
		if (btnOutlineScaleTween != null)
			btnOutlineScaleTween.cancel();
		btnOutlineScaleTween = FlxTween.tween(btnOutline.scale, {x: bgScale * 1.1, y: bgScale * 1.1}, 0.15);
		tweenColor(!disabled ? btnBGColorHovered : btnBGColorDisabled, !disabled ? btnOutlineColorHovered : btnOutlineColorDisabled,
			!disabled ? btnTextColorHovered : btnTextColorDisabled);
		if (btnIcon != null && !disabled)
			switchIconImage(btnIconImageHovered);
		if (hoverSound != '')
			SuffState.playUISound(Paths.sound(hoverSound));
	}

	public function switchIconImage(img:FlxGraphic) {
		btnIcon.loadGraphic(img);
		btnIcon.setGraphicSize(btnBG.width, btnBG.height);
		btnIcon.updateHitbox();

		centerStuffOnBG();
	}

	function clickButton() {
		if (disabled)
			return;
		tweenColor(!disabled ? btnBGColorClicked : btnBGColorDisabled, !disabled ? btnOutlineColorClicked : btnOutlineColorDisabled,
			!disabled ? btnTextColorClicked : btnTextColorDisabled);
		if (btnIcon != null && !disabled)
			btnIcon.color = btnTextColorClicked;
		if (clickSound != '')
			SuffState.playUISound(Paths.sound(clickSound));
	}

	function idleButton() {
		tweenColor(!disabled ? btnBGColor : btnBGColorDisabled, !disabled ? btnOutlineColor : btnOutlineColorDisabled,
			!disabled ? btnTextColor : btnTextColorDisabled);
		if (btnBGScaleTween != null)
			btnBGScaleTween.cancel();
		btnBGScaleTween = FlxTween.tween(btnBG.scale, {x: bgScale, y: bgScale}, 0.15);
		if (btnOutlineScaleTween != null)
			btnOutlineScaleTween.cancel();
		btnOutlineScaleTween = FlxTween.tween(btnOutline.scale, {x: bgScale, y: bgScale}, 0.15);
		if (btnText != null && !disabled)
			btnText.color = btnTextColor;
		if (btnIcon != null && !disabled)
			switchIconImage(btnIconImage);
		if (tooltipText != '')
			Tooltip.text = '';
	}

	function tweenColor(finalBGColor:FlxColor, finalOutlineColor:FlxColor, finalTextColor:FlxColor) {
		if (btnBGColorTween != null)
			btnBGColorTween.cancel();
		if (btnOutlineColorTween != null)
			btnOutlineColorTween.cancel();
		if (btnTextColorTween != null)
			btnTextColorTween.cancel();
		if (btnBG.color != finalBGColor)
			btnBGColorTween = FlxTween.color(btnBG, 0.1, btnBG.color, finalBGColor);
		if (btnOutline.color != finalOutlineColor)
			btnOutlineColorTween = FlxTween.color(btnOutline, 0.1, btnOutline.color, finalOutlineColor);
		/*
		if (btnText != null && btnText.color != finalTextColor)
			btnTextColorTween = FlxTween.color(btnText, 0.1, btnText.color, finalTextColor);
		*/
	}
}
