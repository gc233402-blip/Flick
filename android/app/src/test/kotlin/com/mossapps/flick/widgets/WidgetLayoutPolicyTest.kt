package com.mossapps.flick.widgets

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.roundToInt
import kotlin.math.sin

class WidgetLayoutPolicyTest {
    @Test
    fun miniMatchesTheBottomBarsFixedGeometry() {
        assertEquals(56, WidgetLayoutPolicy.miniDefault.heightDp)
        assertEquals(140, WidgetLayoutPolicy.miniTextWidth(WidgetSize(260, 56), true, true))
        assertEquals(200, WidgetLayoutPolicy.miniTextWidth(WidgetSize(320, 112), true, true))
        assertEquals(256, WidgetLayoutPolicy.miniTextWidth(WidgetSize(320, 56), false, true))
        assertEquals(248, WidgetLayoutPolicy.miniTextWidth(WidgetSize(320, 56), true, false))
    }

    @Test
    fun compactLeavesRoomForItsSmallPlayButton() {
        assertEquals(68, WidgetLayoutPolicy.compactTextWidth(WidgetSize(156, 156), true))
        assertEquals(80, WidgetLayoutPolicy.compactTextWidth(WidgetSize(168, 168), true))
        assertEquals(136, WidgetLayoutPolicy.compactTextWidth(WidgetSize(168, 168), false))
        for (height in listOf(156, 168)) {
            val playBottom = (height - 48) / 2 - 8 + 48
            val skipTop = height - 8 - 48
            assertTrue(playBottom <= skipTop)
        }
    }

    @Test
    fun compactSquaresOnlyUnusuallyTallLegacyAllocations() {
        for (size in listOf(WidgetLayoutPolicy.compactDefault, WidgetSize(110, 156),
            WidgetSize(148, 222), WidgetSize(226, 263), WidgetSize(225, 110))) {
            assertEquals(size, WidgetLayoutPolicy.compactCardSize(size, legacySizing = true))
        }
        for (size in listOf(WidgetSize(110, 225), WidgetSize(148, 290),
            WidgetSize(156, 235), WidgetSize(226, 400))) {
            val card = WidgetLayoutPolicy.compactCardSize(size, legacySizing = true)
            assertEquals(WidgetSize(size.widthDp, size.widthDp), card)
            assertTrue(card.heightDp <= size.heightDp)
            assertTrue(WidgetLayoutPolicy.compactTextWidth(card, true) >= 42)
        }
        val card = WidgetLayoutPolicy.compactCardSize(WidgetSize(148, 290), legacySizing = true)
        assertEquals(CompactLayout.SHORT, WidgetLayoutPolicy.compactLayout(card))
        assertEquals(80, WidgetLayoutPolicy.compactTextWidth(card, true))
    }

    @Test
    fun compactPreservesModernTargetCellSizingRegardlessOfAspectRatio() {
        for (size in listOf(WidgetSize(110, 225), WidgetSize(148, 290),
            WidgetSize(156, 235), WidgetSize(226, 263), WidgetSize(226, 400))) {
            assertEquals(size, WidgetLayoutPolicy.compactCardSize(size, legacySizing = false))
        }
    }

    @Test
    fun compactReflowsUsingWidgetBoundsRatherThanThePhoneModel() {
        assertEquals(CompactLayout.REGULAR, WidgetLayoutPolicy.compactLayout(WidgetSize(156, 156)))
        assertEquals(CompactLayout.REGULAR, WidgetLayoutPolicy.compactLayout(WidgetLayoutPolicy.compactDefault))
        assertEquals(CompactLayout.SHORT, WidgetLayoutPolicy.compactLayout(WidgetSize(225, 110)))
        assertEquals(CompactLayout.SHORT, WidgetLayoutPolicy.compactLayout(WidgetSize(110, 155)))
        assertEquals(CompactLayout.NARROW, WidgetLayoutPolicy.compactLayout(WidgetSize(110, 156)))
        assertEquals(CompactLayout.NARROW, WidgetLayoutPolicy.compactLayout(WidgetSize(155, 225)))
        assertEquals(42, WidgetLayoutPolicy.compactTextWidth(WidgetSize(110, 110), true))
        assertEquals(98, WidgetLayoutPolicy.compactTextWidth(WidgetSize(110, 110), false))
        assertEquals(98, WidgetLayoutPolicy.compactTextWidth(WidgetSize(110, 156), true))
        assertEquals(157, WidgetLayoutPolicy.compactTextWidth(WidgetSize(225, 110), true))
    }

