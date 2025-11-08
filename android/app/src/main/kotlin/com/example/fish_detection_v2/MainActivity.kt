package com.example.fish_detection_v2
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.media.MediaScannerConnection
import android.os.Bundle

class MainActivity: FlutterActivity() {
    private val CHANNEL = "media_scanner_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "scanFile") {
                    val path = call.argument<String>("path")
                    if (path != null) {
                        MediaScannerConnection.scanFile(context, arrayOf(path), null, null)
                        result.success(true)
                    } else {
                        result.error("INVALID_PATH", "Path tidak valid", null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}