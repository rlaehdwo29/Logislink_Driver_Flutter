package com.logislink.driver;

import android.content.Context;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

import java.util.Map;

public class NativeViewFactory extends PlatformViewFactory {

    private FlutterActivity activity;

    public NativeViewFactory(FlutterActivity activity) {
        super(StandardMessageCodec.INSTANCE);
        this.activity = activity;
    }

    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        Map<String, Object> creationParams = (Map<String, Object>) args;
        return new NativeView(activity, context, viewId, creationParams);
    }
}