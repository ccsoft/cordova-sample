/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "CordovaFacebook.h"
#import <Cordova/CDV.h>
#import <UIKit/UIKit.h>

@implementation CordovaFacebook


static id <CDVCommandDelegate> commandDelegate = nil;
+ (id <CDVCommandDelegate>) commandDelegate {return commandDelegate;}
+ (void)setCommandDelegate:(id <CDVCommandDelegate>)del {commandDelegate = del;}


static NSString* loginCallbackId = nil;
+ (NSString*) loginCallbackId {return loginCallbackId;}
+ (void)setLoginCallbackId:(NSString *)cb {loginCallbackId = cb;}

static NSMutableArray *readPermissions;
+ (NSMutableArray *)readPermissions { return readPermissions; }
//+ (void)setReadPermissions:(NSMutableArray *)param { readPermissions = param; }

static NSMutableArray *publishPermissions;
+ (NSMutableArray *)publishPermissions { return publishPermissions; }
//+ (void)setPublishPermissions:(NSMutableArray *)param { publishPermissions = param; }

+(void)load {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifiedOpenUrl:)
                                                 name:@"CordovaPluginOpenURLNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifiedApplicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

+(void)notifiedOpenUrl:(NSNotification*)notification {
    NSDictionary* params = notification.userInfo;
    if (params == nil) {
        return;
    }
    
    NSURL *url = [params objectForKey:@"url"];
    NSString *sourceApplication = [params objectForKey:@"sourceApplication"];
    
    NSLog(@"Notification received by FB plugin notifiedOpenUrl method");
    // Note this handler block should be the exact same as the handler passed to any open calls.
    [FBSession.activeSession setStateChangeHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         // Call sessionStateChanged:state:error method to handle session state changes
         [CordovaFacebook sessionStateChanged:session state:state error:error];
     }];
  
    BOOL success = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    if(success) {
        [params setValue:@"facebook" forKey:@"success"];
    }
}

+(void)notifiedApplicationDidBecomeActive:(NSNotification*)notification {
    NSLog(@"notifiedApplicationDidBecomeActive");
    // Handle the user leaving the app while the Facebook login dialog is being shown
    // For example: when the user presses the iOS "home" button while the login dialog is active
    [FBAppCall handleDidBecomeActive];
}

+ (BOOL)activeSessionHasPermissions:(NSArray *)permissions
{
    __block BOOL hasPermissions = YES;
    for (NSString *permission in permissions)
    {
        NSInteger index = [[FBSession activeSession].permissions indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isEqualToString:permission])
            {
                *stop = YES;
            }
            return *stop;
        }];
        
        if (index == NSNotFound)
        {
            hasPermissions = NO;
        }
    }
    return hasPermissions;
}

// This method will handle ALL the session state changes in the app
+ (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        
        if([CordovaFacebook loginCallbackId] != nil) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[[FBSession.activeSession accessTokenData] accessToken] ];
            [[CordovaFacebook commandDelegate] sendPluginResult:pluginResult callbackId:[CordovaFacebook loginCallbackId]];
        }
        else {
            NSLog(@"noone to callback");
        }
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        if([CordovaFacebook loginCallbackId] != nil) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Login failed or closed"];
            [[CordovaFacebook commandDelegate] sendPluginResult:pluginResult callbackId:[CordovaFacebook loginCallbackId]];
        }
    }

    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *errorText;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            errorText = [FBErrorUtility userMessageForError:error];
        } else {

            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                errorText = @"User cancelled login";
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                errorText = @"Your current session is no longer valid. Please log in again.";
                
                // For simplicity, here we just show a generic message for all other errors
                // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                errorText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
            }
        }
        
        NSLog(@"%@", errorText);
        if([CordovaFacebook loginCallbackId] != nil) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorText];
            [[CordovaFacebook commandDelegate] sendPluginResult:pluginResult callbackId:[CordovaFacebook loginCallbackId]];
        }
        
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
    }
}

- (void)init:(CDVInvokedUrlCommand*)command
{
    [CordovaFacebook setLoginCallbackId:command.callbackId];
    [CordovaFacebook setCommandDelegate:self.commandDelegate];
//    NSString* appId = [command.arguments objectAtIndex:0];
//    NSString* appNamespace = [command.arguments objectAtIndex:1];
    
    NSLog(@"FB SDK: %@", [FBSettings sdkVersion]);
    
    NSArray* appPermissions = [command.arguments objectAtIndex:2];
    readPermissions = [[NSMutableArray alloc] init];
    publishPermissions = [[NSMutableArray alloc] init];
    for (NSString* perm in appPermissions) {
        if([CordovaFacebook isReadPermission:perm]) {
            [readPermissions addObject:perm];
        } else {
            [publishPermissions addObject:perm];
        }
    }
    
    // Whenever a person inits, check for a cached session
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          [CordovaFacebook sessionStateChanged:session state:state error:error];
                                      }];
    }
}

- (void)login:(CDVInvokedUrlCommand*)command
{
    [CordovaFacebook setLoginCallbackId:nil];
    if([FBSession.activeSession isOpen]){
        NSLog(@"already logged in");
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[[FBSession.activeSession accessTokenData] accessToken] ];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    if(readPermissions == nil) {
        NSLog(@"init with some permissions first");
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"no read permissions"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    [CordovaFacebook setLoginCallbackId:command.callbackId];
    // Open a session showing the user the login UI
    // You must ALWAYS ask for basic_info permissions when opening a session
    [FBSession openActiveSessionWithReadPermissions:readPermissions
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
         [CordovaFacebook sessionStateChanged:session state:state error:error];
     }];
}

