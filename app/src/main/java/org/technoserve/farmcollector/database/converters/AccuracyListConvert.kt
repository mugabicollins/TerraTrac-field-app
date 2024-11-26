package org.technoserve.farmcollector.database.converters

import androidx.room.TypeConverter

/**
 * *
 *  this converter is used to convert Accuracy list values into list to a string representation, enclosed in brackets and  Remove the brackets and split the string into a list
 */

class AccuracyListConvert {
    @TypeConverter
    fun fromAccuracyList(value: List<Float?>?): String? {
        return value?.let {
            "[" + it.joinToString(separator = ",") { it?.toString() ?: "null" } + "]"
        }
    }
    @TypeConverter
    fun toAccuracyList(value: String?): List<Float?>? {
        if (value == "[]") {
            return emptyList()
        }
        return value?.removePrefix("[")?.removeSuffix("]")?.split(",")?.map {
            it.trim().toFloatOrNull()
        }
    }
}