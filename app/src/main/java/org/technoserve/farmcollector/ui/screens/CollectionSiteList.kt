package org.technoserve.farmcollector.ui.screens

import android.app.Application
import android.widget.Toast
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material3.Button
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Alignment.Companion.BottomEnd
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import androidx.paging.LoadState
import androidx.paging.compose.collectAsLazyPagingItems
import com.valentinilk.shimmer.shimmer
import kotlinx.coroutines.delay
import org.technoserve.farmcollector.R
import org.technoserve.farmcollector.database.CollectionSite
import org.technoserve.farmcollector.database.FarmViewModel
import org.technoserve.farmcollector.database.FarmViewModelFactory
import org.technoserve.farmcollector.database.RestoreStatus
import org.technoserve.farmcollector.database.sync.DeviceIdUtil
import org.technoserve.farmcollector.ui.composes.UpdateCollectionDialog
import org.technoserve.farmcollector.ui.composes.isValidPhoneNumber


/**
 *  This function is used to display the list of collection sites
 */

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CollectionSiteList(navController: NavController) {
    val context = LocalContext.current
    val farmViewModel: FarmViewModel =
        viewModel(
            factory = FarmViewModelFactory(context.applicationContext as Application),
        )
    val selectedIds = remember { mutableStateListOf<Long>() }
    val showDeleteDialog = remember { mutableStateOf(false) }
    val listItems by farmViewModel.readAllSites.observeAsState(listOf())
    var (searchQuery, setSearchQuery) = remember { mutableStateOf("") }
    fun onDelete() {
        val toDelete = mutableListOf<Long>()
        toDelete.addAll(selectedIds)
        farmViewModel.deleteListSite(toDelete)
        selectedIds.removeAll(selectedIds)
        showDeleteDialog.value = false
    }

    val isLoading = remember { mutableStateOf(true) }
    var deviceId by remember { mutableStateOf("") }
    val restoreStatus by farmViewModel.restoreStatus.observeAsState()
    var phone by remember { mutableStateOf("") }
    var email by remember { mutableStateOf("") }

    var showRestorePrompt by remember { mutableStateOf(false) }
    var finalMessage by remember { mutableStateOf("") }
    var showFinalMessage by remember { mutableStateOf(false) }

    val isDarkTheme = isSystemInDarkTheme()
    val inputLabelColor = if (isDarkTheme) Color.LightGray else Color.DarkGray
    val inputTextColor = if (isDarkTheme) Color.White else Color.Black
    val inputBorder = if (isDarkTheme) Color.LightGray else Color.DarkGray

    val lazyPagingItems = farmViewModel.pager.collectAsLazyPagingItems()

    val pageSize = 3
    val pagedData = farmViewModel.pager.collectAsLazyPagingItems()
    var currentPage by remember { mutableIntStateOf(1) }

    var isSearchActive by remember { mutableStateOf(false) }

    val cwsListItems by farmViewModel.readAllSites.observeAsState(listOf())

    val filteredList = cwsListItems.filter {
        it.name.contains(searchQuery, ignoreCase = true)
    }

    LaunchedEffect(Unit) {
        deviceId = DeviceIdUtil.getDeviceId(context)
    }


    LaunchedEffect(Unit) {
        delay(500)
        isLoading.value = false
    }

    Scaffold(
        topBar = {
            FarmListHeader(
                title = stringResource(id = R.string.collection_site_list),
                onSearchQueryChanged = setSearchQuery,
                onBackClicked = { navController.navigate("home") },
                showSearch = true,
                showRestore = true,
                onRestoreClicked = {
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
                    }
                }
            )
        },
        floatingActionButton = {
            Box(
                modifier = Modifier
                    .fillMaxSize()
            ) {
                FloatingActionButton(
                    onClick = {
                        navController.navigate("addSite")
                    },
                    containerColor = MaterialTheme.colorScheme.surface,
                    contentColor = MaterialTheme.colorScheme.onSurface,
                    modifier = Modifier
                        .padding(end = 0.dp, bottom = 48.dp)
                        .background(MaterialTheme.colorScheme.background)
                        .align(BottomEnd)
                ) {
                    Icon(Icons.Default.Add, contentDescription = "Add a Site")
                }
            }
        },
        content = { paddingValues ->
            Column(
                modifier = Modifier
                    .padding(paddingValues)
                    .fillMaxSize()
            ) {
                // Search field below the header
                if (isSearchActive) {
                    OutlinedTextField(
                        value = searchQuery,
                        onValueChange = { searchQuery = it },
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp, vertical = 8.dp),
                        label = { Text(stringResource(R.string.search)) },
                        singleLine = true,
                        colors = TextFieldDefaults.outlinedTextFieldColors(
                            cursorColor = MaterialTheme.colorScheme.onSurface,
                        ),
                    )
                }

                when {
                    pagedData.loadState.refresh is LoadState.Loading -> {
                        LazyColumn {
                            items(4) {
                                SkeletonSiteCard()
                                Spacer(modifier = Modifier.height(8.dp))
                            }
                        }
                    }

                    pagedData.loadState.refresh is LoadState.Error -> {
                        Text(
                            text = stringResource(id = R.string.error_loading_more_sites),
                            modifier = Modifier
                                .fillMaxSize()
                                .padding(8.dp),
                            textAlign = TextAlign.Center,
                            style = MaterialTheme.typography.bodyMedium,
                            color = Color.Red
                        )
                    }

                    cwsListItems.isNotEmpty() -> {
                        Column(modifier = Modifier.weight(1f)) {
                            if (searchQuery.isNotEmpty() && filteredList.isEmpty()) {
                                Text(
                                    text = stringResource(R.string.no_results_found),
                                    modifier = Modifier
                                        .padding(16.dp)
                                        .fillMaxWidth(),
                                    textAlign = TextAlign.Center,
                                    style = MaterialTheme.typography.bodyMedium,
                                )
                            } else {
                                LazyColumn {
                                    val pageSize = 4
                                    val startIndex = (currentPage - 1) * pageSize
                                    val endIndex = minOf(startIndex + pageSize, filteredList.size)

                                    items(endIndex - startIndex) { index ->
                                        val siteIndex = startIndex + index
                                        val site = filteredList[siteIndex]
                                        SiteCard(
                                            site = site,
                                            onCardClick = {
                                                navController.navigate("farmList/${site.siteId}")
                                            },
                                            totalFarms = farmViewModel.getTotalFarms(site.siteId)
                                                .observeAsState(0).value,
                                            farmsWithIncompleteData = farmViewModel.getFarmsWithIncompleteData(
                                                site.siteId
                                            )
                                                .observeAsState(0).value,
                                            onDeleteClick = {
                                                selectedIds.add(site.siteId)
                                                showDeleteDialog.value = true
                                            },
                                            farmViewModel = farmViewModel,
                                        )
                                        // Spacer(modifier = Modifier.height(8.dp))
                                    }

                                    item {
                                        CustomPaginationControls(
                                            currentPage = currentPage,
                                            totalPages = (filteredList.size + pageSize - 1) / pageSize,
                                            onPageChange = { newPage ->
                                                currentPage = newPage
                                            }
                                        )
                                    }
                                }
                            }
                        }
                    }

                    else -> {
                        Box(
                            modifier = Modifier.fillMaxSize(),
                            contentAlignment = Alignment.Center
                        ) {
                            Image(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(16.dp, 8.dp),
                                painter = painterResource(id = R.drawable.no_data2),
                                contentDescription = null
                            )
                        }
                    }
                }
            }
        },
        modifier = Modifier
            .background(MaterialTheme.colorScheme.primary)
            .fillMaxWidth()
    )



    when (restoreStatus) {
        is RestoreStatus.InProgress -> {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(16.dp),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator()
            }
        }

        is RestoreStatus.Success -> {
            Column(
                modifier = Modifier
                    .padding(top = 72.dp)
                    .fillMaxSize()
            ) {
                val status = restoreStatus as RestoreStatus.Success
                Toast.makeText(
                    context,
                    context.getString(
                        R.string.restoration_completed,
                        status.addedCount,
                        status.sitesCreated
                    ),
                    Toast.LENGTH_LONG
                ).show()
                showRestorePrompt = false
            }
        }

        is RestoreStatus.Error -> {

            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(16.dp),
                contentAlignment = Alignment.Center
            ) {
                if (showRestorePrompt) {
                    Column(
                        modifier = Modifier
                            .background(MaterialTheme.colorScheme.background.copy(alpha = 0.7f))
                            .padding(16.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center
                    ) {

                        if (showFinalMessage) {
                            Toast.makeText(
                                context,
                                context.getString(
                                    R.string.no_data_found,
                                ),
                                Toast.LENGTH_LONG // Duration of the toast (LONG or SHORT)
                            ).show()
                        }

                        showFinalMessage = false
                        TextField(
                            value = phone,
                            onValueChange = { phone = it },
                            modifier = Modifier.fillMaxWidth(),
                            singleLine = true,
                            label = {
                                Text(
                                    stringResource(id = R.string.phone_number),
                                    color = inputLabelColor
                                )
                            },
                            supportingText = {
                                if (phone.isNotEmpty() && !isValidPhoneNumber(phone)) Text(
                                    stringResource(R.string.error_invalid_phone_number, phone)
                                )
                            },
                            isError = phone.isNotEmpty() && !isValidPhoneNumber(phone),
                            colors = TextFieldDefaults.colors(
                                errorLeadingIconColor = Color.Red,
                                cursorColor = inputTextColor,
                                errorCursorColor = Color.Red,
                                focusedIndicatorColor = inputBorder,
                                unfocusedIndicatorColor = inputBorder,
                                errorIndicatorColor = Color.Red
                            )

                        )
                        TextField(
                            value = email,
                            onValueChange = { email = it },
                            modifier = Modifier.fillMaxWidth(),
                            singleLine = true,
                            label = {
                                Text(
                                    stringResource(id = R.string.email),
                                    color = inputLabelColor
                                )
                            },
                            supportingText = {
                                if (email.isNotEmpty() && !android.util.Patterns.EMAIL_ADDRESS.matcher(
                                        email
                                    ).matches()
                                )
                                    Text(stringResource(R.string.error_invalid_email_address))
                            },
                            isError = email.isNotEmpty() && !android.util.Patterns.EMAIL_ADDRESS.matcher(
                                email
                            ).matches(),
                            colors = TextFieldDefaults.colors(
                                errorLeadingIconColor = Color.Red,
                                cursorColor = inputTextColor,
                                errorCursorColor = Color.Red,
                                focusedIndicatorColor = inputBorder,
                                unfocusedIndicatorColor = inputBorder,
                                errorIndicatorColor = Color.Red
                            ),
                        )

                        Spacer(modifier = Modifier.height(16.dp))
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Button(
                                onClick = {
                                    showRestorePrompt = false
                                    showFinalMessage = false
                                },
                                modifier = Modifier.weight(1f)
                            ) {
                                Text(stringResource(id = R.string.cancel))
                            }

                            Spacer(modifier = Modifier.width(8.dp))
                            Button(
                                onClick = {
                                    if (phone.isNotBlank() || email.isNotBlank()) {
                                        showRestorePrompt =
                                            false
                                        farmViewModel.restoreData(
                                            deviceId = deviceId,
                                            phoneNumber = phone,
                                            email = email,
                                            farmViewModel = farmViewModel
                                        ) { success ->
                                            finalMessage = if (success) {
                                                context.getString(R.string.data_restored_successfully)
                                            } else {
                                                context.getString(R.string.no_data_found)
                                            }
                                            showFinalMessage = true
                                        }
                                    }
                                },
                                enabled = email.isNotBlank() || phone.isNotBlank(),
                                modifier = Modifier.weight(1f)
                            ) {
                                Text(context.getString(R.string.restore_data))
                            }
                        }
                    }
                } else {
                    if (showFinalMessage) {
                        // Show the toast
                        Toast.makeText(
                            context,
                            finalMessage,
                            Toast.LENGTH_LONG
                        ).show()
                    }
                }
            }
        }

        null -> {
            if (isLoading.value) {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(16.dp),
                    contentAlignment = Alignment.Center
                ) {

                }
            } else {
                Column(
                    modifier = Modifier
                        .padding(top = 48.dp)
                ) {

                }
            }
        }
    }

    if (showDeleteDialog.value) {
        SiteDeleteAllDialogPresenter(showDeleteDialog, onProceedFn = { onDelete() })
    }
}


