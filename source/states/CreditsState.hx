package states;

import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import mods.Mods;
import ui.Alphabet;
import flixel.group.FlxGroup.FlxTypedGroup;
import lime.utils.Assets;
import haxe.Json;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;

using StringTools;

// REMEMBER TO FINISH THIS AND CHARACTER EDITOR!!!!

class Credit
{
    public var name:String;
    public var description:String;
    public var color:String;

    public function new(name:String, description:String, color:String)
    {
        this.name = name;
        this.description = description;
        this.color = color;
    }
}

class CreditsState extends MusicBeatState
{
    var curSelected:Int = 0;

    var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

    var box:FlxSprite;
    var desc:FlxText;

    var json:Dynamic;

    var credits:Array<Credit> = [];

    var grpIcons:FlxTypedGroup<CreditsIcon>;
    var grpText:FlxTypedGroup<Alphabet>;

    override public function create()
    {
        super.create();

        bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        add(bg);

		json = Json.parse(Assets.getText('assets/data/credits.json')).credits;

		for(i in 0...json.length)
		{
            var credit = json[i];
			credits.push(new Credit(credit.name, credit.description, credit.color));
		}

		#if (MODS_ALLOWED && sys)
		for(mod in Mods.activeMods)
		{
			if(Mods.activeMods.length > 0)
			{
				if(sys.FileSystem.exists(Sys.getCwd() + 'mods/$mod/data/credits.json'))
				{
					var modJson = Json.parse(sys.io.File.getContent(Sys.getCwd() + 'mods/$mod/data/credits.json')).credits;

					for(i in 0...modJson.length)
					{
                        var credit = modJson[i];
                        credits.push(new Credit(credit.name, credit.description, credit.color));
					}
				}
			}
		}
		#end

        grpIcons = new FlxTypedGroup<CreditsIcon>();
        add(grpIcons);

        grpText = new FlxTypedGroup<Alphabet>();
        add(grpText);

        var credits_i:Int = 0;
        for(credit in credits)
        {
            var alphabet:Alphabet = new Alphabet(0, (70 * credits_i) + 30, credit.name);
            alphabet.isMenuItem = true;
            alphabet.targetY = credits_i;
            grpText.add(alphabet);

            alphabet.x += 200;
            //alphabet.xAdd = 100;
            //alphabet.yAdd -= 330;
            alphabet.forceX = 200;

			var icon:CreditsIcon = new CreditsIcon(alphabet.x - 105, alphabet.y, credit.name);
			icon.sprTracker = alphabet;
			grpIcons.add(icon);

            credits_i++;
        }

        bg.color = FlxColor.fromString(Paths.getHexCode(credits[curSelected].color));

        box = new FlxSprite(0, FlxG.height * 0.8).makeGraphic(1, 1, FlxColor.BLACK);
        box.alpha = 0.6;
        add(box);

        desc = new FlxText(0, box.y + 5, FlxG.width - 10, "swag shit", 24);
        desc.setFormat(Paths.font("vcr"), 24, FlxColor.WHITE, CENTER);
        desc.screenCenter(X);
        add(desc);

        changeSelection();
    }

    function changeSelection(?change:Int = 0)
    {
		FlxG.sound.play(Paths.sound('scrollMenu'));

		curSelected += change;

		if (curSelected < 0)
			curSelected = credits.length - 1;

		if (curSelected >= credits.length)
			curSelected = 0;

        var bullShit:Int = 0;
		for (item in grpText.members)
        {
            item.targetY = bullShit - curSelected;
            bullShit++;

            item.alpha = 0.6;

            if (item.targetY == 0)
            {
                item.alpha = 1;
            }
        }

		var newColor:Int = FlxColor.fromString(Paths.getHexCode(credits[curSelected].color));
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

        desc.text = credits[curSelected].description;
        desc.screenCenter(X);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if(controls.BACK)
            FlxG.switchState(new MainMenuState());

        if(controls.UI_UP_P)
            changeSelection(-1);

        if(controls.UI_DOWN_P)
            changeSelection(1);

        box.scale.x = desc.width + 10;
        box.scale.y = desc.height + 10;
        box.updateHitbox();
        box.screenCenter(X);
    }
}

class CreditsIcon extends FlxSprite
{
    public var page:Int = 0;

    public var sprTracker:FlxSprite;

    public var copyAlpha:Bool = true;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;

    override public function new(x:Float, y:Float, icon:String)
    {
        super(x, y);

        icon = icon.toLowerCase();
        loadGraphic(Paths.image('credits/$icon', 'shared')); // it's in shared because the credit icons shouldn't need to be preloaded
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

		if (sprTracker != null) {
			setPosition(sprTracker.x - 130 + offsetX, sprTracker.y + 30 + offsetY);
			if(copyAlpha) {
				alpha = sprTracker.alpha;
			}
		}
    }
}