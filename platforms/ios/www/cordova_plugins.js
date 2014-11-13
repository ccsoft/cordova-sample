cordova.define('cordova/plugin_list', function(require, exports, module) {
module.exports = [
    {
        "file": "plugins/org.apache.cordova.console/www/console-via-logger.js",
        "id": "org.apache.cordova.console.console",
        "clobbers": [
            "console"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.console/www/logger.js",
        "id": "org.apache.cordova.console.logger",
        "clobbers": [
            "cordova.logger"
        ]
    },
    {
        "file": "plugins/com.ccsoft.plugin.CordovaFacebook/www/CordovaFacebook.js",
        "id": "com.ccsoft.plugin.CordovaFacebook.CordovaFacebook",
        "merges": [
            "CC"
        ]
    }
];
module.exports.metadata = 
// TOP OF METADATA
{
    "org.apache.cordova.console": "0.2.5",
    "com.ccsoft.plugin.CordovaFacebook": "1.0.3"
}
// BOTTOM OF METADATA
});