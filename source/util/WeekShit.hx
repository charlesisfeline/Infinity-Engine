package util;

import options.OptionsHandler;

using StringTools;

class WeekShit
{
    static public var completedWeeks:Map<String, Bool> = new Map<String, Bool>();

    static public function init()
    {
        if(Options.getData('completedWeeks') == null)
        {
            var jsonDirs:Array<String> = [];
            var jsons:Array<String> = [];

			#if sys
			jsonDirs = sys.FileSystem.readDirectory(Sys.getCwd() + "assets/weeks/");
			#else
			jsonDirs = ["tutorial.json", "week1.json", "week2.json", "week3.json", "week4.json", "week5.json", "week6.json"];
			#end
    
            for(dir in jsonDirs)
            {
                if(dir.endsWith(".json"))
                    jsons.push(dir.split(".json")[0]);
            }

            for(json in jsons)
            {
                completedWeeks.set(json, false);
            }

            Options.setData('completedWeeks', completedWeeks);
        }
        else
        {
            completedWeeks = Options.getData('completedWeeks');
        }
    }

	static public function setCompletedWeek(week:String, ?completed:Bool = true)
	{
		completedWeeks.set(week, true);
		Options.setData('completedWeeks', completedWeeks);
	}

	static public function getCompletedWeek(week:String)
	{
        var answer:Bool = false;

        if(completedWeeks.exists(week))
            answer = completedWeeks.get(week);
        else
        {
            trace("OH FUCK! THIS COMPLETED WEEK: " + week + " DOESN'T EXIST!!!");
            trace(Options.getData('completedWeeks'));
        }

		return answer;
	}
}