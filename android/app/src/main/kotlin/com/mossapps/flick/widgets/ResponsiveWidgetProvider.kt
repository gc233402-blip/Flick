package com.mossapps.flick.widgets

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.os.Build
import android.os.Bundle
import android.util.SizeF
import android.widget.RemoteViews

abstract class ResponsiveWidgetProvider : AppWidgetProvider() {
    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        onUpdate(context, appWidgetManager, intArrayOf(appWidgetId))
    }

    internal fun responsiveViews(
        options: Bundle,
        defaultSize: WidgetSize,
        render: (WidgetSize) -> RemoteViews,
    ): RemoteViews {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            @Suppress("DEPRECATION")
            val sizes = options.getParcelableArrayList<SizeF>(AppWidgetManager.OPTION_APPWIDGET_SIZES)
                ?.filter { it.width.isFinite() && it.height.isFinite() && it.width > 0 && it.height > 0 }
                ?.distinct()
            if (!sizes.isNullOrEmpty()) {
                // RemoteViews accepts at most sixteen size variants.
                return RemoteViews(sizes.take(16).associateWith {
                    render(WidgetSize(it.width.toInt(), it.height.toInt()))
                })
            }
        }

        fun dimension(key: String, fallback: Int) = options.getInt(key, fallback).takeIf { it > 0 } ?: fallback
        val portrait = WidgetSize(
            dimension(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, defaultSize.widthDp),
            dimension(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT, defaultSize.heightDp),
        )
        val landscape = WidgetSize(
            dimension(AppWidgetManager.OPTION_APPWIDGET_MAX_WIDTH, portrait.widthDp),
            dimension(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, portrait.heightDp),
        )
        return if (portrait == landscape) render(portrait)
        else RemoteViews(render(landscape), render(portrait))
    }
}
