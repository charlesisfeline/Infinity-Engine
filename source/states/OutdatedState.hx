package states;

import engine.EngineSettings;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

using StringTools;

class OutdatedState extends MusicBeatState
{
	public static var leftState:Bool = false;

	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		var ver = "v" + EngineSettings.version.trim();
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"Hello! You're running an outdated version of the engine.\nYour version is: "
			+ ver
			+ " while the most recent version is "
			+ "v" + TitleState.updateVersion
			+ "!\n\nPress SPACE to go to the Github, or ESCAPE to ignore.\nThis screen can be disabled in options.",
			32);
		txt.setFormat(Paths.font("vcr"), 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
		{
			Paths.openURL("https://github.com/CubeSword/Infinity-Engine/releases");
		}
		if (controls.BACK)
		{
			leftState = true;
			FlxG.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
}
