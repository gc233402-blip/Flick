package com.mossapps.flick.widgets

import android.content.Context
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/** Today's listening snapshot saved by WidgetSyncService; stale days render empty. */
internal data class WidgetReplayState(
    val fresh: Boolean,
    val timeMs: Long,
    val plays: Int,
    val timeDelta: Int,
    val playsDelta: Int,
    val covers: List<String>,
) {
    val hasData: Boolean get() = fresh && (timeMs > 0 || plays > 0)

    companion object {
        const val UNKNOWN_DELTA = -1000

        fun snapshot(
            day: String?, today: String, timeMs: Long = 0, plays: Int = 0,
            timeDelta: Int = UNKNOWN_DELTA, playsDelta: Int = UNKNOWN_DELTA,
            covers: List<String> = emptyList(),
        ): WidgetReplayState {
            if (day != today) {
                return WidgetReplayState(false, 0, 0, UNKNOWN_DELTA, UNKNOWN_DELTA, emptyList())
            }
            val hasData = timeMs > 0 || plays > 0
            return WidgetReplayState(
                true, timeMs.coerceAtLeast(0), plays.coerceAtLeast(0),
                if (hasData) timeDelta else UNKNOWN_DELTA,
                if (hasData) playsDelta else UNKNOWN_DELTA,
                if (hasData) covers.filter { it.isNotBlank() }.take(3) else emptyList(),
            )
        }

        fun read(context: Context): WidgetReplayState {
            val prefs = WidgetPrefs.get(context)
            val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
            val day = prefs.getString(WidgetPrefs.KEY_REPLAY_DAY, null)
            if (day != today) return snapshot(day, today)
            fun long(key: String): Long = try {
                prefs.getLong(key, 0L)
            } catch (_: ClassCastException) {
                prefs.getInt(key, 0).toLong()
            }
            fun int(key: String): Int = try {
                prefs.getInt(key, 0)
            } catch (_: ClassCastException) {
                prefs.getLong(key, 0L).toInt()
            }
            val covers = listOf(
                WidgetPrefs.KEY_REPLAY_COVER_1,
                WidgetPrefs.KEY_REPLAY_COVER_2,
                WidgetPrefs.KEY_REPLAY_COVER_3,
            ).mapNotNull { key -> prefs.getString(key, null)?.takeIf { it.isNotBlank() } }
            val state = snapshot(
                day = day, today = today,
                timeMs = long(WidgetPrefs.KEY_REPLAY_TIME_MS).coerceAtLeast(0),
                plays = int(WidgetPrefs.KEY_REPLAY_PLAYS).coerceAtLeast(0),
                timeDelta = long(WidgetPrefs.KEY_REPLAY_TIME_DELTA).toInt(),
                playsDelta = long(WidgetPrefs.KEY_REPLAY_PLAYS_DELTA).toInt(),
                covers = covers,
            )
            // Dart invalidates the day while publishing the other fields.
            return if (prefs.getString(WidgetPrefs.KEY_REPLAY_DAY, null) == day) state else snapshot(null, today)
        }
    }
}
