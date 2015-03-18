/// <reference path='vungle.d.ts'/>

module CC {
    export class Vungle implements IVungle {        
        init(vungleid: string, config?: IVungleConfig, successcb?: () => void, errorcb?: (err: string) => void) {
            (<any>window).cordova.exec(() => {
                if (successcb) successcb();
            }, (err) => {
                if(errorcb) errorcb(err);
            }, "CordovaVungle", "init", [vungleid, config]);
        }

        playAd(config?: IVungleConfig, successcb?: (completed: boolean) => void, errorcb?: (err: string) => void) {
            (<any>window).cordova.exec((completed: boolean) => {
                if(successcb) successcb(completed);
            }, (err) => {
                if(errorcb) errorcb(err);
            }, "CordovaVungle", "playAd", [config]);
        }

        isVideoAvailable(successcb: (avail: boolean) => void, errorcb?: (err: string) => void) {
            (<any>window).cordova.exec((s: number) => {
                successcb(s == 1 ? true : false);
            }, (err) => {                    
                if(errorcb) errorcb(err);
            }, "CordovaVungle", "isVideoAvailable", []);
        }
    }
}

declare var module;
module.exports = CC;