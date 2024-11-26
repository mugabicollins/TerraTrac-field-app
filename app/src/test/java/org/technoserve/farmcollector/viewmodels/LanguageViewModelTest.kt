package org.technoserve.farmcollector.viewmodels

import android.content.Context
import android.content.SharedPreferences
import android.content.res.Resources
import android.content.res.Configuration
import androidx.arch.core.executor.testing.InstantTaskExecutorRule
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.*
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito
import org.mockito.Mockito.mock
import org.mockito.kotlin.whenever
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.technoserve.farmcollector.database.models.Language
import java.util.Locale


@RunWith(RobolectricTestRunner::class)
@Config(sdk = [33])
class LanguageViewModelTest{
    @get:Rule
    val instantTaskExecutorRule = InstantTaskExecutorRule()

    private lateinit var languageViewModel: LanguageViewModel
    private lateinit var context: Context
    private lateinit var sharedPreferences: SharedPreferences
    private lateinit var resources: Resources

    @Before
    fun setUp() {
        // Mocking Context and SharedPreferences
        context = mock()
        sharedPreferences = mock()
        resources = mock()

        // Mocking shared preferences return value
        whenever(sharedPreferences.getString("preferred_language", Locale.getDefault().language)).thenReturn("en")
        whenever(context.getSharedPreferences("settings", Context.MODE_PRIVATE)).thenReturn(sharedPreferences)
        whenever(context.resources).thenReturn(resources)

        // Initializing the ViewModel
        languageViewModel = LanguageViewModel(ApplicationProvider.getApplicationContext())
    }

    @Test
    fun testGetDefaultLanguage() {
        // Given that the preferred language is "en"
        val defaultLanguage = languageViewModel.getDefaultLanguage()

        // Then it should return the "en" language
        assertEquals("en", defaultLanguage.code)
    }

    @Test
    fun testSavePreferredLanguage() {
        // Given a new language to save
        val newLanguage = Language("fr", "French")

        // When saving the new language
        languageViewModel.savePreferredLanguage(newLanguage)

        // Then SharedPreferences should store the new language
        Mockito.verify(sharedPreferences).edit().putString("preferred_language", "fr")
    }

    @Test
    fun testSelectLanguage() {
        // Given a language "fr" and a mock context
        val newLanguage = Language("fr", "French")
        val mockContext = mock<Context>()

        // When selecting the language
        languageViewModel.selectLanguage(newLanguage, mockContext)

        // Then currentLanguage should be updated
        assertEquals("fr", languageViewModel.currentLanguage.value.code)

        // And SharedPreferences should be updated with the new language
        Mockito.verify(sharedPreferences).edit().putString("preferred_language", "fr")
    }

    @Test
    fun testUpdateLocale() {
        // Given a mock context and locale
        val locale = Locale("fr")
        val mockContext = mock<Context>()
        val config = mock<Configuration>()

        // Mock the resources and configuration
        whenever(mockContext.resources).thenReturn(resources)
        whenever(resources.configuration).thenReturn(config)

        // When updating the locale
        languageViewModel.updateLocale(mockContext, locale)

        // Then it should set the locale on resources configuration
        Mockito.verify(resources.configuration).setLocale(locale)
        Mockito.verify(resources.configuration).setLayoutDirection(locale)
    }

    @Test
    fun testGetLocalizedLanguages() {
        // Given a mock context with language strings
        val context = ApplicationProvider.getApplicationContext<Context>()
        val languages = languageViewModel.getLocalizedLanguages(context)

        // Then the languages list should contain the predefined languages
        assertEquals(6, languages.size)
        assertTrue(languages.any { it.code == "en" })
        assertTrue(languages.any { it.code == "fr" })
    }
}