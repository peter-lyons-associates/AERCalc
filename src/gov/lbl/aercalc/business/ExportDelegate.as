/**
 * Created by danie on 27/02/2017.
 */
package gov.lbl.aercalc.business {

import gov.lbl.aercalc.util.Logger;

import flash.filesystem.File;
import flash.filesystem.FileMode;

import mx.collections.ArrayCollection;

import spark.formatters.DateTimeFormatter;

import gov.lbl.aercalc.model.domain.WindowVO;

public class ExportDelegate {


    // List of property names that we export
    // Make sure these are in the order you want them
    // to appear in the generated csv
    // Include title for the csv column head, the property name, and whether
    // to escape the delimiter if it appears in property value
    private var _exportColumns:Array = [
        {
            title: "WincovER Record ID",
            varName: "id",
            escapeDelimiter: false,
           /* includeInParentRow: true,*/
            blankIfZero: false
        },
       /* {
            title: "Parent ID",
            varName: "parent_id",
            escapeDelimiter: false,
            includeInParentRow: true,
            blankIfZero: true
        },
        {
            title: "Parent/Child",
            varName: "parentChildType",
            escapeDelimiter: false,
            includeInParentRow: true,
            blankIfZero: false
        },*/
        {
            title: "Name", // this is full w7 name
            varName: "name",
            escapeDelimiter: true,
            /* includeInParentRow: true,*/
            blankIfZero: false
        },
        {
            title: "Width",
            varName: "width",
            escapeDelimiter: true,
            /* includeInParentRow: true,*/
            blankIfZero: false
        },
        {
            title: "Height",
            varName: "height",
            escapeDelimiter: true,
            /* includeInParentRow: true,*/
            blankIfZero: false
        },
        {
            title: "U-factor",
            varName: "UvalWinter",
            escapeDelimiter: false,
            /* includeInParentRow: false,*/
            blankIfZero: false
        },
        {
            title: "SHGC",
            varName: "SHGC",
            escapeDelimiter: false,
            /* includeInParentRow: false,*/
            blankIfZero: false
        },
        {
            title: "Tvis",
            varName: "Tvis",
            escapeDelimiter: false,
            /* includeInParentRow: false,*/
            blankIfZero: false
        },
        {
            title: "Fixed ?",
            varName: "Fixed",
            escapeDelimiter: false,
            /* includeInParentRow: true,*/
            blankIfZero: false
        },
        {
            title: "Shading System Type",
            varName: "shadingSystemType",
            escapeDelimiter: false,
            /* includeInParentRow: false,*/
            blankIfZero: false
        },
        {
            title: "Attachment Position",
            varName: "attachmentPosition",
            escapeDelimiter: true,
            /* includeInParentRow: true,*/
            blankIfZero: false
        },
        {
            title: "Slat Condition",
            varName: "slatCondition",
            escapeDelimiter: true,
            /* includeInParentRow: true,*/
            blankIfZero: false
        },
        {
            title: "Product Name",
            varName: "productName",
            escapeDelimiter: true,
            /* includeInParentRow: true,*/
            blankIfZero: false
        },
        {
            title: "W7 ID",
            varName: "W7ID",
            escapeDelimiter: false,
            /* includeInParentRow: false,*/
            blankIfZero: false
        },
        {
            title: "W7 Glz Sys ID",
            varName: "W7GlzSysID",
            escapeDelimiter: false,
           /* includeInParentRow: false,*/
            blankIfZero: false
        },
        {
            title: "Baseline Window Type",
            varName: "baseWindowType",
            escapeDelimiter: false,
            /* includeInParentRow: false,*/
            blankIfZero: false
        },
        {
            title: "WINDOW Origin DB Filepath",
            varName: "WINDOWOriginDB",
            escapeDelimiter: false,
            /* includeInParentRow: false,*/
            blankIfZero: false

        },
        {
            title: "CGDB Version",
            varName: "cgdbVersion",
            escapeDelimiter: false,
            /* includeInParentRow: false,*/
            blankIfZero: false
        },
        {
            title: "CGDB ID",
            varName: "W7ShdSysID",
            escapeDelimiter: false,
           /* includeInParentRow: false,*/
            blankIfZero: false
        },
        {
            title: "WINDOW Version",
            varName: "WINDOWVersion",
            escapeDelimiter: false,
            /* includeInParentRow: false,*/
            blankIfZero: false
        },
        {
            title: "Manufacturer",
            varName: "shadingSystemManufacturer",
            escapeDelimiter: true,
            /* includeInParentRow: true,*/
            blankIfZero: false
        },
        {
            title: "Material Manufacturer",
            varName: "shadingMaterialManufacturer",
            escapeDelimiter: false,
            /* includeInParentRow: true,*/
            blankIfZero: false
        },

        {
            title: "WincovER Version",
            varName: "WincovERVersion",
            escapeDelimiter: false,
            /* includeInParentRow: false,*/
            blankIfZero: false
        },
        {
            title: "ESCalc Version",
            varName: "WincovERCalcVersion",
            escapeDelimiter: false,
            /* includeInParentRow: false,*/
            blankIfZero: false
        },
        {
            title: "THERM Files",
            varName: "THERMFiles",
            escapeDelimiter: false,
            /* includeInParentRow: false,*/
            blankIfZero: false
        },
        {
            title: "Tsol",
            varName: "Tsol",
            escapeDelimiter: false,
            /* includeInParentRow: false,*/
            blankIfZero: false
        },
        /*{
            title: "TvT",
            varName: "TvT",
            escapeDelimiter: false,
           /!* includeInParentRow: false,*!/
            blankIfZero: true
        },*/
        /*{
            title: "AL",
            varName: "airInfiltration",
            escapeDelimiter: false,
           /!* includeInParentRow: false,*!/
            blankIfZero: false
        },*/
        /*{
            title: "Heating Value",
            varName: "heatingValue",
            escapeDelimiter: false,
           /!* includeInParentRow: true,*!/
            blankIfZero: true
        },
        {
            title: "Heating Rating",
            varName: "heatingRating",
            escapeDelimiter: false,
           /!* includeInParentRow: true,*!/
            blankIfZero: true
        },*/
        /*{
            title: "Cooling Value",
            varName: "coolingValue",
            escapeDelimiter: false,
           /!* includeInParentRow: true,*!/
            blankIfZero: true
        },
        {
            title: "Cooling Rating",
            varName: "coolingRating",
            escapeDelimiter: false,
           /!* includeInParentRow: true,*!/
            blankIfZero: true
        },*/





        /*{
            title: "EnergyPlus Version",
            varName: "EPlusVersion",
            escapeDelimiter: false,
           /!* includeInParentRow: false,*!/
            blankIfZero: false
        },*/

       /* {
            title: "BSDF",
            varName: "hasBSDF",
            escapeDelimiter: false,
           /!* includeInParentRow: false,*!/
            blankIfZero: false
        },
        {
            title: "Status",
            varName: "versionStatus",
            escapeDelimiter: true,
           /!* includeInParentRow: false,*!/
            blankIfZero: false
        },*/
       /* {
            title: "AERC ID",
            varName: "userID",
            escapeDelimiter: false,
           /!* includeInParentRow: true,*!/
            blankIfZero: false
        },*/
        /*{
            title: "Emissivity Front",
            varName: "Emishout",
            escapeDelimiter: false,
           /!* includeInParentRow: false,*!/
            blankIfZero: false
        },
        {
            title: "Emissivity Back",
            varName: "Emishin",
            escapeDelimiter: false,
           /!* includeInParentRow: false,*!/
            blankIfZero: false
        },*/


        {
            title: "Manual Cooling Stars",
            varName: "manualCoolingStars",
            escapeDelimiter: false,
            /* includeInParentRow: true,*/
            blankIfZero: blankIfZeroDependingFixed(false)
        },
        {
            title: "Manual Heating Stars",
            varName: "manualHeatingStars",
            escapeDelimiter: false,
            /* includeInParentRow: true,*/
            blankIfZero: blankIfZeroDependingFixed(false)
        },
        {
            title: "Manual Cooling PC",
            varName: "manualCoolingPC",
            escapeDelimiter: false,
            /* includeInParentRow: true,*/
            blankIfZero: blankIfZeroDependingFixed(false)
        },
        {
            title: "Manual Heating PC",
            varName: "manualHeatingPC",
            escapeDelimiter: false,
            /* includeInParentRow: true,*/
            blankIfZero: blankIfZeroDependingFixed(false)
        },
        {
            title: "Timer Cooling Stars",
            varName: "timerCoolingStars",
            escapeDelimiter: false,
            /* includeInParentRow: true,*/
            blankIfZero: blankIfZeroDependingFixed(false)
        },
        {
            title: "Timer Heating Stars",
            varName: "timerHeatingStars",
            escapeDelimiter: false,
            /* includeInParentRow: true,*/
            blankIfZero: blankIfZeroDependingFixed(false)
        },
        {
            title: "Timer Cooling PC",
            varName: "timerCoolingPC",
            escapeDelimiter: false,
            /* includeInParentRow: true,*/
            blankIfZero: blankIfZeroDependingFixed(false)
        },
        {
            title: "Timer Heating PC",
            varName: "timerHeatingPC",
            escapeDelimiter: false,
            /* includeInParentRow: true,*/
            blankIfZero: blankIfZeroDependingFixed(false)
        },


        {
            title: "Sensor Cooling Stars",
            varName: "sensorCoolingStars",
            escapeDelimiter: false,
            /* includeInParentRow: true,*/
            blankIfZero: blankIfZeroDependingFixed(false)
        },
        {
            title: "Sensor Heating Stars",
            varName: "sensorHeatingStars",
            escapeDelimiter: false,
            /* includeInParentRow: true,*/
            blankIfZero: blankIfZeroDependingFixed(false)
        },
        {
            title: "Sensor Cooling PC",
            varName: "sensorCoolingPC",
            escapeDelimiter: false,
            /* includeInParentRow: true,*/
            blankIfZero: blankIfZeroDependingFixed(false)
        },
        {
            title: "Sensor Heating PC",
            varName: "sensorHeatingPC",
            escapeDelimiter: false,
            /* includeInParentRow: true,*/
            blankIfZero: blankIfZeroDependingFixed(false)
        },
        {
            title: "Fixed Cooling Stars",
            varName: "fixedCoolingStars",
            escapeDelimiter: false,
            /* includeInParentRow: true,*/
            blankIfZero: blankIfZeroDependingFixed(true)
        },
        {
            title: "Fixed Heating Stars",
            varName: "fixedHeatingStars",
            escapeDelimiter: false,
            /* includeInParentRow: true,*/
            blankIfZero: blankIfZeroDependingFixed(true)
        },
        {
            title: "Fixed Cooling PC",
            varName: "fixedCoolingPC",
            escapeDelimiter: false,
            /* includeInParentRow: true,*/
            blankIfZero: blankIfZeroDependingFixed(true)
        },
        {
            title: "Fixed Heating PC",
            varName: "fixedHeatingPC",
            escapeDelimiter: false,
            /* includeInParentRow: true,*/
            blankIfZero: blankIfZeroDependingFixed(true)
        }

    ];


    private static function isFixed(winVO:WindowVO):Boolean{
        return winVO && winVO.Fixed && (winVO.fixedHeatingStars || winVO.fixedHeatingPC || winVO.fixedCoolingPC || winVO.fixedCoolingStars);
    }

    private static function isNotFixed(winVO:WindowVO):Boolean{
        return winVO && !winVO.Fixed && (
                winVO.manualHeatingStars || winVO.manualHeatingPC || winVO.manualCoolingPC || winVO.manualCoolingStars
                ||  winVO.timerHeatingStars || winVO.timerHeatingPC || winVO.timerCoolingPC || winVO.timerCoolingStars
                ||  winVO.sensorHeatingStars || winVO.sensorHeatingPC || winVO.sensorCoolingPC || winVO.sensorCoolingStars
        );
    }

    private static function blankIfZeroDependingFixed(fixedState:Boolean):Function{
        return function(winVO:WindowVO):Boolean{
            if (fixedState && isFixed(winVO)) return false;
            if (!fixedState && isNotFixed(winVO)) return false;
            return true;
        }
    }

    /*
    public var manualCoolingStars:Number;
		public var manualHeatingStars:Number;
		public var manualCoolingPC:Number;
		public var manualHeatingPC:Number;
		public var timerCoolingStars:Number;
		public var timerHeatingStars:Number;
		public var timerCoolingPC:Number;
		public var timerHeatingPC:Number;
		public var sensorCoolingStars:Number;
		public var sensorHeatingStars:Number;
		public var sensorCoolingPC:Number;
		public var sensorHeatingPC:Number;
		public var fixedCoolingStars:Number;
		public var fixedHeatingStars:Number;
		public var fixedCoolingPC:Number;
		public var fixedHeatingPC:Number;
     */

	public function getColumnsDefs():Array {
		return _exportColumns
	}
	
	/* Util function just to help get column info */
	public function getColumnIndex(varName:String):int {
		var numCols:uint = _exportColumns.length;
		for (var colIndex:uint=0; colIndex<numCols; colIndex++){
			if (_exportColumns[colIndex].varName==varName){
				return colIndex;
			}
		}
		return -1;
	}

    public function ExportDelegate() {
    }

    /*  Take windows provided in argument and return one csv-based string,
        including a header row as first row.

        @param windowsAC             ArrayCollection of WindowVOs to export to csv.
        @param delimiter             String value. Delimiter to use, defaults to comma
        @param includeHeaderInfo     Boolean value. If true, write out some meta-data at top of csv. Defaults to false

        @return String containing csv data.

     */
    public function getCSVFromWindows(windowsAC:ArrayCollection, delimiter:String = "", includeHeaderInfo:Boolean = false):String{

        var exportStr:String = "";
        var delimiter:String = ",";
        var fileName:String = "";

        // Write meta-data header if required
        Logger.debug("Exporting csv at : " + exportDateTime);
        if (includeHeaderInfo){
            var formatter:DateTimeFormatter = new DateTimeFormatter();
            formatter.dateTimePattern = "hh:mm a, MM/dd/yyyy";
            var exportDateTime:String = formatter.format(new Date());
            exportStr += "Date Created: " + exportDateTime + File.lineEnding;
            exportStr += "Number of Windows: " + windowsAC.length.toString() + File.lineEnding;
        }

        var numWindows:uint = windowsAC.length;
        var numCols:uint = _exportColumns.length;

        //write column headers
        for (var colIndex:uint = 0; colIndex<numCols; colIndex++){

            var title:String = _exportColumns[colIndex].title;

            //Avoid SYLK bug in Excel. See https://support.microsoft.com/en-us/help/323626/-sylk-file-format-is-not-valid-error-message-when-you-open-file
            if (colIndex==0 && title=="ID"){
                title = "id";
            }

            exportStr += title;
            if (colIndex<numCols-1) {
                exportStr += ",";
            }
            else {
                exportStr += File.lineEnding;
            }
        }

        // write a row for each window, only writing the window properties
        // that are defined in this class
        for (var rowIndex:uint = 0; rowIndex < numWindows; rowIndex ++) {

            var rowData:String = "";
            var currWindow:WindowVO = windowsAC[rowIndex]as WindowVO;
            exportStr += writeWindowAsCSVLine(currWindow);
            /*if (currWindow.isParent && currWindow.isOpen){
				var numChildren:uint = currWindow.children.length;
                for (var childRowIndex:uint = 0; childRowIndex < numChildren; childRowIndex++){
                    exportStr += writeWindowAsCSVLine(currWindow.children[childRowIndex]);
                }
            }*/
        }

        return exportStr;
    }

    /* Write window properties as a line of csv */
    private function writeWindowAsCSVLine(currWindow:WindowVO):String {

        var rowData:String = "";
        var numCols:uint = _exportColumns.length;

        for (var colIndex:uint = 0; colIndex < numCols; colIndex++) {

            var colData:Object = _exportColumns[colIndex];
            var value:String = currWindow[colData.varName];

            /*if (currWindow.isParent){
                if (colData.varName == "attachmentPosition"){
                    var value:String = currWindow.getChildAttachmentPosition();
                }
                if (colData.varName == "shadingSystemManufacturer"){
                    value = currWindow.getChildShadingSystemManufacturer();
                }
                if (colData.varName == "shadingMaterialManufacturer"){
                    value = currWindow.getChildShadingMaterialManufacturer();
                }
                if (colData.includeInParentRow==false) {
                    value = "";
                }
            }*/

            if (value=="0"){
                var zeroFuncCheckBlank:Function = colData.blankIfZero as Function;
                var zeroCheckBlank:Boolean;
                if (zeroFuncCheckBlank != null) zeroCheckBlank = zeroFuncCheckBlank(currWindow);
                else {
                    zeroCheckBlank = colData.blankIfZero;
                }
                if (zeroCheckBlank) value= "";
            }

            if (value!="" && colData.escapeDelimiter) {
                value = escapeValueForCSV(value);
            }
            rowData += value;
            if (colIndex<numCols-1) {
                rowData += ",";
            }
            else {
                rowData += File.lineEnding;
            }
        }

        return rowData;
    }

    /*  Escape a value for CSV export. We follow these rules:
        - If the value contains a comma, newline or double quote, then the String value should be returned enclosed in double quotes.
        - Any double quote characters in the value should be escaped with another double quote.
        - Remove any newlines.
     */
    private function escapeValueForCSV(originalString:String):String {
        var newString:String = originalString.replace("\"", "\\\"");
        if (newString.indexOf("\n")>-1){
            newString = newString.split("\n").join(". ");
        }
        return '"' + newString + '"';
    }


}
}
