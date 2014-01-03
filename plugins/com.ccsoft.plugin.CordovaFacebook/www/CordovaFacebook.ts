module CC {
    export class CordovaFacebook {
        constructor(private appId: string, private appNamespace: string, private appPermissions: string[]) {
        }

        init(successcb?: (r: any) => void, failcb?: (err: any) => void) {
            (<any>window).cordova.exec(
                (response) => {
                    console.log("init call successful " + response);
                    if (successcb) successcb(response);
                },
                (err) => {
                    console.log("init call failed with error: " + err);
                    if (failcb) failcb(err);
                }, "CordovaFacebook", "init", [this.appId, this.appNamespace, this.appPermissions]);
        }
        
        login(successcb?: (r: any) => void, failcb?: (err: any) => void) {
            (<any>window).cordova.exec(
                (response) => {
                    console.log("login call successful " + response);
                    if (successcb) successcb(response);
                },
                (err) => {
                    console.log("login call failed with error: " + err);
                    if (failcb) failcb(err);
                }, "CordovaFacebook", "login", []);
        }

        logout(successcb?: (r: any) => void) {
            (<any>window).cordova.exec(
                (response) => {
                    console.log("logout call successful");
                    if (successcb) successcb(response);
                },
                (err) => {
                    console.log(err)
            }, "CordovaFacebook", "logout", []);
        }

        info(successcb?: (r: any) => void, failcb?: (err: any) => void) {
            (<any>window).cordova.exec(
                (response) => {
                    console.log("info call successful " + response);
                    if (successcb) successcb(response);
                },
                (err) => {
                    console.log("info call failed with error: " + err);
                    if (failcb) failcb(err);
                }, "CordovaFacebook", "info", []);
        }

        feed(name: string, webUrl: string, logoUrl: string, caption: string, description: string, successcb?: (r: any) => void, failcb?: (err: any) => void) {
            (<any>window).cordova.exec(
                (response) => {
                    console.log("feed call successful: " + response.post_id);
                    if (successcb) {
                        if (response && response.post_id) {
                            successcb(response.post_id);
                        } else {
                            successcb(null);
                        }
                    }
                },
                (err) => {
                    console.log("feed call failed with error: " + err);
                    if (failcb) failcb(err);
            }, "CordovaFacebook", "feed", [name, webUrl, logoUrl, caption, description]);
        }
    }
}