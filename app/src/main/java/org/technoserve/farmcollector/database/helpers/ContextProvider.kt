package org.technoserve.farmcollector.database.helpers

import android.content.Context

object ContextProvider {
    private lateinit var context: Context

    fun initialize(context: Context) {
        ContextProvider.context = context.applicationContext
    }

    fun getContext(): Context = context
}
