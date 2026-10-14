package com.mossapps.flick.widgets

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class WidgetReplayStateTest {
    @Test
    fun staleOrPartiallyPublishedDaysHideStatisticsAndCovers() {
        for (day in listOf(null, "", "2026-10-13")) {
            val state = WidgetReplayState.snapshot(day, "2026-10-14", 90_000, 4, 20, 10, listOf("cover"))
            assertFalse(state.fresh)
            assertFalse(state.hasData)
            assertEquals(0L, state.timeMs)
            assertEquals(0, state.plays)
            assertEquals(WidgetReplayState.UNKNOWN_DELTA, state.timeDelta)
            assertTrue(state.covers.isEmpty())
        }
    }

    @Test
    fun currentDayPreservesRealStatisticsButEmptySnapshotsClearDecorations() {
        val state = WidgetReplayState.snapshot("2026-10-14", "2026-10-14", 90_000, 4, 20, 10, listOf("cover"))
        assertTrue(state.hasData)
        assertEquals(4, state.plays)
        assertEquals(20, state.timeDelta)
        assertEquals(listOf("cover"), state.covers)
        val empty = WidgetReplayState.snapshot("2026-10-14", "2026-10-14", -1, -1, 20, 10, listOf("cover"))
        assertTrue(empty.fresh)
        assertFalse(empty.hasData)
        assertEquals(WidgetReplayState.UNKNOWN_DELTA, empty.playsDelta)
        assertTrue(empty.covers.isEmpty())
    }
}
