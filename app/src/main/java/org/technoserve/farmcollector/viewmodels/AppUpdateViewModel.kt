package org.technoserve.farmcollector.viewmodels

import android.app.Activity
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.platform.LocalContext
import androidx.lifecycle.ViewModel
import com.google.android.play.core.appupdate.AppUpdateManager
import com.google.android.play.core.appupdate.AppUpdateManagerFactory
import com.google.android.play.core.install.model.AppUpdateType
import com.google.android.play.core.install.model.UpdateAvailability
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import org.technoserve.farmcollector.R

class AppUpdateViewModel : ViewModel() {
    private val _updateAvailable = MutableStateFlow(false)
    val updateAvailable = _updateAvailable.asStateFlow()

    private lateinit var appUpdateManager: AppUpdateManager
    private val updateType = AppUpdateType.IMMEDIATE

    fun initializeAppUpdateCheck(activity: Activity) {
        appUpdateManager = AppUpdateManagerFactory.create(activity)
        checkForUpdate(activity)
    }

    private fun checkForUpdate(activity: Activity) {
        appUpdateManager.appUpdateInfo.addOnSuccessListener { appUpdateInfo ->
            if (appUpdateInfo.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE) {
                _updateAvailable.value = true
                // Force update
                appUpdateManager.startUpdateFlowForResult(
                    appUpdateInfo,
                    updateType,
                    activity,
                    APP_UPDATE_REQUEST_CODE
                )
            }
        }
    }

    companion object {
        const val APP_UPDATE_REQUEST_CODE = 123
    }
}

@Composable
fun UpdateAlert(
    showDialog: Boolean,
    onDismiss: () -> Unit,
    onConfirm: () -> Unit
) {
    if (showDialog) {
        AlertDialog(
            onDismissRequest = onDismiss,
            title = { Text("Update Available") },
            text = { Text("A new version of the app is available. Please update to continue using the app.") },
            confirmButton = {
                Button(onClick = onConfirm) {
                    Text("Update Now")
                }
            },
            dismissButton = null // No dismiss button for forced update
        )
    }
}

@Composable
fun RestoreDataAlert(
    showDialog: Boolean,
    onDismiss: () -> Unit,
    deviceId: String,
    farmViewModel: FarmViewModel,
) {
    val context = LocalContext.current
    var finalMessage by remember { mutableStateOf("") }
    var showFinalMessage by remember { mutableStateOf(false) }
    var showRestorePrompt by remember { mutableStateOf(false) }

    if (showDialog) {
        AlertDialog(
            onDismissRequest = onDismiss,
            title = { Text("Data Restoration") },
            text = {
                Text("During restoration, you will recover some of the previously deleted records. Do you want to continue?")
            },
            confirmButton = {
                Button(
                    onClick = {
                        farmViewModel.restoreData(
                            deviceId = deviceId,
                            phoneNumber = "",
                            email = "",
                            farmViewModel = farmViewModel
                        ) { success ->
                            if (success) {
                                finalMessage = context.getString(R.string.data_restored_successfully)
                            } else {
                                showFinalMessage = true
                                showRestorePrompt = true
                            }
                            onDismiss()
                        }
                    }
                ) {
                    Text("Continue")
                }
            },
            dismissButton = {
                TextButton(onClick = onDismiss) {
                    Text("Cancel")
                }
            }
        )
    }
}

@Composable
fun ExitConfirmationDialog(
    showDialog: Boolean,
    onDismiss: () -> Unit,
    onConfirm: () -> Unit
) {
    if (showDialog) {
        AlertDialog(
            onDismissRequest = onDismiss,
            title = { Text("Exit App") },
            text = { Text("Are you sure you want to exit the app?") },
            confirmButton = {
                Button(onClick = onConfirm) {
                    Text("Yes")
                }
            },
            dismissButton = {
                TextButton(onClick = onDismiss) {
                    Text("No")
                }
            }
        )
    }
}

@Composable
fun UndoDeleteSnackbar(
    show: Boolean,
    onDismiss: () -> Unit,
    onUndo: () -> Unit
) {
    if (show) {
        Snackbar(
            action = {
                TextButton(onClick = onUndo) {
                    Text("UNDO")
                }
            },
            dismissAction = {
                IconButton(onClick = onDismiss) {
                    Icon(Icons.Default.Close, contentDescription = "Dismiss")
                }
            }
        ) {
            Text("Item deleted")
        }
    }
}
