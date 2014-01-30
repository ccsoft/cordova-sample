module CC {
    export class CordovaThings {
        getAppVersion(successcb: (version: string) => void, failcb?: (error: string) => void) {
            if (!(<any>window).cordova) {
                if (failcb) failcb("no cordova");
                return;
            }
            (<any>window).cordova.exec(
                (response) => {                    
                    successcb(response);
                },
                (err) => {
                    console.log("getAppVersion call failed with error: " + err);
                    if (failcb) failcb(err);
                }, "CordovaThings", "getAppVersion", []);
        } 
    }
}