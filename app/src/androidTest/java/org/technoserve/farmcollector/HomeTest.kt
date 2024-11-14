package org.technoserve.farmcollector

//import android.app.Application
//import androidx.compose.runtime.Composable
//import androidx.compose.ui.test.*
//import androidx.compose.ui.test.junit4.createComposeRule
//import androidx.navigation.compose.rememberNavController
//import androidx.test.core.app.ApplicationProvider
//import androidx.test.ext.junit.runners.AndroidJUnit4
//import org.junit.Before
//import org.junit.Rule
//import org.junit.Test
//import org.junit.runner.RunWith
//import org.technoserve.farmcollector.ui.screens.Home
//import org.technoserve.farmcollector.utils.Language
//import org.technoserve.farmcollector.utils.LanguageViewModel
//
//@RunWith(AndroidJUnit4::class)
//class HomeTest {
//    @JvmField
//    @get:Rule
//    val composeTestRule = createComposeRule()
//
//    private lateinit var application: Application
//    private lateinit var languageViewModel: LanguageViewModel
//    private val testLanguages = listOf(Language("en", "English"), Language("es", "Spanish"))
//
//    @Before
//    fun setUp() {
//        application = ApplicationProvider.getApplicationContext()
//        languageViewModel = LanguageViewModel(application)
//    }
//
//    @Test
//    fun homeScreen_whenLaunched_displaysAppIconAndTitle() {
//        // Arrange & Act
//        setHomeContent()
//
//        // Assert
//        composeTestRule.onNodeWithContentDescription("App Icon")
//            .assertExists()
//            .assertIsDisplayed()
//
//        composeTestRule.onNodeWithText("MyApp") // Replace with actual app name
//            .assertExists()
//            .assertIsDisplayed()
//    }
//
//    @Composable
//    @Test
//    fun GetStartedButton_whenClicked_navigatesToSiteList() {
//        // Arrange
//        val navController = rememberNavController()
//
//        composeTestRule.setContent {
//            Home(
//                navController = navController,
//                languageViewModel = languageViewModel,
//                languages = testLanguages
//            )
//        }
//
//        // Act
//        composeTestRule.onNodeWithText("Get Started")
//            .assertExists()
//            .assertIsDisplayed()
//            .performClick()
//
//        // Assert
//        composeTestRule.waitForIdle()
//        assert(navController.currentDestination?.route == "siteList")
//    }
//
//    @Test
//    fun developerInfo_isDisplayedCorrectly() {
//        // Arrange & Act
//        setHomeContent()
//
//        // Assert
//        composeTestRule.onNodeWithText("Developed by")
//            .assertExists()
//            .assertIsDisplayed()
//
//        composeTestRule.onNodeWithContentDescription("TNS Labs Logo")
//            .assertExists()
//            .assertIsDisplayed()
//    }
//
//    private fun setHomeContent() {
//        composeTestRule.setContent {
//            Home(
//                navController = rememberNavController(),
//                languageViewModel = languageViewModel,
//                languages = testLanguages
//            )
//        }
//        composeTestRule.waitForIdle()
//    }
//}