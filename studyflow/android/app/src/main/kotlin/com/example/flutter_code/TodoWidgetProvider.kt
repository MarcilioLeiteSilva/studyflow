package com.example.flutter_code

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class TodoWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                val pendingCount = widgetData.getInt("pending_count", 0)
                setTextViewText(R.id.pending_count, pendingCount.toString())
                
                setTextViewText(R.id.task_title_0, widgetData.getString("task_title_0", ""))
                setTextViewText(R.id.task_title_1, widgetData.getString("task_title_1", ""))
                setTextViewText(R.id.task_title_2, widgetData.getString("task_title_2", ""))
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
