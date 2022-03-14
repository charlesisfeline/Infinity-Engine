package util;

import flixel.graphics.FlxGraphic;
import openfl.media.Sound;
import lime.utils.Assets;

class Cache
{
    public static var songCache:Map<String, Sound> = [];
    public static var musicCache:Map<String, Sound> = [];
    public static var soundCache:Map<String, Sound> = [];
    public static var imageCache:Map<String, FlxGraphic> = [];

    public static function addToCache(key:String, value:Dynamic, cacheName:String)
    {
        var cache = convertStringToCache(cacheName);

        cache.set(key, value);
    }

    public static function getFromCache(key:String, cacheName:String)
    {
        var cache = convertStringToCache(cacheName);
        
        return cache.get(key);
    }

    public static function convertStringToCache(name:String):Dynamic
    {
        switch(name.toLowerCase())
        {
            case "song":
                return songCache;
            case "music":
                return imageCache;
            case "sound":
                return soundCache;
            case "image":
                return imageCache;
            default:
                return new Map<String, String>();
        }
    }

	public static function clearCache()
    {
        for (key in Cache.imageCache.keys())
        {
            if (key != null)
            {
                Assets.cache.clear(key);
                Cache.imageCache.remove(key);
            }
        }

        Cache.imageCache = [];
        
        for (key in Cache.soundCache.keys())
        {
            if (key != null)
            {
                openfl.Assets.cache.clear(key);
                Cache.soundCache.remove(key);
            }
        }

        Cache.soundCache = [];

        for (key in Cache.musicCache.keys())
        {
            if (key != null)
            {
                openfl.Assets.cache.clear(key);
                Cache.musicCache.remove(key);
            }
        }

        Cache.musicCache = [];

        for (key in Cache.songCache.keys())
        {
            if (key != null)
            {
                openfl.Assets.cache.clear(key);
                Cache.songCache.remove(key);
            }
        }

        Cache.songCache = [];
    }
}