    @Test
    fun compactOnlyShowsProgressWhenItFitsBetweenTheSkipButtons() {
        for (height in listOf(110, 155, 156, 168, 225)) {
            assertFalse(WidgetLayoutPolicy.compactShowsProgress(WidgetSize(110, height)))
            assertFalse(WidgetLayoutPolicy.compactShowsProgress(WidgetSize(147, height)))
            assertTrue(WidgetLayoutPolicy.compactShowsProgress(WidgetSize(148, height)))
            assertTrue(WidgetLayoutPolicy.compactShowsProgress(WidgetSize(156, height)))
            assertTrue(WidgetLayoutPolicy.compactShowsProgress(WidgetSize(225, height)))
        }
    }

    @Test
    fun flagshipTilesAndCoversFitEverySupportedSize() {
        for (width in listOf(250, 320, 400, 439, 440, 559, 560, 704)) {
            for (height in listOf(180, 208, 240, 328, 500)) {
                val geometry = WidgetLayoutPolicy.flagship(WidgetSize(width, height))
                assertTrue((geometry.gridWidthDp - 8) / 2 >= 48)
                assertTrue((height - geometry.paddingDp * 2 - 8) / 2 >= 48)
                assertTrue(geometry.textWidthDp >= 48)
                assertEquals(width, geometry.paddingDp * 2 + geometry.panelWidthDp +
                    geometry.gapDp + geometry.gridWidthDp)
                val coverRow = if (geometry.repeatInHeader) geometry.coverDp + 48
                    else geometry.coverDp * (geometry.upcomingSlots + 1) + geometry.upcomingSlots * 8
                assertTrue(coverRow <= geometry.panelContentWidthDp)
                val contentHeight = height - geometry.paddingDp * 2 - geometry.panelPaddingDp * 2
                // Cover, metadata, progress and timestamps must also fit vertically.
                assertTrue(geometry.coverDp + 89 <= contentHeight)
            }
        }
    }

    @Test
    fun flagshipReflowsUpcomingArtAndRepeatRatherThanShrinkingTargets() {
        val small = WidgetLayoutPolicy.flagship(WidgetSize(250, 180))
        assertTrue(small.repeatInHeader)
        assertEquals(0, small.upcomingSlots)
        val wide = WidgetLayoutPolicy.flagship(WidgetSize(440, 240))
        assertFalse(wide.repeatInHeader)
        assertEquals(2, wide.upcomingSlots)
        assertEquals(144, wide.gridWidthDp)
        assertEquals(184, WidgetLayoutPolicy.flagship(WidgetSize(704, 328)).gridWidthDp)
    }

    @Test
    fun timestampsHandleLongTracksAndInvalidPositions() {
        assertEquals("0:00", WidgetLayoutPolicy.time(-1))
        assertEquals("0:48", WidgetLayoutPolicy.time(48000))
        assertEquals("2:02", WidgetLayoutPolicy.time(122000))
        assertEquals("1:02:03", WidgetLayoutPolicy.time(3723000))
    }

    @Test
    fun progressClampsInvalidAndExtremePositionsWithoutOverflow() {
        assertEquals(0, WidgetLayoutPolicy.progress(50, 0))
        assertEquals(0, WidgetLayoutPolicy.progress(-50, 100))
        assertEquals(500, WidgetLayoutPolicy.progress(50, 100))
        assertEquals(1000, WidgetLayoutPolicy.progress(150, 100))
        assertEquals(1000, WidgetLayoutPolicy.progress(Long.MAX_VALUE, Long.MAX_VALUE))
    }

