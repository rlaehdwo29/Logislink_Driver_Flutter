package com.logislink.driver;

import android.content.Context;
import android.graphics.Color;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;

import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.platform.PlatformView;

public class NativeView implements PlatformView {

    private FrameLayout layout;

    public NativeView(FlutterActivity activity, Context context, int id, Map<String, Object> creationParams) {
        layout = new FrameLayout(context);
        layout.setBackgroundColor(Color.argb(255, 230, 230, 230));

        TextView textView = new TextView(context);
        textView.setLayoutParams(new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
        ));
        textView.setText("이 화면은 안드로이드 화면입니다.\nfloatingActionButton 클릭 시 티맵화면이 띄어집니다.");
        textView.setGravity(Gravity.CENTER);
        layout.addView(textView);
    }

    @Override
    public View getView() {
        return layout;
    }

    @Override
    public void dispose() {
    }
}