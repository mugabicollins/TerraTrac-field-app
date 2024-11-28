package org.technoserve.farmcollector.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.technoserve.farmcollector.R
import org.technoserve.farmcollector.database.models.Farm
import org.technoserve.farmcollector.ui.screens.farms.formatInput
/**
 * A card displaying a farm's information.
 *
 * @param farm The Farm object to display.
 * @param onCardClick A callback to be invoked when the card is clicked.
 * @param onDeleteClick A callback to be invoked when the delete icon is clicked.
 */
@Composable
fun FarmCard(
    farm: Farm,
    onCardClick: () -> Unit,
    onDeleteClick: () -> Unit,
) {
    val textColor = MaterialTheme.colorScheme.onBackground
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
                    Text(
                        text = farm.farmerName,
                        style =
                        MaterialTheme.typography.bodySmall.copy(
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Bold,
                            color = textColor,
                        ),
                        modifier =
                        Modifier
                            .weight(1.1f)
                            .padding(bottom = 4.dp),
                    )
                    Text(
                        text = "${stringResource(id = R.string.size)}: ${formatInput(farm.size.toString())} ${
                            stringResource(id = R.string.ha)
                        }",
                        style = MaterialTheme.typography.bodySmall.copy(color = textColor),
                        modifier =
                        Modifier
                            .weight(0.9f)
                            .padding(bottom = 4.dp),
                    )
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
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.fillMaxWidth(),
                ) {
                    Text(
                        text = "${stringResource(id = R.string.village)}: ${farm.village}",
                        style = MaterialTheme.typography.bodySmall.copy(color = textColor),
                        modifier = Modifier.weight(1f),
                    )
                    Text(
                        text = "${stringResource(id = R.string.district)}: ${farm.district}",
                        style = MaterialTheme.typography.bodySmall.copy(color = textColor),
                        modifier = Modifier.weight(1f),
                    )
                }

                // Show the label if the farm needs an update
                if (farm.needsUpdate) {
                    Text(
                        text = stringResource(id = R.string.needs_update),
                        color = Color.Blue,
                        fontWeight = FontWeight.Bold,
                        fontSize = 12.sp,  // Adjust font size
                        modifier = Modifier.padding(top = 4.dp)
                    )
                }
            }
        }
    }
}