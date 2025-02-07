package org.technoserve.farmcollector.ui.components

import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Clear
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Share
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.technoserve.farmcollector.R

/*
 *  This function is used to display the header for the farm list with search, export, share, and import buttons
 *  @param title: The title of the header
 *  @param onBackClicked: A function to be called when the back button is clicked
 *  @param onExportClicked: A function to be called when the export button is clicked
 *  @param onShareClicked: A function to be called when the share button is clicked
 *  @param onImportClicked: A function to be called when the import button is clicked
 * @param onSearchQueryChanged : A function to be called when the search query is changed
 * @param showExport: A function to be called when the export button is clicked and the export button is clicked
 * @param showShar: A function to be called when the export button is clicked
 * @param showSearch: A function to be called when the export button is clicked
 * @param onRestoreClicked: A function to be called when the restore button is clicked and the restore button is clicked
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FarmListHeaderPlots(
    title: String,
    onBackClicked: () -> Unit,
    onExportClicked: () -> Unit,
    onShareClicked: () -> Unit,
    onImportClicked: () -> Unit,
    onSearchQueryChanged: (String) -> Unit,
    showExport: Boolean,
    showShare: Boolean,
    showSearch: Boolean,
    onRestoreClicked: () -> Unit,
    isBackupEnabled: Boolean, // ✅ Backup toggle state
    showLastSync: Boolean, // ✅ Boolean to show/hide last sync time
    lastSyncTime: String, // ✅ Last sync timestamp
    onBackupToggleClicked: (Boolean) -> Unit // ✅ Callback for toggling backup
) {

    var searchQuery by remember { mutableStateOf("") }
    var isSearchVisible by remember { mutableStateOf(false) }
    var isImportDisabled by remember { mutableStateOf(false) }

    TopAppBar(
//        title = {
//            Text(
//                text = title,
//                fontSize = 22.sp,
//                maxLines = 1,
//                overflow = TextOverflow.Ellipsis
//            )
//        },
        title = {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween // ✅ Ensures Last Sync doesn’t overlap Back Icon
            ) {
                Text(
                    text = title,
                    color = MaterialTheme.colorScheme.onPrimary,
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.weight(1f) // ✅ Prevents overlap with actions
                )

                // ✅ Show last sync info only if enabled
                if (showLastSync) {
                    Column(
                        modifier = Modifier.padding(end = 12.dp),
                        verticalArrangement = Arrangement.Center
                    ) {
                        Text(
                            text = "Last Synced:",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onPrimary
                        )
                        Text(
                            text = lastSyncTime,
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onPrimary,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }
        },

        navigationIcon = {
            IconButton(onClick = {
                if (isSearchVisible) {
                    searchQuery = ""
                    onSearchQueryChanged("")
                    isSearchVisible = false
                } else {
                    onBackClicked()
                }
            }) {
                Icon(
                    imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                    contentDescription = "Back",
                    tint = MaterialTheme.colorScheme.onPrimary
                )
            }
        },
        actions = {
            Row(
                horizontalArrangement = Arrangement.End,
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.horizontalScroll(rememberScrollState())
            ) {

                // ✅ Backup Toggle (Green when ON, Red when OFF)
                if (showLastSync) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        modifier = Modifier.padding(end = 12.dp)
                    ) {
                        Text(
                            "Backup",
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onPrimary
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                        Switch(
                            checked = isBackupEnabled,
                            onCheckedChange = onBackupToggleClicked,
                            colors = SwitchDefaults.colors(
                                checkedThumbColor = MaterialTheme.colorScheme.primary, // Green when enabled
                                checkedTrackColor = MaterialTheme.colorScheme.tertiary,
                                uncheckedThumbColor = MaterialTheme.colorScheme.error, // Red when disabled
                                uncheckedTrackColor = MaterialTheme.colorScheme.errorContainer
                            )
                        )
                    }
                }
                IconButton(
                    onClick = { onRestoreClicked() },
                    modifier = Modifier.size(36.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.Refresh,
                        contentDescription = "Restore",
                        modifier = Modifier.size(24.dp),
                        tint = MaterialTheme.colorScheme.onPrimary
                    )
                }
                if (showExport) {
                    IconButton(onClick = onExportClicked, modifier = Modifier.size(36.dp)) {
                        Icon(
                            painter = painterResource(id = R.drawable.save),
                            contentDescription = "Export",
                            modifier = Modifier.size(24.dp),
                            tint = MaterialTheme.colorScheme.onPrimary,
                        )
                    }
                }
                if (showShare) {
                    IconButton(onClick = onShareClicked, modifier = Modifier.size(36.dp)) {
                        Icon(
                            imageVector = Icons.Default.Share,
                            contentDescription = "Share",
                            modifier = Modifier.size(24.dp),
                            tint = MaterialTheme.colorScheme.onPrimary
                        )
                    }
                }
                IconButton(
                    onClick = {
                        if (!isImportDisabled) {
                            onImportClicked()
                        }
                    },
                    modifier = Modifier.size(36.dp)
                ) {
                    Icon(
                        painter = painterResource(id = R.drawable.icons8_import_file_48),
                        contentDescription = "Import",
                        modifier = Modifier.size(24.dp),
                        tint = MaterialTheme.colorScheme.onPrimary,
                    )
                }
                if (showSearch) {
                    IconButton(onClick = {
                        isSearchVisible = !isSearchVisible
                    }, modifier = Modifier.size(36.dp)) {
                        Icon(
                            imageVector = Icons.Default.Search,
                            contentDescription = "Search",
                            modifier = Modifier.size(24.dp),
                            tint = MaterialTheme.colorScheme.onPrimary
                        )
                    }
                }
            }
        },
    )
    if (isSearchVisible) {
        Box(
            modifier = Modifier
                .padding(top = 54.dp)
                .fillMaxWidth(),
            contentAlignment = Alignment.Center
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.Center,
                modifier = Modifier.fillMaxWidth()
            ) {
                OutlinedTextField(
                    value = searchQuery,
                    onValueChange = {
                        searchQuery = it
                        onSearchQueryChanged(it)
                    },
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(8.dp)
                        .clip(RoundedCornerShape(0.dp)),
                    placeholder = { Text(stringResource(R.string.search)) },
                    leadingIcon = {
                        IconButton(onClick = {
                            searchQuery = ""
                            onSearchQueryChanged("")
                            isSearchVisible = false
                        }) {
                            Icon(
                                Icons.AutoMirrored.Filled.ArrowBack,
                                contentDescription = "Back",
                                tint = MaterialTheme.colorScheme.onSurface
                            )
                        }
                    },
                    trailingIcon = {
                        if (searchQuery != "") {
                            IconButton(onClick = {
                                searchQuery = ""
                                onSearchQueryChanged("")
                            }) {
                                Icon(
                                    Icons.Default.Clear,
                                    contentDescription = "Clear",
                                    tint = MaterialTheme.colorScheme.onSurface
                                )
                            }
                        }
                    },
                    singleLine = true,
                    colors = TextFieldDefaults.colors(
                        cursorColor = MaterialTheme.colorScheme.onSurface,
                        focusedTextColor = MaterialTheme.colorScheme.onSurface,
                        errorCursorColor = Color.Red,
//                        focusedIndicatorColor = Color.Transparent,
//                        unfocusedIndicatorColor = MaterialTheme.colorScheme.onSurfaceVariant,
//                        errorIndicatorColor = Color.Red
                        // ✅ Ensure Border Always Stays Visible
                        focusedIndicatorColor = MaterialTheme.colorScheme.onSurfaceVariant, // Border when focused
                        unfocusedIndicatorColor = MaterialTheme.colorScheme.onSurfaceVariant, // Border when unfocused
                        errorIndicatorColor = Color.Red, // Border when error state


                        // ✅ Add Background Colors
                        focusedContainerColor = MaterialTheme.colorScheme.background,  // Background when focused
                        unfocusedContainerColor = MaterialTheme.colorScheme.background, // Background when not focused
                        errorContainerColor =  Color.Red// Light red for error state
                    ),
                    shape = RoundedCornerShape(0.dp)
                )

            }
        }
    }
}