package com.fenestralia.wincover.model {

public class WincoverCalcInputVO {

    public var name:String;
    public var bsdf_path:String;
    public var shgc:Number;
    public var uvalue:Number;

    public function WincoverCalcInputVO() {
    }

    public function toJSON(k):*
    {
        return { "name": this.name, "bsdf_path": this.bsdf_path, "shgc": this.shgc, "uvalue": this.uvalue }
    }
}
}
