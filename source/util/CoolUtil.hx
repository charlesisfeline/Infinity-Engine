package util;

import flixel.FlxG;
import options.OptionsHandler;
import states.PlayState;
import lime.utils.Assets;

using StringTools;

class CoolUtil
{
	public static var defaultDifficulties:Array<String> = [
		'easy',
		'normal',
		'hard'
	];
	public static var defaultDifficulty:String = 'normal'; //The chart that has no suffix and starting difficulty on Freeplay/Story Mode

	public static var difficulties:Array<String> = [];

	public static function getDifficultyFilePath(num:Null<Int> = null)
	{
		if(num == null) num = PlayState.storyDifficulty;

		var fileSuffix:String = difficulties[num];
		if(fileSuffix != defaultDifficulty)
		{
			fileSuffix = '-' + fileSuffix;
		}
		else
		{
			fileSuffix = '';
		}

		return Paths.formatToSongPath(fileSuffix);
	}

	public static function difficultyString():String
	{
		return difficulties[PlayState.storyDifficulty].toUpperCase();
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function boundTo(value:Float, min:Float, max:Float):Float {
		var newValue:Float = value;

		if(newValue < min)
			newValue = min;
		else if(newValue > max)
			newValue = max;
		
		return newValue;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

    static public function updateFramerate()
	{
		FlxG.updateFramerate = Options.getData('fps-cap');
		FlxG.drawFramerate = Options.getData('fps-cap');
	}
}
