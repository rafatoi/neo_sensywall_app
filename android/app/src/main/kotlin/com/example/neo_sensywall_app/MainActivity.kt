package com.example.neo_sensywall_app

import android.bluetooth.BluetoothAdapter
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            PLATFORM_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "androidSdkInt" -> result.success(Build.VERSION.SDK_INT)
                "requestEnableBluetooth" -> {
                    try {
                        startActivity(Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE))
                        result.success(null)
                    } catch (error: SecurityException) {
                        result.error(
                            "bluetooth_permission",
                            error.message,
                            null
                        )
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private companion object {
        const val PLATFORM_CHANNEL = "sensy_wall/platform"
    }
}
