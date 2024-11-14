package org.technoserve.farmcollector

import androidx.annotation.StringRes
import androidx.compose.ui.test.*
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.navigation.testing.TestNavHostController
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import junit.framework.TestCase.assertEquals
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito.mock
import org.mockito.Mockito.verify
import org.technoserve.farmcollector.ui.screens.Home
import org.technoserve.farmcollector.utils.Language
import org.technoserve.farmcollector.utils.LanguageViewModel

@RunWith(AndroidJUnit4::class)
class HomeTest {
    @get:Rule
    val composeTestRule = createComposeRule()

    private lateinit var navController: TestNavHostController
    private lateinit var languageViewModel: LanguageViewModel
    private val testLanguages = listOf(
        Language("en", "English"),
        Language("es", "Spanish")
    )

    @Before
    fun setup() {
        navController = TestNavHostController(InstrumentationRegistry.getInstrumentation().targetContext)
        languageViewModel = mock(LanguageViewModel::class.java)
    }

    @Test
    fun homeScreen_displaysAppName() {
        composeTestRule.setContent {
            Home(
                navController = navController,
                languageViewModel = languageViewModel,
                languages = testLanguages
            )
        }

        composeTestRule
            .onNodeWithText(getResourceString(R.string.app_name))
            .assertExists()
            .assertIsDisplayed()
    }

    @Test
    fun homeScreen_displaysGetStartedButton() {
        composeTestRule.setContent {
            Home(
                navController = navController,
                languageViewModel = languageViewModel,
                languages = testLanguages
            )
        }

        composeTestRule
            .onNodeWithText(getResourceString(R.string.get_started))
            .assertExists()
            .assertIsDisplayed()
            .assertHasClickAction()
    }

    @Test
    fun homeScreen_clickGetStartedNavigatesToSiteList() {
        composeTestRule.setContent {
            Home(
                navController = navController,
                languageViewModel = languageViewModel,
                languages = testLanguages
            )
        }

        composeTestRule
            .onNodeWithText(getResourceString(R.string.get_started))
            .performClick()

        // Verify navigation occurred
        assertEquals("siteList", navController.currentDestination?.route)
    }

    @Test
    fun homeScreen_displaysAppIntro() {
        composeTestRule.setContent {
            Home(
                navController = navController,
                languageViewModel = languageViewModel,
                languages = testLanguages
            )
        }

        composeTestRule
            .onNodeWithText(getResourceString(R.string.app_intro))
            .assertExists()
            .assertIsDisplayed()
    }

    @Test
    fun homeScreen_displaysDeveloperInfo() {
        composeTestRule.setContent {
            Home(
                navController = navController,
                languageViewModel = languageViewModel,
                languages = testLanguages
            )
        }

        composeTestRule
            .onNodeWithText(getResourceString(R.string.developed_by))
            .assertExists()
            .assertIsDisplayed()
    }

    @Test
    fun homeScreen_displaysLanguageSelector() {
        composeTestRule.setContent {
            Home(
                navController = navController,
                languageViewModel = languageViewModel,
                languages = testLanguages
            )
        }

        // Verify LanguageSelector is displayed
        // Note: This assumes LanguageSelector has a testTag. You might need to add one.
        composeTestRule
            .onNodeWithTag("language_selector")
            .assertExists()
            .assertIsDisplayed()
    }

    @Test
    fun homeScreen_displaysAppIcon() {
        composeTestRule.setContent {
            Home(
                navController = navController,
                languageViewModel = languageViewModel,
                languages = testLanguages
            )
        }

        composeTestRule
            .onNodeWithContentDescription("app_icon")
            .assertExists()
            .assertIsDisplayed()
    }

    @Test
    fun homeScreen_displaysLabsLogo() {
        composeTestRule.setContent {
            Home(
                navController = navController,
                languageViewModel = languageViewModel,
                languages = testLanguages
            )
        }

        composeTestRule
            .onNodeWithContentDescription("tns_labs")
            .assertExists()
            .assertIsDisplayed()
    }

    private fun getResourceString(@StringRes resourceId: Int): String {
        return InstrumentationRegistry.getInstrumentation()
            .targetContext.resources.getString(resourceId)
    }
}