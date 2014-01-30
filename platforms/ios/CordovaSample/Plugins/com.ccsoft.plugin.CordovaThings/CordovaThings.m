#import "CordovaThings.h"
#import <Cordova/CDV.h>

@implementation CordovaThings

- (void)getAppVersion:(CDVInvokedUrlCommand*)command
{
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
	CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:version];
    [self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];	
}

@end
