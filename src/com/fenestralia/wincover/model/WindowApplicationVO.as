package com.fenestralia.wincover.model {
public class WindowApplicationVO {

    public static const UNKNOWN_APPLICATION_TYPE:String = 'Unknown';

    private static const map:Object = {};
    public static function retrieve(key:String):WindowApplicationVO{
        var inst:WindowApplicationVO = map[key] as WindowApplicationVO;
        if (!inst) {
            //retrieve an 'unknown' key
            inst = map[UNKNOWN_APPLICATION_TYPE] as WindowApplicationVO;
        }
        return inst;
    }

    public static function populate(rawData:Object):uint{
        var count:uint = 0;
        var key:String;
        //empty the contents, if repopulating.
        for (key in map) {
            delete map[key];
        }
        for (key in rawData) {
            var rawObject:Object = rawData[key];
            var inst:WindowApplicationVO = new WindowApplicationVO(key, rawObject);
            map[key] = inst;
            count++;
        }
        //add an 'unknown' key
        map[UNKNOWN_APPLICATION_TYPE] = new WindowApplicationVO(UNKNOWN_APPLICATION_TYPE, {'product_type':'unknown', 'position': 'unknown'})
        return count;
    }

    private var _rawObject:Object;
    private var _key:String;

    public function WindowApplicationVO(key:String, rawObject:Object) {
        _key = key;
        _rawObject = rawObject;
    }

    public function get key():String{
        return _key;
    }

    public function get productType():String{
        return _rawObject.product_type;
    }

    public function get position():String{
        return _rawObject.position;
    }

}
}
