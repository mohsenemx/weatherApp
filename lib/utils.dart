// ignore_for_file: unused_element, unused_import, unnecessary_brace_in_string_interps, avoid_print, prefer_const_constructors, prefer_typing_uninitialized_variables, avoid_unnecessary_containers, camel_case_types

import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';
import './secret.dart';
import './main.dart';
import './homescreen.dart';
import 'locales.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
String? cLat;
String? cLon;
Future<bool> getCountrybyCity(String cityName) async {
  var a;
  var j;
  try {
    logger.info('Trying to get country from city name');
    a = await http.get(Uri.parse(
        'http://api.openweathermap.org/geo/1.0/direct?q=${cityName}&limit=1&appid=${WeatherAPIKey}'));
    j = jsonDecode(a.body);
  } on http.ClientException catch (e) {
    logger.warn('Failed to get city name, error: ${e.message}');
    print(e);
  }

  try {
    logger.info('Trying to parse location data');
    cLat = j[0]['lat'].toStringAsFixed(4) ?? 0;
    cLon = j[0]['lon'].toStringAsFixed(4) ?? 0;
    return false;
  } on RangeError catch (e) {
    logger.warn(
        'Failed to parse location data, Error probably is caused because the api returned empty data, error: ${e.message}');
    print(e);
    hfs.currentState?.isWrongCity();
    return true;
  } on NoSuchMethodError catch (e) {
    logger.warn('Failed to parse location data, error: ${e}');
    print(e);
    return true;
  }
}

IconData chooseIcon(String name) {
  logger.info('Choosing an icon');
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
      return WeatherIcons.moon_waning_crescent_4;
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
  } else {
    return Icons.check_box;
  }
}

void showSnackBar(String message, context) {
  logger.info('Displaying city not found snackbar');
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
  String? humidity;
  String? windSpeed;
  String? windDeg;
  String? feelsLike;
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
  logger.info('Fetching future forecast data');
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
    logger.warn('Failed to fetch forecast data ${e.message}');
    print(e);
  }

  for (int i = 0; i < 10; i++) {
    HourlyForecastClass hfc = HourlyForecastClass();
    hfc.mainWeather = j?['list'][i]['weather'][0]['main'] ?? 'Error';
    hfc.unixTime = j?['list'][i]['dt'].toString() ?? '1';
    hfc.feelsLike = j?['list'][i]['main']['feels_like'].toStringAsFixed(1);
    hfc.windSpeed = j?['list'][i]['wind']['speed'].toString() ?? 'Error';
    hfc.windDeg = j?['list'][i]['wind']['deg'].toString() ?? '1';
    hfc.humidity = j?['list'][i]['main']['humidity'].toString() ?? 'Error';
    hfc.temp = double.parse(j?['list'][i]['main']['temp'].toString() ?? '100')
        .round()
        .toString();
    hfc.convertUnixTime();
    futureForeCast.add(hfc);
  }
  language.translateWeathersLoop(futureForeCast);
}

class HourlyForecast extends StatelessWidget {
  final mainWeather;
  final temp;
  final time;
  final humidity;
  final windSpeed;
  final windDeg;
  final feelsLike;
  final int index;
  const HourlyForecast({
    super.key,
    required this.mainWeather,
    required this.temp,
    required this.time,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    required this.feelsLike,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
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
          child: GestureDetector(
            onTap: () {
              showTempDiag(
                context,
                index,
                temp,
                mainWeather,
                feelsLike,
                humidity,
                time,
                windSpeed,
                windDeg,
                
              );
            },
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
                Text('$temp °C', style: smallSB),
                Text(time, style: smallSB),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//GlobalKey<frfState> frfKey = GlobalKey();

class frf extends StatefulWidget {
  const frf({super.key});

  @override
  State<frf> createState() => frfState();
}

class frfState extends State<frf> {
  List<String> futureMainWeathers = [];
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: futureForeCast.length,
          itemBuilder: (BuildContext context, int index) {
            return HourlyForecast(
              mainWeather: futureForeCast[index].mainWeather,
              temp: futureForeCast[index].temp,
              time: futureForeCast[index].time,
              humidity: futureForeCast[index].humidity,
              windSpeed: futureForeCast[index].windSpeed,
              windDeg: futureForeCast[index].windDeg,
              feelsLike: futureForeCast[index].feelsLike,

              index: index,
            );
          },
          separatorBuilder: (context, index) => SizedBox()),
    );
  }
}

Widget? futureForecastWidget;
Future<void> showTempDiag(
  context,
  int index,
  String temp,
  String weather,
  String feelsLike,
  String humidity,
  String time,
  String windSpeed,
  String windDeg,
) async {
  IconData weatherIcon = chooseIcon(weather);
  int windDegInt = int.parse(windDeg);
  String windSpeedDouble = (double.parse(windSpeed) * 3.6).toStringAsFixed(1);
  return showDialog<void>(
    context: context,
    //barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: DivColor,
        elevation: 5,
        title: Column(
          children: [
            Text(
              time,
              style: mediumSSB,
            ),
            SizedBox(
              height: 5,
            ),
            Text('${temp} °C', style: mediumBigBold),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  weatherIcon,
                  color: IconColor,
                ),
                SizedBox(
                  width: 5,
                ),
              ],
            ),
            Builder(builder: (context) {
              if (language.currentLanguage == "fa") {
                return Text(
                  ' ${current_weather.tempfeelslike} °C  ${language.feelsLike} ',
                  style: mediumSSB,
                );
              } else {
                return Text(
                  '${language.feelsLike} ${current_weather.tempfeelslike} °C',
                  style: mediumSSB,
                );
              }
            }),
            SizedBox(
              height: 15,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WindIcon(
                  degree: windDegInt,
                  color: IconColor,
                ),
                SizedBox(
                  width: 5,
                ),
                Text('${windSpeedDouble} ${language.kmh}', style: smallSB),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Future<void> universalPopUp(context, Widget twidget) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: DivColor,
        title: twidget,
      );
    },
  );
}
