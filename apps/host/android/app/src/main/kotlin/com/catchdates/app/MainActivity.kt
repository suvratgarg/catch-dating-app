package com.catchdates.app

import android.content.Intent
import android.provider.CalendarContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "catch/calendar")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "addToCalendar" -> result.success(addToCalendar(call.arguments))
                    else -> result.notImplemented()
                }
            }
    }

    private fun addToCalendar(arguments: Any?): Boolean {
        val event = arguments as? Map<*, *> ?: return false
        val title = event["title"] as? String ?: return false
        val startTimeMillis = (event["startTimeMillis"] as? Number)?.toLong() ?: return false
        val endTimeMillis = (event["endTimeMillis"] as? Number)?.toLong() ?: return false

        val intent = Intent(Intent.ACTION_INSERT).apply {
            setDataAndType(
                CalendarContract.Events.CONTENT_URI,
                "vnd.android.cursor.item/event",
            )
            putExtra(CalendarContract.Events.TITLE, title)
            putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, startTimeMillis)
            putExtra(CalendarContract.EXTRA_EVENT_END_TIME, endTimeMillis)
            putExtra(CalendarContract.Events.EVENT_TIMEZONE, TimeZone.getDefault().id)
            putExtra(CalendarContract.Events.EVENT_END_TIMEZONE, TimeZone.getDefault().id)
            (event["description"] as? String)?.let {
                putExtra(CalendarContract.Events.DESCRIPTION, it)
            }
            (event["location"] as? String)?.let {
                putExtra(CalendarContract.Events.EVENT_LOCATION, it)
            }
        }

        if (intent.resolveActivity(packageManager) == null) return false
        startActivity(intent)
        return true
    }
}
