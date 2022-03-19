package options;

import flixel.math.FlxMath;
import util.CoolUtil;
import ui.AttachedAlphabet;
import flixel.FlxG;
import ui.Checkbox;
import options.OptionsHandler;
import ui.Alphabet;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import substates.MusicBeatSubstate;

class BaseOptionsMenu extends MusicBeatSubstate
{
    public var menuBG:FlxSprite;

    public var enterTimer:Float = 0.2;

    public var curSelected:Int = 0;
    public var grpOptions:FlxTypedGroup<Alphabet>;

    public var grpValues:FlxTypedGroup<AttachedAlphabet>;
    public var valueNumber:Array<Int> = [];

    public var options:Array<Option> = [];

    var checkboxGroup:FlxTypedGroup<Checkbox>;
	
	var checkboxNumber:Array<Int> = [];
	var checkboxArray:Array<Checkbox> = [];

    override public function new()
    {
        super();

        menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		add(menuBG);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		grpValues = new FlxTypedGroup<AttachedAlphabet>();
		add(grpValues);

		checkboxGroup = new FlxTypedGroup<Checkbox>();
		add(checkboxGroup);
    }

    override public function create()
    {
        super.create();

        refreshOptions(); // DON'T REMOVE
    }

    var holdTime:Float = 0;

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        enterTimer -= elapsed;

        if(enterTimer < 0)
            enterTimer = 0;

        menuBG.antialiasing = Options.getData('anti-aliasing');

        if(enterTimer <= 0)
        {
            if(controls.BACK)
                close();

            if(controls.UI_LEFT || controls.UI_RIGHT)
                holdTime += elapsed;
            else
                holdTime = 0;

            if(holdTime > 0.5 || (controls.UI_LEFT_P || controls.UI_RIGHT_P))
            {
                var mult:Float = controls.UI_LEFT ? (0 - options[curSelected].multiplier) : (options[curSelected].multiplier);
                switch(options[curSelected].type)
                {
                    case 'float' | 'int':
                        if(options[curSelected].type == 'int')
                            mult = Math.floor(mult);

                        Options.setData(options[curSelected].variable, Options.getData(options[curSelected].variable) + mult);

                        if(Options.getData(options[curSelected].variable) < options[curSelected].values[0])
                            Options.setData(options[curSelected].variable, options[curSelected].values[0]);

                        if(Options.getData(options[curSelected].variable) > options[curSelected].values[1])
                            Options.setData(options[curSelected].variable, options[curSelected].values[1]);

                        reloadValues();

                        if(options[curSelected].variable == 'fps-cap')
                            CoolUtil.updateFramerate();
                    case 'string':
                        var swagSkinNum:Int = 0;

                        for(skinNum in 0...UISkinList.skins.length)
                        {
                            if(options[curSelected].values[skinNum] == Options.getData(options[curSelected].variable))
                            {
                                swagSkinNum = skinNum;
                                break;
                            }
                        }

                        var str_mult = controls.UI_LEFT_P ? -1 : 1;

                        swagSkinNum += str_mult;

                        if(swagSkinNum < 0)
                            swagSkinNum = options[curSelected].values.length - 1;

                        if(swagSkinNum > options[curSelected].values.length - 1)
                            swagSkinNum = 0;

                        Options.setData(options[curSelected].variable, options[curSelected].values[swagSkinNum]);
                        reloadValues();
                }
            }

            if(controls.UI_UP_P)
                changeSelection(-1);

            if(controls.UI_DOWN_P)
                changeSelection(1);

            if(controls.ACCEPT)
            {
                switch(options[curSelected].type)
                {
                    case 'menu':
                        switch(options[curSelected].title)
                        {
                            case 'Character Editor':
                                FlxG.switchState(new states.CharacterEditor());
                        }
                    case 'bool':
                        Options.setData(options[curSelected].variable, !Options.getData(options[curSelected].variable));
                        reloadCheckboxes();
                }
            }
        }
    }

	public function reloadCheckboxes()
    {
        for(i in 0...checkboxGroup.members.length)
        {
            checkboxGroup.members[i].checked = Options.getData(options[checkboxNumber[i]].variable);
            checkboxGroup.members[i].refresh();
        }
    }

	public function reloadValues()
    {
        for(i in 0...grpValues.members.length)
        {
            grpValues.members[i].changeText(FlxMath.roundDecimal(Options.getData(options[valueNumber[i]].variable), options[valueNumber[i]].decimals)+"");
        }
    }

    public function addOption(option:Option)
    {
        if(options == null || options.length < 1) options = [];

        options.push(option);
    }

    public function refreshOptions()
    {
        for(i in 0...options.length)
        {
            var swagOption:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].title, false, false);
            swagOption.isMenuItem = true;
            swagOption.targetY = i;
            swagOption.ID = i;

            var usesCheckbox:Bool = false;
            var isNumber:Bool = false;
            var isString:Bool = false;
            var isMenu:Bool = false;
            
            switch(options[i].type)
            {
                case "bool":
                    usesCheckbox = true;
                case "float" | "int":
                    isNumber = true;
                case "string":
                    isString = true;
                case "menu":
                    isMenu = true;
            }

            if(!isMenu)
            {
                swagOption.x += 300;
                swagOption.xAdd = 200;
            }
            
            // MAKE FLOAT/INT/STRING TYPES WORK HERE TOO!!!!!

            if(usesCheckbox) {
                var checkbox:Checkbox = new Checkbox(swagOption.x - 105, swagOption.y);
                checkbox.sprTracker = swagOption;
                checkboxNumber.push(i);
                checkboxArray.push(checkbox);
                checkbox.ID = i;
                checkbox.offsetX -= 150;
                checkbox.offsetY -= 150;

                checkbox.checked = Options.getData(options[i].variable) == true;
                checkbox.refresh();

                checkboxGroup.add(checkbox);
            }

            grpOptions.add(swagOption);

            if(isNumber || isString)
            {
                var swagValue:AttachedAlphabet = new AttachedAlphabet(Options.getData(options[i].variable), 400, 0);
                swagValue.sprTracker = swagOption;
                valueNumber.push(i);
                swagValue.ID = i;
                grpValues.add(swagValue);
            }

            curSelected = 0;
            changeSelection();
        }
    }

    function changeSelection(?change:Int = 0)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'));
        
        curSelected += change;

        if(curSelected < 0)
            curSelected = options.length - 1;

        if(curSelected > options.length - 1)
            curSelected = 0;

        grpOptions.forEachAlive(function(option:Alphabet) {
            option.alpha = 0.6;
        });

        grpValues.forEachAlive(function(option:Alphabet) {
            option.alpha = 0.6;

            if(option.ID == curSelected)
                option.alpha = 1;
        });

        grpOptions.members[curSelected].alpha = 1;
        //grpValues.members[valueNumber[curSelected]].alpha = 1;

        var bullShit:Int = 0;
        
		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;
		}
    }
}