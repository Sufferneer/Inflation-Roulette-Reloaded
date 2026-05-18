package states.extras;

import flixel.addons.display.FlxGridOverlay;
import ui.objects.SuffIconButton;
import backend.typedefs.GalleryEnvelopeData;
import states.extras.GalleryMainMenuState;
import objects.CharacterSimple;
import objects.particleEmitters.ScrapEmitter;
import substates.GalleryArtworkSubState;
import flixel.graphics.FlxGraphic;

class GalleryEntryState extends SuffState {
	var allowInput:Bool = false;
	var showingCharacter:Bool = false;
	public static var envelopeData:GalleryEnvelopeData;
	var descriptionText:String = '';

	var bg:FlxSprite;
	var grid:FlxBackdrop;
	var topOverlay:FlxBackdrop;
	var bottomOverlay:FlxBackdrop;
	var overlay:FlxBackdrop;
	var render:FlxSprite;
	var character:CharacterSimple;
	var characterHitbox:FlxSprite;
	var title:FlxText;
	var description:FlxText;
	var characterButton:SuffIconButton;
	var artworkButton:SuffIconButton;
	var exitButton:SuffIconButton;

	var clickRate:Float = 0;

	override function create() {
		for (art in envelopeData.artwork) {
			Paths.image('ui/menus/extras/gallery/images/${envelopeData.id}/$art');
		}
		super.create();

		persistentDraw = true;

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
		bg.color = FlxColor.fromString(envelopeData.color);
		add(bg);

		overlay = new FlxBackdrop(Paths.image('ui/transitions/horizontal'), Y);
		overlay.x = FlxG.width / 2 - 40;
		if (bg.color.brightness > (1 / 3)) {
			// nice hue shifted dark-shaded color for overlay
			overlay.color = Utilities.getDarkerShade(bg.color);
		} else {
			// fuck it, if it's black enough you're getting the all-white white treatment
			overlay.color = 0xFFFFFFFF;
		}
		overlay.alpha = 0.5;
		overlay.velocity.set(0, 64);
		add(overlay);

		grid = new FlxBackdrop(FlxGridOverlay.createGrid(64, 64, 128, 128, true, 0x60FFFFFF, 0x0));
		grid.velocity.set(64, 64);
		add(grid);

		for (i in 0...Math.ceil(FlxG.height / 64)) {
			var text:FlxText = new FlxText(envelopeData.quotes[i % envelopeData.quotes.length], 64);
			text.font = Paths.font('default', false);
			var textBG:FlxBackdrop = new FlxBackdrop(text.graphic, X, 64);
			textBG.y = i * 64;
			textBG.alpha = 0.25;
			textBG.velocity.x = i % 2 == 0 ? -64 : 64;
			add(textBG);
		}

		topOverlay = new FlxBackdrop(Paths.image('ui/transitions/default'), X);
		topOverlay.y = -(FlxG.height + 80) + 40;
		topOverlay.color = 0x40FFFFFF;
		topOverlay.alpha = 0.375;
		topOverlay.velocity.set(-64, 0);
		add(topOverlay);

		bottomOverlay = new FlxBackdrop(Paths.image('ui/transitions/default'), X);
		bottomOverlay.y = (FlxG.height - 80) - 40;
		bottomOverlay.color = 0x40FFFFFF;
		bottomOverlay.alpha = 0.375;
		bottomOverlay.velocity.set(64, 0);
		add(bottomOverlay);

		var renderGraphic:FlxGraphic = Paths.image('ui/menus/extras/gallery/images/placeholderRender');
		if (Paths.fileExists(Paths.getImagePath('ui/menus/extras/gallery/images/${envelopeData.id}/${envelopeData.artwork[0]}')))
			renderGraphic = Paths.image('ui/menus/extras/gallery/images/${envelopeData.id}/${envelopeData.artwork[0]}');
		render = new FlxSprite(FlxG.width).loadGraphic(renderGraphic);
		var leScale = (FlxG.height - 120) / render.height;
		render.scale.set(leScale, leScale);
		render.updateHitbox();
		render.screenCenter(Y);
		add(render);
		FlxTween.tween(render, {x: FlxG.width / 2 + (FlxG.width / 2 - render.width) / 2}, 1, {
			ease: FlxEase.quintOut
		});

		var titleText = Language.getPhrase(envelopeData.titleTranslationKey, [], Language.getPhrase('galleryMainMenu.envelope.${envelopeData.id}'));
		title = new FlxText(60, 60, FlxG.width / 2 - 120, titleText, 64);
		title.color = overlay.color;
		add(title);

		descriptionText = Language.getPhrase('galleryMainMenu.envelope.${envelopeData.id}.description');
		description = new FlxText(title.x, title.y + title.height + 16, FlxG.width / 2 - title.x * 2, descriptionText, 32);
		description.font = Paths.font('default');
		while (description.height > FlxG.height - title.y - description.y) {
			description.size -= 1;
		}
		description.text = '';
		description.color = title.color;
		add(description);

		artworkButton = new SuffIconButton(20, 20, 'buttons/artwork', null, 2);
		artworkButton.x = FlxG.width - artworkButton.width - 20 - ScreenSafeZone.X;
		artworkButton.y = FlxG.height - artworkButton.height - 20 - ScreenSafeZone.Y;
		artworkButton.onClick = function() {
			openSubState(new GalleryArtworkSubState(envelopeData.id, envelopeData.artwork));
		};
		add(artworkButton);

		var hasJson:Bool = Paths.fileExists(Paths.getPath('data/characters/${envelopeData.id}/cosmetic.json'));
		var hasAddonJson:Bool = #if _ALLOW_ADDONS Paths.fileExists(Paths.addonFolders('data/characters/${envelopeData.id}/cosmetic.json')) #else false #end;
		if (envelopeData.hasCharacter && (hasJson || hasAddonJson)) {
			character = new CharacterSimple(envelopeData.id, 0, 0);
			character.playAnim('idle');
			character.x = FlxG.width + character.width / 2;
			character.y = FlxG.height - (FlxG.height - character.height) - 20;
			members.insert(members.indexOf(artworkButton) - 1, character);

			characterHitbox = new FlxSprite().makeGraphic(Std.int(FlxG.width / 2 - 320), FlxG.height - 320, 0x00);
			characterHitbox.x = FlxG.width / 2 + (FlxG.width / 2 - characterHitbox.width) / 2;
			characterHitbox.y = (FlxG.height - characterHitbox.height) / 2;
			characterHitbox.visible = false;
			add(characterHitbox);

			characterButton = new SuffIconButton(20, 20, 'buttons/character', null, 2);
			characterButton.x = artworkButton.x - artworkButton.width - 20;
			characterButton.y = artworkButton.y;
			characterButton.onClick = function() {
				toggleCharacter();
			}
			add(characterButton);
		}

		exitButton = new SuffIconButton(20, 20 + ScreenSafeZone.Y, 'buttons/exit', null, 2);
		exitButton.x = FlxG.width - exitButton.width - 20 - ScreenSafeZone.X;
		exitButton.onClick = function() {
			exitMenu();
		};
		add(exitButton);

		allowInput = true;
	}

