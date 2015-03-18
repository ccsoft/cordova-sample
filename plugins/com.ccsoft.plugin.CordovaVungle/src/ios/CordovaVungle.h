#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import <VungleSDK/VungleSDK.h>

@interface CordovaVungle : CDVPlugin<VungleSDKDelegate> {

}

- (void) init:(CDVInvokedUrlCommand*)command;
- (void) playAd:(CDVInvokedUrlCommand*)command;
- (void) isVideoAvailable:(CDVInvokedUrlCommand*)command;

@end
