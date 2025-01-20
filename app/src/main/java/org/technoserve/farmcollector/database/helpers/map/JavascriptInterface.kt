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

//    @JavascriptInterface
//    fun receivePlotData(plotDataJson: String) {
//        try {
//            Log.d("JavaScriptInterface", "Received Plot Data: $plotDataJson")
//
////            // Parse the JSON string into a Farm object
////            val gson = GsonBuilder()
////                .registerTypeAdapter(
////                    object : TypeToken<Pair<Double?, Double?>>() {}.type,
////                    PairDeserializer()
////                )
////                .create()
////            val farmData = gson.fromJson(plotDataJson, Farm::class.java)
//
//            // Initialize farm data with default values
//            val farmData = Farm(
//                siteId = 0,
//                remoteId = UUID.fromString("e262ae0e-dcf9-41a4-8418-49971478e6e2"),
//                farmerPhoto = "",
//                farmerName = "",
//                memberId = "",
//                village = "",
//                district = "",
//                purchases = 0.0f,
//                size = 0.0f,
//                latitude = "0.0",
//                longitude = "0.0",
//                coordinates = emptyList(),
//                accuracyArray = emptyList(),
//                createdAt = System.currentTimeMillis(),
//                updatedAt = System.currentTimeMillis(),
//            )
//
//
//
//
//            Log.d("JavaScriptInterface", "Parsed Farm Data: $farmData")
//
////            // Validate critical fields
////            if (farmData.siteId.isNullOrEmpty() || farmData.farmerName.isNullOrEmpty()) {
////                Log.w("JavaScriptInterface", "Critical fields are missing in the received data.")
////            }
//
//            // Navigate to the AddFarm composable, passing plotDataJson as a parameter
//            (context as? MainActivity)?.let { activity ->
//                activity.runOnUiThread {
//                    val encodedPlotData = Uri.encode(plotDataJson)
//                    Log.d("JavaScriptInterface", "Encoded Plot Data: $encodedPlotData")
//
//                    // Build the navigation route
//                    navController.navigate("addFarm/${farmData.siteId ?: "0"}/$farmData")
//                }
//            } ?: run {
//                Log.e("JavaScriptInterface", "Context is not MainActivity, unable to navigate.")
//            }
//        } catch (e: Exception) {
//            Log.e("JavaScriptInterface", "Error processing received plot data: ${e.message}", e)
//        }
//
//
////        (context as? MainActivity)?.lifecycleScope?.launch {
////            val farmDao = AppDatabase.getInstance(context).farmsDAO()
////
////            // Combine form data with plot data
////            val farm = Farm(
////                siteId = farmData.siteId,
////                remoteId= farmData.remoteId,
////                farmerPhoto= farmData.farmerPhoto,
////                farmerName= farmData.farmerName,
////                memberId = farmData.memberId,
////                village = farmData.village,
////                district = farmData.district,
////                purchases = farmData.purchases,
////                size = farmData.size,
////                latitude = farmData.latitude,
////                longitude= farmData.longitude,
////                coordinates = farmData.coordinates,
////                accuracyArray= farmData.accuracyArray,
////                createdAt = Instant.now().millis,
////                updatedAt = Instant.now().millis
////            )
////
////            // Save to the database
////            farmDao.insert(farm)
////            Log.d("JavaScriptInterface", "Plot Data with Form Details saved to database.")
////        }
//    }

//    @JavascriptInterface
//    fun receivePlotData(plotDataJson: String) {
//
//        Log.d("JavaScriptInterface", "Received Plot Data: $plotDataJson")
//
//
//        try {
//            val gson = GsonBuilder()
//                .registerTypeAdapter(
//                    object : TypeToken<List<Pair<Double?, Double?>>>() {}.type,
//                    JsonDeserializer { json, _, _ ->
//                        val coordinates = mutableListOf<Pair<Double?, Double?>>()
//                        val jsonArray = json.asJsonArray
//                        for (coordArray in jsonArray) {
//                            val pair = coordArray.asJsonArray
//                            coordinates.add(
//                                Pair(
//                                    pair[0].asDouble,  // Latitude
//                                    pair[1].asDouble   // Longitude
//                                )
//                            )
//                        }
//                        coordinates
//                    }
//                )
//                .create()
//
//
//
//            val farmData = gson.fromJson(plotDataJson, Farm::class.java)
//            Log.d("JavaScriptInterface", "Parsed Plot Data: $farmData")
//
//            // Navigate to the AddFarm composable on the main thread
//            Handler(Looper.getMainLooper()).post {
//                // navController.navigate("addFarm/${farmData.siteId ?: "0"}/$farmData")
//                navController.navigate("addFarm/${1L}/${farmData}")
//            }
//
//            // Store the received plot data for later use
//            // latestPlotData = plotDataJson
//
//        } catch (e: Exception) {
//            Log.e("JavaScriptInterface", "Error parsing plot data: ${e.message}", e)
//        }
//
//
//
////            // Initialize farm data with default values
////            val farmData = Farm(
////                siteId = 0,
////                remoteId = UUID.fromString("e262ae0e-dcf9-41a4-8418-49971478e6e2"),
////                farmerPhoto = "",
////                farmerName = "",
////                memberId = "",
////                village = "",
////                district = "",
////                purchases = 0.0f,
////                size = 0.0f,
////                latitude = "0.0",
////                longitude = "0.0",
////                coordinates = emptyList(),
////                accuracyArray = emptyList(),
////                createdAt = System.currentTimeMillis(),
////                updatedAt = System.currentTimeMillis(),
////            )
//
//
//    }

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

    @JavascriptInterface
    fun getSelecedPlot(id: Long): String {
        return Gson().toJson(AppDatabase.getInstance(context).farmsDAO().getFarmById(id))
    }
}