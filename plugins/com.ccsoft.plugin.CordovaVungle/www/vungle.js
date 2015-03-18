/// <reference path='vungle.d.ts'/>
var CC;
(function (CC) {
    var Vungle = (function () {
        function Vungle() {
        }
        Vungle.prototype.init = function (vungleid, config, successcb, errorcb) {
            window.cordova.exec(function () {
                if (successcb)
                    successcb();
            }, function (err) {
                if (errorcb)
                    errorcb(err);
            }, "CordovaVungle", "init", [vungleid, config]);
        };
        Vungle.prototype.playAd = function (config, successcb, errorcb) {
            window.cordova.exec(function (completed) {
                if (successcb)
                    successcb(completed);
            }, function (err) {
                if (errorcb)
                    errorcb(err);
            }, "CordovaVungle", "playAd", [config]);
        };
        Vungle.prototype.isVideoAvailable = function (successcb, errorcb) {
            window.cordova.exec(function (s) {
                successcb(s == 1 ? true : false);
            }, function (err) {
                if (errorcb)
                    errorcb(err);
            }, "CordovaVungle", "isVideoAvailable", []);
        };
        return Vungle;
    })();
    CC.Vungle = Vungle;
})(CC || (CC = {}));
module.exports = CC;
