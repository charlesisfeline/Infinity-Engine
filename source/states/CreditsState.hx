package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;

class CreditsState extends MusicBeatState
{
    var bg:FlxSprite;
    var placeholderText:FlxText;

    override public function create()
    {
        super.create();

        bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        placeholderText = new FlxText(0, 0, 0, "Credits coming soon!", 32);
        placeholderText.screenCenter();

        add(bg);
        add(placeholderText);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if(controls.BACK)
            FlxG.switchState(new MainMenuState());
    }
}