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

  print(j);
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
  try {
    a = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=${cLat}&lon=${cLon}&appid=${WeatherAPIKey}&units=metric&cnt=5'));
    print(a.body);
    j = jsonDecode(a.body);
  } on http.ClientException catch (e) {
    print(e);
  }

  //print(j);

  if (j?['list'] ?? true) {
    return;
  }
  print(j['list']);
  for (int i = 0; i < 5; i++) {
    HourlyForecastClass hfc = HourlyForecastClass();
    hfc.mainWeather = j['list'][i]['weather'][0]['main'];
    hfc.unixTime = j['list'][i]['dt'].toString();
    hfc.temp = double.parse(j['list'][i]['main']['temp'].toString()).round().toString();
    hfc.convertUnixTime();
    futureForeCast.add(hfc);
  }

  /*futureForeCast.forEach((element) {
    print(
        'futureforecasts $i, mainWeather: ${element.mainWeather} temp: ${element.temp}, time: ${element.time}');
    i++;
  });*/
}

class HourlyForecast extends StatelessWidget {
  final mainWeather;
  final temp;
  final time;
  const HourlyForecast(
      {super.key,
      required this.mainWeather,
      required this.temp,
      required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: 110,
        maxWidth: 60,
        minWidth: 50,
      ),
      decoration: divDecoration,
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
    );
  }
}
