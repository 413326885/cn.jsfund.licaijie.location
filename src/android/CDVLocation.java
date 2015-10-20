package cn.jsfund.licaijie.location;

import com.tencent.map.geolocation.TencentLocation;
import com.tencent.map.geolocation.TencentLocationListener;
import com.tencent.map.geolocation.TencentLocationManager;
import com.tencent.map.geolocation.TencentLocationRequest;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.LOG;
import org.json.JSONException;
import org.json.JSONObject;

public class CDVLocation extends CordovaPlugin implements TencentLocationListener
{
    private TencentLocationManager mLocationManager;
    public static CallbackContext currentCallbackContext;

    @Override
    public boolean execute(String action, CordovaArgs args, CallbackContext callbackContext) throws JSONException {

        if (action.equals("init")) {
            currentCallbackContext = callbackContext;
            final String key = (String) args.get(0);
            LOG.i("LOCATION", "location init " + key);
            mLocationManager = TencentLocationManager.getInstance(this.cordova.getActivity());
            mLocationManager.setKey(key);
            mLocationManager.requestLocationUpdates(
                    TencentLocationRequest.create()
                            .setRequestLevel(TencentLocationRequest.REQUEST_LEVEL_ADMIN_AREA)
                            .setInterval(0).setAllowDirection(false),
                    this
            );
            return true;
        }

        return super.execute(action, args, callbackContext);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        mLocationManager.removeUpdates(this);
    }

    @Override
    public void onLocationChanged(TencentLocation tencentLocation, int i, String s) {
        if (i == TencentLocation.ERROR_OK) {
            JSONObject result = new JSONObject();
            double latitude = tencentLocation.getLatitude();
            double longitude = tencentLocation.getLongitude();
            String cityCode = tencentLocation.getCityCode();
            String cityName = tencentLocation.getCity();
            try {
                result.put("longitude", longitude);
                result.put("latitude", latitude);
                result.put("cityCode", cityCode);
                result.put("cityName", cityName);

            } catch (JSONException e) {
                e.printStackTrace();
            }

            currentCallbackContext.success(result);
        } else {
            currentCallbackContext.error(0);
        }
        mLocationManager.removeUpdates(this);
    }

    @Override
    public void onStatusUpdate(String s, int i, String s1) {
        // pass
    }
}


