package org.technoserve.farmcollector.database.models

data class ParsedFarms(
    val validFarms: List<Farm>,
    val invalidFarms: List<String>
)