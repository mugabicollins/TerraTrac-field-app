package org.technoserve.farmcollector

import androidx.compose.ui.test.junit4.createAndroidComposeRule
import org.junit.Assert.*

import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.technoserve.farmcollector.ui.screens.Greeting

@RunWith(AndroidJUnit4::class)
class GreetingTestKtTest {

    @get:Rule
    val composeTestRule = createAndroidComposeRule<MainActivity>()

    @Test
    fun greeting_displaysCorrectText() {
        // Set the composable to test
        composeTestRule.setContent {
            Greeting(name = "Emmanuel")
        }

        // Assert the text is displayed correctly
        composeTestRule
            .onNodeWithText("Hello, Emmanuel!")
            .assertExists("The Greeting composable did not display the expected text.")
    }
}
