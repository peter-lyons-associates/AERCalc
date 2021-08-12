package gov.lbl.aercalc.model.domain {

public class SimulationResultVO {

    public static const TYPE_FIXED:String = 'fixed';
    public static const TYPE_MANUAL:String = 'manual';
    public static const TYPE_TIMER:String = 'timer';
    public static const TYPE_AUTOMATED:String = 'sensor';


    private static const jsonFieldMapping:Object = {
        "name": "windowName",
        "bsdf_path" : "bsdfPath",
        "operation_type": "operationType",
        "heating_value": 'heatingPC',
        "heating_rating": 'heatingStars',
        "cooling_value": 'coolingPC',
        "cooling_rating": 'coolingStars'
    }
    public static function createFromJSON(rawInput:Object):SimulationResultVO{
        var typed:SimulationResultVO = new SimulationResultVO();
        var mappings:Object = jsonFieldMapping;
        for (var jsonField:String in rawInput) {
            var typedField:String = mappings[jsonField];
            if (!typedField) {
                trace('SimulationResultVO.createFromJSON:: no field mapping for "'+jsonField+'"')
                continue;
            }
            typed[typedField] = rawInput[jsonField];
        }
        //@todo check is this correct (assume fixed if nothing specified)
        if (!typed.operationType) {
            typed.operationType = TYPE_FIXED;
        }
        return typed;
    }

    public static function createFromWindowVO(operationType:String, windowVO:WindowVO):SimulationResultVO{
        var resultVO:SimulationResultVO = new SimulationResultVO();
        resultVO.operationType = operationType;
        resultVO.coolingPC = windowVO[operationType+"CoolingPC"] ;
        resultVO.coolingStars = windowVO[operationType+"CoolingStars"];
        resultVO.heatingPC = windowVO[operationType+"HeatingPC"];
        resultVO.heatingStars = windowVO[operationType+"HeatingStars"];
        return resultVO;
    }

    public var windowID:int = 0;
    public var windowName:String = "";
    public var bsdfPath:String = "";
    public var heatingPC:Number = 0;
    public var heatingStars:Number = 0;
    public var coolingPC:Number = 0;
    public var coolingStars:Number = 0;

    //v2
    public var operationType:String = "";

    public function SimulationResultVO() {
    }

}
}
