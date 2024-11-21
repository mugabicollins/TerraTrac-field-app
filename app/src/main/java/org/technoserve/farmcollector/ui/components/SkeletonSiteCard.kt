package org.technoserve.farmcollector.ui.components

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
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ElevatedCard
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.valentinilk.shimmer.shimmer
import org.technoserve.farmcollector.ui.screens.farms.isSystemInDarkTheme

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