- (void)logout:(CDVInvokedUrlCommand*)command
{
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)info:(CDVInvokedUrlCommand*)command
{
    if([FBSession.activeSession isOpen] == NO) { // not have a session to post
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"no active session"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    [[FBRequest requestForMe] startWithCompletionHandler:
     ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *info, NSError *error) {
         if (!error) {
             NSLog(@"User info: %@", info);
             CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:info];
             [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
         }
         else {
             CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"failed to get info"];
             [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
         }
     }];
}

- (void)feed:(CDVInvokedUrlCommand*)command
{
    if([FBSession.activeSession isOpen] == NO) { // not have a session to post
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"no active session"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    // if need publish permissions
    if(publishPermissions.count > 0 && [CordovaFacebook activeSessionHasPermissions:publishPermissions] == NO) {
            [FBSession.activeSession requestNewPublishPermissions:publishPermissions
                              defaultAudience:FBSessionDefaultAudienceEveryone
                            completionHandler:^(FBSession *session, NSError *error) {
                                if(error != nil) {
                                    NSLog(@"Request publish err:%@", error);
                                    return;
                                }
                                else if ([CordovaFacebook activeSessionHasPermissions:publishPermissions] == NO) {
                                    NSLog(@"Request publish failed");
                                    return;
                                }
                                NSLog(@"Request publish granted for: %@", publishPermissions);
                                // do feed post now
                                [self post:command];
                            }];
    }
    else {
        // do feed post now
        [self post:command];
    }
}

- (void)post:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/*
 I hope someday Facebook SDK will have a better method for this.
 */
+ (BOOL)isReadPermission: (NSString*) permission
{
    if([permission isEqualToString:@"basic_info"]) return YES;
    if([permission isEqualToString:@"user_about_me"]) return YES;
    if([permission isEqualToString:@"friends_about_me"]) return YES;
    if([permission isEqualToString:@"user_activities"]) return YES;
    if([permission isEqualToString:@"friends_activities"]) return YES;
    if([permission isEqualToString:@"user_birthday"]) return YES;
    if([permission isEqualToString:@"friends_birthday"]) return YES;
    if([permission isEqualToString:@"user_checkins"]) return YES;
    if([permission isEqualToString:@"friends_checkins"]) return YES;
    if([permission isEqualToString:@"user_education_history"]) return YES;
    if([permission isEqualToString:@"friends_education_history"]) return YES;
    if([permission isEqualToString:@"user_events"]) return YES;
    if([permission isEqualToString:@"friends_events"]) return YES;
    if([permission isEqualToString:@"user_groups"]) return YES;
    if([permission isEqualToString:@"friends_groups"]) return YES;
    if([permission isEqualToString:@"user_hometown"]) return YES;
    if([permission isEqualToString:@"friends_hometown"]) return YES;
    if([permission isEqualToString:@"user_interests"]) return YES;
    if([permission isEqualToString:@"friends_interests"]) return YES;
    if([permission isEqualToString:@"user_photos"]) return YES;
    if([permission isEqualToString:@"friends_photos"]) return YES;
    if([permission isEqualToString:@"user_likes"]) return YES;
    if([permission isEqualToString:@"friends_likes"]) return YES;
    if([permission isEqualToString:@"user_notes"]) return YES;
    if([permission isEqualToString:@"friends_notes"]) return YES;
    if([permission isEqualToString:@"user_online_presence"]) return YES;
    if([permission isEqualToString:@"friends_online_presence"]) return YES;
    if([permission isEqualToString:@"user_religion_politics"]) return YES;
    if([permission isEqualToString:@"friends_religion_politics"]) return YES;
    if([permission isEqualToString:@"user_relationships"]) return YES;
    if([permission isEqualToString:@"friends_relationships"]) return YES;
    if([permission isEqualToString:@"user_relationship_details"]) return YES;
    if([permission isEqualToString:@"friends_relationship_details"]) return YES;
    if([permission isEqualToString:@"user_status"]) return YES;
    if([permission isEqualToString:@"friends_status"]) return YES;
    if([permission isEqualToString:@"user_subscriptions"]) return YES;
    if([permission isEqualToString:@"friends_subscriptions"]) return YES;
    if([permission isEqualToString:@"user_videos"]) return YES;
    if([permission isEqualToString:@"friends_videos"]) return YES;
    if([permission isEqualToString:@"user_website"]) return YES;
    if([permission isEqualToString:@"friends_website"]) return YES;
    if([permission isEqualToString:@"user_work_history"]) return YES;
    if([permission isEqualToString:@"friends_work_history"]) return YES;
    if([permission isEqualToString:@"user_location"]) return YES;
    if([permission isEqualToString:@"friends_location"]) return YES;
    if([permission isEqualToString:@"user_photo_video_tags"]) return YES;
    if([permission isEqualToString:@"friends_photo_video_tags"]) return YES;
    if([permission isEqualToString:@"read_friendlists"]) return YES;
    if([permission isEqualToString:@"read_mailbox"]) return YES;
    if([permission isEqualToString:@"read_requests"]) return YES;
    if([permission isEqualToString:@"read_stream"]) return YES;
    if([permission isEqualToString:@"read_insights"]) return YES;
    if([permission isEqualToString:@"xmpp_login"]) return YES;
    if([permission isEqualToString:@"email"]) return YES;
    
    return NO;
}

@end