@Composable
fun SiteCard(
    site: CollectionSite,
    onCardClick: () -> Unit,
    totalFarms: Int,
    farmsWithIncompleteData: Int,
    onDeleteClick: () -> Unit,
    farmViewModel: FarmViewModel,
) {
    val showDialog = remember { mutableStateOf(false) }
    if (showDialog.value) {
        UpdateCollectionDialog(
            site = site,
            showDialog = showDialog,
            farmViewModel = farmViewModel,
        )
    }
    val textColor = MaterialTheme.colorScheme.onBackground
    val iconColor = MaterialTheme.colorScheme.onBackground

    Column(
        modifier =
        Modifier
            .fillMaxSize()
            .padding(top = 8.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        ElevatedCard(
            elevation =
            CardDefaults.cardElevation(
                defaultElevation = 6.dp,
            ),
            modifier =
            Modifier
                .background(MaterialTheme.colorScheme.background)
                .fillMaxWidth()
                .padding(8.dp),
            onClick = {
                onCardClick()
            },
        ) {
            Column(
                modifier =
                Modifier
                    .background(MaterialTheme.colorScheme.background)
                    .padding(16.dp),
            ) {
                Row(
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.fillMaxWidth(),
                ) {
                    Column(
                        modifier =
                        Modifier
                            .weight(1.1f)
                            .padding(bottom = 4.dp),
                    ) {
                        Text(
                            text = site.name,
                            style =
                            MaterialTheme.typography.bodySmall.copy(
                                fontSize = 18.sp,
                                fontWeight = FontWeight.Bold,
                                color = textColor,
                            ),
                            modifier =
                            Modifier
                                .padding(bottom = 1.dp),
                        )
                        Text(
                            text = "${stringResource(id = R.string.agent_name)}: ${site.agentName}",
                            style = MaterialTheme.typography.bodySmall.copy(color = textColor),
                            modifier =
                            Modifier
                                .padding(bottom = 1.dp),
                        )
                        if (site.phoneNumber.isNotEmpty()) {
                            Text(
                                text = "${stringResource(id = R.string.phone_number)}: ${site.phoneNumber}",
                                style = MaterialTheme.typography.bodySmall.copy(color = textColor),
                            )
                        }

                        Text(
                            text = stringResource(
                                id = R.string.total_farms,
                                totalFarms
                            ),
                            style = MaterialTheme.typography.bodySmall.copy(
                                fontWeight = FontWeight.Bold,
                            ),
                        )

                        Text(
                            text = stringResource(
                                id = R.string.total_farms_with_incomplete_data,
                                farmsWithIncompleteData
                            ),
                            style = MaterialTheme.typography.bodySmall.copy(
                                fontWeight = FontWeight.Bold,
                                color = Color.Blue
                            ),
                        )
                    }
                    IconButton(
                        onClick = {
                            showDialog.value = true
                        },
                        modifier =
                        Modifier
                            .size(24.dp)
                            .padding(4.dp),
                    ) {
                        Icon(
                            imageVector = Icons.Default.Edit,
                            contentDescription = "Update",
                            tint = iconColor,
                        )
                    }
                    Spacer(modifier = Modifier.padding(10.dp))
                    IconButton(
                        onClick = {
                            onDeleteClick()
                        },
                        modifier =
                        Modifier
                            .size(24.dp)
                            .padding(4.dp),
                    ) {
                        Icon(
                            imageVector = Icons.Default.Delete,
                            contentDescription = "Delete",
                            tint = Color.Red,
                        )
                    }
                }
            }
        }
    }
}


@Composable
fun SkeletonSiteCard() {
    val isDarkTheme = isSystemInDarkTheme()
    val backgroundColor = if (isDarkTheme) Color.Black else Color.White
    val placeholderColor = if (isDarkTheme) Color.DarkGray else Color.LightGray

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(top = 8.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        ElevatedCard(
            elevation = CardDefaults.cardElevation(defaultElevation = 6.dp),
            modifier = Modifier
                .background(backgroundColor)
                .fillMaxWidth()
                .padding(2.dp)
                .shimmer()
        ) {
            Column(
                modifier = Modifier
                    .background(backgroundColor)
                    .padding(8.dp),
            ) {
                Row(
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier
                        .background(backgroundColor)
                        .padding(2.dp)
                        .fillMaxWidth()
                ) {
                    // Checkbox placeholder with shimmer
                    Box(
                        modifier = Modifier
                            .size(24.dp)
                            .background(placeholderColor, shape = CircleShape)
                    )
                    Spacer(modifier = Modifier.width(8.dp))

                    // Placeholder for site info
                    Column(
                        modifier = Modifier
                            .weight(1f)
                            .padding(start = 2.dp)
                    ) {
                        repeat(5) { // Repeat placeholders for each text line
                            Spacer(
                                modifier = Modifier
                                    .height(16.dp)
                                    .fillMaxWidth(0.8f)
                                    .background(placeholderColor, shape = RoundedCornerShape(4.dp))
                                    .padding(bottom = 4.dp)
                            )
                        }

                        Spacer(modifier = Modifier.height(8.dp))

                        // Placeholder for farm info
                        Box(
                            modifier = Modifier
                                .height(16.dp)
                                .fillMaxWidth(0.5f)
                                .background(placeholderColor, shape = RoundedCornerShape(4.dp))
                        )

                        Spacer(modifier = Modifier.height(4.dp))

                        // Placeholder for farms with incomplete data
                        Box(
                            modifier = Modifier
                                .height(16.dp)
                                .fillMaxWidth(0.6f)
                                .background(placeholderColor, shape = RoundedCornerShape(4.dp))
                        )
                    }

                    Spacer(modifier = Modifier.width(8.dp))

                    // Icon placeholder with shimmer
                    Box(
                        modifier = Modifier
                            .size(24.dp)
                            .background(placeholderColor, shape = CircleShape)
                    )
                }
            }
        }
    }
}


@Composable
fun CustomPaginationControls(
    currentPage: Int,
    totalPages: Int,
    onPageChange: (Int) -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(8.dp),
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically
    ) {
        IconButton(
            onClick = { if (currentPage > 1) onPageChange(currentPage - 1) },
            enabled = currentPage > 1
        ) {
            Icon(
                painter = painterResource(R.drawable.previous),
                contentDescription = "Previous Page"
            )
        }

        Text("Page $currentPage of $totalPages", modifier = Modifier.padding(horizontal = 16.dp))

        IconButton(
            onClick = { if (currentPage < totalPages) onPageChange(currentPage + 1) },
            enabled = currentPage < totalPages
        ) {
            Icon(painter = painterResource(R.drawable.next), contentDescription = "Next Page")
        }
    }
}