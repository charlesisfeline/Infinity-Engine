package ui;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

typedef DialogueData = {
    var box_skin:String;
    var font:String;
    var font_size:Int;
    var dialogue:Array<DialogueContent>;
};

typedef DialogueContent = {
    var character:String;
    var text:String;
    var speed:Float;
};

class InfinityDialogueBox extends FlxSpriteGroup
{
    public var finishThing:Void->Void;

    public var dialogueJson:DialogueData;

    public var box:FlxSprite;

    public function new(dialoguePath:String)
    {
        super();


    }
}