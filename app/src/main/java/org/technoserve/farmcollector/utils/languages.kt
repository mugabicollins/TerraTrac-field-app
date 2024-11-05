package org.technoserve.farmcollector.utils

/**
 * This class defines the language with language code and display name
 */

data class Language(val code: String, val displayName: String)

val languages = listOf(
    Language("en", "English"),
    Language("fr", "French"),
    Language("es", "Spanish"),
    Language("am", "Amharic"),
    Language("om", "Oromo"),
    Language("sw", "Swahili")
)

