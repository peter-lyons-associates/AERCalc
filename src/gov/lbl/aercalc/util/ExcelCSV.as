package gov.lbl.aercalc.util {
import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.filesystem.File;

public class ExcelCSV {
    //GD - added this util because it is much easier for testing/comparing the results to expected values when they are automatically launched in Excel.
    private static var _checked:Boolean;
    private static var _excelExe:File;

    private static function searchOfficeRoot():void{
        var base:File = new File('C:\\Program Files (x86)\\Microsoft Office\\root');
        if (base.exists && base.isDirectory) {
            var contents:Array = base.getDirectoryListing();
            var prospectiveExe:File;
            var l:uint = contents.length;
            var highestVersion:uint = 0;
            var highestVersionFile:File;
            for (var i:uint=0;i<l;i++) {
                var contentFile:File = contents[i];
                if (contentFile.isDirectory && contentFile.name.indexOf("Office") == 0) {
                    var version:uint = parseInt(contentFile.name.substr("Office".length));
                    if (version > highestVersion) {
                        highestVersion = version;
                        highestVersionFile = contentFile;
                    }
                }
            }
            if (highestVersionFile) {
                prospectiveExe = highestVersionFile.resolvePath("excel.exe");
                if (prospectiveExe.exists) {
                    _excelExe = prospectiveExe;
                } else {
                    _excelExe = null;
                }
            }


        } else {
            _excelExe = null;
        }
    }


    public static function get hasKnownExcel():Boolean{
        if (!_checked) {
            searchOfficeRoot();
            _checked = true
        }
        return _excelExe && _excelExe.exists;
    }



    public static function launchCSV(csv:File):Boolean {
        if (hasKnownExcel && csv && csv.exists) {
            var nativeProcess:NativeProcess = new NativeProcess();

            var startupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
            startupInfo.executable = _excelExe;
            startupInfo.arguments = new <String>[csv.nativePath];
            nativeProcess.start(startupInfo);
            return true;
        }

        return false;
    }
}
}
