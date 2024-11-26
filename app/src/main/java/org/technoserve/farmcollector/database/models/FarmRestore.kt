package org.technoserve.farmcollector.database.models

data class FarmRestore(
    val id: Long,
    val remote_id: String,
    val farmer_name: String,
    val member_id: String?,
    val size: Double,
    val agent_name: String?,
    val village: String,
    val district: String,
    val latitude: Double,
    val longitude: Double,
    val coordinates: List<List<Double>>,
    val accuracyArray: List<Float?>?,
    val created_at: String,
    val updated_at: String,
    val site_id: Long
)
