package options;

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

    public var curSelected:Int = 0;
    public var grpOptions:FlxTypedGroup<Alphabet>;

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

		checkboxGroup = new FlxTypedGroup<Checkbox>();
		add(checkboxGroup);
    }

    override public function create()
    {
        super.create();

        refreshOptions(); // DON'T REMOVE
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        menuBG.antialiasing = Options.getData('anti-aliasing');

        if(controls.BACK)
            close();

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
                        case 'UI Skin':
                            openSubState(new controls.ControlsSubState());
                    }
                case 'bool':
                    Options.setData(options[curSelected].variable, !Options.getData(options[curSelected].variable));
                    reloadCheckboxes();
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
            var isMenu:Bool = false;
            
            switch(options[i].type)
            {
                case "bool":
                    usesCheckbox = true;
                case "menu":
                    isMenu = true;
            }

            swagOption.x += 300;
            swagOption.xAdd = 200;
            
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

        var bullShit:Int = 0;

        grpOptions.members[curSelected].alpha = 1;
        
		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;
		}
    }
}