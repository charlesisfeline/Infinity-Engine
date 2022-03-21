package states;

import lime.system.Clipboard;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUI;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;
import flixel.FlxSprite;

using StringTools;

class OffsetMaker extends MusicBeatState
{
    var sprite:FlxSprite;

    var uiGroup:FlxGroup = new FlxGroup();
    var box:FlxUI;

    var usedShared:Bool = true;

    var spriteScale:Float = 0.5;

    var curSelected:Int = 0;

    override public function create()
    {
        FlxG.mouse.visible = true;

        var grayBG:FlxSprite = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.GRAY);
        grayBG.screenCenter();
        grayBG.scrollFactor.set();
        add(grayBG);

        sprite = new FlxSprite();

        sprite.frames = Paths.getSparrowAtlas('CHECKBOX_assets', usedShared ? 'shared' : null);
        sprite.animation.addByPrefix('check', 'check0', 24, false);
        sprite.animation.play('check');

        sprite.scale.set(spriteScale, spriteScale);
        sprite.updateHitbox();

        animList.push('check');
        animOffsets.set('check', [0, 0]);
        sprite.offset.set(0, 0);

        sprite.screenCenter();
        sprite.scrollFactor.set();

        add(sprite);

        add(uiGroup);
        create_UI();
    }

    var animationInput:FlxUIInputText;
    var animationInput2:FlxUIInputText;

    var fpsInput:FlxUINumericStepper;

    var animBTN:FlxButton;
    var removeBTN:FlxButton;

    var animList:Array<String> = [];
    var animOffsets:Map<String, Array<Int>> = new Map<String, Array<Int>>();

    var animListText:FlxText;

    function create_UI()
    {
        box = new FlxUI(null, null);
        var uiBox = new FlxUITabMenu(null, [], false);

        uiBox.resize(300, 540);
        uiBox.x = (FlxG.width - uiBox.width) - 20;
        uiBox.y = 10;
        uiBox.scrollFactor.set();

        var warnText:FlxText = new FlxText(uiBox.x + 10, uiBox.y + 10, 0, "Animation Name");
        animationInput = new FlxUIInputText(warnText.x, warnText.y + 20, 100, "check", 8);

        var warnText2:FlxText = new FlxText(uiBox.x + 10, animationInput.y + 10, 0, "Animation From XML");
        animationInput2 = new FlxUIInputText(warnText.x, warnText2.y + 20, 100, "check0", 8);

        animBTN = new FlxButton(animationInput.x + (animationInput.width + 10), animationInput.y, "Add", function(){
            sprite.animation.addByPrefix(animationInput.text, animationInput2.text, Math.floor(fpsInput.value), false);
            sprite.animation.play(animationInput.text);

            if(!animList.contains(animationInput.text)) animList.push(animationInput.text);

            animOffsets.set(animationInput.text, [0, 0]);
        });

        removeBTN = new FlxButton(animBTN.x + (animBTN.width + 10), animationInput.y, "Remove", function(){
            sprite.animation.remove(animationInput.text);

            if(animList.contains(animationInput.text)) animList.remove(animationInput.text);

            if(animOffsets.exists(animationInput.text))
                animOffsets.remove(animationInput.text);
        });

        var warnText3:FlxText = new FlxText(uiBox.x + 10, animationInput2.y + 10, 0, "Framerate");
        fpsInput = new FlxUINumericStepper(warnText.x, warnText3.y + 20, 10, 24, 1, 60);

        box.add(uiBox);

        box.add(warnText);
        box.add(animationInput);

        box.add(warnText2);
        box.add(animationInput2);

        box.add(animBTN);
        box.add(removeBTN);

        box.add(warnText3);
        box.add(fpsInput);

        // add the shity
        uiGroup.add(box);

        // add shit unrelated to ui box funny real no faek nono fakeee
        animListText = new FlxText(10, 10, 0, "???", 16);
        add(animListText);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        var shift = FlxG.keys.pressed.SHIFT;
        var leftP = FlxG.keys.justPressed.J;
        var downP = FlxG.keys.justPressed.K;
        var upP = FlxG.keys.justPressed.I;
        var rightP = FlxG.keys.justPressed.L;

		var inputTexts:Array<FlxUIInputText> = [animationInput, animationInput2];
		for (i in 0...inputTexts.length) {
			if(inputTexts[i].hasFocus) {
				/*if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.V && Clipboard.text != null) { //Copy paste
					inputTexts[i].text = ClipboardAdd(inputTexts[i].text);
					inputTexts[i].caretIndex = inputTexts[i].text.length;
					getEvent(FlxUIInputText.CHANGE_EVENT, inputTexts[i], null, []);
				}*/
				if(FlxG.keys.justPressed.ENTER) {
					inputTexts[i].hasFocus = false;
				}
                FlxG.sound.muteKeys = [];
                FlxG.sound.volumeDownKeys = [];
                FlxG.sound.volumeUpKeys = [];
				super.update(elapsed);
				return;
			}
		}
		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;

        if(controls.BACK)
        {
            FlxG.mouse.visible = false;
            FlxG.switchState(new MainMenuState());
        }

        if(controls.UI_UP_P)
            changeSelection(-1);

        if(controls.UI_DOWN_P)
            changeSelection(1);

        if(FlxG.keys.justPressed.SPACE)
            sprite.animation.play(sprite.animation.curAnim.name, true);

        if(leftP)
        {
            var offset = animOffsets.get(sprite.animation.curAnim.name);

            if(shift)
                animOffsets.set(sprite.animation.curAnim.name, [offset[0] + 10, offset[1]]);
            else
                animOffsets.set(sprite.animation.curAnim.name, [offset[0] + 1, offset[1]]);

            var offset2 = animOffsets.get(sprite.animation.curAnim.name);
            sprite.offset.set(offset2[0], offset2[1]);
        }

        if(rightP)
        {
            var offset = animOffsets.get(sprite.animation.curAnim.name);
            
            if(shift)
                animOffsets.set(sprite.animation.curAnim.name, [offset[0] - 10, offset[1]]);
            else
                animOffsets.set(sprite.animation.curAnim.name, [offset[0] - 1, offset[1]]);

            var offset2 = animOffsets.get(sprite.animation.curAnim.name);
            sprite.offset.set(offset2[0], offset2[1]);
        }

        if(upP)
        {
            var offset = animOffsets.get(sprite.animation.curAnim.name);
            
            if(shift)
                animOffsets.set(sprite.animation.curAnim.name, [offset[0], offset[1] + 10]);
            else
                animOffsets.set(sprite.animation.curAnim.name, [offset[0], offset[1] + 1]);

            var offset2 = animOffsets.get(sprite.animation.curAnim.name);
            sprite.offset.set(offset2[0], offset2[1]);
        }

        if(downP)
        {
            var offset = animOffsets.get(sprite.animation.curAnim.name);
            
            if(shift)
                animOffsets.set(sprite.animation.curAnim.name, [offset[0], offset[1] - 10]);
            else
                animOffsets.set(sprite.animation.curAnim.name, [offset[0], offset[1] - 1]);

            var offset2 = animOffsets.get(sprite.animation.curAnim.name);
            sprite.offset.set(offset2[0], offset2[1]);
        }

        animListText.text = "";

        for(i in 0...animList.length)
        {
            var shit = animOffsets.get(animList[i]);

            if(curSelected == i)
                animListText.text += ">> " + animList[i] + " [" + shit[0] + ", " + shit[1] + "]" + "\n";
            else
                animListText.text += animList[i] + " [" + shit[0] + ", " + shit[1] + "]" + "\n";
        }
    }

    function changeSelection(?change:Int = 0)
    {
        curSelected += change;

        if(curSelected < 0)
            curSelected = animList.length - 1;

        if(curSelected > animList.length - 1)
            curSelected = 0;

        sprite.animation.play(animList[curSelected]);

        var offset = animOffsets.get(sprite.animation.curAnim.name);
        sprite.offset.set(offset[0], offset[1]);
    }

	function ClipboardAdd(prefix:String = ''):String {
		if(prefix.toLowerCase().endsWith('v')) //probably copy paste attempt
		{
			prefix = prefix.substring(0, prefix.length-1);
		}

		var text:String = prefix + Clipboard.text.replace('\n', '');
		return text;
	}
}