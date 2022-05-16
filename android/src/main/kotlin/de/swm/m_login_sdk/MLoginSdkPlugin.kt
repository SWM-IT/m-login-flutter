package de.swm.m_login_sdk

import android.app.Activity
import android.app.Application
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.browser.customtabs.CustomTabsIntent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry

/** MLoginSdkPlugin */
class MLoginSdkPlugin : FlutterPlugin, MethodCallHandler,
    // Receive Activity lifecycle callbacks. Required to launch Custom Tabs in the current task
    ActivityAware,
    // Receive a callback when the Flutter activity is launched with a new intent. This is the case
    // when returning from the Custom Tabs browser session.
    PluginRegistry.NewIntentListener,
    // React on lifecycle events. Especially: Returning from canceled session
    Application.ActivityLifecycleCallbacks {

    private lateinit var channel: MethodChannel

    private val runningAuthenticationCalls = mutableMapOf<String, MethodChannel.Result>()

    private var activityBinding: ActivityPluginBinding? = null
    private var launchedBrowser = false

    // region $MethodCallHandler

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        if (call.method == "authenticate") {
            authenticate(call, result)
        } else {
            result.notImplemented()
        }
    }

    // endregion
    // region $Actual Logic

    private fun authenticate(call: MethodCall, result: MethodChannel.Result) {
        val activity = activityBinding?.activity ?: run { return }

        val url = Uri.parse(call.argument<String>("url")!!)
        val callbackUrlScheme = call.argument<String>("callbackUrlScheme")!!

        // TODO: ephemeral is not yet supported by Android's custom tabs. Re-check some time later.
        // val ephemeral = call.argument<Boolean>("ephemeral") ?: false

        runningAuthenticationCalls[callbackUrlScheme] = result

        val intent = CustomTabsIntent.Builder().build()
        val keepAliveIntent = Intent(activity, KeepAliveService::class.java)

        intent.intent.putExtra("android.support.customtabs.extra.KEEP_ALIVE", keepAliveIntent)

        try {
            intent.launchUrl(activity, url)
        } catch (e: ActivityNotFoundException) {
            runningAuthenticationCalls.remove(callbackUrlScheme)
            // text is max 2 lines since Android 12
            Toast.makeText(
                activity,
                R.string.toast_no_browser_installed,
                Toast.LENGTH_SHORT
            ).show()
            result.error("NO_BROWSER_INSTALLED", "no browser installed", null)
            return
        }

        launchedBrowser = true
    }

    private fun onRedirectionReceived(intent: Intent) {
        val url = intent.data
        val scheme = url?.scheme
        runningAuthenticationCalls.remove(scheme)?.success(url?.toString())
    }

    private fun onReturnedFromBrowser() {
        // Mark all still not finished calls as CANCELED
        // Successful attempts were removed before reaching this method in [onRedirectionReceived]
        runningAuthenticationCalls.values.forEach {
            it.error("CANCELED", "User canceled", null)
        }
        runningAuthenticationCalls.clear()
    }

    // endregion
    // region $NewIntentListener

    override fun onNewIntent(intent: Intent): Boolean {
        // this is the best case! Getting a new intent means that the activity is
        // re-started - probably thanks to a redirect.
        onRedirectionReceived(intent)
        return true
    }

    // endregion
    // region $FlutterPlugin

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "m_login_sdk")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    // endregion
    // region $ActivityAware

    override fun onAttachedToActivity(binding: ActivityPluginBinding) = attached(binding)

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) =
        attached(binding)

    override fun onDetachedFromActivity() = detached()

    override fun onDetachedFromActivityForConfigChanges() = detached()

    private fun attached(binding: ActivityPluginBinding) {
        activityBinding = binding
        binding.addOnNewIntentListener(this)
        binding.activity.application.registerActivityLifecycleCallbacks(this)
    }

    private fun detached() {
        activityBinding?.removeOnNewIntentListener(this)
        activityBinding = null
    }

    // endregion
    // region $LifecycleListener

    override fun onActivityResumed(activity: Activity) {
        if (activity !is FlutterActivity) return

        if (launchedBrowser) onReturnedFromBrowser()
        launchedBrowser = false
    }

    override fun onActivityPaused(activity: Activity) = Unit
    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) = Unit
    override fun onActivityStarted(activity: Activity) = Unit
    override fun onActivityStopped(activity: Activity) = Unit
    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) = Unit
    override fun onActivityDestroyed(activity: Activity) = Unit

    // endregion
}
