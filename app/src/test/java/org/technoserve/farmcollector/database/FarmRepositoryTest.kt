package org.technoserve.farmcollector.database

import org.junit.Assert.*

import androidx.arch.core.executor.testing.InstantTaskExecutorRule
import androidx.lifecycle.MutableLiveData
import kotlinx.coroutines.runBlocking
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.mockito.Mock
import org.mockito.Mockito.*
import org.mockito.MockitoAnnotations
import org.technoserve.farmcollector.database.dao.FarmDAO
import org.technoserve.farmcollector.database.models.CollectionSite
import org.technoserve.farmcollector.database.models.Farm
import org.technoserve.farmcollector.repositories.FarmRepository
import java.util.UUID

class FarmRepositoryTest {

    @get:Rule
    val rule = InstantTaskExecutorRule()

    @Mock
    private lateinit var mockFarmDAO: FarmDAO
    private lateinit var farmRepository: FarmRepository

    @Before
    fun setUp() {
        MockitoAnnotations.openMocks(this)  // Use openMocks instead of initMocks
        farmRepository = FarmRepository(mockFarmDAO)
    }

    @Test
    fun `get readAllSites returns all sites`() {
        val expectedSites = MutableLiveData<List<CollectionSite>>()
        `when`(mockFarmDAO.getSites()).thenReturn(expectedSites)

        val sites = farmRepository.readAllSites
        assertEquals(expectedSites, sites)
    }

    @Test
    fun `get readData returns all farms`() {
        val expectedFarms = MutableLiveData<List<Farm>>()
        `when`(mockFarmDAO.getData()).thenReturn(expectedFarms)

        val data = farmRepository.readData
        assertEquals(expectedFarms, data)
    }

    @Test
    fun `readAllFarms returns farms for specific site`() {
        val siteId = 1L
        val expectedFarms = MutableLiveData<List<Farm>>()
        `when`(mockFarmDAO.getAll(siteId)).thenReturn(expectedFarms)

        val farms = farmRepository.readAllFarms(siteId)
        assertEquals(expectedFarms, farms)
    }

    @Test
    fun `addFarm inserts new farm when no duplicate exists`(): Unit = runBlocking {
        val farm = Farm(
            siteId = 1L,
            farmerPhoto = "photo.jpg",
            farmerName = "Old Farmer",
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
        `when`(mockFarmDAO.getFarmByDetails(UUID.randomUUID(), anyString(), anyString(), anyString())).thenReturn(null)

        farmRepository.addFarm(farm)
        verify(mockFarmDAO).insert(farm)
    }

    @Test
    fun `addFarm updates farm if duplicate exists and needs update`() = runBlocking {
        // Setup data for existing farm
        val existingFarm = Farm(
            siteId = 1L,
            farmerPhoto = "photo.jpg",
            farmerName = "Old Farmer",
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

        val newFarm = existingFarm.copy(farmerName = "New Farmer")

        // Mock DAO method to return existing farm
        `when`(mockFarmDAO.getFarmByDetails(existingFarm.remoteId, existingFarm.memberId, existingFarm.village, existingFarm.district))
            .thenReturn(existingFarm)

        // Perform the add operation
        farmRepository.addFarm(newFarm)

        // Verify that the DAO update method was called
        verify(mockFarmDAO).update(newFarm)
    }


    @Test
    fun `addSite inserts site if not duplicate`(): Unit = runBlocking {
        val site = CollectionSite(
            district = "Test District", name = "Test Site", village = "Test Village",
            agentName = "TEST Agent",
            phoneNumber = "1234555",
            email = "test@email.com",
            createdAt = 17000,
            updatedAt = 17000
        )
        `when`(mockFarmDAO.getSiteByDetails(anyLong(), anyString(), anyString(), anyString())).thenReturn(null)

        val result = farmRepository.addSite(site)
        assertTrue(result)
        verify(mockFarmDAO).insertSite(site)
    }

    @Test
    fun `deleteFarmById deletes farm by remote id`() = runBlocking {
        val farm = Farm(
            siteId = 1L,
            farmerPhoto = "photo.jpg",
            farmerName = "Old Farmer",
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

        farmRepository.deleteFarmById(farm)
        verify(mockFarmDAO).deleteFarmByRemoteId(farm.remoteId)
    }

    @Test
    fun `getTotalFarmsForSite returns total farms for a site`() {
        val siteId = 1L
        val expectedTotal = MutableLiveData(10)
        `when`(mockFarmDAO.getTotalFarmsForSite(siteId)).thenReturn(expectedTotal)

        val total = farmRepository.getTotalFarmsForSite(siteId)
        assertEquals(expectedTotal, total)
    }

    @Test
    fun `getFarmsWithIncompleteDataForSite returns incomplete farms count`() {
        val siteId = 1L
        val expectedCount = MutableLiveData(2)
        `when`(mockFarmDAO.getFarmsWithIncompleteDataForSite(siteId)).thenReturn(expectedCount)

        val incompleteCount = farmRepository.getFarmsWithIncompleteDataForSite(siteId)
        assertEquals(expectedCount, incompleteCount)
    }
}