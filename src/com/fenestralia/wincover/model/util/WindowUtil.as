package com.fenestralia.wincover.model.util {
import com.fenestralia.wincover.model.WindowApplicationVO;

import gov.lbl.aercalc.model.ImportModel;
import gov.lbl.aercalc.model.domain.W7WindowImportVO;
import gov.lbl.aercalc.model.domain.WindowVO;
import gov.lbl.aercalc.util.Utils;

public class WindowUtil {

    private static const SLAT_CONDITION_REGEX:RegExp = /^open|closed|fixed\s*[+-]?\d+$/

    private static function createErrorState(message:String):ParsingState{
        var errState:ParsingState = new ParsingState();
        errState._errorMessage = message;
        //errState._ok = false; (redundant: default is false)
        return errState;
    }
    public static function parseBaseCaseWindowID(stringVal:String, targetWindowVO:Object, version:String = null):ParsingState{
        var errorState:ParsingState;
        if (stringVal && ImportModel.VALID_BASE_CASE_WINDOW_IDS.indexOf(stringVal) != -1) {
            targetWindowVO.baseWindowType = stringVal;
        } else {
            errorState = createErrorState("The base case Window ID \""+stringVal+"\" is not recognised in the W7 name: \"" +targetWindowVO.W7Name + "\"");
        }
        return errorState;
    }


    public static function parseSlatCondition(stringVal:String, targetWindowVO:Object, version:String = null):ParsingState{
        var errorState:ParsingState;
        if (!stringVal) {
            targetWindowVO.slatCondition = '';
        } else {
            if (SLAT_CONDITION_REGEX.test(stringVal)) {
                targetWindowVO.slatCondition = stringVal;
            } else {
                errorState = createErrorState("The slat condition is not recognised in the W7 name: \"" +targetWindowVO.W7Name + "\"");
            }
        }

        return errorState;
    }

    public static function parseID(WincovER_ID:String, targetWindowVO:Object, importVO:Boolean=true, version:String=null):ParsingState{
        var errorState:ParsingState;
        var parts:Array = WincovER_ID.split("-");
        if (parts.length != 3) {
            errorState = createErrorState("There were not exactly 3 parts to the W7 ID: \"" +WincovER_ID +"\" in \""+targetWindowVO.W7Name + "\"");
        } else {
            var fieldVal:String = parts[0];
            if (hasLength(fieldVal)) {
                if (importVO) targetWindowVO.supplierID = fieldVal;
            } else {
                errorState = createErrorState("The SupplierID part of the  W7 ID is empty: \"" +WincovER_ID +"\" in \""+targetWindowVO.W7Name + "\"");
            }
            if (!errorState) {
                fieldVal = parts[1];
                var winAppVO:WindowApplicationVO;
                if (fieldVal && fieldVal.length == 3 ) {
                    winAppVO = WindowApplicationVO.retrieve(fieldVal);
                    if (winAppVO.key == WindowApplicationVO.UNKNOWN_APPLICATION_TYPE) {
                        errorState = createErrorState("The Application Code part of the  W7 ID is not recognised: \"" +WincovER_ID +"\" in \""+targetWindowVO.W7Name + "\"");
                    }
                    //this setter should support the individual 'flat' property getters (proxying from the referenced instance)
                    targetWindowVO.winApplicationVO = winAppVO;

                } else {
                    errorState = createErrorState("The Application Code part of the  W7 ID is not valid: \"" +WincovER_ID +"\" in \""+targetWindowVO.W7Name + "\"");
                }

            }

            if (!errorState) {
                fieldVal = parts[2];
                if (fieldVal && fieldVal.length && parseInt(fieldVal).toString() == stripLeadingZeros(fieldVal)) {
                    if (importVO) targetWindowVO.sequenceNum = fieldVal;
                } else {
                    errorState = createErrorState("The Sequence number part of the W7 ID is not valid: \"" +WincovER_ID +"\" in \""+targetWindowVO.W7Name + "\"");
                }

            }

        }

        return errorState;
    }

    public static function parseDBName(w7Name:String, targetWindowVO:WindowVO, version:String=null):ParsingState {

        //<product name>::<WincovER ID>::<slat condition>::BW-<basecase window ID>

        var errorState:ParsingState;
        w7Name = Utils.scrubNewlines(w7Name);

        var parts:Array = w7Name.split("::");

        targetWindowVO.name = w7Name;

        if (parts.length != 4) {
            errorState = createErrorState("There were not exactly 4 parts to the W7 Name: \"" +w7Name + "\"");
        } else {
            if (hasLength(parts[0])) {
                //isvalidname check?
                targetWindowVO.productName =parts[0];
            } else {
                errorState = createErrorState("The Name portion has no length: \"" +w7Name + "\"");
            }
            if (!errorState) {
                //proceed for ID
                if (hasLength(parts[1])) {
                    //isvalidID check?
                    targetWindowVO.WincovER_ID = parts[1]
                    errorState = parseID(targetWindowVO.WincovER_ID, targetWindowVO, false );
                }else {
                    errorState = createErrorState("The ID portion has no length: \"" +w7Name + "\"");
                }
            }

            if (!errorState) {

                errorState = parseSlatCondition(parts[2], targetWindowVO);
            }
            if (!errorState) {
                errorState = parseBaseCaseWindowID(parts[3], targetWindowVO);
            }

        }

        return errorState || ParsingState.validParsingState;
    }


    public static function parseImportName(w7Name:String, targetWindowVO:W7WindowImportVO, version:String=null):ParsingState {

        //<product name>::<WincovER ID>::<slat condition>::BW-<basecase window ID>

        var errorState:ParsingState;
        w7Name = Utils.scrubNewlines(w7Name);

        var parts:Array = w7Name.split("::");

        targetWindowVO.W7Name = w7Name;

        if (parts.length != 4) {
            errorState = createErrorState("There were not exactly 4 parts to the W7 Name: \"" +w7Name + "\"");
        } else {
            if (hasLength(parts[0])) {
                //isvalidname check?
                targetWindowVO.name =parts[0];
            } else {
                errorState = createErrorState("The Name portion has no length: \"" +w7Name + "\"");
            }
            if (!errorState) {
                //proceed for ID
                if (hasLength(parts[1])) {
                    //isvalidID check?
                    targetWindowVO.WincovER_ID = parts[1]
                    errorState = parseID(targetWindowVO.WincovER_ID, targetWindowVO );
                }else {
                    errorState = createErrorState("The ID portion has no length: \"" +w7Name + "\"");
                }
            }

            if (!errorState) {

                errorState = parseSlatCondition(parts[2], targetWindowVO);
            }
            if (!errorState) {
                errorState = parseBaseCaseWindowID(parts[3], targetWindowVO);
            }

        }

        return errorState || ParsingState.validParsingState;
    }


    public static function hasLength(str:String):Boolean{
        return str && str.length;
    }

    public static function stripLeadingZeros(str:String):String{
        if (!str) return '';
        str = Utils.chump(str);
        if (!str) return '';
        var i:uint = 0;
        var l:uint = str.length;
        while (i<l) {
            if (str.charAt(i) != '0') break;
            i++;
        }
        return str.substr(i);
    }

}
}
