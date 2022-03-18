package options;

import mods.Mods;

using StringTools;

class UISkinList
{
    static public var skins:Array<String> = [];

    static public function init()
    {
        // DEFINE HARDCODED SKINS HERE
        skins = [
            "default",
            "default-pixel",
            "circles",
            "circles-pixel",
            "diamond",
            "diamond-pixel",
            "square",
            "square-pixel",
        ];

        #if (MODS_ALLOWED && sys)
        for(mod in Mods.activeMods)
        {
            if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/ui-skins'))
            {
                var initArray = sys.FileSystem.readDirectory(Sys.getCwd() + 'mods/$mod/ui-skins');

                for(shit in initArray)
                {
                    if(!skins.contains(shit) && !shit.contains('.'))
                        skins.push(shit);
                }
            }
        }
        #end
    }
}