package org.technoserve.farmcollector.ui.screens

import android.app.Application
import androidx.compose.runtime.Composable
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertTextEquals
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.navigation.compose.rememberNavController
import androidx.test.core.app.ApplicationProvider
import org.junit.Rule
import org.junit.Test
import org.technoserve.farmcollector.utils.Language
import org.technoserve.farmcollector.utils.LanguageViewModel

class HomeKtTest{
    @get:Rule
    val composeTestRule = createComposeRule()

    private val application = ApplicationProvider.getApplicationContext() as Application


//    @Test
//    fun home_displaysAppIcon_andTitle() {
//        composeTestRule.setContent {
//            Home(
//                navController = rememberNavController(),
//                languageViewModel = LanguageViewModel(application = application),
//                languages = listOf(Language("en", "English"), Language("es", "Spanish"))
//            )
//        }
//
//        composeTestRule.onNodeWithContentDescription("App Icon")
//            .assertIsDisplayed()
//
//        composeTestRule.onNodeWithText("App Name")
//            .assertIsDisplayed()
//            .assertTextEquals("MyApp") // Replace with the actual app name if different
//    }
//
//    @Composable
//    @Test
//    fun Home_getStartedButton_navigatesToSiteList() {
//        val navController = rememberNavController()
//
//        composeTestRule.setContent {
//            Home(
//                navController = navController,
//                languageViewModel = LanguageViewModel(application = application),
//                languages = listOf(Language("en", "English"), Language("es", "Spanish"))
//            )
//        }
//
//        composeTestRule.onNodeWithText("Get Started").performClick()
//
//        // Check that navigation to "siteList" has occurred
//        assert(navController.currentDestination?.route == "siteList")
//    }

    @Test
    fun home_displaysDeveloperInfoCorrectly() {
        composeTestRule.setContent {
            Home(
                navController = rememberNavController(),
                languageViewModel = LanguageViewModel(application = application),
                languages = listOf(Language("en", "English"), Language("es", "Spanish"))
            )
        }

        composeTestRule.onNodeWithText("Developed by")
            .assertIsDisplayed()
        composeTestRule.onNodeWithContentDescription("TNS Labs Logo")
            .assertIsDisplayed()
    }

}