package org.technoserve.farmcollector

//import android.app.Application
//import androidx.compose.ui.test.junit4.createAndroidComposeRule
//import androidx.compose.ui.test.onNodeWithText
//import androidx.compose.ui.test.performClick
//import androidx.test.core.app.ApplicationProvider
//import androidx.test.ext.junit.runners.AndroidJUnit4
//import org.junit.Rule
//import org.junit.Test
//import org.junit.runner.RunWith
//import org.technoserve.farmcollector.ui.screens.Home
//import org.technoserve.farmcollector.utils.Language
//import org.technoserve.farmcollector.utils.LanguageViewModel
//
//@RunWith(AndroidJUnit4::class)
//class HomeIntegrationTest {
//    @get:Rule
//    val composeTestRule = createAndroidComposeRule<MainActivity>()
//
//    private val application = ApplicationProvider.getApplicationContext() as Application
//
//    @Test
//    fun home_languageSelection_updatesCorrectly() {
////        val navController = TestNavHostController(composeTestRule.activity)
//        val languageViewModel = LanguageViewModel(application)
////
////        composeTestRule.setContent {
////            Home(
////                navController = navController,
////                languageViewModel = languageViewModel,
////                languages = listOf(Language("en", "English"), Language("es", "Spanish"))
////            )
////        }
//
//        // Simulate a click on the language selector
//        composeTestRule.onNodeWithText("Select Language").performClick()
//
//        // Assert that languages are displayed
//        composeTestRule.onNodeWithText("English").assertExists()
//        composeTestRule.onNodeWithText("Spanish").assertExists()
//
//        // Select a language and verify it updates the view model
//        composeTestRule.onNodeWithText("Spanish").performClick()
//        assert(languageViewModel.currentLanguage.value.displayName == "Spanish")
//    }
//}