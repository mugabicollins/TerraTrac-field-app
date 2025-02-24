package org.technoserve.farmcollector.ui.components


import android.os.Build
import android.widget.Toast
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.annotation.RequiresApi
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import org.technoserve.farmcollector.BuildConfig
import org.technoserve.farmcollector.R
import org.technoserve.farmcollector.database.sync.remote.ApiService
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.util.concurrent.TimeUnit

//    // Use BuildConfig.USER_GUIDE_URL where the file is hosted.
//    val response = api.downloadUserGuide("https://docs.google.com/document/d/e/2PACX-1vRAqn1l2Dv_y1vWQJPRBT6Gt2eZK2e2uJS8wayI069YXxOZ9zQovG1CCD8aO2sOLzGRzUCKIa2bBWDl/pub?export=download")

//@OptIn(ExperimentalMaterial3Api::class)
//@Composable
//fun UserGuideScreen() {
//    val context = LocalContext.current
//    val coroutineScope = rememberCoroutineScope()
//
//    // Create the launcher at the composable scope.
//    val documentLauncher = rememberLauncherForActivityResult(
//        contract = ActivityResultContracts.CreateDocument("application/pdf"),
//        onResult = { uri ->
//            if (uri != null) {
//                coroutineScope.launch {
//                    try {
//                        withContext(Dispatchers.IO) {
//                            // File name in assets
//                            val assetFileName = "TerraTrac Mobile Application User Guide.pdf"
//                            val assetManager = context.assets
//                            // Open the file from assets
//                            val inputStream = assetManager.open(assetFileName)
//                            // Open an output stream to the selected location
//                            context.contentResolver.openOutputStream(uri)?.use { outputStream ->
//                                inputStream.copyTo(outputStream)
//                            }
//                            inputStream.close()
//                        }
//                        Toast.makeText(
//                            context,
//                            context.getString(R.string.download_success),
//                            Toast.LENGTH_LONG
//                        ).show()
//                    } catch (e: Exception) {
//                        Toast.makeText(
//                            context,
//                            context.getString(R.string.download_failed, e.localizedMessage),
//                            Toast.LENGTH_LONG
//                        ).show()
//                    }
//                }
//            } else {
//                Toast.makeText(
//                    context,
//                    context.getString(R.string.no_location_selected),
//                    Toast.LENGTH_SHORT
//                ).show()
//            }
//        }
//    )
//
//    Scaffold(
//        topBar = {
//            TopAppBar(title = { Text(text = stringResource(R.string.user_guide_title)) })
//        }
//    ) { paddingValues ->
//        Column(
//            modifier = Modifier
//                .fillMaxSize()
//                .padding(paddingValues)
//                .padding(16.dp),
//            horizontalAlignment = Alignment.CenterHorizontally,
//            verticalArrangement = Arrangement.Center
//        ) {
//            Text(
//                text = stringResource(R.string.welcome_message),
//                style = MaterialTheme.typography.bodyMedium,
//                textAlign = TextAlign.Center
//            )
//            Spacer(modifier = Modifier.height(24.dp))
//            Button(onClick = {
//                // Launch the document creation, suggesting the file name.
//                documentLauncher.launch("TerraTrac Mobile Application User Guide.pdf")
//            }) {
//                Icon(
//                    painter = painterResource(id = R.drawable.save),
//                    contentDescription = stringResource(id = R.string.download_csv),
//                    tint = MaterialTheme.colorScheme.onPrimary
//                )
//                Spacer(modifier = Modifier.width(8.dp))
//                Text(text=stringResource(R.string.download_user_guide))
//            }
//        }
//    }
//}

@RequiresApi(Build.VERSION_CODES.Q)
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun UserGuideScreen(navController: NavController) {
    val context = LocalContext.current
    val coroutineScope = rememberCoroutineScope()

    // Retrofit API Setup
    val retrofit = Retrofit.Builder()
        .baseUrl(BuildConfig.BASE_URL)
        .client(
            OkHttpClient.Builder()
                .connectTimeout(30, TimeUnit.SECONDS)
                .readTimeout(30, TimeUnit.SECONDS)
                .writeTimeout(30, TimeUnit.SECONDS)
                .addInterceptor { chain ->
                    val request = chain.request().newBuilder()
                        .addHeader("Accept", "application/pdf")
                        .build()
                    chain.proceed(request)
                }
                .build()
        )
        .addConverterFactory(GsonConverterFactory.create())
        .build()

    val api = retrofit.create(ApiService::class.java)

    // Document launcher for file selection
    val documentLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.CreateDocument("application/pdf"),
        onResult = { selectedUri ->
            if (selectedUri != null) {
                coroutineScope.launch {
                    try {
                        val fileUrl = BuildConfig.USER_GUIDE_URL
                            .replace("/edit?usp=sharing", "/export?format=pdf")

                        val response = api.downloadUserGuide(fileUrl)

                        if (response.isSuccessful) {
                            response.body()?.byteStream()?.use { inputStream ->
                                context.contentResolver.openOutputStream(selectedUri)?.use { outputStream ->
                                    inputStream.copyTo(outputStream)
                                } ?: throw Exception("Unable to open output stream.")
                            } ?: throw Exception("Response body is null.")

                            Toast.makeText(
                                context,
                                context.getString(R.string.download_success),
                                Toast.LENGTH_LONG
                            ).show()
                            navController.popBackStack()
                        } else {
                            throw Exception("HTTP error: ${response.code()}")
                        }
                    } catch (e: Exception) {
                        Toast.makeText(
                            context,
                            context.getString(R.string.download_failed, e.localizedMessage),
                            Toast.LENGTH_LONG
                        ).show()
                    }
                }
            } else {
                Toast.makeText(
                    context,
                    context.getString(R.string.no_location_selected),
                    Toast.LENGTH_SHORT
                ).show()
            }
        }
    )

    Scaffold(
        topBar = {
            TopAppBar(title = { Text(text = stringResource(R.string.user_guide_title)) })
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text(
                text = stringResource(R.string.welcome_message),
                style = MaterialTheme.typography.bodyMedium,
                textAlign = TextAlign.Center
            )
            Spacer(modifier = Modifier.height(24.dp))
            Button(onClick = {
                documentLauncher.launch("TerraTrac Mobile Application User Guide.pdf")
            }) {
                Icon(
                    painter = painterResource(id = R.drawable.save),
                    contentDescription = stringResource(id = R.string.download_user_guide),
                    tint = MaterialTheme.colorScheme.onPrimary
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(text = stringResource(R.string.download_user_guide))
            }
        }
    }
}
