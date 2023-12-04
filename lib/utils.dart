// ignore_for_file: unused_element, unused_import, unnecessary_brace_in_string_interps, avoid_print, prefer_const_constructors, prefer_typing_uninitialized_variables, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';
import './secret.dart';
import './homescreen.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

bool wrongCity = false;
String? cLat;
String? cLon;

Future<String> getCountrybyCity(String cityName) async {
  var a;
  var j;
  try {
    a = await http.get(Uri.parse(
        'http://api.openweathermap.org/geo/1.0/direct?q=${cityName}&limit=1&appid=${WeatherAPIKey}'));
    j = jsonDecode(a.body);
  } on http.ClientException catch (e) {
    print(e);
  }

  //print(j);
  try {
    cLat = j[0]['lat'].toStringAsFixed(2) ?? 36.33;
    cLon = j[0]['lon'].toStringAsFixed(2) ?? 53.03;
    return j[0]['country'];
  } on RangeError catch (e) {
    print(e);
    return "";
  } on NoSuchMethodError catch (e) {
    print(e);
    return "";
  }
}

IconData chooseIcon(String name) {
  if (name == 'Thunderstorm') {
    return WeatherIcons.thunderstorm;
  } else if (name == 'Snow') {
    return WeatherIcons.snow;
  } else if (name == 'Drizzle') {
    return WeatherIcons.rain_mix;
  } else if (name == 'Rain') {
    return WeatherIcons.rain;
  } else if (name == 'Clear') {
    if (useNight) {
      return WeatherIcons.night_clear;
    } else {
      return WeatherIcons.day_sunny;
    }
  } else if (name == 'Clouds') {
    return WeatherIcons.cloudy;
  } else if (name == 'Mist') {
    return WeatherIcons.fog;
  } else if (name == 'Fog') {
    return WeatherIcons.fog;
  } else if (name == 'nodata') {
    return WeatherIcons.night_fog;
  }
  return IconData(0);
}

void showSnackBar(String message, context) {
  var snackBar = SnackBar(
    backgroundColor: Colors.red,
    content: Text(
      message,
      style: TextStyle(
        fontFamily: 'sf',
        color: Colors.black,
      ),
    ),
    duration: Duration(seconds: 2),
  );

// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

class HourlyForecastClass {
  String? mainWeather;
  String? temp;
  String? unixTime;
  String? time;
  String? a;
  // add full information
  void convertUnixTime() {
    var date = DateTime.fromMillisecondsSinceEpoch(int.parse(unixTime!) * 1000);
    String a = DateFormat.Hm().format(date).toString();
    time = a;
  }
}

List<HourlyForecastClass> futureForeCast = [];
Future<void> getNext5Hours(cityName) async {
  //print('$cLat $cLon');
  var a, j;
  if (cLat == "" || cLat == null) {
    cLat = 36.33.toString();
  }
  if (cLon == "" || cLon == null) {
    cLon = 53.03.toString();
  }
  try {
    a = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=${cLat}&lon=${cLon}&appid=${WeatherAPIKey}&units=metric&cnt=10'));
    //print(a.body);
    j = jsonDecode(a.body);
  } on http.ClientException catch (e) {
    print(e);
  }

  for (int i = 0; i < 10; i++) {
    HourlyForecastClass hfc = HourlyForecastClass();
    hfc.mainWeather = j?['list'][i]['weather'][0]['main'] ?? 'Error';
    hfc.unixTime = j?['list'][i]['dt'].toString() ?? '1';
    hfc.temp = double.parse(j?['list'][i]['main']['temp'].toString() ?? '1000')
        .round()
        .toString();
    hfc.convertUnixTime();
    futureForeCast.add(hfc);
  }
}

class HourlyForecast extends StatelessWidget {
  final mainWeather;
  final temp;
  final time;
  final int index;
  const HourlyForecast({
    super.key,
    required this.mainWeather,
    required this.temp,
    required this.time,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300 + (index * 100)),
        curve: Curves.fastOutSlowIn,
        constraints: BoxConstraints(
          maxHeight: 110,
          maxWidth: 60,
          minWidth: 50,
        ),
        decoration: divDecoration,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                chooseIcon(mainWeather),
                color: IconColor,
              ),
              SizedBox(
                height: 10,
              ),
              Text(mainWeather, style: smallSB),
              SizedBox(
                height: 5,
              ),
              Text('${temp} °C', style: smallSB),
              Text(time, style: smallSB),
            ],
          ),
        ),
      ),
    );
  }
}

Widget futureForecastWidget = SizedBox.expand(
  child: ListView.separated(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemCount: futureForeCast.length,
      itemBuilder: (BuildContext context, int index) {
        return HourlyForecast(
          mainWeather: futureForeCast[index].mainWeather,
          temp: futureForeCast[index].temp,
          time: futureForeCast[index].time,
          index: index,
        );
      },
      separatorBuilder: (context, index) => SizedBox()),
);
