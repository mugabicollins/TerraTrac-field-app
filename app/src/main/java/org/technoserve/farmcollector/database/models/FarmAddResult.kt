package org.technoserve.farmcollector.database.models

data class FarmAddResult(
    val success: Boolean,
    val message: String,
    val farm: Farm,
)
