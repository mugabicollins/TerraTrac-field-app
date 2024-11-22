package org.technoserve.farmcollector.map

data class LocationState(
    val latitude: Double = 0.0,
    val longitude: Double = 0.0,
    val isLoading: Boolean = false,
    val error: String? = null,
    val isUsingGPS: Boolean = true,
    val accuracy: Float = 0f
)
