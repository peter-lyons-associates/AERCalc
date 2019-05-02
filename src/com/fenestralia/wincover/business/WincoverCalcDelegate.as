package com.fenestralia.wincover.business {
import gov.lbl.aercalc.events.SimulationEvent;
import gov.lbl.aercalc.util.Utils;
import flash.events.EventDispatcher;

import mx.core.Application;

public class WincoverCalcDelegate extends EventDispatcher {

    import flash.desktop.NativeApplication;
    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import mx.events.DynamicEvent;

    import gov.lbl.aercalc.model.ApplicationModel;
    import gov.lbl.aercalc.model.domain.WindowVO;
    import gov.lbl.aercalc.util.Logger;
    import gov.lbl.aercalc.error.FileMissingError;

    public static const RUN_WINCOVER_CALC_FAILED:String = "WincovERCalcFailed";
    public static const RUN_WINCOVER_CALC_FINISHED:String = "WincovERCalcFinished";

    //Subdirectory conventions for using WincovER-Calc
    public static const WC_INPUT_DIR:String = "input";
    public static const WC_OUTPUT_DIR:String = "output";


    protected var _inputDir:File;
    protected var _outputDir:File;
    protected var _wincoverCalcProcess:NativeProcess;
    protected var _currentWindowVO:WindowVO;

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

    public function calculateRatings(window:WindowVO){

        //TODO: Write window properties to input.json
        try {
            createInputFileJSON(window);
        } catch(error:Error){
            Logger.error("Couldn't write input.json file for WincovER. Error"+ error.messages, this);
            // TODO: This should fail gracefully with message, not throw error
            throw new Error(error.message);
        }


    }

    public function cancel(){

        if (_wincoverCalcProcess && _wincoverCalcProcess.running)
        {
            _wincoverCalcProcess.standardInput.writeUTFBytes("Exit\n");
        }
        removeAllProcessEventListeners();
    }


    /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /* PUBLIC CALLBACK FOR WINCOVER-CALC NATIVE PROCESS */
    /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

    /*  Handles the native process message that the process has finished. Determines
        if process exited correctly, and if so begins workflow to read output file.
     */
    public function onWincoverCalcProcessFinished(event:NativeProcessExitEvent):void
    {
        Logger.info("WincovER-Calc completed successfully. Reading output...",this);
        removeAllProcessEventListeners();
        _readWincoverCalcOutput();
    }

    /*  Handle stdout messages arriving from WincovER-Calc. Launches a status
        message with any text that arrives from stdout.
     */
    public function onWincoverCalcStandardOutput(event:ProgressEvent):void
    {
        var text:String = _wincoverCalcProcess.standardOutput.readUTFBytes(_wincoverCalcProcess.standardOutput.bytesAvailable);
        var evt:SimulationEvent = new SimulationEvent(SimulationEvent.SIMULATION_STATUS, true);
        // Groom incoming text so we can show it properly in progress dialog
        var txt_to_remove:String = Utils.makeUsableAsAFilename(_currentWindowVO.name) + "_";
        evt.statusMessage = text;
        Logger.debug(text);
        dispatcher.dispatchEvent(evt);
    }

    /*  Handle errors arriving via stderror. Since we handle process error once the process has exited,
        there's nothing to do here really except log out the incoming errors.
     */
    public function onWincoverCalcStandardError(event:ProgressEvent):void
    {
        var text:String = _wincoverCalcProcess.standardError.readUTFBytes(_wincoverCalcProcess.standardError.bytesAvailable);
        Logger.error(text);
    }


    /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /*                  PRIVATE METHODS                 */
    /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

    /* Creates a string for the input file, formatted in the JSON structure
       as expected by wincover-calc. Then writes that to the approprate sub directory.
    */
    protected function createInputFileJSON(wVO:WindowVO):void {

        var inputObject:WincoverCalcInputVO = new WincoverCalcInputVO();
        inputObject.name = wVO.name;

        // TODO: Move this to helper method
        var bsdfName:String = Utils.makeUsableAsAFilename(wVO.name) + "_bsdf.idf";
        var projectBSDFDir:File = applicationModel.getCurrentProjectBSDFDir();
        var w7IdfFile:File = projectBSDFDir.resolvePath(bsdfName);
        if (!w7IdfFile.exists){
            var msg:String = "Missing idf file: " + w7IdfFile.nativePath;
            throw new FileMissingError(msg);
        }


        inputObject.bsdf_path = w7IdfFile.nativePath;
        inputObject.shgc = wVO.SHGC;
        inputObject.uValue = wVO.UvalWinter;
        var input_file_json:String = JSON.stringify(inputObject);
        input_file_json = "{ \"windows\": [ " + input_file_json + "] }";
        Logger.debug("Input file json is: " + input_file_json);

        var inputFile:File = ApplicationModel.baseStorageDir.resolvePath(ApplicationModel.WINCOVER_CALC_INPUT_SUBDIR).resolvePath("input.json");
        var stream:FileStream = new FileStream();
        stream.open(inputFile, FileMode.WRITE);
        stream.writeUTFBytes(input_file_json);
        stream.close();
    }


    protected function _readWincoverCalcOutput():void{
        // TODO: Read output and return event with ratings for window
        // TODO: Notify of error if can't ready output


        var msg:DynamicEvent = new DynamicEvent(WincoverCalcDelegate.RUN_WINCOVER_CALC_FINISHED, true);

    }

    protected function _runWincoverCalc():void {
        // TODO
    }




    public function removeAllProcessEventListeners():void
    {
        _wincoverCalcProcess.removeEventListener(NativeProcessExitEvent.EXIT, onWincoverCalcProcessFinished);
        _wincoverCalcProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onWincoverCalcStandardOutput);
        _wincoverCalcProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, onWincoverCalcStandardError);
    }
}
}