	function toggleCharacter() {
		showingCharacter = !showingCharacter;
		if (showingCharacter) {
			FlxTween.cancelTweensOf(render);
			FlxTween.cancelTweensOf(character);
			FlxTween.tween(render, {x: FlxG.width}, 0.25, {
				ease: FlxEase.quintOut,
				onComplete: function(_) {
					character.popped = false;
					character.currentPressure = 0;
					character.playAnim('idle');
					characterHitbox.visible = character.getPressurePercentage() <= 1;
					character.disableBellySounds = character.getPressurePercentage() > 1;
					FlxTween.tween(character, {x: FlxG.width * 0.75}, 0.25, {
						ease: FlxEase.quintOut
					});
				}
			});
		} else {
			if (scraps != null)
				scraps.clear();
			characterHitbox.visible = false;
			character.disableBellySounds = true;
			FlxTween.tween(character, {x: FlxG.width + character.width / 2}, 0.25, {
				ease: FlxEase.quintOut,
				onComplete: function(_) {
					FlxTween.tween(render, {x: FlxG.width / 2 + (FlxG.width / 2 - render.width) / 2}, 0.25, {
						ease: FlxEase.quintOut
					});
				}
			});
		}
	}

	function exitMenu() {
		if (!allowInput) return;
		allowInput = false;
		SuffState.switchState(new GalleryMainMenuState());
	}

	var descriptionTick:Float = 0;
	var descriptionRate:Float = 1;
	var descriptionCurChar:Int = 0;

	final PAUSE_PUNCTUATION:String = ',.?!:;~';

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (!allowInput)
			return;

		descriptionTick += elapsed * descriptionRate;
		if (descriptionTick > 0.02 && descriptionCurChar < descriptionText.length) {
			var curChar = descriptionText.substr(descriptionCurChar, 1);
			description.text = description.text + curChar;
			if (descriptionCurChar % 3 == 0) {
				SuffState.playUISound(Paths.soundRandom('ui/type', 1, 4), 0.8);
			}
			if (curChar == '\n') {
				SuffState.playUISound(Paths.sound('ui/typeEnter'));
			}
			descriptionTick = 0;
			if (PAUSE_PUNCTUATION.contains(curChar))
				descriptionTick = -0.125;
			descriptionCurChar++;
			if (descriptionCurChar == descriptionText.length)
				SuffState.playUISound(Paths.sound('ui/typeEnter'));
		}

		descriptionRate = FlxG.mouse.pressed ? 10 : 1;

		if (Controls.justPressed('exit')) {
			exitMenu();
		}

		if (character == null || !characterHitbox.visible)
			return;
		if (FlxG.mouse.overlaps(characterHitbox, this.camera) && FlxG.mouse.justPressed) {
			clickRate += 1;
			character.currentPressure++;
			if (character.currentPressure <= character.maxPressure) {
				var fwoompSuffix:String = character.getPressurePercentage() >= 0.5 ? 'Large' : 'Small';
				SuffState.playSound(Paths.soundRandom('game/belly/fwoomps/fwoomp' + fwoompSuffix, 1, Constants.FWOOMPS_SAMPLE_COUNT), 0.75, 0.5);
				character.playAnim('shocked', true);
				if (idleTimer != null) idleTimer.cancel();
				idleTimer = new FlxTimer().start(1.0, function(_) {
					character.playAnim('idle', true);
				});
			} else {
				if (clickRate > 5 && !character.disableBellySounds && Preferences.data.enablePopping) {
					character.disableBellySounds = true;
					character.popped = true;
					SuffState.playSound(Paths.sound('game/belly/burst'));
					if (!Preferences.data.enablePhotosensitiveMode)
						FlxG.camera.flash(0xFFFFFFFF, 0.125);
					FlxG.camera.shake(0.02 * Preferences.data.cameraEffectIntensity, 0.125);
					character.playAnim('idle', true);
					scraps = new ScrapEmitter(character.x, character.y - character.height / 2.5, character.id, 690);
					members.insert(members.indexOf(artworkButton) - 1, scraps);
				} else {
					character.playAnim('helpless', true);
				}
			}
		}
		clickRate *= (1 - elapsed);
	}

	var idleTimer:FlxTimer;
	var scraps:ScrapEmitter;
}