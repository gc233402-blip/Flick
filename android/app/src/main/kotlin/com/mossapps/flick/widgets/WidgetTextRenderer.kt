package com.mossapps.flick.widgets

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Typeface
import android.text.Layout
import android.text.StaticLayout
import android.text.TextPaint
import android.text.TextUtils
import android.util.TypedValue
import android.util.LruCache
import androidx.annotation.FontRes
import androidx.core.content.res.ResourcesCompat


object WidgetTextRenderer {
    private data class Key(
        val text: String, val font: Int, val sizePx: Float, val color: Int,
        val width: Int, val height: Int, val alignment: Layout.Alignment, val locale: String,
        val weight: Int, val shadowColor: Int, val fakeBold: Boolean, val fitWidth: Boolean,
        val fillHeight: Boolean, val baselineInset: Float,
    )
    private val cache = object : LruCache<Key, Bitmap>(2 * 1024 * 1024) {
        override fun sizeOf(key: Key, value: Bitmap): Int = value.allocationByteCount
    }
    private val fonts = HashMap<Int, Typeface>()

    private fun font(context: Context, @FontRes fallback: Int, weight: Int): Typeface =
        fonts.getOrPut(weight) {
            try {
                val asset = if (weight >= 600) "Bold" else "Regular"
                Typeface.Builder(context.assets, "flutter_assets/assets/fonts/GoogleSansFlex-$asset.ttf")
                    .setWeight(weight).build()
                    ?: ResourcesCompat.getFont(context, fallback) ?: Typeface.DEFAULT
            } catch (_: RuntimeException) {
                ResourcesCompat.getFont(context, fallback) ?: Typeface.DEFAULT
            }
        }

    fun createTextBitmap(
        context: Context,
        text: String,
        @FontRes fontRes: Int,
        textSizeSp: Int,
        textColor: Int,
        maxWidthPx: Int,
        alignment: Layout.Alignment = Layout.Alignment.ALIGN_NORMAL,
        maxHeightPx: Int = Int.MAX_VALUE,
        fontWeight: Int = 400,
        shadowColor: Int = 0,
        fakeBold: Boolean = false,
        fitWidth: Boolean = false,
        fillHeight: Boolean = false,
    ): Bitmap {
        val dm = context.resources.displayMetrics
        val paint = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
            typeface = font(context, fontRes, fontWeight)
            textSize = TypedValue.applyDimension(
                TypedValue.COMPLEX_UNIT_SP,
                textSizeSp.toFloat(),
                dm,
            )
            color = textColor
            textLocale = context.resources.configuration.locales[0]
            if (shadowColor != 0) setShadowLayer(dm.density, 0f, dm.density * 0.5f, shadowColor)
            // The bundled font ships Regular and Bold only; a small synthetic
            // weight fills the gap for secondary metadata.
            if (fakeBold) setFakeBoldText(true)
        }
        val width = maxWidthPx.coerceAtLeast(1)
        val height = maxHeightPx.coerceAtLeast(1)
        // Honor SP (including system font scaling), fitting only when the finite
        // launcher cell cannot hold a full line. The full label stays accessible.
        if (paint.fontSpacing > height) paint.textSize *= height / paint.fontSpacing
        val baselineInset = if (fillHeight) paint.fontMetrics.descent else 0f
        val singleLine = text.replace('\n', ' ').replace('\r', ' ')
        if (fitWidth) {
            val measured = paint.measureText(singleLine)
            if (measured > width) paint.textSize *= width / measured
        }
        val key = Key(text, fontRes, paint.textSize, textColor, width, height, alignment,
            paint.textLocale.toLanguageTag(), fontWeight, shadowColor, fakeBold, fitWidth, fillHeight, baselineInset)
        cache.get(key)?.let { return it }
        val ellipsized = TextUtils.ellipsize(
            singleLine,
            paint,
            width.toFloat(),
            TextUtils.TruncateAt.END,
        )
        val layout = StaticLayout.Builder.obtain(ellipsized, 0, ellipsized.length, paint, width)
            .setAlignment(alignment)
            .setIncludePad(false)
            .setMaxLines(1)
            .build()
        val bitmap = Bitmap.createBitmap(width,
            if (fillHeight) height else layout.height.coerceIn(1, height), Bitmap.Config.ARGB_8888)
        if (fillHeight) bitmap.density = dm.densityDpi
        val canvas = Canvas(bitmap)
        // A fixed metric box keeps adjacent values on the same baseline even
        // when a long duration or play count has to fit a narrower column.
        if (fillHeight) canvas.translate(0f,
            (height - baselineInset - layout.getLineBaseline(0)).coerceAtLeast(0f))
        layout.draw(canvas)
        cache.put(key, bitmap)
        return bitmap
    }
}
