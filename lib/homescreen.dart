// ignore_for_file: unnecessary_new, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_print, unused_import, unnecessary_brace_in_string_interps, non_constant_identifier_names, unused_local_variable, unused_catch_clause

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import './main.dart';
import './utils.dart';
import './secret.dart';

final gKey = GlobalKey<ScaffoldState>();
//
TextStyle bigBold = TextStyle(fontFamily: 'sf', fontSize: 60);
TextStyle mediumBold = TextStyle(fontFamily: 'sf', fontSize: 20);
TextStyle mediumSB = TextStyle(fontFamily: 'sfsb', fontSize: 30);
TextStyle smallSB = TextStyle(fontFamily: 'sfsb', fontSize: 15);
BoxDecoration divDecoration = BoxDecoration(
  color: Colors.white.withOpacity(0.4),
  borderRadius: BorderRadius.circular(10),
);
double IconSize = 60;
Color? IconColor = Colors.grey[900];
WeatherFactory wf = new WeatherFactory(WeatherAPIKey);
Weather? w;
bool useNight = false;
IconData? mainIcon;
String? countryname;
String? temperature;
String? tempfeelslike;
String? humidity;
String? windSpeed;
String? mainWeather;
String? weatherDescription;
String? nowHour;
String? pressure;
String? sunrise;
String? sunset;
Gradient? background = Gradient.lerp(gar1, gar2, 0.5);
List<String> settings = ['No city set'];
void setStorage() {
  box.put('settings', settings);
}

void loadStorage() {
  if (box.get('settings') == null) {
    // todo
  } else {
    settings = box.get('settings');
  }
}

Future<void> getWeatherData(String cityName) async {
  // do something
  //double? temperature;
  try {
    w = await wf.currentWeatherByCityName(cityName);
  } on OpenWeatherAPIException catch (e) {
    wrongCity = true;
  } on ClientException catch (e) {
    print(e);
  }

  temperature = w?.temperature?.celsius?.round().toString() ?? 'Error';
  tempfeelslike = w?.tempFeelsLike?.celsius?.round().toString() ?? 'Error';
  humidity = w?.humidity?.round().toString() ?? 'Error';
  windSpeed = ((w?.windSpeed ?? 1) * 3.6).round().toString();
  countryname = w?.country ?? 'Error';
  mainWeather = w?.weatherMain ?? 'Error';
  weatherDescription = w?.weatherDescription?.toString() ?? 'Error';
  pressure = ((w?.pressure ?? 1000) / 1000).toString();
  sunrise = '${w?.sunrise?.hour.toString()}:${w?.sunrise?.minute.toString()}';
  sunset = '${w?.sunset?.hour.toString()}:${w?.sunset?.minute.toString()}';
  List<String> formattedTime =
      DateFormat.Hm().format(w?.date ?? DateTime.now()).split(':');
  nowHour = formattedTime[0];
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
  void f() {}
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController? cityName;
  @override
  void initState() {
    super.initState();
    if (useNight) {
      background = Gradient.lerp(gar3, gar4, 0.5);
      bigBold = TextStyle(
          fontFamily: 'sf',
          fontSize: 60,
          color: Color.fromRGBO(192, 192, 192, 0.949));
      mediumBold = TextStyle(
          fontFamily: 'sf',
          fontSize: 20,
          color: Color.fromRGBO(192, 192, 192, 0.949));
      mediumSB = TextStyle(
          fontFamily: 'sfsb',
          fontSize: 30,
          color: Color.fromRGBO(192, 192, 192, 0.949));
      IconColor = Color.fromRGBO(192, 192, 192, 0.949);
      divDecoration = BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
      );
      smallSB = TextStyle(
          fontFamily: 'sfsb',
          fontSize: 15,
          color: Color.fromRGBO(192, 192, 192, 0.949));
    }
    cityName = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      getData();
    });
    return RefreshIndicator(
      displacement: 10,
      backgroundColor: Colors.white,
      onRefresh: () async {
        setState(() {
          getWeatherData(settings[0]);
          getCountrybyCity(settings[0]);
        });
        Future.delayed(Duration(seconds: 3));
      },
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
          minWidth: MediaQuery.of(context).size.width,
          maxHeight: MediaQuery.of(context).size.height,
          maxWidth: MediaQuery.of(context).size.width,
        ),
        decoration: BoxDecoration(
          gradient: background,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 400,
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          mainIcon,
                          color: IconColor,
                          size: IconSize,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          temperature ?? "Error",
                          style: bigBold,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              ' °C',
                              style: mediumBold,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            '${mainWeather}',
                            style: mediumSB,
                          ),
                        ),
                        Center(
                          child: Text(
                            'Feels like ${tempfeelslike} °C',
                            style: mediumBold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Sunrise: ${sunrise}',
                      style: smallSB,
                    ),
                  ],
                ),
                SizedBox(
                  width: 100,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Sunset:  ${sunset}',
                      style: smallSB,
                    ),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ListView.builder(
                  itemCount: futureForeCast.length,
                  itemBuilder: (BuildContext context, int index) {
                    return HourlyForecast(
                      mainWeather: futureForeCast[index].mainWeather,
                      temp: futureForeCast[index].temp,
                      time: futureForeCast[index].time,
                    );
                  },
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              constraints: BoxConstraints(
                minHeight: 55,
                maxWidth: 350,
              ),
              decoration: divDecoration,
              child: Row(
                // Show humidty
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.water_drop_outlined,
                    color: IconColor,
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Text(
                    'Humidity:   ${humidity}%',
                    style: smallSB,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              constraints: BoxConstraints(
                minHeight: 55,
                maxWidth: 350,
              ),
              decoration: divDecoration,
              child: Row(
                // Show wind speed
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.air,
                    color: IconColor,
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Text(
                    'Wind Speed:   ${windSpeed} km/h',
                    style: smallSB,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              constraints: BoxConstraints(
                minHeight: 55,
                maxWidth: 350,
              ),
              decoration: divDecoration,
              child: Row(
                // Show long description of current weather
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.abc,
                    color: IconColor,
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Text(
                    weatherDescription!,
                    style: smallSB,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              constraints: BoxConstraints(
                minHeight: 55,
                maxWidth: 350,
              ),
              decoration: divDecoration,
              child: Row(
                // Show air pressure
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    WeatherIcons.windy,
                    color: IconColor,
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Text(
                    '${pressure!} atm',
                    style: smallSB,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}
