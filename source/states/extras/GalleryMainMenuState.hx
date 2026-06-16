package states.extras;

import ui.objects.SuffIconButton;
import flixel.addons.display.FlxGridOverlay;
import ui.objects.GalleryEnvelope;
import states.extras.GalleryEntryState;

class GalleryMainMenuState extends SuffState {
	var allowInput:Bool = false;

	var bg:FlxSprite;
	var grid:FlxBackdrop;
	var envelopes:FlxTypedContainer<GalleryEnvelope> = new FlxTypedContainer<GalleryEnvelope>();
	var exitButton:SuffIconButton;

	var envelopeWidth:Float = 0;
	final envelopeSpacing:Float = 80;

	override function create() {
		super.create();

		Window.setTitle(Language.getPhrase('galleryMainMenu.windowDisplay'));

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
		bg.color = 0xFFE0E0E0;
		bg.scrollFactor.set();
		add(bg);

		grid = new FlxBackdrop(FlxGridOverlay.createGrid(64, 64, 128, 128, true, 0x60FFFFFF, 0x00FFFFFF));
		grid.scrollFactor.set();
		grid.velocity.set(64, 64);
		add(grid);

		add(envelopes);
		var list:Array<String> = Paths.readDirectories('data/extras/gallery/envelopes', 'data/extras/gallery/envelopes/envelopeList.txt', 'json');
		list.remove('dev');
		list.push('dev');
		list.remove('community');
		list.push('community');
		// Make sure dev envelope is at the last
		for (num => item in list) {
			var envelope:GalleryEnvelope = new GalleryEnvelope(0, 0, item);
			envelopeWidth = envelope.width + envelopeSpacing * (list.length - 1);
			envelope.originalPos = FlxPoint.get((FlxG.width - envelopeWidth) / 2 + num * envelopeSpacing, (FlxG.height - envelope.height) / 2);
			envelope.x = envelope.intendedPos.x = envelope.originalPos.x;
			envelope.y = envelope.intendedPos.y = FlxG.height;
			FlxTween.tween(envelope, {'intendedPos.y': envelope.originalPos.y}, 0.75, {
				ease: FlxEase.quintOut,
				startDelay: 0.1 * num,
				onStart: function(_) {
					SuffState.playUISound(Paths.soundRandom('game/weapon', 1, 3), 1, 2.25 + Math.random() * 0.25);
				},
				onUpdate: function(_) {
					envelope.y = envelope.intendedPos.y;
				}
			});
			envelope.onClick = function() {
				confirmSelection();
			};
			envelopes.add(envelope);
		}

		exitButton = new SuffIconButton(20, 20 + ScreenSafeArea.Y, 'buttons/exit', null, 2);
		exitButton.x = FlxG.width - exitButton.width - 20 - ScreenSafeArea.X;
		exitButton.onClick = function() {
			exitMenu();
		};
		add(exitButton);

		new FlxTimer().start(1, function(_){
			allowInput = true;
		});
	}

	function exitMenu() {
		if (!allowInput) return;
		allowInput = false;
		SuffState.switchState(new MainMenuState());
	}

	function confirmSelection() {
		allowInput = false;
		for (num => item in envelopes.members) {
			item.disabled = true;
			if (num == selectedIndex) {
				GalleryEntryState.envelopeData = item.envelopeData;
				FlxTween.tween(item, {
					'intendedPos.x': (FlxG.width - item.width) / 2,
					'intendedPos.y': (FlxG.height - item.height) / 2,
					angle: 0
				}, 0.25, {
					ease: FlxEase.quintOut
				});
				FlxTween.color(bg, 0.5, bg.color, FlxColor.fromString(item.envelopeData.color));
			} else {
				FlxTween.tween(item, { 'intendedPos.y': FlxG.height * 1.25 }, 0.25, {
					ease: FlxEase.quintOut
				});
			}
		}
		new FlxTimer().start(0.5, function(_) {
			SuffState.switchState(new GalleryEntryState());
		});
	}

	var selectedIndex:Int = 0;

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (!allowInput)
			return;

		selectedIndex = Math.floor((FlxG.mouse.getScreenPosition(this.camera).x - (FlxG.width - envelopeWidth) / 2)
		/ (envelopeWidth / envelopes.members.length));
		selectedIndex = Std.int(FlxMath.bound(selectedIndex, 0, envelopes.members.length - 1));
		var selectedMember = envelopes.members[selectedIndex];
		selectedMember.intendedPos.x = selectedMember.originalPos.x;
		for (num => item in envelopes.members) {
			item.disabled = num != selectedIndex;
			if (num != selectedIndex) {
				item.intendedPos.y = (FlxG.height - item.height) / 2 + envelopeSpacing * 2;
				if (num > selectedIndex) {
					item.intendedPos.x = selectedMember.originalPos.x + selectedMember.width / 2 + envelopeSpacing * (num -
					selectedIndex);
				} else if (num < selectedIndex) {
					item.intendedPos.x = selectedMember.originalPos.x - selectedMember.width / 2 + envelopeSpacing * (num -
					selectedIndex);
				}
			} else {
				item.intendedPos.y = (FlxG.height - item.height) / 2;
			}
		}
		if (Controls.justPressed('exit')) {
			exitMenu();
		}
	}
}