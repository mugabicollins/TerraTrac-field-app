package org.technoserve.farmcollector.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Clear
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.DropdownMenu
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
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.technoserve.farmcollector.R
/**
 * The FarmListHeader component displays the top app bar with a title, search field, and navigation icons.
 *
 * @param title The title to be displayed in the top app bar.
 * @param onSearchQueryChanged A callback function to handle changes in the search query.
 * @param onBackClicked A callback function to handle the back button click event.
 * @param showSearch A boolean flag indicating whether to show the search field.
 * @param showRestore A boolean flag indicating whether to show the restore button.
 *  @param onRestoreClicked A callback function to handle the restore button click event.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FarmListHeader(
    title: String,
    onSearchQueryChanged: (String) -> Unit,
    onBackClicked: () -> Unit,
    showSearch: Boolean,
    showRestore: Boolean,
    onRestoreClicked: () -> Unit,
    isBackupEnabled: Boolean, // ✅ Backup toggle state
    showLastSync: Boolean, // ✅ Boolean to show/hide last sync time
    lastSyncTime: String, // ✅ Last sync timestamp
    onBackupToggleClicked: (Boolean) -> Unit // ✅ Callback for toggling backup
) {
    // State to hold the search query
    var searchQuery by remember { mutableStateOf("") }

    // State to determine if the search mode is active
    var isSearchVisible by remember { mutableStateOf(false) }

//    TopAppBar(
//        modifier = Modifier
//            .background(MaterialTheme.colorScheme.primary)
//            .fillMaxWidth(),
//        navigationIcon = {
//            IconButton(onClick = {
//                if (isSearchVisible) {
//                    // Exit search mode, clear search query
//                    searchQuery = ""
//                    onSearchQueryChanged("")
//                    isSearchVisible = false
//                } else {
//                    // Navigate back normally
//                    onBackClicked()
//                }
//            }) {
//                Icon(
//                    imageVector = Icons.AutoMirrored.Filled.ArrowBack,
//                    contentDescription = "Back",
//                    tint = MaterialTheme.colorScheme.onPrimary
//                )
//            }
//        },
//        title = {
//            Text(
//                text = title,
//                color = MaterialTheme.colorScheme.onPrimary,
//                fontSize = 22.sp,
//                maxLines = 1,
//                overflow = TextOverflow.Ellipsis
//            )
//        },
//        actions = {
//
//            if (showRestore) {
//                IconButton(
//                    onClick = { onRestoreClicked() },
//                    modifier = Modifier.size(36.dp)
//                ) {
//                    Icon(
//                        imageVector = Icons.Default.Refresh,
//                        contentDescription = "Restore",
//                        modifier = Modifier.size(24.dp),
//                        tint = MaterialTheme.colorScheme.onPrimary
//                    )
//                }
//            }
//            if (showSearch) {
//                IconButton(onClick = {
//                    isSearchVisible = !isSearchVisible
//                }, modifier = Modifier.size(36.dp)) {
//                    Icon(
//                        imageVector = Icons.Default.Search,
//                        contentDescription = "Search",
//                        modifier = Modifier.size(24.dp),
//                        tint = MaterialTheme.colorScheme.onPrimary
//                    )
//                }
//            }
//        },
//    )

//    TopAppBar(
//        modifier = Modifier
//            .fillMaxWidth()
//            .background(MaterialTheme.colorScheme.primary)
//            .padding(horizontal = 12.dp),
//        navigationIcon = {
//            IconButton(onClick = {
//                if (isSearchVisible) {
//                    onSearchQueryChanged("")
//                } else {
//                    onBackClicked()
//                }
//            }) {
//                Icon(
//                    imageVector = Icons.AutoMirrored.Filled.ArrowBack,
//                    contentDescription = "Back",
//                    tint = MaterialTheme.colorScheme.onPrimary
//                )
//            }
//        },
//        title = {
//            Row(
//                modifier = Modifier.fillMaxWidth(),
//                verticalAlignment = Alignment.CenterVertically,
//                horizontalArrangement = Arrangement.SpaceBetween // ✅ Ensures Last Sync doesn’t overlap Back Icon
//            ) {
//                Text(
//                    text = title,
//                    color = MaterialTheme.colorScheme.onPrimary,
//                    fontSize = 20.sp,
//                    fontWeight = FontWeight.Bold,
//                    maxLines = 1,
//                    overflow = TextOverflow.Ellipsis,
//                    modifier = Modifier.weight(1f) // ✅ Prevents overlap with actions
//                )
//
//                // ✅ Show last sync info only if enabled
//                if (showLastSync) {
//                    Column(
//                        modifier = Modifier.padding(end = 12.dp),
//                        verticalArrangement = Arrangement.Center
//                    ) {
//                        Text(
//                            text = "Last Synced:",
//                            style = MaterialTheme.typography.bodySmall,
//                            color = MaterialTheme.colorScheme.onPrimary
//                        )
//                        Text(
//                            text = lastSyncTime,
//                            style = MaterialTheme.typography.bodySmall,
//                            color = MaterialTheme.colorScheme.onPrimary,
//                            fontWeight = FontWeight.Bold
//                        )
//                    }
//                }
//            }
//        },
//        actions = {
//            Row(
//                verticalAlignment = Alignment.CenterVertically,
//                horizontalArrangement = Arrangement.End
//            ) {
//                // ✅ Backup Toggle (Green when ON, Red when OFF)
//                if (showLastSync) {
//                    Row(
//                        verticalAlignment = Alignment.CenterVertically,
//                        modifier = Modifier.padding(end = 6.dp)
//                    ) {
//                        Text(
//                            "Backup Now",
//                            style = MaterialTheme.typography.bodyMedium,
//                            color = MaterialTheme.colorScheme.onPrimary
//                        )
//                        Spacer(modifier = Modifier.width(6.dp))
//                        Switch(
//                            checked = isBackupEnabled,
//                            onCheckedChange = onBackupToggleClicked,
//                            modifier = Modifier.size(24.dp),
//                            colors = SwitchDefaults.colors(
//                                checkedThumbColor = MaterialTheme.colorScheme.primary, // Green when enabled
//                                checkedTrackColor = MaterialTheme.colorScheme.tertiary,
//                                uncheckedThumbColor = MaterialTheme.colorScheme.error, // Red when disabled
//                                uncheckedTrackColor = MaterialTheme.colorScheme.errorContainer
//                            )
//                        )
//                    }
//                }
//
//                // ✅ Restore Button
//                if (showRestore) {
//                    IconButton(
//                        onClick = onRestoreClicked,
//                        modifier = Modifier.size(36.dp)
//                    ) {
//                        Icon(
//                            imageVector = Icons.Default.Refresh,
//                            contentDescription = "Restore",
//                            modifier = Modifier.size(24.dp),
//                            tint = MaterialTheme.colorScheme.onPrimary
//                        )
//                    }
//                }
//
//                // ✅ Search Button
//                if (showSearch) {
//                    IconButton(onClick = {
//                        isSearchVisible = !isSearchVisible
//                    }, modifier = Modifier.size(36.dp)) {
//                        Icon(
//                            imageVector = Icons.Default.Search,
//                            contentDescription = "Search",
//                            modifier = Modifier.size(24.dp),
//                            tint = MaterialTheme.colorScheme.onPrimary
//                        )
//                    }
//                }
//            }
//        }
//    )


    val configuration = LocalConfiguration.current
    val screenWidth = configuration.screenWidthDp.dp
    println("screenWidth $screenWidth")
    var isLastSyncDropdownVisible by remember { mutableStateOf(false) }

// Adjust sizes based on screen width
    val iconSize = if (screenWidth < 360.dp) 20.dp else 24.dp
    val switchScale = if (screenWidth < 360.dp) 0.6f else 0.8f
    val horizontalPadding = if (screenWidth < 360.dp) 8.dp else 12.dp
    val titleFontSize = if (screenWidth < 360.dp) 16.sp else 18.sp
    val backupTextStyle = if (screenWidth < 360.dp) {
        MaterialTheme.typography.bodySmall
    } else {
        MaterialTheme.typography.bodyMedium
    }

    TopAppBar(
        modifier = Modifier
            .fillMaxWidth()
            .background(MaterialTheme.colorScheme.primary)
            .padding(horizontal = horizontalPadding),
        navigationIcon = {
            IconButton(
                onClick = {
                    if (isSearchVisible) {
                        onSearchQueryChanged("")
                    } else {
                        onBackClicked()
                    }
                },
                modifier = Modifier.size(if (screenWidth < 360.dp) 32.dp else 36.dp)
            ) {
                Icon(
                    imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                    contentDescription = stringResource(id = R.string.back),
                    tint = MaterialTheme.colorScheme.onPrimary,
                    modifier = Modifier.size(iconSize)
                )
            }
        },
        title = {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = title,
                    color = MaterialTheme.colorScheme.onPrimary,
                    fontSize = titleFontSize,
//                    fontWeight = FontWeight.Bold,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.weight(1f)
                )

                if (showLastSync) {
                    if (screenWidth >= 380.dp) {
                        // Show regular column on larger screens
                        Column(
                            modifier = Modifier.padding(end = 4.dp),
                            verticalArrangement = Arrangement.Center
                        ) {
                            Text(
                                text = stringResource(id = R.string.last_synced),
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
                    } else {
                        // Show dropdown on small screens
                        Box {
                            IconButton(
                                onClick = { isLastSyncDropdownVisible = !isLastSyncDropdownVisible },
                                modifier = Modifier.size(32.dp)
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Info,
                                    contentDescription = stringResource(id = R.string.last_synced),
                                    tint = MaterialTheme.colorScheme.onPrimary,
                                    modifier = Modifier.size(iconSize)
                                )
                            }

                            DropdownMenu(
                                expanded = isLastSyncDropdownVisible,
                                onDismissRequest = { isLastSyncDropdownVisible = false },
                                modifier = Modifier
                                    .background(MaterialTheme.colorScheme.surface)
                                    .width(IntrinsicSize.Min)
                            ) {
                                Column(
                                    modifier = Modifier.padding(8.dp),
                                    horizontalAlignment = Alignment.Start
                                ) {
                                    Text(
                                        text = stringResource(id = R.string.last_synced),
                                        style = MaterialTheme.typography.bodySmall,
                                        color = MaterialTheme.colorScheme.onSurface
                                    )
                                    Text(
                                        text = lastSyncTime,
                                        style = MaterialTheme.typography.bodySmall,
                                        color = MaterialTheme.colorScheme.onSurface,
                                        fontWeight = FontWeight.Bold
                                    )
                                }
                            }
                        }
                    }
                }
            }
        },
        actions = {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.End,
                modifier = Modifier.padding(start = if (screenWidth < 380.dp) 2.dp else 4.dp)
            ) {
                if (showLastSync) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        modifier = Modifier.padding(end = if (screenWidth < 380.dp) 2.dp else 4.dp)
                    ) {
                        Text(
                            text = stringResource(id = R.string.backup_now),
                            style = backupTextStyle,
                            color = MaterialTheme.colorScheme.onPrimary
                        )
                        Spacer(modifier = Modifier.width(1.dp))
                        Switch(
                            checked = isBackupEnabled,
                            onCheckedChange = onBackupToggleClicked,
                            thumbContent = {
                                Icon(
                                    imageVector = if (isBackupEnabled) Icons.Filled.Check else Icons.Filled.Close,
                                    contentDescription = stringResource(id = R.string.backup_now),
                                    modifier = Modifier.size(SwitchDefaults.IconSize)
                                )
                            },
                            modifier = Modifier.scale(switchScale),
                            colors = SwitchDefaults.colors(
                                checkedThumbColor = MaterialTheme.colorScheme.primary,
                                checkedTrackColor = MaterialTheme.colorScheme.tertiary,
                                uncheckedThumbColor = MaterialTheme.colorScheme.error,
                                uncheckedTrackColor = MaterialTheme.colorScheme.errorContainer
                            )
                        )
                    }
                }

                // Rest of the actions remain the same
                if (showRestore) {
                    IconButton(
                        onClick = onRestoreClicked,
                        modifier = Modifier.size(if (screenWidth < 380.dp) 32.dp else 36.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Refresh,
                            contentDescription = stringResource(id = R.string.restore),
                            modifier = Modifier.size(iconSize),
                            tint = MaterialTheme.colorScheme.onPrimary
                        )
                    }
                }

                if (showSearch) {
                    IconButton(
                        onClick = { isSearchVisible = !isSearchVisible },
                        modifier = Modifier.size(if (screenWidth < 380.dp) 32.dp else 36.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Search,
                            contentDescription = stringResource(id = R.string.search),
                            modifier = Modifier.size(iconSize),
                            tint = MaterialTheme.colorScheme.onPrimary
                        )
                    }
                }
            }
        }
    )


    // Show search field when search mode is active
    if (isSearchVisible) {
        Box(
            modifier = Modifier
                .padding(top = 54.dp)
                .background(MaterialTheme.colorScheme.background)
                .fillMaxWidth(),
            contentAlignment = Alignment.Center // Center the Row within the Box
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.Center, // Center the contents within the Row
                modifier = Modifier.fillMaxWidth()
            ) {
                OutlinedTextField(
                    value = searchQuery,
                    onValueChange = {
                        searchQuery = it
                        onSearchQueryChanged(it)
                    },
                    modifier = Modifier
                        .fillMaxWidth() // Center with a smaller width
                        .padding(8.dp)
                        .background(MaterialTheme.colorScheme.background)
//                        .border(
//                        width = 1.dp, // ✅ Border width
//                        color = MaterialTheme.colorScheme.onSurfaceVariant, // ✅ Border color
//                        shape = MaterialTheme.shapes.medium // ✅ Rounded corners
//                    )
                        .clip(RoundedCornerShape(0.dp)), // Add rounded corners
                    placeholder = {
                        Text(
                            stringResource(R.string.search),
                            color = MaterialTheme.colorScheme.onBackground
                        )
                    },
                    leadingIcon = {
                        IconButton(onClick = {
                            // Exit search mode and clear search
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
//                        errorIndicatorColor = Color.Red,

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