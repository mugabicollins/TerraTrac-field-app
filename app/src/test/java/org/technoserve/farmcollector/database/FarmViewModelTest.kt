package org.technoserve.farmcollector.database

import android.app.Application
import androidx.lifecycle.LiveData
import androidx.lifecycle.Observer
import kotlinx.coroutines.runBlocking
import org.junit.Assert.*
import org.junit.Before

import org.junit.Test
import org.mockito.ArgumentMatchers.any
import org.mockito.Mock
import org.mockito.Mockito.never
import org.mockito.Mockito.verify
import org.mockito.Mockito.`when`
import org.mockito.MockitoAnnotations


object LiveDataTestUtil {
    fun <T> getValue(liveData: LiveData<T>): T {
        val observer = Observer<T> {}
        liveData.observeForever(observer)
        val value = liveData.value
        liveData.removeObserver(observer)
        return value!!
    }
}

class FarmViewModelTest {

    @Mock
    private lateinit var mockFarmRepository: FarmRepository

    @Mock
    private lateinit var mockFarmDAO: FarmDAO

    @Mock
    private lateinit var mockLiveData: LiveData<List<Farm>>

    private lateinit var farmViewModel: FarmViewModel

    @Mock
    private lateinit var mockApplication: Application

    @Before
    fun setUp() {
        MockitoAnnotations.openMocks(this)  // Initialize mocks

        // Initialize the repository with the mocked DAO
        `when`(mockFarmRepository.readAllFarms(any())).thenReturn(mockLiveData)

        // Initialize the FarmViewModel with the mocked Application and repository
        farmViewModel = FarmViewModel(mockApplication)
    }


    @Test
    fun `addFarm adds farm if not duplicate`(): Unit = runBlocking {
        // Given
        val newFarm = Farm(
            siteId = 1L,
            farmerPhoto = "photo.jpg",
            farmerName = "New Farmer",
            memberId = "12345",
            village = "Village A",
            district = "District X",
            purchases = 10f,
            size = 100f,
            latitude = "12.34",
            longitude = "56.78",
            coordinates = listOf(Pair(12.34, 56.78)),
            accuracyArray = listOf(5.0f),
            synced = false,
            scheduledForSync = false,
            createdAt = System.currentTimeMillis(),
            updatedAt = System.currentTimeMillis(),
            needsUpdate = true
        )
        val siteId = 1L
        val existingFarm = null // simulate no duplicate farm exists

        // When
        `when`(mockFarmRepository.isFarmDuplicateBoolean(newFarm)).thenReturn(false)
        `when`(mockFarmRepository.addFarm(newFarm)).thenReturn(Unit)
        `when`(mockFarmRepository.readAllFarms(siteId)).thenReturn(mockLiveData)

        farmViewModel.addFarm(newFarm, siteId)

        // Then
        verify(mockFarmRepository).addFarm(newFarm)
        assertNotNull(farmViewModel.farms.value)
    }

    @Test
    fun `addFarm returns error if duplicate farm exists`() = runBlocking {
        // Given
        val duplicateFarm = Farm(
            siteId = 1L,
            farmerPhoto = "photo.jpg",
            farmerName = "New Farmer",
            memberId = "12345",
            village = "Village A",
            district = "District X",
            purchases = 10f,
            size = 100f,
            latitude = "12.34",
            longitude = "56.78",
            coordinates = listOf(Pair(12.34, 56.78)),
            accuracyArray = listOf(5.0f),
            synced = false,
            scheduledForSync = false,
            createdAt = System.currentTimeMillis(),
            updatedAt = System.currentTimeMillis(),
            needsUpdate = true
        )
        val siteId = 1L
        val existingFarm = duplicateFarm

        // When
        `when`(mockFarmRepository.isFarmDuplicateBoolean(duplicateFarm)).thenReturn(true)

        farmViewModel.addFarm(duplicateFarm, siteId)

        // Then
        verify(mockFarmRepository, never()).addFarm(duplicateFarm)
        assertNull(farmViewModel.farms.value)
    }


    @Test
    fun `updateFarm updates farm successfully`() = runBlocking {
        // Given
        val newFarm = Farm(
            siteId = 1L,
            farmerPhoto = "photo.jpg",
            farmerName = "New Farmer",
            memberId = "12345",
            village = "Village A",
            district = "District X",
            purchases = 10f,
            size = 100f,
            latitude = "12.34",
            longitude = "56.78",
            coordinates = listOf(Pair(12.34, 56.78)),
            accuracyArray = listOf(5.0f),
            synced = false,
            scheduledForSync = false,
            createdAt = System.currentTimeMillis(),
            updatedAt = System.currentTimeMillis(),
            needsUpdate = true
        )
        val existingFarm = newFarm
        val updatedFarm = existingFarm.copy(farmerName = "Updated Farmer")
        val siteId = 1L

        // When
        `when`(mockFarmRepository.updateFarm(updatedFarm)).thenReturn(Unit)
        `when`(mockFarmRepository.readAllFarms(siteId)).thenReturn(mockLiveData)

        farmViewModel.updateFarm(updatedFarm)

        // Then
        verify(mockFarmRepository).updateFarm(updatedFarm)
        assertNotNull(farmViewModel.farms.value)
        assertTrue(farmViewModel.farms.value?.contains(updatedFarm) == true)
    }


    @Test
    fun `deleteFarmById deletes farm successfully`() = runBlocking {
        // Given
        val newFarm = Farm(
            siteId = 1L,
            farmerPhoto = "photo.jpg",
            farmerName = "New Farmer",
            memberId = "12345",
            village = "Village A",
            district = "District X",
            purchases = 10f,
            size = 100f,
            latitude = "12.34",
            longitude = "56.78",
            coordinates = listOf(Pair(12.34, 56.78)),
            accuracyArray = listOf(5.0f),
            synced = false,
            scheduledForSync = false,
            createdAt = System.currentTimeMillis(),
            updatedAt = System.currentTimeMillis(),
            needsUpdate = true
        )
        val farmToDelete = newFarm

        // When
        `when`(mockFarmRepository.deleteFarmById(farmToDelete)).thenReturn(Unit)
        `when`(mockFarmRepository.readAllFarms(farmToDelete.siteId)).thenReturn(mockLiveData)

        farmViewModel.deleteFarmById(farmToDelete)

        // Then
        verify(mockFarmRepository).deleteFarmById(farmToDelete)
        assertNotNull(farmViewModel.farms.value)
    }

    @Test
    fun `addFarm updates LiveData`() = runBlocking {
        // Given

        val newFarm = Farm(
            siteId = 1L,
            farmerPhoto = "photo.jpg",
            farmerName = "New Farmer",
            memberId = "12345",
            village = "Village A",
            district = "District X",
            purchases = 10f,
            size = 100f,
            latitude = "12.34",
            longitude = "56.78",
            coordinates = listOf(Pair(12.34, 56.78)),
            accuracyArray = listOf(5.0f),
            synced = false,
            scheduledForSync = false,
            createdAt = System.currentTimeMillis(),
            updatedAt = System.currentTimeMillis(),
            needsUpdate = true
        )

        val siteId = 1L

        // When
        `when`(mockFarmRepository.isFarmDuplicateBoolean(newFarm)).thenReturn(false)
        `when`(mockFarmRepository.readAllFarms(siteId)).thenReturn(mockLiveData)

        farmViewModel.addFarm(newFarm, siteId)

        // Then
        val updatedFarms = LiveDataTestUtil.getValue(farmViewModel.farms)
        assertTrue(updatedFarms.contains(newFarm))
    }
}