    @Test
    fun replayKeepsStatsAndCoversInsideEverySupportedSize() {
        for (width in listOf(250, 279, 280, 320, 359, 360, 500, 704)) {
            for (height in listOf(110, 128, 160, 200, 240, 328)) {
                val geometry = WidgetLayoutPolicy.replay(WidgetSize(width, height))
                assertTrue(geometry.covers >= 1)
                assertTrue(geometry.artworkHeightDp <= geometry.contentHeightDp)
                assertTrue(geometry.contentHeightDp >= 58)
                assertTrue(geometry.valueSp >= 24)
                assertTrue(geometry.metricsHeightDp + (if (geometry.showCaption) 18 else 0) <= geometry.contentHeightDp)
                assertTrue(geometry.timeWidthDp > geometry.playsWidthDp)
                assertEquals(width, geometry.statsWidthDp + geometry.artworkWidthDp + 12 + geometry.paddingDp * 2)
                assertEquals(height, geometry.contentHeightDp + 20 + geometry.bodyGapDp + geometry.paddingDp * 2)
                assertTrue(geometry.statsWidthDp >= 144)
                assertTrue(geometry.brandTextWidthDp + 22 + 86 + 8 + geometry.paddingDp * 2 <= width)
            }
        }
        assertEquals(1, WidgetLayoutPolicy.replay(WidgetSize(250, 110)).covers)
        assertEquals(2, WidgetLayoutPolicy.replay(WidgetSize(300, 160)).covers)
        assertEquals(3, WidgetLayoutPolicy.replay(WidgetSize(320, 160)).covers)
        assertEquals(3, WidgetLayoutPolicy.replay(WidgetSize(400, 160)).covers)
        assertTrue(WidgetLayoutPolicy.replay(WidgetSize(320, 180)).valueSp >= 35)
        val expanded = WidgetLayoutPolicy.replay(WidgetSize(500, 240))
        val normal = WidgetLayoutPolicy.replay(WidgetLayoutPolicy.replayDefault)
        assertTrue(expanded.coverDp > normal.coverDp)
        assertTrue(expanded.valueSp > normal.valueSp)
    }

    @Test
    fun replayTimeAndDeltaLabelsMatchTheInAppRecapFormat() {
        assertEquals("0m", WidgetLayoutPolicy.listeningTime(0))
        assertEquals("48m", WidgetLayoutPolicy.listeningTime(48 * 60L * 1000L))
        assertEquals("1h", WidgetLayoutPolicy.listeningTime(3_600_000))
        assertEquals("1h 5m", WidgetLayoutPolicy.listeningTime(65 * 60L * 1000L))
        assertEquals("0m", WidgetLayoutPolicy.listeningTime(-5))
        assertEquals("+10%", WidgetLayoutPolicy.percentLabel(10))
        assertEquals("-5%", WidgetLayoutPolicy.percentLabel(-5))
        assertEquals("0%", WidgetLayoutPolicy.percentLabel(0))
    }

    @Test
    fun replayArtworkTintPicksReadableForegrounds() {
        val light = ReplayPalette.artwork(0xFFF1D9C0.toInt())
        assertEquals(0xFF000000.toInt(), light.foreground)
        assertEquals(0x13000000, light.border)
        val dark = ReplayPalette.artwork(0xFF1F3D1F.toInt())
        assertEquals(0xFFFFFFFF.toInt(), dark.foreground)
        assertEquals(0x13FFFFFF, dark.border)
        assertEquals(0xFFF1F0EB.toInt(), ReplayPalette.NIGHT.foreground)
        assertEquals(0xFFE3F369.toInt(), ReplayPalette.NIGHT.positive)
    }

