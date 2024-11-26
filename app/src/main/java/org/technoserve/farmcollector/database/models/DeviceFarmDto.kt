package org.technoserve.farmcollector.database.models

data class DeviceFarmDto(
    val device_id: String,
    val collection_site: CollectionSiteDto,
    val farms: List<FarmDetailDto>
)
