package com.logislink.driver;


import android.content.Intent;
import android.net.Uri;

import com.logislink.driver.logislink_driver_flutter.NativeViewFactory;
import com.logislink.driver.logislink_driver_flutter.util.Const;
import com.skt.Tmap.TMapTapi;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "testing.flutter.android";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {

        // Flutter 메인화면에 보여지는 Android Native View 설정
        flutterEngine.getPlatformViewsController().getRegistry()
                .registerViewFactory("androidView", new NativeViewFactory(this));

        GeneratedPluginRegistrant.registerWith(flutterEngine);

        // FloatingActionButton 터치 시 호출되는 함수
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((MethodCall call, MethodChannel.Result result) -> {
                    String _name = call.argument("name");
                    double _lat = call.argument("lat");
                    double _lon = call.argument("lon");
                    if (call.method.equals("showActivity")) {
                        TMapTapi tMapTapi = new TMapTapi(this);
                        tMapTapi.setSKTMapAuthentication(Const.TMAP_NATIVE_APP_KEY);
                        if (tMapTapi.isTmapApplicationInstalled()) {
                            tMapTapi.invokeRoute(_name, (float) _lon, (float) _lat);
                        } else {
                            Intent intent = new Intent(Intent.ACTION_VIEW);
                            intent.setData(Uri.parse("http://play.google.com/store/apps/details?id=com.skt.tmap.ku"));
                            startActivity(intent);
                        }
                    } else {
                        result.error("unavailable", "cannot start activity", null);
                    }
                });
    }
}