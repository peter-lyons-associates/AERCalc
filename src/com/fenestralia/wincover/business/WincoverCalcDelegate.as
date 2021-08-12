package com.fenestralia.wincover.business {
import com.fenestralia.wincover.events.WincoverCalcOutputEvent;
import com.fenestralia.wincover.model.WincoverCalcInputVO;

import gov.lbl.aercalc.events.SimulationEvent;
import gov.lbl.aercalc.model.domain.SimulationResultVO;
import gov.lbl.aercalc.util.Utils;
import flash.events.EventDispatcher;

import mx.core.Application;

public class WincoverCalcDelegate extends EventDispatcher {

    import flash.desktop.NativeApplication;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.desktop.NativeProcess;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import gov.lbl.aercalc.model.ApplicationModel;
    import gov.lbl.aercalc.model.domain.WindowVO;
    import gov.lbl.aercalc.util.Logger;
    import gov.lbl.aercalc.error.FileMissingError;
    import gov.lbl.aercalc.error.SimulationError;

    //Subdirectory conventions for using WincovER_Calc
    public static const WC_INPUT_DIR:String = "input";
    public static const WC_OUTPUT_DIR:String = "output";


    protected var _inputDir:File;
    protected var _outputDir:File;
    protected var _wincoverCalcProcess:NativeProcess;
    protected var _windowID:int;
    protected var _windowName:String;
    protected var _simulationInProgress:Boolean = false;
    protected var _errorText:String;

    protected var _wincoverCalcDir:File = ApplicationModel.baseStorageDir.resolvePath(ApplicationModel.WINCOVER_CALC_SUBDIR);

    [Inject]
    public var applicationModel:ApplicationModel;

    [Dispatcher]
    public var dispatcher:IEventDispatcher;

    [PostConstruct]
    public function init():void
    {
        _wincoverCalcProcess = new NativeProcess();
    }

    public function WincoverCalcDelegate() {


    }

    /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /*                 PUBLIC METHODS                   */
    /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

    public function calculateRatings(window:WindowVO):void{

        if (window==null){
            throw new Error("window cannot be null");
        }

        // Hold on to window ID info for eventual
        // return via result VO
        _windowID = window.id;
        _windowName = window.name;

        // Set 'in process' flag
        _simulationInProgress = true;

        //TODO: Write window properties to input.json
        try {
            var inputFile:File = createInputFileJSON(window);
        } catch(error:Error){
            Logger.error("Couldn't write input.json file for WincovER. Error"+ error.message, this);
            // TODO: This should fail gracefully with message, not throw error
            throw new Error(error.message);
        }
        try {
            runWincoverCalc(inputFile);
        } catch (error:Error){
            Logger.error("Couldn't run WincovER_Calc Error"+ error.message, this);
            // TODO: This should fail gracefully with message, not throw error
            throw new Error(error.message);
        }


    }

    public function cancel():void{

        if (_wincoverCalcProcess && _wincoverCalcProcess.running)
        {
            _wincoverCalcProcess.standardInput.writeUTFBytes("Exit\n");
        }
        removeAllProcessEventListeners();
        _simulationInProgress = false;
    }


    /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /* PUBLIC CALLBACK FOR WINCOVER-CALC NATIVE PROCESS */
    /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

    /*  Handles the native process message that the process has finished. Determines
        if process exited correctly, and if so begins workflow to read output file.
     */
    public function onWincoverCalcProcessFinished(event:NativeProcessExitEvent):void
    {
        Logger.info("WincovER_Calc completed successfully. Reading output...",this);
        _simulationInProgress = false;
        removeAllProcessEventListeners();

        if (event.exitCode > 0){
            Logger.error("WincovER-Calc exited with an error : " + event.exitCode);
            var evt:WincoverCalcOutputEvent = new WincoverCalcOutputEvent(WincoverCalcOutputEvent.RUN_WINCOVER_CALC_FAILED, true);
            evt.error = "WincovER-Calc exited with an error. See log for details.";
            dispatchEvent(evt);
        } else {
            readWincoverCalcResults();
        }
    }

    /*  Handle stdout messages arriving from WincovER_Calc. Launches a status
        message with any text that arrives from stdout.
     */
    public function onWincoverCalcStandardOutput(event:ProgressEvent):void
    {
        if (_simulationInProgress){
            var text:String = _wincoverCalcProcess.standardOutput.readUTFBytes(_wincoverCalcProcess.standardOutput.bytesAvailable);
            var evt:SimulationEvent = new SimulationEvent(SimulationEvent.SIMULATION_STATUS, true);
            // Groom incoming text so we can show it properly in progress dialog
            var txt_to_remove:String = Utils.makeUsableAsAFilename(_windowName) + "_";
            evt.statusMessage = text;
            Logger.debug("Wincover-calc output:" + text);
            dispatcher.dispatchEvent(evt);
        }
    }

    /*  Handle errors arriving via stderror. Since we handle process error once the process has exited,
        there's nothing to do here really except log out the incoming errors.
     */
    public function onWincoverCalcStandardError(event:ProgressEvent):void
    {
        _errorText = _wincoverCalcProcess.standardError.readUTFBytes(_wincoverCalcProcess.standardError.bytesAvailable);
        Logger.error(_errorText);
    }


    /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /*                  PRIVATE METHODS                 */
    /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

    /* Creates a string for the input file, formatted in the JSON structure
       as expected by wincover-calc. Then writes that to the approprate sub directory.
    */
    protected function createInputFileJSON(wVO:WindowVO):File {
//@todo UPDATE create new Input File

        const inputWrapperObj:Object = { windows: null}; //json pseudo-representation is: "{ \"windows\": [ " + {inputArray item list} + "] }"


        if (wVO.Fixed) {
            //we only need a single fixed InputVO
            inputWrapperObj.windows = createInputsArray(wVO,[WincoverCalcInputVO.TYPE_FIXED]);
        } else {
            //we should create InputVOs corresponding to 'manual', 'timer', and 'sensor'
            inputWrapperObj.windows = createInputsArray(wVO,[WincoverCalcInputVO.TYPE_MANUAL, WincoverCalcInputVO.TYPE_TIMER, WincoverCalcInputVO.TYPE_AUTOMATED]);
        }
       /* var inputObject:WincoverCalcInputVO = new WincoverCalcInputVO();
        inputObject.name = wVO.name;*/
        // TODO: Move this to helper method
        /*var bsdfName:String = Utils.makeUsableAsAFilename(wVO.name) + "_bsdf.idf";
        var projectBSDFDir:File = applicationModel.getCurrentProjectBSDFDir();

        var w7IdfFile:File = projectBSDFDir.resolvePath(bsdfName);
        if (!w7IdfFile.exists){
            var msg:String = "Missing idf file: " + w7IdfFile.nativePath;
            throw new FileMissingError(msg);
        }
        var path:String = w7IdfFile.nativePath;*/
       /* inputObject.bsdf_path = path.replace( /\\/g, '/');
        inputObject.shgc = wVO.SHGC;
        inputObject.uvalue = wVO.UvalWinter;*/
        //inputArray.push(inputObject);

        var input_file_json:String = JSON.stringify(inputWrapperObj);
    //    input_file_json = "{ \"windows\": [ " + input_file_json + "] }";
        Logger.debug("Input file json is: " + input_file_json);

        var inputFile:File = ApplicationModel.baseStorageDir.resolvePath(ApplicationModel.WINCOVER_CALC_SUBDIR).resolvePath(ApplicationModel.WINCOVER_CALC_INPUT_FILENAME);
        var stream:FileStream = new FileStream();
        stream.open(inputFile, FileMode.WRITE);
        stream.writeUTFBytes(input_file_json);
        stream.close();

        return inputFile;
    }


    private function createInputsArray(fromWinVO:WindowVO, operations:Array):Array{
        var output:Array = [];
        var bsdfName:String = Utils.makeUsableAsAFilename(fromWinVO.name) + "_bsdf.idf";
        var projectBSDFDir:File = applicationModel.getCurrentProjectBSDFDir();
        var w7IdfFile:File = projectBSDFDir.resolvePath(bsdfName);
        if (!w7IdfFile.exists){
            var msg:String = "Missing idf file: " + w7IdfFile.nativePath;
            throw new FileMissingError(msg);
        }
        var path:String = w7IdfFile.nativePath.replace( /\\/g, '/');
        for each(var operationType:String in operations) {
            var inputObject:WincoverCalcInputVO = new WincoverCalcInputVO();
            inputObject.name = fromWinVO.name;

            inputObject.bsdf_path = path/*.replace( /\\/g, '/')*/;
            inputObject.shgc = fromWinVO.SHGC;
            inputObject.uvalue = fromWinVO.UvalWinter;
            inputObject.operationType = operationType;
            output.push(inputObject);
        }
        return output;
    }


    protected function runWincoverCalc(inputFile:File):void {

        _errorText = null;

        if (_wincoverCalcProcess) {
            _wincoverCalcProcess.exit(true);
            removeAllProcessEventListeners();
        }
        _wincoverCalcProcess = new NativeProcess();
        _wincoverCalcProcess.addEventListener(NativeProcessExitEvent.EXIT, onWincoverCalcProcessFinished);
        _wincoverCalcProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onWincoverCalcStandardOutput);
        _wincoverCalcProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onWincoverCalcStandardError);

        var processArgs:Vector.<String> = new Vector.<String>();
        processArgs.push(inputFile.nativePath);
        processArgs.push("--verbose");

        var startupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
        var wincoverCalcExe:File = _wincoverCalcDir.resolvePath(ApplicationModel.WINCOVER_CALC_EXE_FILE_NAME);
        startupInfo.executable = wincoverCalcExe;
        startupInfo.workingDirectory = _wincoverCalcDir;
        startupInfo.arguments = processArgs;

        try
        {
            _wincoverCalcProcess.start(startupInfo)
        }
        catch (err:Error)
        {
            //Since we haven't gone async yet, this should be a regular error, not an error event
            var msg:String = "Cannot start EnergyPlus. " + err.errorID + " : " + err.message;
            throw new SimulationError(msg);
            _simulationInProgress = false;
        }
    }


    protected function readWincoverCalcResults():void{
        // TODO: Read output results and return event with ratings for window
        // TODO: Notify of error if can't read results.
        var errorMsg:String = null;
        var evt:WincoverCalcOutputEvent;
        try {
            var resultsFile:File = ApplicationModel.baseStorageDir.resolvePath(ApplicationModel.WINCOVER_CALC_OUTPUT_SUBDIR).resolvePath(ApplicationModel.WINCOVER_CALC_OUTPUT_FILENAME);
            var stream:FileStream = new FileStream();
            stream.open(resultsFile, FileMode.READ);
            var resultsText:String = stream.readUTFBytes(stream.bytesAvailable);
            stream.close();
        } catch (err:Error) {
            Logger.error("Couldn't load results.json file: " + err, this);
            evt = new WincoverCalcOutputEvent(WincoverCalcOutputEvent.RUN_WINCOVER_CALC_FINISHED, true);
            evt.error = "Couldn't load WincovER_Calc results.json. See log for details.";
            dispatchEvent(evt);
            return;
        }

        try{
            var resultArr:Array = JSON.parse(resultsText) as Array;
            if (!resultArr || ! resultArr.length) throw new Error('No Results found');

            resultArr = typedResults(resultArr);

            //@todo remove:
            /* var results:Object = JSON.parse(resultsText)[0];
          ar heatingValue:Number = results.heating_value;
           var heatingRating:Number = results.heating_rating;
           var coolingValue:Number = results.cooling_value;
           var coolingRating:Number = results.cooling_rating;*/
        } catch (err:Error) {
            Logger.error("Couldn't read results.json: " + err, this);
            evt = new WincoverCalcOutputEvent(WincoverCalcOutputEvent.RUN_WINCOVER_CALC_FINISHED, true);
            evt.error = "Couldn't read WincovER_Calc results.json. See log for details.";
            dispatchEvent(evt);
            return;
        }

        //TODO: validate results

        evt = new WincoverCalcOutputEvent(WincoverCalcOutputEvent.RUN_WINCOVER_CALC_FINISHED, true);

       //@todo remove:
        evt.windowID = _windowID;
        evt.windowName = _windowName;
       /* evt.heatingValue = heatingValue;
        evt.heatingRating = heatingRating;
        evt.coolingValue = coolingValue;
        evt.coolingRating = coolingRating;*/

        evt.results = resultArr;
        dispatchEvent(evt);

    }


    private function typedResults(rawInput:Array):Array{
        //assume rawInput is never null, and always has items
        var l:uint = rawInput.length;
        var processedInput:Array = rawInput.slice();


        while (l) {
            l--;
            processedInput[l] = SimulationResultVO.createFromJSON(processedInput[l])
        }

        //for convenience
        return processedInput;
    }


    public function removeAllProcessEventListeners():void
    {
        _wincoverCalcProcess.removeEventListener(NativeProcessExitEvent.EXIT, onWincoverCalcProcessFinished);
        _wincoverCalcProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onWincoverCalcStandardOutput);
        _wincoverCalcProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, onWincoverCalcStandardError);
    }
}
}
