package com.mossapps.flick.widgets

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.BitmapShader
import android.graphics.Canvas
import android.graphics.LinearGradient
import android.graphics.Matrix
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.graphics.Shader
import android.util.LruCache
import androidx.core.graphics.ColorUtils
import com.mossapps.flick.R
import java.io.File
import kotlin.math.max
import kotlin.math.roundToInt

object WidgetArtLoader {

    private const val MAX_PX = 256
    private data class Key(
        val path: String, val modified: Long, val length: Long, val maxPx: Int,
        val width: Int = 0, val height: Int = 0, val radiusDp: Int = 0, val density: Int = 0,
        val leftCornersOnly: Boolean = false, val overlayColor: Int = 0,
        val placeholder: Int = R.drawable.widget_default_art,
    )
    private val cache = object : LruCache<Key, Bitmap>(6 * 1024 * 1024) {
        override fun sizeOf(key: Key, value: Bitmap): Int = value.allocationByteCount
    }

    fun load(path: String?, maxPx: Int = MAX_PX): Bitmap? {
        if (path.isNullOrEmpty() || maxPx <= 0) return null
        val file = File(path)
        if (!file.isFile) return null
        val key = Key(file.absolutePath, file.lastModified(), file.length(), maxPx)
        cache.get(key)?.let { return it }
        val opts = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeFile(path, opts)
        if (opts.outWidth <= 0 || opts.outHeight <= 0) return null
        val sample = calculateSampleSize(opts.outWidth, opts.outHeight, maxPx)
        val bitmap = BitmapFactory.decodeFile(path, BitmapFactory.Options().apply {
            inSampleSize = sample
            inPreferredConfig = Bitmap.Config.RGB_565
        }) ?: return null
        cache.put(key, bitmap)
        // Do not recycle evictions: a RemoteViews may still reference the bitmap.
        return bitmap
    }

