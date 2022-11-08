package de.nucleus.foss_warn

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

import android.net.Uri
import android.content.Intent
import android.os.Build
import android.content.Context
import android.os.PowerManager
import android.provider.Settings

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "flutter.native/helper").setMethodCallHandler {
                call, result ->
            when {
                call.method.equals("showIgnoreBatteryOptimizationDialog") -> {
                    val pm: PowerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
                    val packageName: String = getApplicationContext().getPackageName()

                    if (!pm.isIgnoringBatteryOptimizations(packageName)) {
                        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                        intent.setData(Uri.parse("package:$packageName"))
                        startActivity(intent)
                    }
                }
            }
        }
    }

    private fun showIgnoreBatteryOptimizationDialog(result: MethodChannel.Result) {

    }
}