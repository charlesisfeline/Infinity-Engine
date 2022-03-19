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
            "Update Warnings",
            "Disabling this prevents the game from telling you when a new update is available.",
            "update-warnings",
            "bool"
        );
        addOption(option);

        var option:Option = new Option(
            "Botplay",
            "Enabling this allows a bot to play the game for you. Scores won't be saved with this enabled.",
            "botplay",
            "bool"
        );
        addOption(option);

        var option:Option = new Option(
            "Scroll Speed",
            "Adjust how fast your notes go.\n0 = Chart Scroll Speed",
            "scroll-speed",
            "float",
            [0, 10],
            0.1, // multiplier
            1 // how many decimal numbers there are, 2 = 69.69% for example
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