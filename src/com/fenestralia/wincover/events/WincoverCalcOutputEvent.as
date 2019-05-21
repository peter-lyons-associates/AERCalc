package com.fenestralia.wincover.events {

import flash.events.Event;

public class WincoverCalcOutputEvent extends Event {

    public static const RUN_WINCOVER_CALC_FINISHED:String = "wincovercalc_output_finished";
    public static const RUN_WINCOVER_CALC_FAILED:String = "wincovercalc_output_failed";

    public var windowID:int;
    public var windowName:String;
    public var heatingValue:Number;
    public var heatingRating:Number;
    public var coolingValue:Number;
    public var coolingRating:Number;
    public var error:String;

    public function WincoverCalcOutputEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
    {
        super(type, bubbles, cancelable);
    }
}
}

