package org.technoserve.farmcollector.ui.screens.map

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Bitmap
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.Uri
import android.view.ViewGroup
import android.webkit.GeolocationPermissions
import android.webkit.WebChromeClient
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.viewinterop.AndroidView
import java.io.File
import java.net.URLConnection

/**
 * Implementation of caching mechanism for performance
 *
 */

@SuppressLint("SetJavaScriptEnabled")
@Composable
fun WebViewPage(url: String) {
    val context = LocalContext.current
    var backEnabled by remember { mutableStateOf(false) }
    var webView: WebView? = null

    // Define cache directory
    val cachePath = File(context.cacheDir, "webview-cache")
    if (!cachePath.exists()) {
        cachePath.mkdirs()
    }

    AndroidView(
        factory = {
            WebView(it).apply {
                layoutParams = ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT
                )

                // Enable JavaScript and required settings
                settings.apply {
                    javaScriptEnabled = true
                    domStorageEnabled = true
                    setGeolocationEnabled(true)
                    builtInZoomControls = true
                    displayZoomControls = false
                    allowFileAccess = true
                    allowContentAccess = true
                    loadWithOverviewMode = true
                    useWideViewPort = true

                    // Cache settings
                    cacheMode = WebSettings.LOAD_CACHE_ELSE_NETWORK // Use cached resources when available
                    databaseEnabled = true
                }

                webChromeClient = object : WebChromeClient() {
                    override fun onGeolocationPermissionsShowPrompt(
                        origin: String,
                        callback: GeolocationPermissions.Callback
                    ) {
                        callback.invoke(origin, true, false)
                    }
                }

                webViewClient = object : WebViewClient() {
                    override fun onPageStarted(view: WebView, url: String?, favicon: Bitmap?) {
                        super.onPageStarted(view, url, favicon)
                    }

                    override fun shouldInterceptRequest(
                        view: WebView?,
                        request: WebResourceRequest?
                    ): WebResourceResponse? {
                        val url = request?.url.toString()
                        val cachedResponse = getCachedResponse(context, url)
                        if (cachedResponse != null) {
                            return cachedResponse
                        }
                        return super.shouldInterceptRequest(view, request)
                    }

                    override fun onPageFinished(view: WebView?, url: String?) {
                        super.onPageFinished(view, url)
                        view?.evaluateJavascript("if(map){map.invalidateSize(true);}", null)
                    }
                }

                // Load URL with fallback to cached content
                if (isNetworkAvailable(context)) {
                    loadUrl(url)
                } else {
                    val cachedFile = File(cachePath, "${Uri.parse(url).host}.mht")
                    if (cachedFile.exists()) {
                        loadUrl("file://${cachedFile.absolutePath}")
                    } else {
                        loadUrl(url)
                    }
                }
                webView = this
            }
        },
        modifier = Modifier
            .fillMaxSize()
            .semantics { contentDescription = "Web View" },
        update = { webView ->
            webView.evaluateJavascript("if(map){map.invalidateSize(true);}", null)
        }
    )

    BackHandler(enabled = backEnabled) {
        webView?.goBack()
    }
}

// Utility function to check network availability
private fun isNetworkAvailable(context: Context): Boolean {
    val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
    val network = connectivityManager.activeNetwork
    val capabilities = connectivityManager.getNetworkCapabilities(network)
    return capabilities != null &&
            (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) ||
                    capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR))
}

// Function to get cached response
private fun getCachedResponse(context: Context, url: String): WebResourceResponse? {
    val cache = context.cacheDir
    val cachedFile = File(cache, Uri.parse(url).lastPathSegment ?: return null)

    if (cachedFile.exists()) {
        try {
            val mimeType = URLConnection.guessContentTypeFromName(url)
            return WebResourceResponse(
                mimeType ?: "text/plain",
                "UTF-8",
                cachedFile.inputStream()
            )
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
    return null
}