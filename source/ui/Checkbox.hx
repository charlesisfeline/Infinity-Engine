package ui;

import flixel.FlxSprite;

using StringTools;

class Checkbox extends FlxSprite
{
    public var refreshed:Bool = false;

    public var oldChecked:Bool = false;
    public var checked:Bool = false;

    public var sprTracker:FlxSprite;

    public var copyAlpha:Bool = true;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;

    override public function new(x, y)
    {
        super(x, y);

        frames = Paths.getSparrowAtlas('CHECKBOX_assets', 'shared');
        animation.addByPrefix('unchecked', 'unchecked0', 24, true);
        animation.addByPrefix('uncheck', 'uncheck0', 24, false);
        animation.addByPrefix('check', 'check0', 24, false);
        animation.addByPrefix('checked', 'checked0', 24, true);

        scale.set(0.5, 0.5);
        updateHitbox();

        playAnim('unchecked');
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

		if (sprTracker != null) {
			setPosition(sprTracker.x + offsetX, sprTracker.y + offsetY);
			if(copyAlpha) {
				alpha = sprTracker.alpha;
			}
		}

        if(animation.curAnim != null)
        {
            if(animation.curAnim.name == 'uncheck' && animation.curAnim.finished)
                playAnim('unchecked');

            if(animation.curAnim.name == 'check' && animation.curAnim.finished)
                playAnim('checked');
        }
    }

    public function refresh()
    {
        if(!refreshed)
        {
            oldChecked = checked;
            
            if(checked)
                playAnim('checked', true);
            else
                playAnim('unchecked', true);
        }
        else
        {
            if(oldChecked != checked)
            {
                if(checked)
                    playAnim('check');
                else
                    playAnim('uncheck');

                oldChecked = checked;
            }
            else
            {
                if(checked)
                    playAnim('checked', true);
                else
                    playAnim('unchecked', true);
            }
        }

        refreshed = true;
    }

    public function playAnim(anim:String, ?force:Bool = false)
    {
        if(animation.getByName(anim) != null)
        {
            animation.play(anim, force);

            if(anim == 'unchecked')
                offset.set(0, 0);

            if(anim == 'checked')
                offset.set(9, 27);

            if(anim == 'uncheck')
                offset.set(9, 27);

            if(anim == 'check')
                offset.set(38, 28);
        }
    }
}