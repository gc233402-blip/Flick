package com.mossapps.flick.widgets

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapShader
import android.graphics.Canvas
import android.graphics.Matrix
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Shader
import android.util.LruCache
import android.view.View
import com.mossapps.flick.R
import java.io.File
import kotlin.math.roundToInt

/** A single binder-bounded sleeve deck keeps overlap consistent on API 26+ launchers. */
internal object WidgetReplayArtwork {
    private data class ArtFile(val path: String, val modified: Long, val length: Long)
    private data class Key(
        val files: List<ArtFile>, val geometry: ReplayGeometry, val colors: ReplayColors,
        val density: Int, val rtl: Boolean,
    )
    private val cache = object : LruCache<Key, Bitmap>(2 * 1024 * 1024) {
        override fun sizeOf(key: Key, value: Bitmap): Int = value.allocationByteCount
    }

    fun create(context: Context, paths: List<String>, geometry: ReplayGeometry, colors: ReplayColors): Bitmap {
        val dm = context.resources.displayMetrics
        val rtl = context.resources.configuration.layoutDirection == View.LAYOUT_DIRECTION_RTL
        val files = paths.take(geometry.covers).map { path ->
            val file = File(path)
            ArtFile(file.absolutePath, file.lastModified(), file.length())
        }
        val key = Key(files, geometry, colors, dm.densityDpi, rtl)
        cache.get(key)?.let { return it }

        val scale = minOf(dm.density, 360f / maxOf(geometry.artworkWidthDp, geometry.artworkHeightDp))
        val bitmap = Bitmap.createBitmap(
            (geometry.artworkWidthDp * scale).roundToInt().coerceAtLeast(1),
            (geometry.artworkHeightDp * scale).roundToInt().coerceAtLeast(1), Bitmap.Config.ARGB_8888,
        )
        // Preserve wrap_content dp bounds even when the bitmap is downsampled.
        bitmap.density = (dm.densityDpi * scale / dm.density).roundToInt().coerceAtLeast(1)
        val canvas = Canvas(bitmap)
        canvas.scale(scale, scale)
        val width = geometry.artworkWidthDp.toFloat()
        val height = geometry.artworkHeightDp.toFloat()
        ornament(canvas, width, height, colors.accent)

        for (sleeve in geometry.sleeves(rtl)) {
            val rect = RectF(sleeve.leftDp, sleeve.topDp,
                sleeve.leftDp + sleeve.sideDp, sleeve.topDp + sleeve.sideDp)
            val saved = canvas.save()
            canvas.rotate(sleeve.rotation, rect.centerX(), rect.centerY())
            cover(context, canvas, rect, files.getOrNull(sleeve.index)?.path, colors)
            canvas.restoreToCount(saved)
        }
        if (geometry.covers == 0) {
            if (geometry.hasData) {
                val side = geometry.coverDp.toFloat()
                cover(context, canvas,
                    RectF((width - side) / 2f, (height - side) / 2f,
                        (width + side) / 2f, (height + side) / 2f), null, colors)
            } else {
                mark(context, canvas, RectF(width * 0.35f, height * 0.25f,
                    width * 0.65f, height * 0.75f), colors.foreground)
            }
        }
        val dots = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = colors.accent }
        for (index in 0..2) canvas.drawCircle(6f + index * 6f, height - 3f, 1.5f, dots)
        cache.put(key, bitmap)
        // Do not recycle cache evictions: published RemoteViews can still refer to them.
        return bitmap
    }

    private fun ornament(canvas: Canvas, width: Float, height: Float, color: Int) {
        // Static native counterpart of replay_loop.svg and replay_contours.svg.
        val orbit = ReplayOrbitGeometry.fit(width, height)
        val saved = canvas.save()
        canvas.rotate(ReplayOrbitGeometry.ROTATION, width / 2f, height / 2f)
        canvas.scale(orbit.scale, orbit.scale, width / 2f, height / 2f)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            this.color = color
            style = Paint.Style.STROKE
            strokeWidth = ReplayOrbitGeometry.STROKE_DP
            alpha = 210
        }
        val loop = RectF(width / 2f - orbit.radiusXDp, height / 2f - orbit.radiusYDp,
            width / 2f + orbit.radiusXDp, height / 2f + orbit.radiusYDp)
        canvas.drawOval(loop, paint)
        paint.strokeWidth = ReplayOrbitGeometry.CONTOUR_STROKE_DP
        paint.alpha = 100
        for (inset in ReplayOrbitGeometry.CONTOUR_INSETS_DP) {
            canvas.drawOval(RectF(loop).apply { inset(-inset, -inset) }, paint)
        }
        canvas.restoreToCount(saved)
    }

    private fun cover(context: Context, canvas: Canvas, rect: RectF, path: String?, colors: ReplayColors) {
        val paint = Paint(Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG).apply {
            color = ReplayPalette.NIGHT.background
            setShadowLayer(3f, 0f, 2f, 0x33000000)
        }
        canvas.drawRoundRect(rect, 5f, 5f, paint)
        paint.clearShadowLayer()
        val art = WidgetArtLoader.load(path, 320)
        if (art != null) {
            val crop = maxOf(rect.width() / art.width, rect.height() / art.height)
            val matrix = Matrix().apply {
                setScale(crop, crop)
                postTranslate(rect.left + (rect.width() - art.width * crop) / 2f,
                    rect.top + (rect.height() - art.height * crop) / 2f)
            }
            paint.shader = BitmapShader(art, Shader.TileMode.CLAMP, Shader.TileMode.CLAMP).apply {
                setLocalMatrix(matrix)
            }
            canvas.drawRoundRect(rect, 5f, 5f, paint)
        } else {
            val inset = rect.width() * 0.3f
            mark(context, canvas, RectF(rect).apply { inset(inset, inset * 0.7f) }, ReplayPalette.ACID.background)
        }
        // A fine edge, not a tint over the album itself.
        paint.shader = null
        paint.style = Paint.Style.STROKE
        paint.strokeWidth = 0.6f
        paint.color = ReplayPalette.lerp(colors.background, colors.foreground, 0.22f)
        canvas.drawRoundRect(rect, 5f, 5f, paint)
    }

    private fun mark(context: Context, canvas: Canvas, rect: RectF, color: Int) {
        context.getDrawable(R.drawable.widget_flick_logo)?.mutate()?.apply {
            setTint(color)
            // The dotted Flick mark has a 4:5 aspect ratio.
            val width = minOf(rect.width(), rect.height() * 0.8f)
            val height = width / 0.8f
            setBounds((rect.centerX() - width / 2f).roundToInt(),
                (rect.centerY() - height / 2f).roundToInt(),
                (rect.centerX() + width / 2f).roundToInt(), (rect.centerY() + height / 2f).roundToInt())
            draw(canvas)
        }
    }
}