    /** XML clipToOutline is API 31+: pre-crop and mask art for older launchers too. */
    internal fun rounded(
        context: Context, path: String?, size: WidgetSize, maxPx: Int, radiusDp: Int,
        leftCornersOnly: Boolean = false, overlayColor: Int = 0,
        placeholder: Int = R.drawable.widget_default_art,
    ): Bitmap {
        val dm = context.resources.displayMetrics
        val targetWidth = (size.widthDp * dm.density).roundToInt().coerceAtLeast(1)
        val targetHeight = (size.heightDp * dm.density).roundToInt().coerceAtLeast(1)
        val scale = (maxPx.toFloat() / max(targetWidth, targetHeight)).coerceAtMost(1f)
        val width = (targetWidth * scale).roundToInt().coerceAtLeast(1)
        val height = (targetHeight * scale).roundToInt().coerceAtLeast(1)
        val file = path?.takeIf { it.isNotEmpty() }?.let { File(it) }
        val key = Key(file?.absolutePath ?: "", file?.lastModified() ?: 0L, file?.length() ?: 0L,
            maxPx, targetWidth, targetHeight, radiusDp, dm.densityDpi,
            leftCornersOnly, overlayColor, placeholder)
        cache.get(key)?.let { return it }

        val source = load(path, maxPx) ?: Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888).also {
            val canvas = Canvas(it)
            canvas.scale(width.toFloat() / targetWidth, height.toFloat() / targetHeight)
            context.getDrawable(placeholder)?.apply {
                setBounds(0, 0, targetWidth, targetHeight)
                draw(canvas)
            }
        }
        val cropScale = max(width.toFloat() / source.width, height.toFloat() / source.height)
        val matrix = Matrix().apply {
            setScale(cropScale, cropScale)
            postTranslate((width - source.width * cropScale) / 2f, (height - source.height * cropScale) / 2f)
        }
        val paint = Paint(Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG).apply {
            shader = BitmapShader(source, Shader.TileMode.CLAMP, Shader.TileMode.CLAMP).apply {
                setLocalMatrix(matrix)
            }
        }
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        // Keep wrap-content cover thumbnails at their requested dp size even
        // when the binder-safe bitmap has been downsampled.
        bitmap.density = (dm.densityDpi * scale).roundToInt().coerceAtLeast(1)
        val radius = radiusDp * dm.density * scale
        val mask = Path().apply {
            val rightRadius = if (leftCornersOnly) 0f else radius
            addRoundRect(RectF(0f, 0f, width.toFloat(), height.toFloat()),
                floatArrayOf(radius, radius, rightRadius, rightRadius, rightRadius, rightRadius, radius, radius),
                Path.Direction.CW)
        }
        val canvas = Canvas(bitmap)
        canvas.drawPath(mask, paint)
        if (overlayColor != 0) {
            paint.shader = null
            paint.color = overlayColor
            canvas.drawPath(mask, paint)
        }
        cache.put(key, bitmap)
        return bitmap
    }

    /** Average color of a cover for the artwork look, clamped into the Replay palette range. */
    internal fun dominantColor(path: String?, maxPx: Int = 96): Int? {
        val bitmap = load(path, maxPx) ?: return null
        val stepX = (bitmap.width / 10).coerceAtLeast(1)
        val stepY = (bitmap.height / 10).coerceAtLeast(1)
        var r = 0L
        var g = 0L
        var b = 0L
        var count = 0
        var y = stepY / 2
        while (y < bitmap.height) {
            var x = stepX / 2
            while (x < bitmap.width) {
                val pixel = bitmap.getPixel(x, y)
                r += pixel shr 16 and 0xFF
                g += pixel shr 8 and 0xFF
                b += pixel and 0xFF
                count++
                x += stepX
            }
            y += stepY
        }
        if (count == 0) return null
        val hsl = FloatArray(3)
        ColorUtils.RGBToHSL((r / count).toInt(), (g / count).toInt(), (b / count).toInt(), hsl)
        hsl[1] = hsl[1].coerceIn(0.35f, 0.75f)
        hsl[2] = hsl[2].coerceIn(0.38f, 0.62f)
        return ColorUtils.HSLToColor(hsl)
    }

    private data class SurfaceKey(
        val start: Int, val end: Int, val border: Int,
        val width: Int, val height: Int, val radius: Int, val density: Int,
    )
    private val surfaceCache = object : LruCache<SurfaceKey, Bitmap>(2 * 1024 * 1024) {
        override fun sizeOf(key: SurfaceKey, value: Bitmap): Int = value.allocationByteCount
    }

    /** Rounded gradient surface for the artwork look; same pre-31 masking rule as [rounded]. */
    internal fun gradientSurface(
        context: Context, size: WidgetSize, maxPx: Int, radiusDp: Int,
        startColor: Int, endColor: Int, borderColor: Int, borderWidthDp: Int = 1,
    ): Bitmap {
        val dm = context.resources.displayMetrics
        val targetWidth = (size.widthDp * dm.density).roundToInt().coerceAtLeast(1)
        val targetHeight = (size.heightDp * dm.density).roundToInt().coerceAtLeast(1)
        val scale = (maxPx.toFloat() / max(targetWidth, targetHeight)).coerceAtMost(1f)
        val width = (targetWidth * scale).roundToInt().coerceAtLeast(1)
        val height = (targetHeight * scale).roundToInt().coerceAtLeast(1)
        val key = SurfaceKey(startColor, endColor, borderColor, width, height, radiusDp, dm.densityDpi)
        surfaceCache.get(key)?.let { return it }
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        bitmap.density = (dm.densityDpi * scale).roundToInt().coerceAtLeast(1)
        val radius = radiusDp * dm.density * scale
        val mask = Path().apply {
            addRoundRect(RectF(0f, 0f, width.toFloat(), height.toFloat()), radius, radius, Path.Direction.CW)
        }
        val canvas = Canvas(bitmap)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        paint.shader = LinearGradient(
            0f, 0f, width.toFloat(), height.toFloat(), startColor, endColor, Shader.TileMode.CLAMP,
        )
        canvas.drawPath(mask, paint)
        paint.shader = null
        paint.style = Paint.Style.STROKE
        paint.color = borderColor
        val stroke = (borderWidthDp * dm.density * scale).coerceAtLeast(1f)
        paint.strokeWidth = stroke
        val inset = stroke / 2f
        val borderMask = Path().apply {
            addRoundRect(
                RectF(inset, inset, width - inset, height - inset),
                radius, radius, Path.Direction.CW,
            )
        }
        canvas.drawPath(borderMask, paint)
        surfaceCache.put(key, bitmap)
        return bitmap
    }

    private fun calculateSampleSize(w: Int, h: Int, maxPx: Int): Int {
        var s = 1
        while (w / s > maxPx || h / s > maxPx) s *= 2
        return s
    }
}
