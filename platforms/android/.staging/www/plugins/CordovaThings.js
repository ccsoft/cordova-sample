var CC;
(function (CC) {
    var CordovaThings = (function () {
        function CordovaThings() {
        }
        CordovaThings.prototype.getAppVersion = function (successcb, failcb) {
            if (!window.cordova) {
                if (failcb)
                    failcb("no cordova");
                return;
            }
            window.cordova.exec(function (response) {
                successcb(response);
            }, function (err) {
                console.log("getAppVersion call failed with error: " + err);
                if (failcb)
                    failcb(err);
            }, "CordovaThings", "getAppVersion", []);
        };
        return CordovaThings;
    })();
    CC.CordovaThings = CordovaThings;
})(CC || (CC = {}));
