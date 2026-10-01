package com.catchdates.app

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.ContactsContract
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

/** Queries only the temporary URI explicitly granted by the system picker. */
internal class NativePhoneContactsPicker(private val activity: Activity) {
    private var pending: MethodChannel.Result? = null
    private val reader = Executors.newSingleThreadExecutor()
    private var disposed = false
    private var sessionPicker = false

    fun pick(result: MethodChannel.Result) {
        if (pending != null || disposed) { result.success(mapOf("status" to "failed")); return }
        sessionPicker = Build.VERSION.SDK_INT >= 37
        // API 37 constants are documented literals so the pinned API 36 SDK can
        // compile this runtime-gated enhancement without a global SDK upgrade.
        val intent = if (sessionPicker) Intent(ACTION_PICK_CONTACTS).apply {
            putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)
            putExtra(EXTRA_SELECTION_LIMIT, 100)
            putStringArrayListExtra(EXTRA_REQUESTED_FIELDS, arrayListOf(
                ContactsContract.CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE,
                ContactsContract.CommonDataKinds.Phone.CONTENT_ITEM_TYPE,
            ))
        } else Intent(Intent.ACTION_PICK, ContactsContract.CommonDataKinds.Phone.CONTENT_URI)
        pending = result
        try { activity.startActivityForResult(intent, REQUEST_CODE) }
        catch (_: ActivityNotFoundException) { finish(mapOf("status" to "unavailable")) }
        catch (_: SecurityException) { finish(mapOf("status" to "denied")) }
        catch (_: IllegalArgumentException) { finish(mapOf("status" to "failed")) }
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_CODE) return false
        if (pending == null) return true
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK) { finish(mapOf("status" to "cancelled")); return true }
        if (uri == null || uri.scheme != "content" ||
            (sessionPicker && uri.authority != SESSION_AUTHORITY)) {
            finish(mapOf("status" to "failed")); return true
        }
        val useSession = sessionPicker
        reader.execute {
            val response = try {
                mapOf("status" to "selected", "contacts" to readSelection(uri, useSession))
            } catch (_: SecurityException) { mapOf("status" to "denied") }
              catch (_: Exception) { mapOf("status" to "failed") }
            activity.runOnUiThread { if (!disposed) finish(response) }
        }
        return true
    }

    private fun readSelection(uri: Uri, session: Boolean): List<Map<String, Any>> {
        val projection = arrayOf(ContactsContract.Contacts.LOOKUP_KEY,
            ContactsContract.Contacts.DISPLAY_NAME_PRIMARY,
            ContactsContract.Data.DATA1, ContactsContract.Data.DATA2, ContactsContract.Data.DATA3) +
            if (session) arrayOf(ContactsContract.Data.MIMETYPE) else emptyArray()
        val contacts = linkedMapOf<String, MutableMap<String, Any>>()
        val cursor = activity.contentResolver.query(uri, projection, null, null, null)
            ?: throw IllegalStateException("Picker cursor unavailable")
        cursor.use {
            var row = 0
            while (it.moveToNext()) {
                val key = it.getString(it.getColumnIndexOrThrow(ContactsContract.Contacts.LOOKUP_KEY))
                    ?.takeIf { value -> value.isNotBlank() } ?: "selected-row-${row++}"
                val name = it.getString(it.getColumnIndexOrThrow(ContactsContract.Contacts.DISPLAY_NAME_PRIMARY)) ?: ""
                val contact = contacts.getOrPut(key) { mutableMapOf("id" to key, "name" to name, "phones" to mutableListOf<Map<String, String>>()) }
                if (contacts.size > 100) throw IllegalStateException("Selection exceeds review limit")
                if (session && it.getString(it.getColumnIndexOrThrow(ContactsContract.Data.MIMETYPE)) != ContactsContract.CommonDataKinds.Phone.CONTENT_ITEM_TYPE) continue
                val value = it.getString(it.getColumnIndexOrThrow(ContactsContract.Data.DATA1)) ?: ""
                val type = it.getInt(it.getColumnIndexOrThrow(ContactsContract.Data.DATA2))
                val customLabel = it.getString(it.getColumnIndexOrThrow(ContactsContract.Data.DATA3))
                val label = ContactsContract.CommonDataKinds.Phone.getTypeLabel(activity.resources, type, customLabel).toString()
                @Suppress("UNCHECKED_CAST")
                val numbers = contact["phones"] as MutableList<Map<String, String>>
                if (value.isNotBlank() && numbers.none { number -> number["value"] == value }) numbers.add(mapOf("value" to value, "label" to label))
            }
        }
        return contacts.values.toList()
    }

    private fun finish(response: Map<String, Any>) {
        val callback = pending
        pending = null
        callback?.success(response)
    }

    fun dispose() {
        disposed = true
        finish(mapOf("status" to "cancelled"))
        reader.shutdownNow()
    }

    companion object {
        private const val REQUEST_CODE = 43017
        // https://developer.android.com/reference/android/provider/ContactsPickerSessionContract
        private const val ACTION_PICK_CONTACTS = "android.provider.action.PICK_CONTACTS"
        private const val EXTRA_REQUESTED_FIELDS = "android.provider.extra.PICK_CONTACTS_REQUESTED_DATA_FIELDS"
        private const val EXTRA_SELECTION_LIMIT = "android.provider.extra.PICK_CONTACTS_SELECTION_LIMIT"
        private const val SESSION_AUTHORITY = "com.android.contacts.picker.sessions"
    }
}
