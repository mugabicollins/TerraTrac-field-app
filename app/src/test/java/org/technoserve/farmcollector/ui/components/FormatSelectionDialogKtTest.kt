package org.technoserve.farmcollector.ui.components

import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import org.junit.Assert.*
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [33])
class FormatSelectionDialogKtTest{
    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun formatSelectionDialogDisplaysCorrectOptions() {
        // Set up the dialog
        composeTestRule.setContent {
            FormatSelectionDialog(
                onDismiss = {},
                onFormatSelected = {}
            )
        }

        // Verify the dialog title
        composeTestRule.onNodeWithText("Select File Format").assertExists()

        // Verify the format options are displayed
        composeTestRule.onNodeWithText("CSV").assertExists()
        composeTestRule.onNodeWithText("GeoJSON").assertExists()
    }

    @Test
    fun formatSelectionDialogSelectsCSV() {
        var selectedFormat = ""

        // Set up the dialog with a callback for format selection
        composeTestRule.setContent {
            FormatSelectionDialog(
                onDismiss = {},
                onFormatSelected = { format -> selectedFormat = format }
            )
        }

        // Select the CSV radio button
        composeTestRule.onNodeWithText("CSV").performClick()

        // Verify that the selected format is CSV
        assert(selectedFormat == "CSV")
    }

    @Test
    fun formatSelectionDialogSelectsGeoJSON() {
        var selectedFormat = ""

        // Set up the dialog with a callback for format selection
        composeTestRule.setContent {
            FormatSelectionDialog(
                onDismiss = {},
                onFormatSelected = { format -> selectedFormat = format }
            )
        }

        // Select the GeoJSON radio button
        composeTestRule.onNodeWithText("GeoJSON").performClick()

        // Verify that the selected format is GeoJSON
        assert(selectedFormat == "GeoJSON")
    }

    @Test
    fun formatSelectionDialogConfirmButtonCallsOnFormatSelected() {
        var selectedFormat = ""
        var dismissed = false

        // Set up the dialog with onDismiss and onFormatSelected callbacks
        composeTestRule.setContent {
            FormatSelectionDialog(
                onDismiss = { dismissed = true },
                onFormatSelected = { format -> selectedFormat = format }
            )
        }

        // Select the CSV format
        composeTestRule.onNodeWithText("CSV").performClick()

        // Click the confirm button
        composeTestRule.onNodeWithText("Confirm").performClick()

        // Verify that the format is selected and onDismiss is called
        assert(selectedFormat == "CSV")
        assert(dismissed)
    }

    @Test
    fun formatSelectionDialogDismissButtonCallsOnDismiss() {
        var dismissed = false

        // Set up the dialog with the onDismiss callback
        composeTestRule.setContent {
            FormatSelectionDialog(
                onDismiss = { dismissed = true },
                onFormatSelected = {}
            )
        }

        // Click the dismiss button
        composeTestRule.onNodeWithText("Cancel").performClick()

        // Verify that the dismiss callback is called
        assert(dismissed)
    }

    @Test
    fun formatSelectionDialogStartsWithCSVSelectedByDefault() {
        var selectedFormat = ""

        // Set up the dialog with a callback for format selection
        composeTestRule.setContent {
            FormatSelectionDialog(
                onDismiss = {},
                onFormatSelected = { format -> selectedFormat = format }
            )
        }

        // Verify that CSV is selected by default
        assert(selectedFormat == "CSV")
    }
}