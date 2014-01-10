var CC;
(function (CC) {
    var CordovaFacebook = (function () {
        function CordovaFacebook(appId, appNamespace, appPermissions) {
            this.appId = appId;
            this.appNamespace = appNamespace;
            this.appPermissions = appPermissions;
        }
        CordovaFacebook.prototype.init = function (successcb, failcb) {
            window.cordova.exec(function (response) {
                console.log("init call successful " + response);
                if (successcb)
                    successcb(response);
            }, function (err) {
                console.log("init call failed with error: " + err);
                if (failcb)
                    failcb(err);
            }, "CordovaFacebook", "init", [this.appId, this.appNamespace, this.appPermissions]);
        };

        CordovaFacebook.prototype.login = function (successcb, failcb) {
            window.cordova.exec(function (response) {
                console.log("login call successful " + response);
                if (successcb)
                    successcb(response);
            }, function (err) {
                console.log("login call failed with error: " + err);
                if (failcb)
                    failcb(err);
            }, "CordovaFacebook", "login", []);
        };

        CordovaFacebook.prototype.logout = function (successcb) {
            window.cordova.exec(function (response) {
                console.log("logout call successful");
                if (successcb)
                    successcb(response);
            }, function (err) {
                console.log(err);
            }, "CordovaFacebook", "logout", []);
        };

        CordovaFacebook.prototype.info = function (successcb, failcb) {
            window.cordova.exec(function (response) {
                console.log("info call successful " + response);                
                if (successcb)
                    successcb(response);
            }, function (err) {
                console.log("info call failed with error: " + err);
                if (failcb)
                    failcb(err);
            }, "CordovaFacebook", "info", []);
        };

        CordovaFacebook.prototype.feed = function (name, webUrl, logoUrl, caption, description, successcb, failcb) {
            window.cordova.exec(function (response) {
                console.log("feed call successful: " + response.post_id);
                if (successcb) {
                    if (response && response.post_id) {
                        successcb(response.post_id);
                    } else {
                        successcb(null);
                    }
                }
            }, function (err) {
                console.log("feed call failed with error: " + err);
                if (failcb)
                    failcb(err);
            }, "CordovaFacebook", "feed", [name, webUrl, logoUrl, caption, description]);
        };
        return CordovaFacebook;
    })();
    CC.CordovaFacebook = CordovaFacebook;
})(CC || (CC = {}));
