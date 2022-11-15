package de.nucleus.foss_warn

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import androidx.annotation.NonNull
import android.net.Uri
import android.content.Intent
import android.os.Build
import android.content.Context
import android.os.PowerManager
import android.provider.Settings

class MainActivity: FlutterActivity() {
    private val CHANNEL = "flutter.native/helper"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            when (call.method) {
                "showIgnoreBatteryOptimizationDialog" -> showIgnoreBatteryOptimizationDialog()
                else -> result.notImplemented()
            }
        }
    }

    private fun showIgnoreBatteryOptimizationDialog() {
        val pm: PowerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        val packageName: String = getApplicationContext().getPackageName()

        if (!pm.isIgnoringBatteryOptimizations(packageName)) {
            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
            intent.setData(Uri.parse("package:$packageName"))
            startActivity(intent)
        }
    }
}