    @Test
    fun replayAllocatesRealCoverCountsAndMoreRoomForDurationLabels() {
        val minimum = WidgetLayoutPolicy.replay(WidgetSize(250, 110))
        assertTrue(minimum.timeWidthDp >= 80)
        val fewerCovers = WidgetLayoutPolicy.replay(WidgetSize(360, 160), 1)
        val threeCovers = WidgetLayoutPolicy.replay(WidgetSize(360, 160), 3)
        assertEquals(1, fewerCovers.covers)
        assertTrue(fewerCovers.timeWidthDp > threeCovers.timeWidthDp)
        val empty = WidgetLayoutPolicy.replay(WidgetSize(250, 110), 0, false)
        assertEquals(0, empty.covers)
        assertTrue(empty.timeWidthDp > 0 && empty.playsWidthDp > 0)
        assertTrue(empty.showCaption)
        assertTrue(empty.metricsHeightDp + 18 <= empty.contentHeightDp)
        assertTrue(empty.sleeves().isEmpty())
    }

    @Test
    fun replaySleevesOverlapWithoutClippingAndKeepTheTopAlbumInFront() {
        for (width in listOf(250, 280, 320, 400, 500, 704)) {
            for (height in listOf(110, 128, 160, 240, 328)) {
                for (count in 0..3) {
                    val geometry = WidgetLayoutPolicy.replay(WidgetSize(width, height), count)
                    val sleeves = geometry.sleeves()
                    assertEquals(geometry.covers, sleeves.size)
                    if (sleeves.isEmpty()) continue
                    assertEquals(0, sleeves.last().index)
                    assertEquals(geometry.coverDp.toFloat(), sleeves.last().sideDp, 0.01f)
                    assertEquals(0f, sleeves.last().rotation, 0.01f)
                    for ((sleeve, mirrored) in sleeves.zip(geometry.sleeves(rtl = true))) {
                        val radians = Math.toRadians(sleeve.rotation.toDouble())
                        val halfExtent = sleeve.sideDp * (abs(cos(radians)) + abs(sin(radians))) / 2
                        val centerX = sleeve.leftDp + sleeve.sideDp / 2
                        val centerY = sleeve.topDp + sleeve.sideDp / 2
                        assertTrue(centerX - halfExtent >= 0)
                        assertTrue(centerX + halfExtent <= geometry.artworkWidthDp)
                        assertTrue(centerY - halfExtent >= 0)
                        assertTrue(centerY + halfExtent <= geometry.artworkHeightDp)
                        assertEquals(geometry.artworkWidthDp.toFloat(),
                            sleeve.leftDp + mirrored.leftDp + sleeve.sideDp, 0.01f)
                        assertEquals(-sleeve.rotation, mirrored.rotation, 0.01f)
                    }
                    for ((back, front) in sleeves.zipWithNext()) {
                        assertTrue(back.leftDp < front.leftDp)
                        assertTrue(back.leftDp + back.sideDp > front.leftDp)
                    }
                }
            }
        }
    }

    @Test
    fun replayOrbitAndEveryContourStayInsideTheArtworkCanvas() {
        for (width in listOf(250, 280, 320, 400, 500, 704)) {
            for (height in listOf(110, 128, 160, 240, 328)) {
                for (count in 0..3) for (hasData in listOf(false, true)) {
                    val geometry = WidgetLayoutPolicy.replay(WidgetSize(width, height), count, hasData)
                    val artWidth = geometry.artworkWidthDp.toFloat()
                    val artHeight = geometry.artworkHeightDp.toFloat()
                    val orbit = ReplayOrbitGeometry.fit(artWidth, artHeight)
                    assertTrue(orbit.scale > 0f && orbit.scale <= 1f)
                    assertEquals(artWidth * 0.54f, orbit.radiusXDp, 0.01f)
                    assertEquals(artHeight * 0.34f, orbit.radiusYDp, 0.01f)
                    val radians = Math.toRadians(ReplayOrbitGeometry.ROTATION.toDouble())
                    val strokes = listOf(0f to ReplayOrbitGeometry.STROKE_DP) +
                        ReplayOrbitGeometry.CONTOUR_INSETS_DP.map { it to ReplayOrbitGeometry.CONTOUR_STROKE_DP }
                    for ((inset, stroke) in strokes) {
                        val radiusX = (orbit.radiusXDp + inset) * orbit.scale
                        val radiusY = (orbit.radiusYDp + inset) * orbit.scale
                        val halfStroke = stroke * orbit.scale / 2
                        val halfWidth = Math.hypot(radiusX * cos(radians), radiusY * sin(radians)) + halfStroke
                        val halfHeight = Math.hypot(radiusX * sin(radians), radiusY * cos(radians)) + halfStroke
                        assertTrue(artWidth / 2 - halfWidth >= ReplayOrbitGeometry.PADDING_DP - 0.001)
                        assertTrue(artHeight / 2 - halfHeight >= ReplayOrbitGeometry.PADDING_DP - 0.001)
                        // Include density scaling and the 360px cap used by the bitmap renderer.
                        for (density in listOf(0.75f, 1f, 1.5f, 2f, 3f, 4f)) {
                            val pixelsPerDp = minOf(density, 360f / maxOf(artWidth, artHeight))
                            assertTrue((artWidth / 2 - halfWidth) * pixelsPerDp >= 1)
                            assertTrue((artHeight / 2 - halfHeight) * pixelsPerDp >= 1)
                            assertTrue((artWidth / 2 + halfWidth) * pixelsPerDp <= (artWidth * pixelsPerDp).roundToInt() - 1)
                            assertTrue((artHeight / 2 + halfHeight) * pixelsPerDp <= (artHeight * pixelsPerDp).roundToInt() - 1)
                        }
                    }
                }
            }
        }
    }

