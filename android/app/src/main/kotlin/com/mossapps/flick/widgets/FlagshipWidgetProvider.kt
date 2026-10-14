package com.mossapps.flick.widgets

import android.appwidget.AppWidgetManager
import android.content.Context
import android.graphics.Color
import android.text.Layout
import android.view.View
import android.widget.RemoteViews
import com.mossapps.flick.R

class FlagshipWidgetProvider : ResponsiveWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        val state = WidgetPlaybackState.read(context)
        val showArtist = WidgetPrefs.getFlagshipShowArtist(context)
        val accent = WidgetPrefs.getFlagshipAccentColor(context)
        val textScale = WidgetPrefs.getFlagshipTextScale(context)
        val upcoming = WidgetUpcomingTrack.read(context)

        for (id in appWidgetIds) {
            val views = responsiveViews(appWidgetManager.getAppWidgetOptions(id), WidgetLayoutPolicy.flagshipDefault) { size ->
                val geometry = WidgetLayoutPolicy.flagship(size)
                val layout = when (geometry.gridWidthDp) {
                    184 -> R.layout.widget_flagship_art_large
                    144 -> R.layout.widget_flagship_art_wide
                    else -> R.layout.widget_flagship_art
                }
                val view = RemoteViews(context.packageName, layout)
                view.setOnClickPendingIntent(R.id.flagship_root, WidgetIntents.openApp(context, 30))
                val padding = WidgetViews.pixels(context, geometry.paddingDp)
                view.setViewPadding(R.id.flagship_root, padding, padding, padding, padding)
                view.setImageViewBitmap(R.id.flagship_panel_art, WidgetArtLoader.rounded(context,
                    state.artPath, WidgetSize(geometry.panelWidthDp, size.heightDp - geometry.paddingDp * 2),
                    512, 20, overlayColor = 0xBD0A0A0A.toInt()))
                val panelPadding = WidgetViews.pixels(context, geometry.panelPaddingDp)
                view.setViewPadding(R.id.flagship_panel_content, panelPadding, panelPadding, panelPadding, panelPadding)
                WidgetViews.art(context, view, R.id.flagship_art, state,
                    WidgetSize(geometry.coverDp, geometry.coverDp), 352, 12)
                for ((index, coverId) in listOf(R.id.flagship_next_art_1, R.id.flagship_next_art_2).withIndex()) {
                    val track = upcoming.getOrNull(index)
                    val visible = track != null && index < geometry.upcomingSlots
                    view.setViewVisibility(coverId, if (visible) View.VISIBLE else View.GONE)
                    if (visible) {
                        view.setImageViewBitmap(coverId, WidgetArtLoader.rounded(context, track.artPath,
                            WidgetSize(geometry.coverDp, geometry.coverDp), 352, 12))
                        view.setInt(coverId, "setImageAlpha", 150)
                        view.setContentDescription(coverId, context.getString(R.string.widget_up_next, track.title))
                        view.setOnClickPendingIntent(coverId, WidgetIntents.openApp(context, coverId))
                    }
                }
                for (coverId in listOf(R.id.flagship_art, R.id.flagship_next_art_1, R.id.flagship_next_art_2)) {
                    view.setInt(coverId, "setMaxWidth", WidgetViews.pixels(context, geometry.coverDp))
                    view.setInt(coverId, "setMaxHeight", WidgetViews.pixels(context, geometry.coverDp))
                }
                view.setViewPadding(R.id.flagship_metadata_text, 0, 0,
                    WidgetViews.pixels(context, if (geometry.repeatInHeader || !state.hasSong) 0 else 56), 0)
                val width = if (state.hasSong) geometry.textWidthDp else geometry.panelContentWidthDp
                val artistVisible = state.hasSong && showArtist && state.artist.isNotBlank()
                WidgetViews.text(context, view, R.id.flagship_title, state.title,
                    WidgetPrefs.scaledSp(16, size.widthDp, 360f, textScale), width, if (artistVisible) 26 else 44, true)
                view.setViewVisibility(R.id.flagship_artist, if (artistVisible) View.VISIBLE else View.GONE)
                if (artistVisible) WidgetViews.text(context, view, R.id.flagship_artist, state.artist,
                    WidgetPrefs.scaledSp(11, size.widthDp, 360f, textScale), width, 18, false)
                view.setOnClickPendingIntent(R.id.flagship_title, WidgetIntents.openApp(context, 31))
                view.setOnClickPendingIntent(R.id.flagship_artist, WidgetIntents.openApp(context, 32))
                view.setViewVisibility(R.id.flagship_controls, if (state.hasSong) View.VISIBLE else View.INVISIBLE)
                WidgetViews.playButton(context, view, state, R.id.flagship_play_pause,
                    R.drawable.widget_button_tile, Color.WHITE)
                WidgetViews.skipButtons(context, view, state, R.id.flagship_prev, R.id.flagship_next, Color.WHITE)
                view.setInt(R.id.flagship_shuffle, "setBackgroundResource",
                    if (state.shuffle) R.drawable.widget_button_tile_active else R.drawable.widget_button_tile)
                view.setInt(R.id.flagship_shuffle, "setColorFilter", if (state.shuffle) accent else Color.WHITE)
                for (repeatId in listOf(R.id.flagship_repeat, R.id.flagship_repeat_header)) {
                    val inHeader = repeatId == R.id.flagship_repeat_header
                    view.setViewVisibility(repeatId,
                        if (state.hasSong && geometry.repeatInHeader == inHeader) View.VISIBLE else View.GONE)
                    view.setInt(repeatId, "setColorFilter", if (state.loopMode != 0) accent else Color.WHITE)
                    view.setInt(repeatId, "setBackgroundResource", if (state.loopMode != 0)
                        R.drawable.widget_button_transport_active_bg else R.drawable.widget_button_transport_bg)
                    view.setImageViewResource(repeatId, if (state.loopMode == 1)
                        R.drawable.widget_ic_lucide_repeat_one else R.drawable.widget_ic_lucide_repeat)
                    view.setContentDescription(repeatId, context.getString(WidgetViews.repeatDescription(state.loopMode)))
                    view.setOnClickPendingIntent(repeatId, WidgetIntents.playerRepeat(context))
                }
                view.setContentDescription(R.id.flagship_shuffle, context.getString(
                    if (state.shuffle) R.string.widget_shuffle_on else R.string.widget_shuffle_off))
                view.setOnClickPendingIntent(R.id.flagship_shuffle, WidgetIntents.playerShuffle(context))
                WidgetViews.progress(view, R.id.flagship_progress, state, accent)
                val timingVisible = state.hasSong && state.durationMs > 0
                view.setViewVisibility(R.id.flagship_times, if (timingVisible) View.VISIBLE else View.GONE)
                if (timingVisible) {
                    val timeWidth = geometry.panelContentWidthDp / 2
                    WidgetViews.text(context, view, R.id.flagship_elapsed,
                        WidgetLayoutPolicy.time(state.positionMs.coerceIn(0, state.durationMs)),
                        11, timeWidth, 18, false, color = Color.WHITE)
                    WidgetViews.text(context, view, R.id.flagship_duration, WidgetLayoutPolicy.time(state.durationMs),
                        11, timeWidth, 18, false, color = Color.WHITE, alignment = Layout.Alignment.ALIGN_OPPOSITE)
                }
                view
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
