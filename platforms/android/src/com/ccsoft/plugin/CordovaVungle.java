
package com.ccsoft.plugin;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import com.vungle.publisher.AdConfig;
import com.vungle.publisher.EventListener;
import com.vungle.publisher.Orientation;
import com.vungle.publisher.VunglePub;

public class CordovaVungle extends CordovaPlugin {
		
	private final String TAG = "com.ccsoft.cordova-vungle";
	
	// get the VunglePub instance
	final VunglePub vunglePub = VunglePub.getInstance();
	
	@Override
	public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException
	{
		try 
		{
			Log.i(TAG, action);
			if (action.equals("init")) {
				final JSONArray argsIn = args;
				Runnable runnable = new Runnable() {
	    			public void run() {
	    				try {
							vunglePub.init(cordova.getActivity(), argsIn.getString(0));
						} catch (JSONException e) {
							callbackContext.error("vungle id missing");
						}				
						try {
							JSONObject jsonConfig = argsIn.getJSONObject(1);
							final AdConfig globalAdConfig = vunglePub.getGlobalAdConfig();
    						processConfig(globalAdConfig, jsonConfig);
						} catch (JSONException e) { // config is optional anyhow
						}
	    				
	    				callbackContext.success();	    				
	    			};
	    		};
	    		cordova.getActivity().runOnUiThread(runnable);
				
				return true;
	    	}
			else if ( action.equals("playAd") ) 
			{
				final AdConfig overrideConfig = new AdConfig();
				if(args.length() > 0) {	
					try {
						JSONObject jsonConfig = args.getJSONObject(0);
						if(jsonConfig != null) {						
							processConfig(overrideConfig, jsonConfig);
						}
					} catch (JSONException e) { // config is optional anyhow
					}					
				}				
				
				vunglePub.setEventListeners(new EventListener() {
					@Override
				    public void onVideoView(boolean isCompletedView, int watchedMillis, int videoDurationMillis) {
				        // Called each time an ad completes. isCompletedView is true if at least  
				        // 80% of the video was watched, which constitutes a completed view.  
				        // watchedMillis is for the longest video view (if the user replayed the 
				        // video).
						if (isCompletedView) {
							Log.i(TAG, "completed view");
							callbackContext.success(1);
						} else {
							Log.i(TAG, "not completed view");
							callbackContext.success(0);				        	
				        }
				    }

				    @Override
				    public void onAdStart() {
				        // Called before playing an ad
				    	Log.i(TAG, "ad started");
				    }

				    @Override
				    public void onAdEnd(boolean wasCallToActionClicked) {
				        // Called when the user leaves the ad and control is returned to your application
				    	Log.i(TAG, "ad ended");
				    }

					@Override
					public void onAdUnavailable(String arg0) {
						Log.i(TAG, "ad unavailable");
						callbackContext.error("Ad unavailable");						
					}

					@Override
					public void onAdPlayableChanged(boolean changed) {
						Log.i(TAG, "ad available changed: " + changed);
					}				   
				});				
				
				Runnable runnable = new Runnable() {
	    			public void run() {
	    				vunglePub.playAd(overrideConfig);	    				
	    			};
	    		};
	    		cordova.getActivity().runOnUiThread(runnable);
													
				return true;				
			}
			else if ( action.equals( "isVideoAvailable" ) ) 
			{				
				final boolean available = vunglePub.isAdPlayable();
				callbackContext.success(available ? 1 : 0 ); 
				return true;
			}
		} 
		catch (Exception ex) 
		{
			callbackContext.error(ex.getMessage());
			return true;
		}
				
		return false;
	}
	
	private void processConfig(AdConfig config, JSONObject json) {
		try {
			config.setIncentivized(json.getBoolean("incentivized"));
		} catch (JSONException e) { // param not supplied			
		}
		
		try {
			config.setIncentivizedUserId(json.getString("incentivizedUserId"));
		} catch (JSONException e) { // param not supplied			
		}
		
		try {
			int orientation = json.getInt("orientation");
			if(orientation == 0) {
				config.setOrientation(Orientation.autoRotate);
			} else {
				config.setOrientation(Orientation.matchVideo);
			}
		} catch (JSONException e) { // param not supplied			
		}
		
		try {
			config.setSoundEnabled(json.getBoolean("soundEnabled"));
		} catch (JSONException e) { // param not supplied			
		}
		
		try {
			config.setBackButtonImmediatelyEnabled(json.getBoolean("backButtonImmediatelyEnabled"));
		} catch (JSONException e) { // param not supplied			
		}
		
		try {
			config.setImmersiveMode(json.getBoolean("immersiveMode"));
		} catch (JSONException e) { // param not supplied			
		}
		
		try {
			config.setIncentivizedCancelDialogTitle(json.getString("incentivizedCancelDialogTitle"));
		} catch (JSONException e) { // param not supplied			
		}
		
		try {
			config.setIncentivizedCancelDialogBodyText(json.getString("incentivizedCancelDialogBodyText"));
		} catch (JSONException e) { // param not supplied			
		}
		
		try {
			config.setIncentivizedCancelDialogCloseButtonText(json.getString("incentivizedCancelDialogCloseButtonText"));
		} catch (JSONException e) { // param not supplied			
		}
		
		try {
			config.setIncentivizedCancelDialogKeepWatchingButtonText(json.getString("incentivizedCancelDialogKeepWatchingButtonText"));
		} catch (JSONException e) { // param not supplied			
		}
		
		try {
			config.setPlacement(json.getString("placement"));
		} catch (JSONException e) { // param not supplied			
		}
		
		try {
			config.setExtra1(json.getString("extra1"));
		} catch (JSONException e) { // param not supplied			
		}
		
		try {
			config.setExtra2(json.getString("extra2"));
		} catch (JSONException e) { // param not supplied			
		}
		
		try {
			config.setExtra3(json.getString("extra3"));
		} catch (JSONException e) { // param not supplied			
		}
		
		try {
			config.setExtra4(json.getString("extra4"));
		} catch (JSONException e) { // param not supplied			
		}
		
		try {
			config.setExtra5(json.getString("extra5"));
		} catch (JSONException e) { // param not supplied			
		}
		
		try {
			config.setExtra6(json.getString("extra6"));
		} catch (JSONException e) { // param not supplied			
		}
		
		try {
			config.setExtra7(json.getString("extra7"));
		} catch (JSONException e) { // param not supplied			
		}
		
		try {
			config.setExtra8(json.getString("extra8"));
		} catch (JSONException e) { // param not supplied			
		}
		
	}
} 