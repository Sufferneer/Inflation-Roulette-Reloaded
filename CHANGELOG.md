# Changelog
All notable changes to this project will be documented in this file.

This project adheres to this versioning: `MAJOR.MINOR.HOTFIX`.

Minor updates will be referred to as _Pitstops_.

## v2.2.0 - Patch of Creativity, Pitstop 2 - 2026-05-21
### Additions
#### Cosmetic
- A bunch of visual effects.
#### Localization
- Added Catalan and Spanish (Mexico) translations.
#### Quality of Life
- Exit button in Character Select
#### Technical
- Android build (beta version, does not support modding yet).
- Version checking to alert you on the latest version of IRR. 
  - This can be disabled in the Options menu
  - Only supports versions >=2.2.0
- Operations are now output on console on the Preload menu.
### Changes
#### Audio
- Replaced some gameplay sounds.
#### Cosmetic
- Increased chance of Cobalt's appearance.
- Splash text now supports Unicode characters.
- Tooltips now switches over to the mouse's left position if it is out-of-bounds
- Language Select Menu now includes translation progress for each language
    - Tap the progress text to see which translation keys are missing.
- Recolored Goober's blush to match other characters'
- Decreased Asimo's gurgle threshold
- Increased visibility of Skill icons on white backgrounds
#### Gameplay
- Quick Play now randomizes player position.
#### Technical
- All changelogs are now kept in one file.
- Skill Cards now only uses one file
#### Utilities
- Character Editor now generates addon metadata and localization files for you.
### Fixes
- Scroll bars, Gallery Image View, Credits menu, and Options sliders snaps elements in place on touchscreens.
- Blurry Cobalt crashes the game.
- Asimo's gallery entry bounded in Desktop builds even when Example Addon is removed.
- ~~Character Editor exporting Character Select Cards incorrectly.~~
- ~~Character Editor exporting every sprite sheet incorrectly~~
- Character Editor exporting everything incorrectly
- Characters always score the minimum edging bonus even when inflated just once
- _Backfire_ achievement now only works for non-CPU characters

## v2.1.1 - Patch of Creativity, Pitstop 1 Hotfix 1 - 2026-04-19
### Changes
#### Internal
- Updated to Lime 8.3.1 and OpenFL 9.5.0
### Removals
- Removed TGA option from Browse File prompt
### Fixes
- _that gun look fire_ artwork being captioned incorrectly
- Missing icon on Linux build
- Creating a new character in the Character Creator crashes the game on Linux
- Stage Viewer non-functional on Linux

## v2.1.0 - Patch of Creativity, Pitstop 1 - 2026-04-19
### Additions
#### Cosmetic
- [ow]o
- New Gallery Entry specifically for showcasing the fruits of our labors
- Don't play at 9:21 PM.
#### Audio & Music
- Preload Screen now precaches music.
- Added _Yippers_ to the Jukebox.
#### Quality of Life
- Added Controls menu.
### Changes
#### Gameplay
- CPU less likely to use certain skills twice in a row if it doesn't benefit them.
- Improved CPU AI.
#### Cosmetic
- Tweaked the appearance of the Shitfucks stage.
- Upscaled Ajuniga's appearance in the Language Select Menu.
- Secret special effects now appear at a higher chance.
- Title and description text in Gallery Menus are now centered correctly.
- Icons of Addon Menu Items in the Addons Menu is now positioned correctly.
- Name text of Addon Menu Items is now scaled correctly to fit its bounding box.
#### Quality of Life
- Ajuniga's animation will now only play once.
- Pressing SHIFT while restarting the game now replays the starting cutscene.
#### Internal
- Updated splashes.
- Jukebox Capsule Text is now handled using a sprite sheet instead of individual sprites
### Removals
#### Internal
- Removed Hide Cursor option
### Fixes
- Asimo's navel and blush toggling between visible and invisible in helpless/idle animations.
- Asimo's Gallery entry being absent in the HTML Build.
- Gaussian Blur shader causes crashes.
- CPUs use offensive skills against themselves when there's no suitable target.
- Animation sprite sets can sometimes split between two spritesheets.
- Chester missing from _All My Fellas_ achievement.
- Fifty-Fifty missing from _Full Tour_ achievement.
- Cylinder contents is revealed briefly when CPUs uses the ability.

