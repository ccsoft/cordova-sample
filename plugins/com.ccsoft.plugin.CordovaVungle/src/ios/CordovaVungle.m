#import "CordovaVungle.h"

@implementation CordovaVungle

static NSString* mCallbackId = nil;
static NSMutableDictionary* mConfig = nil;

- (void) init:(CDVInvokedUrlCommand*)command {
    NSString* vungleId = nil;
    if([command.arguments count] > 0 && [command.arguments objectAtIndex:0] != (id)[NSNull null]) {
        vungleId = [command.arguments objectAtIndex:0];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"no appId sent to init"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    VungleSDK* sdk = [VungleSDK sharedSDK];
    // start vungle publisher library
    [sdk startWithAppId:vungleId];
    [sdk setDelegate:self];
    
    //[sdk setLoggingEnabled:TRUE];
    
    NSLog(@"Vungle SDK: %@", VungleSDKVersion);
    
    if([command.arguments count] > 1 && [command.arguments objectAtIndex:1] != (id)[NSNull null]) {
        NSDictionary *config = [command.arguments objectAtIndex:1];
        mConfig = [self processConfig:config];
    }
        
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (NSMutableDictionary*) processConfig: (NSDictionary*) config {
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    if(mConfig) {
        [result addEntriesFromDictionary:mConfig];
    }
    for (id key in config) {
        NSString *keyVal = (NSString*)key;
        if([keyVal isEqualToString:@"incentivized"]) {
            NSNumber* incentivized = [NSNumber numberWithBool:[[config objectForKey:key] isEqual: @(1)]];
            [result setObject:incentivized forKey:VunglePlayAdOptionKeyIncentivized];
        } else if([keyVal isEqualToString:@"orientation"]) {
            [result setObject:[config objectForKey:key] forKey:VunglePlayAdOptionKeyOrientations]; // !! Be careful, not the same behaviour with android
        } else if([keyVal isEqualToString:@"incentivizedUserId"]) {
            [result setObject:[config objectForKey:key] forKey:VunglePlayAdOptionKeyUser];
        } else if([keyVal isEqualToString:@"placement"]) {
            [result setObject:[config objectForKey:key] forKey:VunglePlayAdOptionKeyPlacement];
        } else if([keyVal isEqualToString:@"extra1"]) {
            [result setObject:[config objectForKey:key] forKey:VunglePlayAdOptionKeyExtra1];
        } else if([keyVal isEqualToString:@"extra2"]) {
            [result setObject:[config objectForKey:key] forKey:VunglePlayAdOptionKeyExtra2];
        } else if([keyVal isEqualToString:@"extra3"]) {
            [result setObject:[config objectForKey:key] forKey:VunglePlayAdOptionKeyExtra3];
        } else if([keyVal isEqualToString:@"extra4"]) {
            [result setObject:[config objectForKey:key] forKey:VunglePlayAdOptionKeyExtra4];
        } else if([keyVal isEqualToString:@"extra5"]) {
            [result setObject:[config objectForKey:key] forKey:VunglePlayAdOptionKeyExtra5];
        } else if([keyVal isEqualToString:@"extra6"]) {
            [result setObject:[config objectForKey:key] forKey:VunglePlayAdOptionKeyExtra6];
        } else if([keyVal isEqualToString:@"extra7"]) {
            [result setObject:[config objectForKey:key] forKey:VunglePlayAdOptionKeyExtra7];
        } else if([keyVal isEqualToString:@"extra8"]) {
            [result setObject:[config objectForKey:key] forKey:VunglePlayAdOptionKeyExtra8];
        } else if([keyVal isEqualToString:@"incentivizedCancelDialogBodyText"]) {
            [VungleSDK sharedSDK].incentivizedAlertText = [config objectForKey:key];
        }  else if([keyVal isEqualToString:@"soundEnabled"]) {
            BOOL muted = [[config objectForKey:key] isEqual: @(0)];
            [[VungleSDK sharedSDK] setMuted:muted];
        }
    }
    return result;
}

- (void)dealloc {
  [[VungleSDK sharedSDK] setDelegate:nil];
}

- (void) playAd:(CDVInvokedUrlCommand*)command
{
    if(self.viewController == nil) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"no view to use"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    NSDictionary *config = nil;
    if([command.arguments count] > 0 && [command.arguments objectAtIndex:0] != (id)[NSNull null]) {
        config = [self processConfig:[command.arguments objectAtIndex:0]];
    } else {
        config = mConfig;
    }
    
    if([config objectForKey:VunglePlayAdOptionKeyIncentivized] != (id)[NSNull null] && [[config objectForKey:VunglePlayAdOptionKeyIncentivized] isEqual:@(1)]) {
        // incentivized ad should be displayed
        mCallbackId = command.callbackId; // we will use it in delegate
    } else {
        mCallbackId = nil;
    }
    
    [[VungleSDK sharedSDK] playAd:self.viewController withOptions:config];
    if(mCallbackId == nil) { // not incentivized, return immediately
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void) isVideoAvailable:(CDVInvokedUrlCommand*)command
{
    bool result = [[VungleSDK sharedSDK] isCachedAdAvailable];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * If implemented, this will get called when ad ad has cached. It's now ready to play!
 
- (void)vungleSDKhasCachedAdAvailable
{
    
}
*/

/**
 * If implemented, this will get called when the SDK is about to show an ad. This point
 * might be a good time to pause your game, and turn off any sound you might be playing.

- (void)vungleSDKwillShowAd
{
    
}
*/

/**
 * If implemented, this will get called when the SDK closes the ad view, but that doesn't always mean
 * the ad experience is complete. There might be a product sheet that will be presented.
 * This point might be a good place to resume your game if there's no product sheet being presented.
 * If the product sheet will be shown, we recommend waiting for it to close before you resume,
 * show a reward confirmation to the user, etc. The viewInfo dictionary will contain the following keys:
 * - "completedView": NSNumber representing a BOOL whether or not the video can be considered a
 *                full view.
 * - "playTime": NSNumber representing the time in seconds that the user watched the video.
 * - "didDownlaod": NSNumber representing a BOOL whether or not the user clicked the download
 *                  button.
 */
- (void)vungleSDKwillCloseAdWithViewInfo:(NSDictionary*)viewInfo willPresentProductSheet:(BOOL)willPresentProductSheet
{
    if(mCallbackId == nil) {
        return;
    }
    BOOL completed = (BOOL)[viewInfo valueForKey:@"completedView"];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:completed];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:mCallbackId];
    mCallbackId = nil;
}

/**
 * If implemented, this will get called when the product sheet is about to be closed.
 * It will only be called if the product sheet was shown.
 
- (void)vungleSDKwillCloseProductSheet:(id)productSheet
{
    
}
 */
@end
