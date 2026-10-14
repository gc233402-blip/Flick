package com.mossapps.flick.widgets

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class WidgetLaunchInboxTest {
    @Test
    fun coldStartTapIsDrainedOnceWhenDartIsReady() {
        val inbox = WidgetLaunchInbox()
        assertNull(inbox.offer("flickwidget://recap/open"))
        assertEquals("flickwidget://recap/open", inbox.attach())
        assertNull(inbox.attach())
    }

    @Test
    fun warmTapsAreDeliveredImmediately() {
        val inbox = WidgetLaunchInbox()
        assertNull(inbox.attach())
        assertEquals("flickwidget://queue/open", inbox.offer("flickwidget://queue/open"))
        assertNull(inbox.attach())
    }

    @Test
    fun ReattachmentKeepsTheLatestTapWithoutReplayingEarlierOnes() {
        val inbox = WidgetLaunchInbox()
        inbox.attach()
        inbox.detach()
        assertNull(inbox.offer("flickwidget://player/open"))
        assertNull(inbox.offer("flickwidget://recap/open"))
        assertEquals("flickwidget://recap/open", inbox.attach())
        assertNull(inbox.attach())
    }
}
