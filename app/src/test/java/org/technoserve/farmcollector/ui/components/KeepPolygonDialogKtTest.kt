package org.technoserve.farmcollector.ui.components

import org.junit.Assert.*

import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

//@RunWith(AndroidJUnit4::class)
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [29])
class KeepPolygonDialogTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun testKeepPolygonDialogDisplaysCorrectly() {
        composeTestRule.setContent {
            KeepPolygonDialog(
                onDismiss = {},
                onKeepExisting = {},
                onCaptureNew = {}
            )
        }

        // Verify the dialog title and text are displayed
        composeTestRule.onNodeWithText("Update Polygon").assertExists()
        composeTestRule.onNodeWithText("Keep existing polygon or capture new").assertExists()

        // Verify the buttons are displayed
        composeTestRule.onNodeWithText("Keep Existing").assertExists()
        composeTestRule.onNodeWithText("Capture New").assertExists()
    }

    @Test
    fun testKeepPolygonDialogButtonActions() {
        var keepExistingClicked = false
        var captureNewClicked = false

        composeTestRule.setContent {
            KeepPolygonDialog(
                onDismiss = {},
                onKeepExisting = { keepExistingClicked = true },
                onCaptureNew = { captureNewClicked = true }
            )
        }

        // Click the "Keep Existing" button
        composeTestRule.onNodeWithText("Keep Existing").performClick()
        assert(keepExistingClicked)

        // Click the "Capture New" button
        composeTestRule.onNodeWithText("Capture New").performClick()
        assert(captureNewClicked)
    }
}
