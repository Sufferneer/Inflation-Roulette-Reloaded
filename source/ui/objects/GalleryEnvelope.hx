package ui.objects;

import backend.typedefs.GalleryEnvelopeData;
import tjson.TJSON as Json;

class GalleryEnvelope extends SuffButton {
	var base:FlxSprite;
	var string:FlxSprite;
	var text:FlxText;

	public var envelopeData:GalleryEnvelopeData;
	public var originalPos:FlxPoint;
	public var intendedPos:FlxPoint;
	var seed:Int = 0;

	static final speedLerp:Float = 12;

	public function new(x:Float, y:Float, envelopeID:String) {
		for (i in 0...envelopeID.length)
			seed += envelopeID.fastCodeAt(i);

		var what = Paths.getImage('ui/menus/extras/gallery/envelope');
		super(x, y, null, null, null, what.width, what.height, false);
		this.clickSound = '';
		this.hoverSound = 'ui/extras/gallery/envelopeHover';
		this.releaseSound = 'ui/extras/gallery/envelopeClick';

		this.envelopeData = cast Json.parse(Paths.getTextFromFile('data/extras/gallery/envelopes/$envelopeID.json'));
		if (this.envelopeData == null) {
			trace('Gallery Envelope $envelopeID does not exist. Using goober\'s');
			this.envelopeData = cast Json.parse(Paths.getTextFromFile('data/extras/gallery/envelopes/goober.json'));
		}
		this.envelopeData.id = envelopeID;

		base = new FlxSprite().loadGraphic(what);
		var leColor = FlxColor.fromString(envelopeData.color);
		var hue = leColor.hue;
		var saturation = leColor.saturation;
		var brightness = leColor.brightness;
		base.color = FlxColor.fromHSB(hue, saturation * 0.25, Math.min(1, brightness * 1.33), 1);
		add(base);

		var sticker:FlxSprite = new FlxSprite().loadGraphic(Paths.getImage
		('ui/menus/extras/gallery/envelopeStickers/$envelopeID'));
		sticker.x = (base.width - sticker.width) / 2 + randomNum(-20, 20);
		sticker.y = (base.height - sticker.height) / 2 + 100 + randomNum(-20, 20);
		sticker.angle = randomNum(-30, 30);
		add(sticker);

		string = new FlxSprite().loadGraphic(Paths.getImage('ui/menus/extras/gallery/envelopeString'));
		add(string);

		text = new FlxText(0, 144, 0, Language.getPhrase(envelopeData.titleTranslationKey, [], Language.getPhrase('galleryMainMenu.envelope.${envelopeData.id}')), 64);
		if (Language.getPhrase('galleryMainMenu.envelope.rotateText') == 'true') {
			if (text.width > (base.height - text.y - 64)) {
				text.scale.x = (base.height - text.y - 64) / text.width;
				text.updateHitbox();
			}
			text.offset.x += text.width / 2 - text.size * 0.75;
			text.offset.y += -text.width * 0.5 + text.size * 0.25;
			text.angle = 90;
		} else {
			text.fieldWidth = text.size;
			if (text.height > (base.height - text.y - 64)) {
				text.scale.y = (base.height - text.y - 64) / text.height;
				text.updateHitbox();
			}
			text.offset.x -= text.size * 0.25;
			text.offset.y -= text.size * 0.25;
		}
		text.angle += randomNum(-3, 3);
		text.color = 0xFF000000;
		text.alpha = 0.375;
		add(text);

		intendedPos = originalPos = FlxPoint.get(x, y);

		this.angle = randomNum(-5, 5);
	}

	function randomNum(min:Float = 0, max:Float = 1):Float {
		// Linear Congruential Generator
		this.seed = (this.seed * 25 + 102803) % 236196;
		return min + this.seed / 236195 * (max - min);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		this.x = FlxMath.lerp(this.x, intendedPos.x, elapsed * speedLerp);
		this.y = FlxMath.lerp(this.y, intendedPos.y, elapsed * speedLerp);
	}
}
