package org.technoserve.farmcollector.database.helpers.map

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import android.webkit.JavascriptInterface
import androidx.lifecycle.lifecycleScope
import com.google.gson.Gson
import kotlinx.coroutines.launch
import org.joda.time.Instant
import org.technoserve.farmcollector.MainActivity
import org.technoserve.farmcollector.database.AppDatabase
import org.technoserve.farmcollector.database.models.Farm
import org.technoserve.farmcollector.ui.screens.farms.addFarm

// JavaScript Interface
class JavaScriptInterface(
    private val context: Context,
) {
    @JavascriptInterface
    fun receivePlotData(plotDataJson: String) {
        try {
            Log.d("JavaScriptInterface", "Received Plot Data: $plotDataJson")

            // Parse the JSON string into a Farm object
            val gson = Gson()
            val farmData = gson.fromJson(plotDataJson, Farm::class.java)

            Log.d("JavaScriptInterface", "Parsed Farm Data: $farmData")

//            // Validate critical fields
//            if (farmData.siteId.isNullOrEmpty() || farmData.farmerName.isNullOrEmpty()) {
//                Log.w("JavaScriptInterface", "Critical fields are missing in the received data.")
//            }

            // Navigate to the AddFarm composable, passing plotDataJson as a parameter
            (context as? MainActivity)?.let { activity ->
                activity.runOnUiThread {
                    val navController = activity.navController
                    val encodedPlotData = Uri.encode(plotDataJson)

                    // Build the navigation route
                    navController.navigate("addFarm/${farmData.siteId ?: "0"}/$encodedPlotData")
                }
            } ?: run {
                Log.e("JavaScriptInterface", "Context is not MainActivity, unable to navigate.")
            }
        } catch (e: Exception) {
            Log.e("JavaScriptInterface", "Error processing received plot data: ${e.message}", e)
        }


//        (context as? MainActivity)?.lifecycleScope?.launch {
//            val farmDao = AppDatabase.getInstance(context).farmsDAO()
//
//            // Combine form data with plot data
//            val farm = Farm(
//                siteId = farmData.siteId,
//                remoteId= farmData.remoteId,
//                farmerPhoto= farmData.farmerPhoto,
//                farmerName= farmData.farmerName,
//                memberId = farmData.memberId,
//                village = farmData.village,
//                district = farmData.district,
//                purchases = farmData.purchases,
//                size = farmData.size,
//                latitude = farmData.latitude,
//                longitude= farmData.longitude,
//                coordinates = farmData.coordinates,
//                accuracyArray= farmData.accuracyArray,
//                createdAt = Instant.now().millis,
//                updatedAt = Instant.now().millis
//            )
//
//            // Save to the database
//            farmDao.insert(farm)
//            Log.d("JavaScriptInterface", "Plot Data with Form Details saved to database.")
//        }
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