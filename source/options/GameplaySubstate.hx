package options;

import flixel.FlxSprite;
import substates.MusicBeatSubstate;

class GameplaySubstate extends BaseOptionsMenu
{
    override public function create()
    {
        var option:Option = new Option(
            "Downscroll",
            "Enabling this will cause all notes to go downwards instead of upwards.",
            "downscroll",
            "bool"
        );
        addOption(option);

        var option:Option = new Option(
            "Middlescroll",
            "Enabling this will cause all notes to go the middle of the screen.",
            "middlescroll",
            "bool"
        );
        addOption(option);

        var option:Option = new Option(
            "Ghost Tapping",
            "Enabling this makes it so if you press a note that doesn't exist, You won't get a miss.",
            "ghost-tapping",
            "bool"
        );
        addOption(option);

        var option:Option = new Option(
            "Anti Mash",
            "Disabling this will allow you to mash endlessly, Scores won't be saved with this disabled.",
            "anti-mash",
            "bool"
        );
        addOption(option);

        var option:Option = new Option(
            "Note Offset",
            "Adjust how early/late your notes spawn.\nNegative = Earlier | Positive = Later",
            "note-offset",
            "int",
            [-1000, 1000],
            1
        );
        addOption(option);

		super.create();
    }
}