package options;

import flixel.FlxG;

class Options
{
	public static function init()
	{
		FlxG.save.bind("infinity-engine", "infinity-team");
		
		for(option in defaultOptions)
		{
			switch(option[1])
			{
				case "bool":
					if(getData(option[0]) == null)
						setData(option[0], option[2]);
				case "float" | "int" | "string":
					if(getData(option[0]) == null)
						setData(option[0], option[2]);
				case "misc":
					if(getData(option[0]) == null)
						setData(option[0], option[2]);
			}
		}
	}

	public static function getData(key:String):Dynamic
	{
		return Reflect.getProperty(FlxG.save.data, key);
	}

	public static function setData(key:String, value:Dynamic)
	{
		Reflect.setProperty(FlxG.save.data, key, value);
		FlxG.save.flush();
	}

	public static function resetData()
	{
		FlxG.save.erase();
		init();
	}

	static public var defaultOptions:Array<Dynamic> = [
		[
			"optimization", // the option's save data name
			"bool", // the type
			false // the value to set to
		],
		[
			"downscroll", // the option's save data name
			"bool", // the type
			false // the value to set to
		],
		[
			"middlescroll", // the option's save data name
			"bool", // the type
			false // the value to set to
		],
		[
			"anti-aliasing", // the option's save data name
			"bool", // the type
			true // the value to set to
		],
		[
			"ghost-tapping", // the option's save data name
			"bool", // the type
			false // the value to set to
		],
		[
			"note-splashes", // the option's save data name
			"bool", // the type
			true // the value to set to
		],
		[
			"camera-zooms", // the option's save data name
			"bool", // the type
			true // the value to set to
		],
		[
			"anti-mash", // the option's save data name
			"bool", // the type
			true // the value to set to
		],
		[
			"fps-cap", // the option's save data name
			"int", // the type
			60 // the value to set to
		],
		[
			"note-offset", // the option's save data name
			"float", // the type
			0 // the value to set to
		],
		[
			"hitsounds", // the option's save data name
			"string", // the type
			//["None", "osu!", "Bloop", "Vine Boom", "Spamton Heal", "Sr Pelo Scream"] // the value to set to
			"None"
		],
		[
			"ui-skin", // the option's save data name
			"string", // the type
			//["None", "osu!", "Bloop", "Vine Boom", "Spamton Heal", "Sr Pelo Scream"] // the value to set to
			"default"
		],
		[
			"keybinds",
			"misc",
			[
				["SPACE"],
				["A", "D"],
				["A", "SPACE", "D"],
				["A", "S", "W", "D"],
				["A", "S", "SPACE", "W", "D"],
				["S", "D", "F", "J", "K", "L"],
				["S", "D", "F", "SPACE", "J", "K", "L"],
				["A", "S", "D", "F", "H", "J", "K", "L"],
				["A", "S", "D", "F", "SPACE", "H", "J", "K", "L"]
			]
		],
		[
			"alt-keybinds",
			"misc",
			[
				["SPACE"],
				["A", "D"],
				["LEFT", "SPACE", "D"],
				["LEFT", "DOWN", "UP", "RIGHT"],
				["LEFT", "DOWN", "SPACE", "UP", "RIGHT"],
				["W", "E", "R", "U", "I", "O"],
				["W", "E", "R", "G", "U", "I", "O"],
				["Q", "W", "E", "R", "U", "I", "O", "P"],
				["Q", "W", "E", "R", "G", "U", "I", "O", "P"],
			]
		]
	];
}
