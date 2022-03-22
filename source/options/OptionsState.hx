package options;

import options.OptionsHandler;
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
		"Controls",
		"Tools",
		"Misc"
	];

	override function create()
	{
		super.create();

		UISkinList.init();
		
		menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
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

		changeSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		menuBG.antialiasing = Options.getData('anti-aliasing');

		if(controls.BACK)
			FlxG.switchState(new states.MainMenuState());

		if(controls.UI_UP_P)
			changeSelection(-1);
		
		if(controls.UI_DOWN_P)
			changeSelection(1);

		if(controls.ACCEPT)
		{
			switch(options[curSelected])
			{
				case "Graphics":
					openSubState(new GraphicsSubstate());
				case "Gameplay":
					openSubState(new GameplaySubstate());
				case "Controls":
					openSubState(new controls.ControlsSubState());
				case "Tools":
					openSubState(new ToolsSubstate());
			}
		}
	}

	function changeSelection(?change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));

		curSelected += change;

		if(curSelected < 0)
			curSelected = options.length - 1;

		if(curSelected > options.length - 1)
			curSelected = 0;

		grpOptions.forEachAlive(function(option:Alphabet) {
			option.alpha = 0.6;
		});

		grpOptions.members[curSelected].alpha = 1;
	}
}
