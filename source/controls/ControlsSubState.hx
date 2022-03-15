package controls;

import substates.MusicBeatSubstate;
import flixel.input.keyboard.FlxKey;
import game.StrumNote;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import options.Options;
import controls.Controls;
import flixel.util.FlxColor;

class ControlsSubState extends MusicBeatSubstate
{
	var menuBG:FlxSprite;
	var cover:FlxSprite;

	var keyCount:Int = 4;
	var laneOffset:Int = 120;

	var checkingForKeys:Bool = false;

	var daNotes:FlxTypedGroup<StrumNote>;
	var daKeybinds:FlxTypedGroup<FlxText>;

	var curSelected:Int = 0;

	var binds:Array<String> = [];

	var changingBinds:Bool = false;

	override public function create()
	{
		super.create();

		binds = Options.getData('keybinds')[keyCount - 1];

		menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.alpha = 0;
		add(menuBG);

		FlxTween.tween(menuBG, {alpha: 1}, 1, {ease: FlxEase.cubeInOut});
		loadMenu();

		changeSelection();
	}

	function loadMenu()
	{
		cover = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		cover.alpha = 0;
		add(cover);

		FlxTween.tween(cover, {alpha: 0.4}, 1, {ease: FlxEase.cubeOut});

		daNotes = new FlxTypedGroup<StrumNote>();
		add(daNotes);

		daKeybinds = new FlxTypedGroup<FlxText>();
		add(daKeybinds);

		for(i in 0...keyCount)
		{
			var daStrum:StrumNote = new StrumNote(0, 0, i, "default");

			// probably a bad way of centering the notes but hey if it works it works :/
			daStrum.screenCenter();
			daStrum.x += (keyCount * ((laneOffset / 2) * -1)) + (laneOffset / 2);
			daStrum.x += i * laneOffset;

			daStrum.y -= 10;
			daStrum.alpha = 0;
			FlxTween.tween(daStrum, {y: daStrum.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			daNotes.add(daStrum);
		}

		for (i in 0...daNotes.members.length) {
			var daKeybindText:FlxText = new FlxText(daNotes.members[i].x, 0, 48, "A", 48, true);
			daKeybindText.scrollFactor.set();
			daKeybindText.screenCenter(Y);
			
			daKeybindText.color = FlxColor.WHITE;
			daKeybindText.borderStyle = OUTLINE;
			daKeybindText.borderColor = FlxColor.BLACK;

			daKeybindText.borderSize = 3;
			daKeybinds.add(daKeybindText);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		menuBG.antialiasing = Options.getData('anti-aliasing');

		if(controls.BACK)
		{
			daNotes.forEachAlive(function(note:StrumNote) {
				FlxTween.tween(note, {alpha: 0}, 1, {ease: FlxEase.cubeOut});
			});

			daKeybinds.forEachAlive(function(key:FlxText) {
				FlxTween.tween(key, {alpha: 0}, 1, {ease: FlxEase.cubeOut});
			});

			FlxTween.tween(menuBG, {alpha: 0}, 1, {ease: FlxEase.cubeOut});
			FlxTween.tween(cover, {alpha: 0}, 1, {
				ease: FlxEase.cubeOut,
				onComplete: function(twn:FlxTween) {
					close();
				}
			});
		}

		// THIS CRASHES THE GAME!!! FIX TOMORROW!!!
		// ALSO REMEMBER TO FIX RATINGS AND COMBOS NOT SHOWING UP CORRECTLY!!!

		if(!changingBinds)
		{
			if(controls.UI_LEFT_P)
				changeSelection(-1);
	
			if(controls.UI_RIGHT_P)
				changeSelection(1);

			if(controls.ACCEPT) {
				checkingForKeys = false;
				changingBinds = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
			}
		} else {
			if(!controls.ACCEPT_P)
				checkingForKeys = true;
			
			if(FlxG.keys.getIsDown().length > 0 && checkingForKeys) {
				binds[curSelected] = FlxG.keys.getIsDown()[0].ID.toString();

				Options.setData('keybinds', binds);
				changingBinds = false;
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
		}

		for(i in 0...daKeybinds.members.length)
		{
			var key:FlxText = daKeybinds.members[i];

			key.text = binds[i];
			key.x = (daNotes.members[i].x + (daNotes.members[i].width / 2) - (24)) + 5;
		}
	}

	function changeSelection(?change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));

		daNotes.members[curSelected].playAnim('static');
		
		curSelected += change;

		if(curSelected < 0)
			curSelected = keyCount - 1;

		if(curSelected > keyCount - 1)
			curSelected = 0;

		daNotes.members[curSelected].playAnim('confirm');
	}
}
