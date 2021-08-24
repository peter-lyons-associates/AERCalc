package com.fenestralia.wincover.model {

public class WincoverCalcInputVO {

    public static const TYPE_FIXED:String = 'fixed';
    public static const TYPE_MANUAL:String = 'manual';
    public static const TYPE_TIMER:String = 'timer';
    public static const TYPE_AUTOMATED:String = 'sensor';

    public var name:String;
    public var bsdf_path:String;
    public var shgc:Number;
    public var uvalue:Number;
    public var operationType:String;

    public function WincoverCalcInputVO() {
    }

    public function toJSON(s:String):*
    {
        return { "name": this.name, "bsdf_path": this.bsdf_path, /*"shgc": this.shgc, "uvalue": this.uvalue,*/ "operation_type": operationType }
    }
}
}
