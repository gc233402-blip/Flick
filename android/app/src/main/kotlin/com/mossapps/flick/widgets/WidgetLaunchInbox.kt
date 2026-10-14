package com.mossapps.flick.widgets

/** Keep the latest widget tap until Dart installs its channel handler. */
internal class WidgetLaunchInbox {
    private var ready = false
    private var pendingUri: String? = null

    fun offer(uri: String): String? {
        if (ready) return uri
        pendingUri = uri
        return null
    }

    fun attach(): String? {
        ready = true
        val uri = pendingUri
        pendingUri = null
        return uri
    }

    fun detach() {
        ready = false
    }
}
