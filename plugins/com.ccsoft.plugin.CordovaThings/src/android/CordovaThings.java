package com.ccsoft.plugin;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

import android.content.pm.PackageInfo;
import android.content.pm.PackageManager.NameNotFoundException;
import android.util.Log;

public class CordovaThings extends CordovaPlugin {
	
	private final String TAG = "CordovaThings";
	
    @Override
    public boolean execute(String action, JSONArray args,
			final CallbackContext callbackContext) throws JSONException {
    	Log.i(TAG, "action:" + action);

    	if (action.equals("getAppVersion")) {
    		PackageInfo pInfo;
			try {
				pInfo = cordova.getActivity().getPackageManager().getPackageInfo(cordova.getActivity().getPackageName(), 0);
				callbackContext.success(pInfo.versionName);
			} catch (NameNotFoundException e) {
				e.printStackTrace();
				callbackContext.error("exception");
			}
			
			return true;
    	}      	
    	
        return false;
    }
}