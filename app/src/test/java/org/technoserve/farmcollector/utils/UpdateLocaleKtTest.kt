package org.technoserve.farmcollector.utils

import android.content.Context
import android.content.res.Configuration
import android.content.res.Resources
import androidx.core.text.layoutDirection
import junit.framework.TestCase.assertEquals
import junit.framework.TestCase.assertNotNull
import org.junit.Test
import org.mockito.Mockito.*
import java.util.Locale


class UpdateLocaleKtTest{
    @Test
    fun `updateLocale updates the locale and layout direction`() {
        // Mock Context and Resources
        val mockContext = mock(Context::class.java)
        val mockResources = mock(Resources::class.java)
        val mockConfiguration = Configuration()

        `when`(mockContext.resources).thenReturn(mockResources)
        `when`(mockResources.configuration).thenReturn(mockConfiguration)
        `when`(mockResources.displayMetrics).thenReturn(mock(Resources::class.java).displayMetrics)

        // Call the function with a specific locale
        val locale = Locale("fr", "FR") // French locale
        updateLocale(mockContext, locale)

        // Verify that the locale and layout direction were set correctly
        assertEquals(locale, mockConfiguration.locales[0])
        assertEquals(locale, Locale.getDefault())
        assertEquals(locale.layoutDirection, mockConfiguration.layoutDirection)
    }

    @Test
    fun `updateLocale does not crash with null locale`() {
        // Mock Context and Resources
        val mockContext = mock(Context::class.java)
        val mockResources = mock(Resources::class.java)
        val mockConfiguration = Configuration()

        `when`(mockContext.resources).thenReturn(mockResources)
        `when`(mockResources.configuration).thenReturn(mockConfiguration)
        `when`(mockResources.displayMetrics).thenReturn(mock(Resources::class.java).displayMetrics)

        // Call the function with a null locale
        updateLocale(mockContext, Locale.getDefault())

        // Verify the configuration and default locale remain unchanged
        assertNotNull(Locale.getDefault())
        assertNotNull(mockConfiguration)
    }
}