package com.mossapps.flick.widgets

import android.appwidget.AppWidgetManager
import android.content.Context
import android.graphics.Color
import android.os.Build
import android.view.View
import android.widget.RemoteViews
import com.mossapps.flick.R

class CompactWidgetProvider : ResponsiveWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        val state = WidgetPlaybackState.read(context)
        val showArt = WidgetPrefs.getCompactShowAlbumArt(context)
        val showArtist = WidgetPrefs.getCompactShowArtist(context)
        val accent = WidgetPrefs.getCompactAccentColor(context)
        val textScale = WidgetPrefs.getCompactTextScale(context)

        for (id in appWidgetIds) {
            val views = responsiveViews(appWidgetManager.getAppWidgetOptions(id), WidgetLayoutPolicy.compactDefault) { hostSize ->
                val size = WidgetLayoutPolicy.compactCardSize(hostSize,
                    legacySizing = Build.VERSION.SDK_INT < Build.VERSION_CODES.S)
                val layout = WidgetLayoutPolicy.compactLayout(size)
                val layoutId = when (layout) {
                    CompactLayout.REGULAR -> R.layout.widget_compact
                    CompactLayout.SHORT -> R.layout.widget_compact_short
                    CompactLayout.NARROW -> R.layout.widget_compact_narrow
                }
                val view = RemoteViews(context.packageName, layoutId)
                view.setInt(R.id.compact_root, "setBackgroundResource", WidgetPrefs.getCompactBackgroundDrawableRes(context))
                view.setOnClickPendingIntent(R.id.compact_root, WidgetIntents.openApp(context, 50))
                view.setViewVisibility(R.id.compact_art_bg, if (showArt) View.VISIBLE else View.GONE)
                val foreground = Color.WHITE
                val shadow = 0x80000000.toInt()
                if (showArt) {
                    // One uniform scrim keeps white metadata readable on bright artwork.
                    view.setImageViewBitmap(R.id.compact_art_bg, WidgetArtLoader.rounded(context,
                        state.artPath, size, 384, 24, overlayColor = 0x4D000000))
                    view.setOnClickPendingIntent(R.id.compact_art_bg, WidgetIntents.openApp(context, 53))
                }
                if (layout == CompactLayout.REGULAR) {
                    view.setInt(R.id.compact_brand, "setColorFilter", foreground)
                }

                val width = WidgetLayoutPolicy.compactTextWidth(size, state.hasSong)
                val artistVisible = state.hasSong && showArtist && state.artist.isNotBlank()
                val titleHeight = if (artistVisible) 22 else if (layout == CompactLayout.NARROW) 42 else 44
                WidgetViews.text(context, view, R.id.compact_title, state.title,
                    WidgetPrefs.scaledSp(12, 168, 168f, textScale), width, titleHeight,
                    true, color = foreground, shadowColor = shadow)
                view.setViewVisibility(R.id.compact_artist, if (artistVisible) View.VISIBLE else View.GONE)
                if (artistVisible) WidgetViews.text(context, view, R.id.compact_artist, state.artist,
                    WidgetPrefs.scaledSp(10, 168, 168f, textScale), width, 18,
                    false, color = WidgetViews.SECONDARY_TEXT, fakeBold = true, shadowColor = shadow)
                view.setViewVisibility(R.id.compact_controls, if (state.hasSong) View.VISIBLE else View.GONE)
                view.setOnClickPendingIntent(R.id.compact_title, WidgetIntents.openApp(context, 51))
                view.setOnClickPendingIntent(R.id.compact_artist, WidgetIntents.openApp(context, 52))
                WidgetViews.playButton(context, view, state, R.id.compact_play_pause,
                    WidgetViews.playBackground(accent, compact = true), 0xFF111111.toInt())
                WidgetViews.skipButtons(context, view, state, R.id.compact_prev, R.id.compact_next, foreground)
                if (WidgetLayoutPolicy.compactShowsProgress(size)) {
                    WidgetViews.progress(view, R.id.compact_progress, state,
                        if (accent == Color.WHITE) foreground else accent)
                } else {
                    view.setViewVisibility(R.id.compact_progress, View.GONE)
                }
                if (size != hostSize) {
                    RemoteViews(context.packageName, R.layout.widget_compact_square).apply {
                        removeAllViews(R.id.compact_square_content)
                        addView(R.id.compact_square_content, view)
                    }
                } else view
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
