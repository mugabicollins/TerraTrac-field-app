package org.technoserve.farmcollector.ui.components

import androidx.compose.ui.test.assertIsNotEnabled
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Assert.*
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.testng.junit.JUnit4TestRunner

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [33])
class CustomPaginationControlsKtTest{

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun paginationDisplaysCorrectCurrentAndTotalPages() {
        val currentPage = 3
        val totalPages = 5

        composeTestRule.setContent {
            CustomPaginationControls(
                currentPage = currentPage,
                totalPages = totalPages,
                onPageChange = {}
            )
        }

        // Verify the displayed text for current and total pages
        composeTestRule.onNodeWithText("Page $currentPage of $totalPages").assertExists()
    }

    @Test
    fun previousButtonIsDisabledOnFirstPage() {
        composeTestRule.setContent {
            CustomPaginationControls(
                currentPage = 1,
                totalPages = 5,
                onPageChange = {}
            )
        }

        // Verify that the "Previous Page" button is disabled
        composeTestRule.onNodeWithContentDescription("Previous Page")
            .assertIsNotEnabled()
    }

    @Test
    fun nextButtonIsDisabledOnLastPage() {
        composeTestRule.setContent {
            CustomPaginationControls(
                currentPage = 5,
                totalPages = 5,
                onPageChange = {}
            )
        }

        // Verify that the "Next Page" button is disabled
        composeTestRule.onNodeWithContentDescription("Next Page")
            .assertIsNotEnabled()
    }

    @Test
    fun previousButtonTriggersOnPageChangeCorrectly() {
        var pageChangedTo = -1

        composeTestRule.setContent {
            CustomPaginationControls(
                currentPage = 3,
                totalPages = 5,
                onPageChange = { page -> pageChangedTo = page }
            )
        }

        // Click the "Previous Page" button
        composeTestRule.onNodeWithContentDescription("Previous Page")
            .performClick()

        // Verify the page changed to the correct value
        assert(pageChangedTo == 2)
    }

    @Test
    fun nextButtonTriggersOnPageChangeCorrectly() {
        var pageChangedTo = -1

        composeTestRule.setContent {
            CustomPaginationControls(
                currentPage = 3,
                totalPages = 5,
                onPageChange = { page -> pageChangedTo = page }
            )
        }

        // Click the "Next Page" button
        composeTestRule.onNodeWithContentDescription("Next Page")
            .performClick()

        // Verify the page changed to the correct value
        assert(pageChangedTo == 4)
    }

    @Test
    fun buttonsAreDisabledWhenOnlyOnePage() {
        composeTestRule.setContent {
            CustomPaginationControls(
                currentPage = 1,
                totalPages = 1,
                onPageChange = {}
            )
        }

        // Verify both "Previous Page" and "Next Page" buttons are disabled
        composeTestRule.onNodeWithContentDescription("Previous Page").assertIsNotEnabled()
        composeTestRule.onNodeWithContentDescription("Next Page").assertIsNotEnabled()
    }
}