package com.example.smart_keyboard_insets

import android.app.Activity
import android.graphics.Rect
import android.os.Build
import android.view.ViewTreeObserver
import android.view.WindowInsets
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.EventChannel

/**
 * SmartKeyboardInsetsPlugin - Android implementation for keyboard metrics detection.
 * 
 * Provides accurate keyboard height and safe area bottom inset detection using
 * ViewTreeObserver for layout changes and WindowInsets for system bar calculations.
 */
class SmartKeyboardInsetsPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var activity: Activity? = null
    private var layoutListener: ViewTreeObserver.OnGlobalLayoutListener? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        // Set up MethodChannel for one-time method calls like getCurrentMetrics
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "smart_keyboard_insets/method")
        methodChannel?.setMethodCallHandler(this)

        // Set up EventChannel for continuous keyboard metrics streaming
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "smart_keyboard_insets/event")
        eventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
                startListening()
            }

            override fun onCancel(arguments: Any?) {
                stopListening()
                eventSink = null
            }
        })
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Clean up listeners to prevent memory leaks
        stopListening()
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        eventChannel?.setStreamHandler(null)
        eventChannel = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getCurrentMetrics" -> {
                val metrics = getCurrentKeyboardMetrics()
                result.success(metrics)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    // ActivityAware lifecycle methods

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        // If there's already an active stream listener, start listening with the new activity
        if (eventSink != null) {
            startListening()
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        // Stop listening before activity is detached for config changes
        stopListening()
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        // Resume listening if there's an active stream listener
        if (eventSink != null) {
            startListening()
        }
    }

    override fun onDetachedFromActivity() {
        // Clean up when activity is fully detached
        stopListening()
        activity = null
    }

    /**
     * Starts listening for keyboard layout changes using ViewTreeObserver.
     * Prevents duplicate listener registration.
     */
    private fun startListening() {
        val currentActivity = activity ?: return
        val rootView = currentActivity.window?.decorView?.rootView ?: return
        
        // Prevent duplicate listener registration (Requirement 9.5)
        if (layoutListener != null) return

        layoutListener = ViewTreeObserver.OnGlobalLayoutListener {
            sendKeyboardMetrics()
        }
        rootView.viewTreeObserver.addOnGlobalLayoutListener(layoutListener)
        
        // Send initial metrics immediately
        sendKeyboardMetrics()
    }

    /**
     * Stops listening for keyboard layout changes and removes the listener.
     */
    private fun stopListening() {
        val currentActivity = activity ?: return
        val rootView = currentActivity.window?.decorView?.rootView ?: return
        
        layoutListener?.let { listener ->
            rootView.viewTreeObserver.removeOnGlobalLayoutListener(listener)
        }
        layoutListener = null
    }

    /**
     * Calculates and sends current keyboard metrics to the Flutter side via EventSink.
     */
    private fun sendKeyboardMetrics() {
        val metrics = getCurrentKeyboardMetrics()
        eventSink?.success(metrics)
    }

    /**
     * Gets the current keyboard metrics including height, safe area, and visibility.
     * Handles null activity gracefully (Requirement 7.10).
     */
    private fun getCurrentKeyboardMetrics(): Map<String, Any> {
        val currentActivity = activity ?: return mapOf(
            "keyboardHeight" to 0.0,
            "safeAreaBottom" to 0.0,
            "isKeyboardVisible" to false
        )

        val rootView = currentActivity.window?.decorView?.rootView ?: return mapOf(
            "keyboardHeight" to 0.0,
            "safeAreaBottom" to 0.0,
            "isKeyboardVisible" to false
        )

        val rect = Rect()
        rootView.getWindowVisibleDisplayFrame(rect)

        val screenHeight = rootView.height
        val keypadHeight = screenHeight - rect.bottom
        val density = currentActivity.resources.displayMetrics.density

        // Keyboard is visible if it takes more than 15% of screen height (Requirement 7.3)
        val isKeyboardVisible = keypadHeight > screenHeight * 0.15
        
        // Convert to logical pixels (Requirement 7.5)
        val keyboardHeightDp = if (isKeyboardVisible) keypadHeight / density else 0f

        val safeAreaBottom = getSafeAreaBottom(currentActivity, density)

        return mapOf(
            "keyboardHeight" to keyboardHeightDp.toDouble(),
            "safeAreaBottom" to safeAreaBottom,
            "isKeyboardVisible" to isKeyboardVisible
        )
    }

    /**
     * Calculates the safe area bottom inset in logical pixels.
     * Uses WindowInsets.Type.systemBars() on Android R+ (Requirement 7.4),
     * with fallback for older versions.
     */
    private fun getSafeAreaBottom(activity: Activity, density: Float): Double {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val insets = activity.window?.decorView?.rootWindowInsets
                ?.getInsets(WindowInsets.Type.systemBars())
            (insets?.bottom?.toFloat() ?: 0f) / density
        } else {
            // Fallback for older Android versions
            val resourceId = activity.resources.getIdentifier(
                "navigation_bar_height", "dimen", "android"
            )
            if (resourceId > 0) {
                activity.resources.getDimensionPixelSize(resourceId) / density
            } else {
                0f
            }
        }.toDouble()
    }
}