## v2.0.0 - Patch of Creativity - 2026-04-08
### Additions
#### Features
##### Modding Tools!
You can finally make your own characters in-game with the built-in editors!
##### Achievements!
A bunch of achievements has been added to the game, varying in difficulty. Collect them all if you dare...
##### Results Screen!
Along with a ranking system, a results screen is added to display the player's performance for each game.
##### Stages!
Updated stages, as well as adding new ones!
##### New Characters!
Introducing Shibanou and Chester! Two new characters for our Character Roster!
#### Minor Features
- Russian translation by ZoiDBoT!
- Skill level for CPU characters!
- Gallery and Jukebox Menu!
- 1v1 and Six-Player Mode!
- Preload Screen for Desktop Builds!
- Clicking on the game logo is highly discouraged.
#### Cosmetic
- Added _Suffirat Small_, a smaller variant of the game UI font. Supports Basic Latin, Latin-1 Supplement, Latin Extended-A, and Cyrillic.
### Changes
#### Cosmetic
- Scraps and confetti no longer fade out and despawn.
- Updated some glyphs in _Suffirat_, as well as adding support for Greek and Coptic, Cyrillic Unicode blocks.
- Updated Goober's Select Card appearance to be consistent with the rest.
- Redrawn game background.
- Added gray stripe to Asimo's scrap particles.
#### Gameplay
- In Inequality, if a skill is given to a player with 3 or more skills, the first skill will be removed first instead of being canceled.
- Game Modes now allow player count (2-6) and score manipulation.
- Player Settings now save correctly.
#### UI
- Updated Main Menu to accommodate more buttons.
- Updated Credits Menu.
- Slowed Credits Menu scrolling speed.
#### Technical
- Upgraded to _Lime 8.1.3_ and _OpenFL 9.4.1_
- Updated splashes
- Reorganized game assets
- Added translation notes in the English lang file.
- Renamed `gui` folder to `ui`
- Sprite sheets are now preloaded beforehand.
#### Semantic
- Amendments are again referred to as _Hotfixes_ in future releases and info text.
### Localization
- Refined Traditional Chinese translations.
### Removals
#### Audio
- Removed Classic Music.
#### Internal
- Removed `offset` fields in Animation Data.
### Fixes
- That fucking white pixel near the cursor.
- Gamemode buttons being colored incorrectly when being pressed on.
- Popped camera offset being used after players are defeated by overinflation.
- Missing copyright symbol on the tooltip of the Credits Button (HTML5).
- Descriptor text in the Character Select Menu not hiding correctly.
- Typo in Force Aliasing (previously was 'Force Alising')
- Camera moving too fast in high frame rates.
- Ambient noise still playing after returning to the Main Menu.

## v1.3.1 - Initial Release, Pitstop 3 Amendment 1 - 2026-02-20
### Fixes
- Re-added Options button in the Main Menu for the HTML5 build.
- Fixed invisible Chinese characters in the Desktop builds.

## v1.3.0 - Initial Release, Pitstop 3 - 2026-02-19
### Additions
#### Translations!
Actually why the fuck would I add this in the first place lmao. Anyway yeah Inflation Roulette can be understood by almost everyone now lol
#### Music
- Planted atrocious album art for _Inflation Roulette: Reloaded OST, Vol. 2_
#### Options
- Added option to hide the mouse cursor in HTML builds. This feature can be disabled by pressing G.
- Added option to toggle between the native cursor and the custom built-in cursor.
### Changes
#### Music
- Renamed Inflation Roulette: Reloaded OST to _Inflation Roulette Reloaded OST, Vol. 1_
#### Internal
- The following paths are renamed:
    - `images/ui/cursor/default_pressed.png` → **_`images/ui/cursor/defaultHeld.png`_**
