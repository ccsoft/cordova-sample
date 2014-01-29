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

#import "CordovaFoursquare.h"
#import "FSOAuth.h"
#import <Cordova/CDV.h>
#import <UIKit/UIKit.h>

@implementation CordovaFoursquare


static id <CDVCommandDelegate> commandDelegate = nil;
+ (id <CDVCommandDelegate>) commandDelegate {return commandDelegate;}
+ (void)setCommandDelegate:(id <CDVCommandDelegate>)del {commandDelegate = del;}


static NSURL* callbackURI = nil;
+ (NSString*) callbackURI {return [callbackURI absoluteString];}
+ (void)setCallbackURI:(NSString *)url {callbackURI = [NSURL URLWithString:url];}


static NSString* loginCallbackId = nil;
+ (NSString*) loginCallbackId {return loginCallbackId;}
+ (void)setLoginCallbackId:(NSString *)cb {loginCallbackId = cb;}

static NSString* clientSecret = nil;
+ (NSString*) clientSecret {return clientSecret;}
+ (void)setClientSecret:(NSString *)val {clientSecret = val;}

static NSString* clientId = nil;
+ (NSString*) clientId {return clientId;}
+ (void)setClientId:(NSString *)val {clientId = val;}


+(void)load {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleOpenURL:)
                                                 name:@"CDVPluginHandleOpenURLNotification"
                                               object:nil];
}

+ (NSString *)errorMessageForCode:(FSOAuthErrorCode)errorCode {
    NSString *resultText = nil;
    
    switch (errorCode) {
        case FSOAuthErrorNone: {
            break;
        }
        case FSOAuthErrorInvalidClient: {
            resultText = @"Invalid client error";
            break;
        }
        case FSOAuthErrorInvalidGrant: {
            resultText = @"Invalid grant error";
            break;
        }
        case FSOAuthErrorInvalidRequest: {
            resultText =  @"Invalid request error";
            break;
        }
        case FSOAuthErrorUnauthorizedClient: {
            resultText =  @"Invalid unauthorized client error";
            break;
        }
        case FSOAuthErrorUnsupportedGrantType: {
            resultText =  @"Invalid unsupported grant error";
            break;
        }
        case FSOAuthErrorUnknown:
        default: {
            resultText =  @"Unknown error";
            break;
        }
    }
    
    return resultText;
}

+(void)handleOpenURL:(NSNotification*)notification {
    NSURL *url = notification.object;
    if ([[url scheme] isEqualToString:[callbackURI scheme]] == FALSE) {
        return;
    }
    if ([[url host] isEqualToString:[callbackURI host]] == FALSE) {
        return;
    }
    if([CordovaFoursquare loginCallbackId] == nil || [CordovaFoursquare commandDelegate] == nil) { // nowhere to call back
        return;
    }
    CDVPluginResult* pluginResult = nil;
    
    FSOAuthErrorCode errorCode;
    NSString *accessCode = [FSOAuth accessCodeForFSOAuthURL:url error:&errorCode];
    if(errorCode != FSOAuthErrorNone) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[CordovaFoursquare errorMessageForCode:errorCode]];
    }
    else if([clientSecret length] == 0 ) { // no client secret, return code
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:accessCode];
    }
    
    if(pluginResult != nil) {
        [self.commandDelegate sendPluginResult:pluginResult callbackId:[CordovaFoursquare loginCallbackId]];
    }
    else { // got secret, so use it
        [FSOAuth requestAccessTokenForCode:accessCode
                                  clientId:[CordovaFoursquare clientId]
                         callbackURIString:[CordovaFoursquare callbackURI]
                              clientSecret:[CordovaFoursquare clientSecret]
                           completionBlock:^(NSString *authToken, BOOL requestCompleted, FSOAuthErrorCode errorCode) {
                               
                               CDVPluginResult *pluginResultInCallback = nil;
                               if (requestCompleted) {
                                   if (errorCode == FSOAuthErrorNone) {
                                       pluginResultInCallback = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:authToken];                                   }
                                   else {
                                       pluginResultInCallback = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[CordovaFoursquare errorMessageForCode:errorCode]];                                   }
                               }
                               else {
                                   pluginResultInCallback = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"An error occurred when attempting to connect to the Foursquare server."];
                               }
                               
                               [[CordovaFoursquare commandDelegate] sendPluginResult:pluginResultInCallback callbackId:[CordovaFoursquare loginCallbackId]];
                           }];
    }
}

- (void)login:(CDVInvokedUrlCommand*)command
{
    [CordovaFoursquare setLoginCallbackId:nil];
    [CordovaFoursquare setCommandDelegate:nil];
    [CordovaFoursquare setClientId:[command.arguments objectAtIndex:0]];
    [CordovaFoursquare setClientSecret:[command.arguments objectAtIndex:1]];
    [CordovaFoursquare setCallbackURI:[command.arguments objectAtIndex:2]];
    
    FSOAuthStatusCode statusCode = [FSOAuth authorizeUserUsingClientId:clientId
                                                     callbackURIString:[CordovaFoursquare callbackURI]
                                                  allowShowingAppStore:NO];

    if(statusCode == FSOAuthStatusSuccess) {
        [CordovaFoursquare setLoginCallbackId:command.callbackId];
        [CordovaFoursquare setCommandDelegate:self.commandDelegate];
    }
    else if(statusCode == FSOAuthStatusErrorFoursquareNotInstalled) {
        CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"0"];
        [self.commandDelegate sendPluginResult:pr callbackId:command.callbackId];
    }
    else {
        NSString *resultText = nil;
        switch (statusCode) {
            case FSOAuthStatusErrorInvalidCallback: {
                resultText = @"Invalid callback URI";
                break;
            }
            case FSOAuthStatusErrorInvalidClientID: {
                resultText = @"Invalid client id";
                break;
            }
            case FSOAuthStatusErrorFoursquareOAuthNotSupported: {
                resultText = @"Installed FSQ app does not support oauth";
                break;
            }
            default: {
                resultText = @"Unknown status code returned";
                break;
            }
        }
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:resultText];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)install:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"not installing"];
    if(clientId != nil && [CordovaFoursquare callbackURI] != nil) {
        // first call login, if got 0 as response we are sure that 4sq app should be installed
        FSOAuthStatusCode statusCode = [FSOAuth authorizeUserUsingClientId:clientId
                                                         callbackURIString:[CordovaFoursquare callbackURI]
                                                      allowShowingAppStore:YES];
        if(statusCode == FSOAuthStatusErrorFoursquareNotInstalled) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


@end
