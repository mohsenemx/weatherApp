// ignore_for_file: unnecessary_new, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_print, unused_import, unnecessary_brace_in_string_interps, non_constant_identifier_names, unused_local_variable, unused_catch_clause, unnecessary_overrides

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
TextStyle mediumSB = TextStyle(fontFamily: 'sfsb', fontSize: 25);
TextStyle smallSB = TextStyle(fontFamily: 'sfsb', fontSize: 15);
BoxDecoration divDecoration = BoxDecoration(
  color: Colors.white.withOpacity(0.35),
  borderRadius: BorderRadius.circular(10),
);
double IconSize = 60;
Color? IconColor = Colors.grey[900];
WeatherFactory wf = new WeatherFactory(WeatherAPIKey);
Weather? w;
bool useNight = false;
IconData? localIcon;
Gradient? background = Gradient.lerp(gar1, gar2, 0.5);

WeatherData current_weather = new WeatherData();
List<String> settings = ['No city set'];

void setStorage() {
  box.put('settings', settings);
  box.put('lastWeather', current_weather);
}

void loadStorage() {
  if (box.get('settings') == null) {
    // todo
  } else {
    settings = box.get('settings');
  }
  if (box.get('lastWeather') == null) {
    // todo
  } else {
    current_weather = box.get('lastWeather');
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

  current_weather.temperature =
      w?.temperature?.celsius?.round().toString() ?? 'Error';
  current_weather.tempfeelslike =
      w?.tempFeelsLike?.celsius?.round().toString() ?? 'Error';
  current_weather.humidity = w?.humidity?.round().toString() ?? 'Error';
  current_weather.windSpeed = ((w?.windSpeed ?? 1) * 3.6).round().toString();
  current_weather.countryname = w?.country ?? 'Error';
  current_weather.mainWeather = w?.weatherMain ?? 'Error';
  current_weather.weatherDescription =
      w?.weatherDescription?.toString() ?? 'Error';
  current_weather.pressure = ((w?.pressure ?? 1000) / 1000).toString();
  current_weather.sunrise =
      '${w?.sunrise?.hour.toString()}:${w?.sunrise?.minute.toString()}';
  current_weather.sunset =
      '${w?.sunset?.hour.toString()}:${w?.sunset?.minute.toString()}';
  List<String> formattedTime =
      DateFormat.Hm().format(DateTime.now()).split(':');
  current_weather.lastUpdated = formattedTime[0];
  DateTime date = DateTime.now();
  current_weather.lastUpdatedFull =
      '${DateFormat.EEEE().format(date)}, ${date.hour}:${date.minute}';
  current_weather.mainIcon = current_weather.mainWeather;
  localIcon = chooseIcon(current_weather.mainIcon ?? 'nodata');
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
  void f() {}
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final myController = TextEditingController();
  late String userData;
  Future<void> _showDialog(context) async {
    return showDialog<void>(
      context: context,
      //barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Column(
            children: [
              TextField(
                controller: myController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Set a city name',
                  hintText: 'Set a city name',
                ),
              ),
              SizedBox(
                width: 125,
                child: TextButton(
                  child: const Text('OK'),
                  onPressed: () async {
                    userData = myController.text;

                    setStorage();
                    setState(() {
                      getData();
                      settings[0] = (userData != '') ? userData : "No city set";
                    });

                    print(settings[0]);
                    myController.text = '';

                    FocusManager.instance.primaryFocus?.unfocus();

                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  TextEditingController? cityName;
  AnimationController? iconAnimation;
  bool tt = true;
  late final Animation<Offset> _offsetAnimation;
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
    iconAnimation =
        new AnimationController(vsync: this, duration: Duration(seconds: 1));

    _offsetAnimation = Tween<Offset>(
      begin: Offset(-6, 0),
      end: Offset(0.0, 0),
    ).animate(CurvedAnimation(parent: iconAnimation!, curve: Curves.linear));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        iconAnimation!.forward();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    iconAnimation!.dispose();
    cityName!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      displacement: 10,
      backgroundColor: Colors.white,
      onRefresh: () async {
        setState(() {
          getWeatherData(settings[0]);
          getCountrybyCity(settings[0]);
        });
        setStorage();
        Future.delayed(Duration(seconds: 3));
      },
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        decoration: BoxDecoration(
          //color: Colors.transparent,
          gradient: background,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
              ),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width + 10,
                  maxHeight: 30,
                ),
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${current_weather.countryname}, ',
                          style: mediumSB,
                        ),
                        Text(settings[0], style: mediumSB),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            onPressed: () {
                              setState(() {
                                _showDialog(context);
                                getData();
                              });

                              if (wrongCity) {
                                showSnackBar('City not found', context);
                                wrongCity = false;
                              }
                              setState(() {});
                            },
                            icon: Icon(Icons.search, color: IconColor))
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 200,
                  ),
                  SizedBox(
                    height: 150,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SlideTransition(
                              position: _offsetAnimation,
                              child: Icon(
                                localIcon,
                                color: IconColor,
                                size: IconSize,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              current_weather.temperature ?? "Error",
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
                                '${current_weather.mainWeather}',
                                style: mediumSB,
                              ),
                            ),
                            Center(
                              child: Text(
                                'Feels like ${current_weather.tempfeelslike} °C',
                                style: mediumSB,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text('Sunrise: ${current_weather.sunrise}', style: smallSB),
                  Text('Sunset: ${current_weather.sunset}', style: smallSB),
                ],
              ),
              Center(
                child: Text('Last Updated: ${current_weather.lastUpdatedFull}',
                    style: smallSB),
              ),
              SizedBox(
                height: 15,
              ),
              SizedBox(
                height: 130,
                width: MediaQuery.of(context).size.width - 20,
                child: futureForecastWidget,
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
                      'Humidity:   ${current_weather.humidity}%',
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
                      'Wind Speed:   ${current_weather.windSpeed} km/h',
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
                      '${current_weather.pressure!} atm',
                      style: smallSB,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 35,
              ),
              Text('Made by MohsenEMX', style: smallSB)
            ],
          ),
        ),
      ),
    );
  }
}
