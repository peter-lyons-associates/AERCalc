package com.fenestralia.wincover.business {

public class WincoverCalcInputVO {

    var name:String;
    var bsdf_path:String;
    var shgc:Number;
    var uValue:Number;

    public function WincoverCalcInputVO() {
    }

    public function toJSON(k):*
    {
        return { "name": this.name, "bsdf_path": this.bsdf_path, "shgc": this.shgc, "uValue": this.uValue }
    }
}
}
