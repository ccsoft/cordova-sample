module CC {
    export class CordovaFoursquare {
        
        login(clientId: string, clientSecret: string, callbackUri: string, successcb?: (r: any) => void, failcb?: (err: any) => void) {
            if (!(<any>window).cordova) {
                if (failcb) failcb("no cordova");
                return;
            }
            (<any>window).cordova.exec(
                (response) => {
                    console.log("login call successful " + response);
                    if (successcb) successcb(response);
                },
                (err) => {
                    console.log("login call failed with error: " + err);
                    if (failcb) failcb(err);
                }, "CordovaFoursquare", "login", [clientId, clientSecret, callbackUri]);
        }
        
        install(successcb?: (r: any) => void, failcb?: (err: any) => void) {
            if (!(<any>window).cordova) {
                if (failcb) failcb("no cordova");
                return;
            }
            (<any>window).cordova.exec(
                (response) => {
                    console.log("install call successful " + response);
                    if (successcb) successcb(response);
                },
                (err) => {
                    console.log("install call failed with error: " + err);
                    if (failcb) failcb(err);
                }, "CordovaFoursquare", "install", []);
        }                       
    }
}