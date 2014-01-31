cordova-foursquare
==================

[Cordova](http://cordova.apache.org/) plugin that handles Foursquare integration for mobile (iOS and Android) apps.

Project uses official Foursquare OAuth projects for [iOS](https://github.com/foursquare/foursquare-ios-oauth) and [Android](https://github.com/foursquare/foursquare-android-oauth) to utilize oauth authentication operations for a mobile app that uses Cordova. 

We also provide [TypeScript](http://www.typescriptlang.org/) source file together with the JavaScript for the client side with this plugin.	

We support only Cordova version > 3.0

##Prerequisites

###iOS
Download/Clone the latest [Official Foursquare OAuth library for iOS](https://github.com/foursquare/foursquare-ios-oauth/), and follow the [steps](https://github.com/foursquare/foursquare-ios-oauth#setting-up-fsoauth-with-your-app).

- Do not forget to add StoreKit.framework to your project.
- Be careful defining the same url scheme in your app.plist file and foursquare app settings.

###Android
Download/Clone the latest [Official Foursquare OAuth library for Android](https://github.com/foursquare/foursquare-android-oauth/), and follow the [steps](https://github.com/foursquare/foursquare-android-oauth#setting-up-the-library-with-your-app).

##Installing the plugin
To add this plugin just type:
```cordova plugin add https://github.com/ccsoft/cordova-foursquare.git```

To remove this plugin type:
```cordova plugin remove com.ccsoft.plugin.CordovaFoursquare```




##Usage
	
Give a reference to the js file (probably in your index.html)

	<script type="text/javascript" src="plugins/CordovaFoursquare.js"></script>

Then in js side (probably in your index.js)

	// Get a reference to the plugin first
    var plugin = new CC.CordovaFoursquare();

The plugin has the following methods:

* [login](#login)
* [install](#install)

*** 

###login
Handles the OAuth flow.

>####parameters

>> *clientId*: string: Your Foursquare client id, you have in [developer portal](https://developer.foursquare.com/). 

>> *clientSecret*: string: Your Foursquare slient secret. If you have a server, use it to verify instead of passing a clientSecret. You can pass an empty string. The return callback then returns the access code instead of an access token. You can get your access token using your own server and keep your secret as secret there. You have it in [developer portal](https://developer.foursquare.com/). 

>> *callbackUri*: string: Your Foursquare callbackUri (used for iOS only), you set in [developer portal](https://developer.foursquare.com/). 

>> *successCallback*: function: Called with a foursquare access token (if secret has been given), access code (if secret has not been given) or "0" which means Foursquare app is not installed in client's device.

>> *failureCallback*: function: Called with failure reason string.
         
>####example

	plugin.login('YOUR_4SQ_CLIENT_ID', 'YOUR_4SQ_OPTIONAL_SECRET', 
		'cordovasample://foursquare', // should have a uri structure with scheme and domain
		successCallback, failureCallback);

***

###install
If login call returns '0' on success, it means our client device does not have Foursquare app installed. You can then show a popup, notify/ask the user if they want to install the app and call this function to redirect user to related app stores.

>####parameters
	
>>*successCallback*: function: Called if install is initiated successfully.
         
>>*failureCallback*: function: Called with failure reason string.
        
>####example

	plugin.install(successCallback, failureCallback);

***

##Sample App
We have a sample cordova app to test the plugin that you can find [here](https://github.com/ccsoft/cordova-sample/tree/foursquare). Please note that the link takes you to a dedicated branch named foursquare, please use that branch to test this plugin. We use separate branches for each plugin we implement.

Once you download/clone and run the app, make sure you enter your Foursquare app settings in index.html.


##License
[Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0.html)