- All references to Mallet Industries are now renamed to *NicklySuffer* instead. This is for the sake of distancing my normal work with my fetish work.
    - This resets user save data.
- Tweaked the code for buttons for colored outline support.
- The `name` and/or `description` fields of JSONs of these following things are rendered **obsolete**. Please use the newly added Lang files for display names and descriptions:
    - Gamemodes
    - Characters
    - Skills
#### UI
- Adjusting shaking animation on an Easter Egg startup screen.
- Recategorized options in the Options Menu.
- Updated Credits Menu.
- Slightly tweaked the layout of the Main Menu to prepare for accommodation for more buttons in a future update.
#### Semantic
- Hotfixes are now referred to as _Amendments_ in future releases and info text.
### Fixes
- Volume of numerous sounds in Easter Egg startup screen are now correctly scaled with User Preferences.
- Fixed music toast from moving out of the screen from excessive clicking.

## v1.2.1 - Initial Release, Pitstop 2 Hotfix 1 - 2026-02-13
My programming incompetence are finally showing themselves isn't it :sob:
### Changes
#### UI
- Adjusting shaking animation on an Easter Egg startup screen.
### Fixes
- Fixed broken confetti textures.
- Fixed Easter Egg input being case-sensitive.

## v1.2 - Initial Release, Pitstop 2 - 2026-02-13
### Additions
#### Features
- Easter Eggs! Type in a secret phrase on the Main Menu to get a special game startup sequence! Press the bottom-right info text to reset.
#### UI
- Top info text on the Main Menu when the current date has specialized splash texts.
- Extended bottom info on the Main Menu text to include the specified platform of the build
- Added warning text to the Addons Menu when no addons are present.
#### Options
- Fullscreen option (but seriously why would you use this)

### Changes
#### Cosmetic
- Updated cursor clicking sounds.
#### UI
- Using the scroll bar in the Options Menu is now smoother.
- Updated Credits Menu.
- Decreased opacity and increased the speed of the checkerboard pattern in the Character Select Screen.
#### Internal
- The following paths are renamed:
    - `sprites/<character>.json` -> **_`<character>/cosmetic.json`_**
    - `<character>.json` -> **_`<character>/stats.json`_**
    - `images/game/bgParticles` -> **_`images/game/particles`_**
    - `images/game/characters/<character>/scraps.png` -> **_`images/game/particles/scrap/<character>.png`_**
- Options save data and game save data are now stored using two separate save files.
### Fixes
- Fixed game failing to load sprite sheets from add-ons. (im terribly sorry guys :sob:)
- Fixed Options Menu scrolling even when not touching the scrollbar. (It'll now scroll via the right side of the screen)

## v1.1 - Initial Release, Pitstop 1 - 2026-02-10
### Additions
#### Cosmetic
- Added clicking sounds when clicking on the screen. This can be disabled in the Options Menu.
- As a homage to my ACTUAL FUCKING classmates playing my game, several splashes are added.

#### Parity
- Added Asimo into the HTML build
- Added Fifty-Fifty into the HTML build

### Changes
#### Internal
- Renamed some internal variables and sound files for standardization. Some user preferences may be reset.
- Metadata for addons are now stored separately in the "metadata" folder.

#### UI
- Minor releases are now referred to as "Pitstops" in the info text of the Main Menu.
- Scrolling in menus are now smoother when using the mouse wheel.

### Fixes
- Fixed crash on HTML build when attempted to load in the non-existent "random.json" file.
- Replaced copyright symbol in Logo tooltip text with (C) since HTML can't display it.

## v1.0 - Initial Release - 2026-02-09
Initial release.