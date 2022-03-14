package options;

import ui.Alphabet;
import states.MusicBeatState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;

class OptionsState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuBG:FlxSprite;
	var grpOptions:FlxTypedGroup<Alphabet>;

	var options:Array<String> = [
		"Graphics",
		"Gameplay",
		"Tools",
		"Misc"
	];

	override function create()
	{
		super.create();
		
		menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for(i in 0...options.length)
		{
			var alphabet:Alphabet = new Alphabet(0, 0, options[i], true);
			alphabet.screenCenter();
			alphabet.y += (100 * (i - (options.length / 2))) + 50;

			grpOptions.add(alphabet);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(controls.BACK)
			FlxG.switchState(new states.MainMenuState());
	}
}
