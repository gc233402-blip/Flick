package com.mossapps.flick.widgets

import android.appwidget.AppWidgetManager
import android.content.Context
import android.graphics.Color
import android.view.View
import android.widget.RemoteViews
import com.mossapps.flick.R

class MiniPlayerWidgetProvider : ResponsiveWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        val state = WidgetPlaybackState.read(context)
        val showArt = WidgetPrefs.getShowAlbumArt(context)
        val showArtist = WidgetPrefs.getShowArtist(context)
        val accent = WidgetPrefs.getAccentColor(context)
        val textScale = WidgetPrefs.getMiniTextScale(context)

        for (id in appWidgetIds) {
            val views = responsiveViews(appWidgetManager.getAppWidgetOptions(id), WidgetLayoutPolicy.miniDefault) { size ->
                val view = RemoteViews(context.packageName, R.layout.widget_mini_player)
                val background = when (WidgetPrefs.get(context).getInt(WidgetPrefs.KEY_BG_OPACITY, 3)) {
                    0 -> R.drawable.widget_mini_background_0
                    1 -> R.drawable.widget_mini_background_1
                    2 -> R.drawable.widget_mini_background_2
                    4 -> R.drawable.widget_mini_background_4
                    else -> R.drawable.widget_mini_background
                }
                view.setInt(R.id.widget_root, "setBackgroundResource", background)
                view.setOnClickPendingIntent(R.id.widget_root, WidgetIntents.openApp(context, 10))
                view.setViewVisibility(R.id.widget_thumbnail, if (showArt) View.VISIBLE else View.GONE)
                if (showArt) {
                    view.setImageViewBitmap(R.id.widget_thumbnail, WidgetArtLoader.rounded(context,
                        state.artPath, WidgetSize(56, 56), 224, 16, leftCornersOnly = true,
                        placeholder = R.drawable.widget_mini_placeholder))
                    view.setOnClickPendingIntent(R.id.widget_thumbnail, WidgetIntents.openApp(context, 13))
                }

                val width = WidgetLayoutPolicy.miniTextWidth(size, showArt, state.hasSong)
                val artistVisible = state.hasSong && showArtist && state.artist.isNotBlank()
                WidgetViews.text(context, view, R.id.widget_title, state.title,
                    WidgetPrefs.scaledSp(14, 320, 320f, textScale), width, if (artistVisible) 22 else 40, true)
                view.setViewVisibility(R.id.widget_artist, if (artistVisible) View.VISIBLE else View.GONE)
                if (artistVisible) WidgetViews.text(context, view, R.id.widget_artist, state.artist,
                    WidgetPrefs.scaledSp(12, 320, 320f, textScale), width, 18, false, weight = 500)
                view.setOnClickPendingIntent(R.id.widget_title, WidgetIntents.openApp(context, 11))
                view.setOnClickPendingIntent(R.id.widget_artist, WidgetIntents.openApp(context, 12))
                WidgetViews.playButton(context, view, state, R.id.widget_play_pause,
                    R.drawable.widget_button_transport_bg, Color.WHITE)
                WidgetViews.progress(view, R.id.widget_progress, state,
                    if (accent == Color.WHITE) 0xFFE0E0E0.toInt() else accent, trackColor = 0,
                    barSize = WidgetSize(size.widthDp, 56), radiusDp = 16)
                view
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
