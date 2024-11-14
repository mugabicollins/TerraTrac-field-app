package org.technoserve.farmcollector.map

import androidx.activity.viewModels
import org.junit.Assert.*



import androidx.arch.core.executor.testing.InstantTaskExecutorRule
import androidx.lifecycle.Observer
import com.google.maps.android.compose.MapType
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.Assert.*
import org.mockito.Mockito.*
import org.mockito.kotlin.mock
import org.technoserve.farmcollector.utils.GeoCalculator

class MapViewModelTest {

    @get:Rule
    val instantTaskExecutorRule = InstantTaskExecutorRule()

    private lateinit var viewModel: MapViewModel

    @Before
    fun setUp() {
        viewModel = MapViewModel()
    }

    @After
    fun tearDown() {
    }

    @Test
    fun `test initial state values`() {
        val initialState = viewModel.state.value
        assertNull(initialState.lastKnownLocation)
        initialState.markers?.let { assertTrue(it.isEmpty()) }
        assertTrue(initialState.clusterItems.isEmpty())
        assertFalse(initialState.clearMap)
        assertEquals(MapType.NORMAL, initialState.mapType)
    }

    @Test
    fun `calculateArea sets coordinates and updates calculated area`() {
        val coordinates = listOf(Pair(10.0, 20.0), Pair(10.0, 30.0), Pair(20.0, 20.0))
        val area = viewModel.calculateArea(coordinates)

        assertEquals(coordinates, viewModel.coordinates.value)
        assertEquals(GeoCalculator.calculateArea(coordinates), area, 0.0)
    }

    @Test
    fun `showAreaDialog sets calculated area and shows dialog on valid input`() = runBlocking {
        val validArea = "100.0"
        val enteredArea = "100.0"

        viewModel.showAreaDialog(validArea, enteredArea)

        assertEquals(validArea, viewModel.size.first())
        assertTrue(viewModel.showDialog.first())
    }

    @Test
    fun `showAreaDialog shows invalid input on non-numeric area`() = runBlocking {
        viewModel.showAreaDialog("100.0", "InvalidInput")

        assertEquals("Invalid input.", viewModel.size.first())
        assertFalse(viewModel.showDialog.first())
    }

    @Test
    fun `dismissDialog hides dialog`() = runBlocking {
        viewModel.dismissDialog()
        assertFalse(viewModel.showDialog.first())
    }

    @Test
    fun `addCoordinate adds single coordinate to cluster items`() {
        viewModel.addCoordinate(10.0, 20.0)

        val clusterItems = viewModel.state.value.clusterItems
        assertTrue(clusterItems.any { it.snippet == "(10.0, 20.0)" })
    }

    @Test
    fun `addCoordinates adds polygon options to cluster items`() {
        val coordinates = listOf(Pair(10.0, 20.0), Pair(10.0, 30.0), Pair(20.0, 20.0))

        viewModel.addCoordinates(coordinates)

        val clusterItems = viewModel.state.value.clusterItems
        assertTrue(clusterItems.any { it.title == "Central Point" })
    }

    @Test
    fun `addMarker adds single marker to markers list`() {
        val coordinate = Pair(10.0, 20.0)
        viewModel.addMarker(coordinate)

        viewModel.state.value.markers?.let { assertTrue(it.contains(coordinate)) }
    }

    @Test
    fun `clearCoordinates clears markers and cluster items`() {
        viewModel.addMarker(Pair(10.0, 20.0))
        viewModel.addCoordinate(10.0, 20.0)

        viewModel.clearCoordinates()

        viewModel.state.value.markers?.let { assertTrue(it.isEmpty()) }
        assertTrue(viewModel.state.value.clusterItems.isEmpty())
    }

    @Test
    fun `removeLastCoordinate removes the last marker`() {
        viewModel.addMarker(Pair(10.0, 20.0))
        viewModel.addMarker(Pair(15.0, 25.0))

        viewModel.removeLastCoordinate()

        viewModel.state.value.markers?.let { assertFalse(it.contains(Pair(15.0, 25.0))) }
    }

    @Test
    fun `onMapTypeChange changes map type`() {
        viewModel.onMapTypeChange(MapType.SATELLITE)

        assertEquals(MapType.SATELLITE, viewModel.state.value.mapType)
    }
}
