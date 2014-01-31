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
        "file": "plugins/com.ccsoft.plugin.CordovaFoursquare/www/CordovaFoursquare.js",
        "id": "com.ccsoft.plugin.CordovaFoursquare.CordovaFoursquare",
        "merges": [
            "CC"
        ]
    }
]
});