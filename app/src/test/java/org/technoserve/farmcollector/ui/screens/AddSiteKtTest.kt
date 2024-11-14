package org.technoserve.farmcollector.ui.screens

import android.os.Build
import androidx.compose.ui.test.junit4.createComposeRule
import org.junit.Assert.*

import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito.mock
import org.mockito.Mockito.`when`
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.shadows.ShadowBuild

data class SiteFormState(
    val name: String,
    val agentName: String,
    val phoneNumber: String,
    val email: String,
    val village: String,
    val district: String
)

fun validateForm(formState: SiteFormState): Boolean {
    // Extract values from the SiteFormState object
    val name = formState.name
    val agentName = formState.agentName
    val phoneNumber = formState.phoneNumber
    val email = formState.email
    val village = formState.village
    val district = formState.district

    // Validate each field as before
    val isNameValid = name.isNotBlank()
    val isAgentNameValid = agentName.isNotBlank()
    val isPhoneNumberValid = phoneNumber.isNotBlank() && isValidPhoneNumber(phoneNumber)
    val isEmailValid = email.isNotBlank() && android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches()
    val isVillageValid = village.isNotBlank()
    val isDistrictValid = district.isNotBlank()

    // Return true if all validations pass
    return isNameValid && isAgentNameValid && isPhoneNumberValid && isEmailValid && isVillageValid && isDistrictValid
}

// Helper function to validate phone number format (example validation)
fun isValidPhoneNumber(phoneNumber: String): Boolean {
    val phoneRegex = "^\\+?[0-9]{10,15}\$"
    return phoneNumber.matches(phoneRegex.toRegex())
}

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [29])
class AddSiteKtTest {

    @Before
    fun setUp() {
        ShadowBuild.setFingerprint("mocked-fingerprint")
    }

    @After
    fun tearDown() {
    }

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun testValidateForm() {
        val formState = SiteFormState(
            name = "Farm Name",
            agentName = "Agent Name",
            phoneNumber = "123456789",
            email = "test@example.com",
            village = "Village Name",
            district = "District Name"
        )

        val result = validateForm(formState)

        // Assert that the form is valid
        assertTrue(result)
    }

    @Test
    fun testInvalidPhoneNumber() {
        val formState = SiteFormState(
            name = "Farm Name",
            agentName = "Agent Name",
            phoneNumber = "12345",  // Invalid phone number
            email = "test@example.com",
            village = "Village Name",
            district = "District Name"
        )

        val result = validateForm(formState)

        // Assert that the form is invalid
        assertFalse(result)
    }
}
