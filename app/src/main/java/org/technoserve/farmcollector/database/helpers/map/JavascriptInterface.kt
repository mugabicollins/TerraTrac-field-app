package org.technoserve.farmcollector.database.helpers.map

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.webkit.JavascriptInterface
import androidx.lifecycle.lifecycleScope
import androidx.navigation.NavController
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.google.gson.JsonDeserializationContext
import com.google.gson.JsonDeserializer
import com.google.gson.JsonElement
import com.google.gson.reflect.TypeToken
import kotlinx.coroutines.launch
import org.joda.time.Instant
import org.json.JSONObject
import org.technoserve.farmcollector.MainActivity
import org.technoserve.farmcollector.database.AppDatabase
import org.technoserve.farmcollector.database.mappers.CoordinatesDeserializer
import org.technoserve.farmcollector.database.models.Farm
import org.technoserve.farmcollector.ui.screens.farms.addFarm
import java.lang.reflect.Type
import java.net.URLEncoder
import java.util.UUID

// JavaScript Interface
class JavaScriptInterface(
    private val context: Context,
    private val navController: NavController
) {




    fun parseCoordinates(coordinatesString: String): List<Pair<Double, Double>> {
        val result = mutableListOf<Pair<Double, Double>>()
        val cleanedString = coordinatesString.trim().removeSurrounding("\"", "").replace(" ", "")

        if (cleanedString.isNotEmpty()) {
            // Check if the coordinates are in polygon or point format
            val isPolygon = cleanedString.startsWith("[[") && cleanedString.endsWith("]]")
            val isPoint = cleanedString.startsWith("[") && cleanedString.endsWith("]") && !isPolygon

            if (isPolygon) {
                // Handle Polygon Format
                val pairs =
                    cleanedString
                        .removePrefix("[[")
                        .removeSuffix("]]")
                        .split("],[")
                        .map { it.split(",") }
                for (pair in pairs) {
                    if (pair.size == 2) {
                        try {
                            val lat = pair[1].toDouble()
                            val lon = pair[0].toDouble()
                            result.add(Pair(lat, lon))
                        } catch (e: NumberFormatException) {
                            println("Error parsing polygon coordinate pair: ${pair.joinToString(",")}")
                        }
                    }
                }
            } else if (isPoint) {
                // Handle Point Format
                val coords = cleanedString.removePrefix("[").removeSuffix("]").split(", ")
                if (coords.size == 2) {
                    try {
                        val lat = coords[1].toDouble()
                        val lon = coords[0].toDouble()
                        result.add(Pair(lat, lon))
                    } catch (e: NumberFormatException) {
                        println("Error parsing point coordinate pair: ${coords.joinToString(",")}")
                    }
                }
            } else {
                println("Unrecognized coordinates format: $coordinatesString")
            }
        }
        return result
    }

    @JavascriptInterface
    fun receivePlotData(plotDataJson: String) {
        Log.d("JavaScriptInterface", "Received Plot Data: $plotDataJson")

        try {
            // Parse the JSON string into a JSONObject
            val jsonObject = JSONObject(plotDataJson)

            // Extract the coordinates as a string
            val coordinatesArray = jsonObject.getJSONArray("coordinates")
            val coordinatesString = coordinatesArray.toString()

            // Use the parseCoordinates function to parse the coordinates
            val parsedCoordinates = parseCoordinates(coordinatesString)

            // Map the parsed data to the Farm object
            val farmData = Farm(
                siteId = jsonObject.getLong("siteId"),
                remoteId = UUID.fromString(jsonObject.getString("remoteId")),
                farmerPhoto = jsonObject.getString("farmerPhoto"),
                farmerName = jsonObject.getString("farmerName"),
                memberId = jsonObject.getString("memberId"),
                village = jsonObject.getString("village"),
                district = jsonObject.getString("district"),
                purchases = jsonObject.optString("purchases")?.toFloatOrNull(),
                size = jsonObject.getDouble("size").toFloat(),
                latitude = jsonObject.getString("latitude"),
                longitude = jsonObject.getString("longitude"),
                coordinates = parsedCoordinates,
                accuracyArray = jsonObject.optJSONArray("accuracyArray")?.let { array ->
                    List(array.length()) { i -> array.getDouble(i).toFloat() }
                },
                createdAt = Instant.parse(jsonObject.getString("createdAt")).millis,
                updatedAt = Instant.parse(jsonObject.getString("updatedAt")).millis,
                synced = false,
                scheduledForSync = false,
                needsUpdate = false
            )

            Log.d("JavaScriptInterface", "Parsed Plot Data: $farmData")

            val gson = Gson()
            val farmDataJson = gson.toJson(farmData)
            if(farmDataJson == null){
                Log.d("JavaScriptInterface", "Farm Data Json is null")
                navController.navigate("addFarm/${farmData.siteId}")
            }
            val encodedFarmDataJson = URLEncoder.encode(farmDataJson, "UTF-8") // Encode J SON to avoid special character issues

            // Navigate to the AddFarm composable on the main thread
            Handler(Looper.getMainLooper()).post {
               //navController.navigate("addFarm/${farmData.siteId}/${farmData}")

                navController.navigate("addFarm/${farmData.siteId}?plotDataJson=$encodedFarmDataJson")
                Log.d("Navigation", "Navigating to: addFarm/$${farmData.siteId}?plotDataJson=$encodedFarmDataJson")

                //  navController.navigate("addFarm/${farmData.siteId}")
            }

        } catch (e: Exception) {
            Log.e("JavaScriptInterface", "Error parsing plot data: ${e.message}", e)
        }
    }




    @JavascriptInterface
    fun getPlots(): String {
        return Gson().toJson(AppDatabase.getInstance(context).farmsDAO().getAllFarms())
    }

    fun parseCoordinatesVisualize(coordinatesString: String): List<Pair<Double, Double>> {
        if (coordinatesString.isEmpty()) return emptyList()

        // Regex to extract (lat, lng) pairs
        val regex = "\\(([^,]+), ([^\\)]+)\\)".toRegex()
        val matches = regex.findAll(coordinatesString)

        // Convert matches to List<Pair<Double, Double>>
        return matches.map { match ->
            val lat = match.groupValues[1].toDouble()
            val lng = match.groupValues[2].toDouble()
            Pair(lat, lng)
        }.toList()
    }

    @JavascriptInterface
    fun getSelectedPlot(id: Long): String {
        val farm = AppDatabase.getInstance(context).farmsDAO().getFarm(id)
        Log.d("Selected farm", "getSelectedPlot: $farm")

        if (farm != null) {
            // Parse coordinates if stored as a string
            val parsedCoordinates = parseCoordinatesVisualize(farm.coordinates.toString())

            Log.d("Selected Coordinates", "getSelectedPlot: $parsedCoordinates")

            // Create a new farm object with parsed coordinates
            val updatedFarm = farm.copy(coordinates = parsedCoordinates)

            // Return JSON representation
            return Gson().toJson(updatedFarm)
        } else {
            return "{}" // Return an empty JSON object if no farm is found
        }
    }


}