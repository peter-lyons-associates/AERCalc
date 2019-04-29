package com.fenestralia.wincover.business {
import gov.lbl.aercalc.events.SimulationEvent;
import gov.lbl.aercalc.util.Utils;

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
    public function onWincoverCaclStandardError(event:ProgressEvent):void
    {
        var text:String = _wincoverCalcProcess.standardError.readUTFBytes(_wincoverCalcProcess.standardError.bytesAvailable);
        Logger.error(text);
    }


    /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /*                  PRIVATE METHODS                 */
    /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


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
