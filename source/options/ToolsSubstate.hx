package options;

import flixel.FlxSprite;
import substates.MusicBeatSubstate;

class ToolsSubstate extends BaseOptionsMenu
{
    override public function create()
    {
        var option:Option = new Option(
            "Character Editor",
            "Create new characters/Edit existing characters with the character editor.",
            "???",
            "menu"
        );
        addOption(option);

		super.create();
    }
}