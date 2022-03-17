package options;

import flixel.FlxSubState;

class Option
{
    public var title:String = "???";
    public var desc:String = "???";
    public var variable:String = "???";
    public var type:String = "bool";
    public var multiplier:Float = 1;
    public var values:Array<Dynamic> = [];

    public function new(title:String, desc:String, variable:String, type:String, ?values:Array<Dynamic>, ?multiplier:Float = 1)
    {
        this.title = title;
        this.desc = desc;
        this.variable = variable;
        this.type = type;
        this.multiplier = multiplier;

        if(values == null || values.length < 1)
            this.values = [];
        else
            this.values = values;
    }
}