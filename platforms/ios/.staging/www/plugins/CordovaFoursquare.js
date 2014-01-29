var CC;
(function (CC) {
    var CordovaFoursquare = (function () {
        function CordovaFoursquare() {
        }
        CordovaFoursquare.prototype.login = function (clientId, clientSecret, callbackUri, successcb, failcb) {
            if (!window.cordova) {
                if (failcb)
                    failcb("no cordova");
                return;
            }
            window.cordova.exec(function (response) {
                console.log("login call successful " + response);
                if (successcb)
                    successcb(response);
            }, function (err) {
                console.log("login call failed with error: " + err);
                if (failcb)
                    failcb(err);
            }, "CordovaFoursquare", "login", [clientId, clientSecret, callbackUri]);
        };

        CordovaFoursquare.prototype.install = function (successcb, failcb) {
            if (!window.cordova) {
                if (failcb)
                    failcb("no cordova");
                return;
            }
            window.cordova.exec(function (response) {
                console.log("install call successful " + response);
                if (successcb)
                    successcb(response);
            }, function (err) {
                console.log("install call failed with error: " + err);
                if (failcb)
                    failcb(err);
            }, "CordovaFoursquare", "install", []);
        };
        return CordovaFoursquare;
    })();
    CC.CordovaFoursquare = CordovaFoursquare;
})(CC || (CC = {}));
