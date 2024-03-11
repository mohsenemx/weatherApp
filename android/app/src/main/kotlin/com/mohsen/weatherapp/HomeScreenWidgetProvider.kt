package com.mohsen.weatherapp

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
class HomeScreenWidgetProvider: HomeWidgetProvider() {
        override val paint: Any
        get() {
            // Implement the property as needed
            // You can return an instance of a class or any other value
            TODO("Not implemented")
        }
     override fun onUpdate(context: Context, appWidgetManager:AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach{ widgetId ->
        val views = RemoteViews(context.packageName, R.layout.widget_layout).apply{
            val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java);
            setOnClickPendingIntent(R.id.widget_root, pendingIntent);
            val temp = widgetData.getString("_mainTemp","something went wrong");
            val weather = widgetData.getString("_mainWeather","something went wrong");
            val feelsLike = widgetData.getString("_feelsLike","something went wrong");
            setTextViewText(R.id.tempText, temp);
            setTextViewText(R.id.mainText, weather);
            setTextViewText(R.id.feelsLikeText, feelsLike);

            //setOnClickPendingIntent(R.id.bt_update, backgroundIntent)
        }
        appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}