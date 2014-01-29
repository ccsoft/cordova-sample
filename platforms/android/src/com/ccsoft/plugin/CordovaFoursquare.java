package com.ccsoft.plugin;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

import com.foursquare.android.nativeoauth.FoursquareCancelException;
import com.foursquare.android.nativeoauth.FoursquareDenyException;
import com.foursquare.android.nativeoauth.FoursquareInvalidRequestException;
import com.foursquare.android.nativeoauth.FoursquareOAuth;
import com.foursquare.android.nativeoauth.FoursquareOAuthException;
import com.foursquare.android.nativeoauth.FoursquareUnsupportedVersionException;
import com.foursquare.android.nativeoauth.model.AccessTokenResponse;
import com.foursquare.android.nativeoauth.model.AuthCodeResponse;

//import org.json.JSONObject;

import android.content.Intent;
import android.util.Log;

public class CordovaFoursquare extends CordovaPlugin {
	
	private final String TAG = "CordovaFoursquare";
	private static final int REQUEST_CODE_FSQ_CONNECT = 200;
    private static final int REQUEST_CODE_FSQ_TOKEN_EXCHANGE = 201;
    
    private CallbackContext mCallbackContext = null;
    private String mClientId;
    private String mClientSecret;
    private Intent mPlayStoreIntent = null;
	
    @Override
    public boolean execute(String action, JSONArray args,
			final CallbackContext callbackContext) throws JSONException {
    	Log.d(TAG, "action:" + action);
    	cordova.setActivityResultCallback(this);

    	if (action.equals("login")) {
    		mClientId = args.getString(0);
    		mClientSecret = args.getString(1);
    		Intent intent = FoursquareOAuth.getConnectIntent(cordova.getActivity(), mClientId);
    		
    		// If the device does not have the Foursquare app installed, we'd
            // get an intent back that would open the Play Store for download.
            // Otherwise we start the auth flow.
            if (FoursquareOAuth.isPlayStoreIntent(intent)) {
                Log.i(TAG, "app not installed");
                mPlayStoreIntent = intent;
                callbackContext.success("0");
            } else {
            	mCallbackContext = callbackContext;
            	cordova.getActivity().startActivityForResult(intent, REQUEST_CODE_FSQ_CONNECT);
            }
            
			return true;
    	}  else if (action.equals("install")) {
    		if(mPlayStoreIntent != null) {
    			cordova.getActivity().startActivity(mPlayStoreIntent);
    			callbackContext.success();
    		} else {
    			callbackContext.error("no intent available");
    		}
    		return true;
    	}
    	
        return false;
    }
    
    
    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
    	Log.i(TAG, "onActivityResult");
    	switch (requestCode) {
	        case REQUEST_CODE_FSQ_CONNECT:
	        	onCompleteConnect(resultCode, data);
	            break;
	            
	        case REQUEST_CODE_FSQ_TOKEN_EXCHANGE:
	            onCompleteTokenExchange(resultCode, data);
	            break;
	
	        default:
	            super.onActivityResult(requestCode, resultCode, data);
	    }
    }
    
    private void onCompleteConnect(int resultCode, Intent data) {
        AuthCodeResponse codeResponse = FoursquareOAuth.getAuthCodeFromResult(resultCode, data);
        Exception exception = codeResponse.getException();
        
        if (exception == null) {
            // Success.
            String code = codeResponse.getCode();
            performTokenExchange(code);
        } else {
            if (exception instanceof FoursquareCancelException) {
                // Cancel.
            	mCallbackContext.error("Canceled");
            } else if (exception instanceof FoursquareDenyException) {
                // Deny.
            	mCallbackContext.error("Denied");                
            } else if (exception instanceof FoursquareOAuthException) {
                // OAuth error.
                String errorMessage = exception.getMessage();
                String errorCode = ((FoursquareOAuthException) exception).getErrorCode();
                mCallbackContext.error(errorMessage + " [" + errorCode + "]");                
            } else if (exception instanceof FoursquareUnsupportedVersionException) {
                // Unsupported Fourquare app version on the device.
            	mCallbackContext.error(exception.getMessage());                
            } else if (exception instanceof FoursquareInvalidRequestException) {
                // Invalid request.
            	mCallbackContext.error(exception.getMessage());     
            } else {
                // Error.
            	mCallbackContext.error(exception.getMessage());
            }
        }
    }
    
    private void onCompleteTokenExchange(int resultCode, Intent data) {
        AccessTokenResponse tokenResponse = FoursquareOAuth.getTokenFromResult(resultCode, data);
        Exception exception = tokenResponse.getException();
        
        if (exception == null) {
            String accessToken = tokenResponse.getAccessToken();
            // Success.
            Log.i(TAG, "Access token: " + accessToken);
            mCallbackContext.success(accessToken);            
        } else {
            if (exception instanceof FoursquareOAuthException) {
                // OAuth error.
                String errorMessage = ((FoursquareOAuthException) exception).getMessage();
                String errorCode = ((FoursquareOAuthException) exception).getErrorCode();
                mCallbackContext.error(errorMessage + " [" + errorCode + "]");
                
            } else {
                // Other exception type.
            	mCallbackContext.error(exception.getMessage());
            }
        }
    }
    
    /**
     * Exchange a code for an OAuth Token. Note that we do not recommend you
     * do this in your app, rather do the exchange on your server. Added here
     * for demo purposes.
     * 
     * @param code 
     *          The auth code returned from the native auth flow.
     */
    private void performTokenExchange(String code) {
    	if(mClientSecret.isEmpty()) {
    		// perform server side exchange on js side with code
    		mCallbackContext.success(code);
    	} else {
    		Intent intent = FoursquareOAuth.getTokenExchangeIntent(cordova.getActivity(), mClientId, mClientSecret, code);
    		cordova.getActivity().startActivityForResult(intent, REQUEST_CODE_FSQ_TOKEN_EXCHANGE);
    	}
    }
}