    @Test
    fun replayMissingArtworkAndEmptyStatesKeepTheSameReadableMetricGrid() {
        for (width in listOf(250, 320, 400, 704)) for (height in listOf(110, 160, 240, 328)) {
            for (hasData in listOf(false, true)) {
                val geometry = WidgetLayoutPolicy.replay(WidgetSize(width, height), 0, hasData)
                assertEquals(0, geometry.covers)
                assertTrue(geometry.statsWidthDp >= 144)
                assertTrue(geometry.artworkHeightDp <= geometry.contentHeightDp)
                assertTrue(geometry.metricsHeightDp + (if (geometry.showCaption) 18 else 0) <= geometry.contentHeightDp)
            }
        }
    }

    @Test
    fun replayAcidAndNightUseTheInAppNeonIdentity() {
        assertEquals(0xFFE3F369.toInt(), ReplayPalette.ACID.background)
        assertEquals(0xFF0A0A0A.toInt(), ReplayPalette.ACID.value)
        assertEquals(0xFFFF5636.toInt(), ReplayPalette.ACID.accent)
        assertEquals(ReplayPalette.ACID.background, ReplayPalette.NIGHT.value)
        assertEquals(ReplayPalette.SIGNAL.background, ReplayPalette.NIGHT.accent)
        assertEquals(ReplayPalette.ACID.positive, ReplayPalette.ACID.negative)
    }

    @Test
    fun replayColoredSurfacesKeepSmallLabelsReadableAtBothGradientEnds() {
        val palettes = mutableListOf(ReplayPalette.NIGHT, ReplayPalette.SIGNAL, ReplayPalette.ACID)
        for (r in 0..255 step 51) for (g in 0..255 step 51) for (b in 0..255 step 51) {
            palettes.add(ReplayPalette.artwork(0xFF000000.toInt() or (r shl 16) or (g shl 8) or b))
        }
        for (palette in palettes) for (surface in listOf(palette.background, palette.shaded)) {
            assertTrue(ReplayPalette.contrast(palette.foreground, surface) >= 4.5f)
            assertTrue(ReplayPalette.contrast(palette.secondary, surface) >= 4.5f)
            assertTrue(ReplayPalette.contrast(palette.positive, surface) >= 4.5f)
            assertTrue(ReplayPalette.contrast(palette.negative, surface) >= 4.5f)
            assertTrue(ReplayPalette.contrast(palette.value, surface) >= 4.5f)
        }
        val dark = ReplayPalette.artwork(0xFF1F3D1F.toInt())
        assertTrue(ReplayPalette.luminance(dark.shaded) < ReplayPalette.luminance(dark.background))
    }
}
