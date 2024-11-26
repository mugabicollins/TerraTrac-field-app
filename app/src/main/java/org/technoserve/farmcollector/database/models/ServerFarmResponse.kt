package org.technoserve.farmcollector.database.models

data class ServerFarmResponse(
    val device_id: String,
    val collection_site: CollectionSiteRestore,
    val farms: List<FarmRestore>
)
