package org.technoserve.farmcollector.database.models

data class ImportResult(
    val success: Boolean,
    val message: String,
    val importedFarms: List<Farm>,
    val duplicateFarms: List<String> = emptyList(),
    val farmsNeedingUpdate: List<Farm> = emptyList(),
    val invalidFarms: List<String> = emptyList()
)
