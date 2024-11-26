package org.technoserve.farmcollector.database.models

data class CollectionSiteRestore(
    val id: Long,
    val local_cs_id: Long,
    val name: String,
    val device_id: String,
    val agent_name: String,
    val email: String,
    val phone_number: String,
    val village: String,
    val district: String,
    val created_at: String,
    val updated_at: String
)
