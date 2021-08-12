package com.fenestralia.wincover.model.util {
public class ParsingState {

    private static var _validParsingState:ParsingState;
    public static function get validParsingState():ParsingState{
        if (!_validParsingState) {
            _validParsingState = new ParsingState();
            _validParsingState._ok = true;
        }
        return _validParsingState;
    }

    internal var _ok:Boolean;
    public function get ok():Boolean{
        return _ok;
    }

    internal var _errorMessage:String;
    public function get errorMessage():String{
        return _errorMessage || '';
    }

    public function ParsingState() {
    }
}
}
