package org.technoserve.farmcollector.database

import org.technoserve.farmcollector.database.dao.FarmDAO
import org.technoserve.farmcollector.database.models.CollectionSiteDto
import org.technoserve.farmcollector.database.models.DeviceFarmDto
import org.technoserve.farmcollector.database.models.Farm
import org.technoserve.farmcollector.database.models.FarmDetailDto

/**
 * This file contains the information about the entities in the database including farms and collection sites
 */

fun List<Farm>.toDeviceFarmDtoList(deviceId: String, farmDao: FarmDAO): List<DeviceFarmDto> {
    return this.groupBy { it.siteId } // Group by siteId
        .mapNotNull { (siteId, farms) ->
            val collectionSite = farmDao.getCollectionSiteById(siteId) ?: return@mapNotNull null

            // Map the collection site details
            val collectionSiteDto = CollectionSiteDto(
                local_cs_id = collectionSite.siteId,
                name = collectionSite.name,
                agent_name = collectionSite.agentName,
                phone_number = collectionSite.phoneNumber,
                email = collectionSite.email,
                village = collectionSite.village,
                district = collectionSite.district
            )

            // Map the farms
            val farmDtos = farms.map { farm ->
                farm.remoteId.let { remoteId ->
                    // Ensure latitude and longitude are not empty or null before parsing
                    val latitude = farm.latitude.takeIf { it.isNotBlank() }?.toDoubleOrNull() ?: 0.0
                    val longitude =
                        farm.longitude.takeIf { it.isNotBlank() }?.toDoubleOrNull() ?: 0.0

                    FarmDetailDto(
                        remote_id = remoteId.toString(),
                        farmer_name = farm.farmerName,
                        member_id = farm.memberId,
                        village = farm.village,
                        district = farm.district,
                        size = farm.size,
                        latitude = latitude,
                        longitude = longitude,
                        coordinates = farm.coordinates?.map { listOf(it.first, it.second) }
                            ?: emptyList(),// Convert coordinate pairs
                        accuracies = farm.accuracyArray?.filterNotNull() // Filter out null values
                    )
                }
            }

            DeviceFarmDto(
                device_id = deviceId,
                collection_site = collectionSiteDto,
                farms = farmDtos
            )
        }
}



