package com.mossapps.flick.widgets

import android.appwidget.AppWidgetManager
import android.content.Context
import android.graphics.Bitmap
import android.text.Layout
import android.view.View
import android.widget.RemoteViews
import com.mossapps.flick.R
import java.text.SimpleDateFormat
import java.util.Date

/**
 * "Flick Replay" widget: today's listening snapshot with the in-app Replay card looks.
 * Tapping anywhere opens the Recap screen through the widget deep link.
 */
class ReplayWidgetProvider : ResponsiveWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        val state = WidgetReplayState.read(context)
        val look = WidgetPrefs.getReplayLook(context)
        for (id in appWidgetIds) {
            val views = responsiveViews(
                appWidgetManager.getAppWidgetOptions(id),
                WidgetLayoutPolicy.replayDefault,
            ) { size -> render(context, size, state, look) }
            appWidgetManager.updateAppWidget(id, views)
        }
    }

    private fun render(context: Context, size: WidgetSize, state: WidgetReplayState, look: String): RemoteViews {
        val geometry = WidgetLayoutPolicy.replay(size, state.covers.size, state.hasData)
        val artwork = look == LOOK_ARTWORK
        val colors = when {
            artwork -> ReplayPalette.artwork(
                WidgetArtLoader.dominantColor(state.covers.firstOrNull())
                    ?: ReplayPalette.NIGHT.background,
            )
            look == LOOK_SIGNAL -> ReplayPalette.SIGNAL
            look == LOOK_NIGHT -> ReplayPalette.NIGHT
            else -> ReplayPalette.ACID
        }
        val view = RemoteViews(context.packageName, R.layout.widget_replay)

        if (artwork) {
            view.setInt(R.id.replay_root, "setBackgroundResource", android.R.color.transparent)
            view.setViewVisibility(R.id.replay_bg_image, View.VISIBLE)
            view.setImageViewBitmap(
                R.id.replay_bg_image,
                WidgetArtLoader.gradientSurface(
                    context, size, 1024, 24, colors.background, colors.shaded, colors.border,
                ),
            )
        } else {
            view.setInt(
                R.id.replay_root, "setBackgroundResource",
                when (look) {
                    LOOK_SIGNAL -> R.drawable.widget_replay_background_signal
                    LOOK_NIGHT -> R.drawable.widget_replay_background
                    else -> R.drawable.widget_replay_background_acid
                },
            )
            view.setViewVisibility(R.id.replay_bg_image, View.GONE)
        }
        view.setOnClickPendingIntent(R.id.replay_root, WidgetIntents.openRecap(context))
        val padding = WidgetViews.pixels(context, geometry.paddingDp)
        view.setViewPadding(R.id.replay_content, padding, padding, padding, padding)
        view.setViewPadding(R.id.replay_body, 0, WidgetViews.pixels(context, geometry.bodyGapDp), 0, 0)

        view.setInt(R.id.replay_brand, "setColorFilter", colors.foreground)
        WidgetViews.text(
            context, view, R.id.replay_brand_text, context.getString(R.string.widget_replay_brand),
            BRAND_SP, geometry.brandTextWidthDp, 16, true,
            color = colors.foreground,
        )
        WidgetViews.text(
            context, view, R.id.replay_date,
            context.getString(R.string.widget_replay_date, SimpleDateFormat(
                android.text.format.DateFormat.getBestDateTimePattern(
                    context.resources.configuration.locales[0], "MMMd"),
                context.resources.configuration.locales[0],
            ).format(Date())),
            10, 86, 16, false, color = colors.secondary, alignment = Layout.Alignment.ALIGN_OPPOSITE,
            fitWidth = true,
        )

        val timeText = WidgetLayoutPolicy.listeningTime(state.timeMs)
        val playsText = state.plays.toString()
        WidgetViews.text(
            context, view, R.id.replay_time_label, context.getString(R.string.widget_replay_time),
            10, geometry.timeWidthDp, 12, false, color = colors.secondary,
        )
        WidgetViews.text(
            context, view, R.id.replay_time_value, timeText,
            geometry.valueSp, geometry.timeWidthDp, geometry.valueHeightDp, true,
            color = colors.value, fitWidth = true, fillHeight = true,
        )
        WidgetViews.text(
            context, view, R.id.replay_plays_label, context.getString(R.string.widget_replay_plays),
            10, geometry.playsWidthDp, 12, false, color = colors.secondary,
        )
        WidgetViews.text(
            context, view, R.id.replay_plays_value, playsText,
            geometry.valueSp, geometry.playsWidthDp, geometry.valueHeightDp, true,
            color = colors.value, fitWidth = true, fillHeight = true,
        )

        val comparisons = ArrayList<String>()
        for ((deltaId, delta) in listOf(R.id.replay_time_delta to state.timeDelta, R.id.replay_plays_delta to state.playsDelta)) {
            val visible = state.hasData && delta != WidgetReplayState.UNKNOWN_DELTA && delta != 0
            // Reserve the same delta row in both columns, even if only one is known.
            view.setViewVisibility(deltaId, if (visible) View.VISIBLE else if (state.hasData) View.INVISIBLE else View.GONE)
            if (visible) {
                WidgetViews.text(
                    context, view, deltaId, WidgetLayoutPolicy.percentLabel(delta),
                    10, if (deltaId == R.id.replay_time_delta) geometry.timeWidthDp else geometry.playsWidthDp, 12, false,
                    color = if (delta < 0) colors.negative else colors.positive,
                )
                comparisons.add(context.getString(
                    if (deltaId == R.id.replay_time_delta) R.string.widget_replay_time_change
                    else R.string.widget_replay_plays_change, WidgetLayoutPolicy.percentLabel(delta)))
            }
        }

        val rule = Bitmap.createBitmap(1, WidgetViews.pixels(context, geometry.metricsHeightDp).coerceAtLeast(1),
            Bitmap.Config.ARGB_8888).apply {
            density = context.resources.displayMetrics.densityDpi
            eraseColor(ReplayPalette.lerp(colors.background, colors.foreground, 0.22f))
        }
        view.setImageViewBitmap(R.id.replay_rule, rule)
        view.setImageViewBitmap(R.id.replay_artwork, WidgetReplayArtwork.create(context, state.covers, geometry, colors))

        val captionVisible = geometry.showCaption && (!state.hasData || comparisons.isNotEmpty())
        view.setViewVisibility(R.id.replay_caption, if (captionVisible) View.VISIBLE else View.GONE)
        if (captionVisible) {
            WidgetViews.text(
                context, view, R.id.replay_caption,
                context.getString(if (state.hasData) R.string.widget_replay_comparison else R.string.widget_replay_empty),
                10, geometry.statsWidthDp, 12, false, color = colors.secondary,
            )
        }

        val summary = if (state.hasData) {
            context.getString(R.string.widget_replay_summary, timeText, state.plays)
        } else {
            context.getString(R.string.widget_replay_empty)
        }
        view.setContentDescription(R.id.replay_root,
            (listOf(summary) + comparisons + context.getString(R.string.widget_replay_open)).joinToString(". "))
        return view
    }

    private companion object {
        const val LOOK_ARTWORK = "artwork"
        const val LOOK_SIGNAL = "signal"
        const val LOOK_NIGHT = "night"
        const val BRAND_SP = 13
    }
}
