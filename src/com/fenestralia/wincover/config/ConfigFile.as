package com.fenestralia.wincover.config {
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;

    import gov.lbl.aercalc.model.ApplicationModel;

    import spark.components.WindowedApplication;

    public class ConfigFile {

        private var _fileName:String = "";
        private var _localStorageDir:String = "config";
        private var _extension:String = ".json";
        private var _applicationStorageFolder:File;

        private var configFile:File;


        public function ConfigFile(application:WindowedApplication, fileName:String, localStorageDir:String = "config", extension:String = ".json") {
            _applicationStorageFolder = ApplicationModel.baseStorageDir;
            _localStorageDir = localStorageDir;
            _extension = extension;
            _fileName = fileName;
            var relativePath:String = _localStorageDir ? _localStorageDir + "/" : "";
            configFile = ApplicationModel.baseStorageDir.resolvePath(relativePath + fileName+extension);
        }

        public function fileExists():Boolean{
            return configFile.exists;
        }

        public function readBinaryData():ByteArray{
            var ret:ByteArray;
            if (fileExists()) {
                var fileStream:FileStream = new FileStream();
                fileStream.open(configFile, FileMode.READ);
                ret = new ByteArray();
                fileStream.readBytes(ret);
                fileStream.close();
            }

            return ret;
        }

        public function readContent():Object{
            var result:Object;

            switch(_extension) {
                case '.json':
                    result = readJSONData(readBinaryData());
                    break;
                case '.xml':
                    result = readXMLData(readBinaryData());
                    break;
                default:
                    throw new Error('unsupported extension type: ' + _extension);
                    break;
            }

            return result;
        }

        protected function readJSONData(content:ByteArray):Object{
            var json:Object = JSON.parse(content.readUTFBytes(content.bytesAvailable));
            return json;
        }

        protected function readXMLData(content:ByteArray):XML{
            var xml:XML = XML(content.readUTFBytes(content.bytesAvailable));
            return xml;
        }
    }
}
