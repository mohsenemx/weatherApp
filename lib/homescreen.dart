// ignore_for_file: unnecessary_new, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_print, unused_import, unnecessary_brace_in_string_interps, non_constant_identifier_names, unused_local_variable, unused_catch_clause, unnecessary_overrides, unnecessary_string_interpolations

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather/weather.dart';
import 'package:weather_icons/weather_icons.dart';
//import 'package:flutter_localization/flutter_localization.dart' as loc;
import 'package:http/http.dart';
import 'package:intl/intl.dart' as intl;
import 'dart:async';
import './main.dart';
import './utils.dart';
import './secret.dart';

final gKey = GlobalKey<ScaffoldState>();

TextStyle bigBold = TextStyle(
  fontFamily: 'sf',
  fontSize: 60,
  fontFamilyFallback: ['vazir'],
);
TextStyle mediumBigBold = TextStyle(
  fontFamily: 'sf',
  fontSize: 35,
  fontFamilyFallback: ['vazir'],
);
TextStyle mediumBold = TextStyle(
  fontFamily: 'sf',
  fontSize: 20,
  fontFamilyFallback: ['vazir'],
);
TextStyle mediumSSB = TextStyle(
  fontFamily: 'sfsb',
  fontSize: 17,
  fontFamilyFallback: ['vazir'],
);
TextStyle mediumSB = TextStyle(
  fontFamily: 'sfsb',
  fontSize: 25,
  fontFamilyFallback: ['vazir'],
);
TextStyle smallSB = TextStyle(
  fontFamily: 'sfsb',
  fontSize: 15,
  fontFamilyFallback: ['vazir'],
);
BoxDecoration divDecoration = BoxDecoration(
  color: Colors.white.withOpacity(0.35),
  borderRadius: BorderRadius.circular(10),
);
Color DivColor = Colors.white.withOpacity(0.80);
double IconSize = 60;
Color? IconColor = Colors.grey[900];
WeatherFactory wf = new WeatherFactory(WeatherAPIKey);
Weather? w;
bool useNight = false;
IconData? localIcon;
Gradient? background = Gradient.lerp(gar1, gar2, 0.5);
TextDirection textdir = TextDirection.ltr;
WeatherData current_weather = new WeatherData();
List<String> settings = ['No city set'];

void setStorage() {
  logger.info('Saving data to local storage');
  box.put('settings', settings);
  box.put('lastWeather', current_weather);
  box.put('firstTime', isThisFirstTimeUsing); //
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
  if (box.get('firstTime') == null) {
    // todo
  } else {
    isThisFirstTimeUsing = box.get('firstTime');
  }
}

Future<void> getWeatherData(String cityName) async {
  // do something
  //double? temperature;
  try {
    w = await wf.currentWeatherByCityName(cityName);
  } on OpenWeatherAPIException catch (e) {
    logger.warn('City not found');
    wrongCity = true;
  } on ClientException catch (e) {
    logger.warn('Failed to fetch weather data');
    print(e);
  }

  current_weather.temperature =
      w?.temperature?.celsius?.round().toString() ?? 'Error';
  current_weather.tempfeelslike =
      w?.tempFeelsLike?.celsius?.round().toString() ?? 'Error';
  current_weather.humidity = w?.humidity?.round().toString() ?? 'Error';
  current_weather.windSpeed = ((w?.windSpeed ?? 1) * 3.6).round().toString();
  current_weather.windDeg = w?.windDegree?.round() ?? 1;
  current_weather.countryname = w?.country ?? 'Error';
  current_weather.mainWeather = w?.weatherMain ?? 'Error';
  current_weather.weatherDescription =
      w?.weatherDescription?.toString() ?? 'Error';
  current_weather.pressure = ((w?.pressure ?? 1000) / 1000).toString();
  current_weather.sunrise =
      '${w?.sunrise?.hour.toString()}:${w?.sunrise?.minute.toString().padLeft(2, '0')}';
  current_weather.sunset =
      '${w?.sunset?.hour.toString()}:${w?.sunset?.minute.toString().padLeft(2, '0')}';
  List<String> formattedTime =
      intl.DateFormat.Hm().format(DateTime.now()).split(':');
  current_weather.lastUpdated = formattedTime[0];
  DateTime date = DateTime.now();
  current_weather.lastUpdatedFull =
      '${intl.DateFormat.EEEE().format(date)}, ${date.hour}:${date.minute}';
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
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '${language.setCityName}',
                  hintText: '${language.setCityName}',
                ),
              ),
              SizedBox(
                width: 125,
                child: TextButton(
                  child: const Text('OK'),
                  onPressed: () async {
                    logger.info(
                        'User searched for a city, name: ${myController.text}');
                    userData = myController.text;

                    setStorage();
                    setState(() {
                      logger.info('Fetching new data from api');
                      getData();
                      getNext5Hours(userData);
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
  @override
  void initState() {
    super.initState();
    if (useNight) {
      logger.info('Using night mode, setting colors');
      background = Gradient.lerp(gar3, gar4, 0.5);
      bigBold = TextStyle(
          fontFamily: 'sf',
          fontSize: 60,
          fontFamilyFallback: ['vazir'],
          color: Color.fromRGBO(192, 192, 192, 0.949));
      mediumBigBold = TextStyle(
          fontFamily: 'sf',
          fontSize: 35,
          fontFamilyFallback: ['vazir'],
          color: Color.fromRGBO(192, 192, 192, 0.949));

      mediumBold = TextStyle(
          fontFamily: 'sf',
          fontSize: 20,
          fontFamilyFallback: ['vazir'],
          color: Color.fromRGBO(192, 192, 192, 0.949));
      mediumSB = TextStyle(
          fontFamily: 'sfsb',
          fontSize: 30,
          fontFamilyFallback: ['vazir'],
          color: Color.fromRGBO(192, 192, 192, 0.949));
      mediumSSB = TextStyle(
          fontFamily: 'sfsb',
          fontFamilyFallback: ['vazir'],
          fontSize: 17,
          color: Color.fromRGBO(192, 192, 192, 0.949));
      IconColor = Color.fromRGBO(192, 192, 192, 0.949);
      divDecoration = BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
      );
      smallSB = TextStyle(
          fontFamily: 'sfsb',
          fontSize: 15,
          fontFamilyFallback: ['vazir'],
          color: Color.fromRGBO(192, 192, 192, 0.949));
      DivColor = Colors.black.withOpacity(0.45);
    }

    cityName = new TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      logger.info('Loaded GUI');
    });
  }

  @override
  void dispose() {
    super.dispose();
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
                  maxHeight: 55,
                ),
                child: Stack(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            if (language.currentLanguage == "en") {
                              setState(() {
                                language.setPersian();
                                //getNext5Hours(settings[0]);
                                frfKey.currentState!.updateTranslations();
                                textdir = TextDirection.rtl;
                              });
                            } else if (language.currentLanguage == "fa") {
                              setState(() {
                                language.setEnglish();
                                //getNext5Hours(settings[0]);
                                frfKey.currentState!.updateTranslations();
                                //language.translateWeathersLoop(futureForeCast);
                                textdir = TextDirection.ltr;
                              });
                            }
                          },
                          icon:
                              Icon(Icons.translate_outlined, color: IconColor),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                              showSnackBar('${language.cityNotFound}', context);
                              wrongCity = false;
                            }
                            setState(() {});
                          },
                          icon: Icon(Icons.settings_outlined, color: IconColor),
                        ),
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
                    height: 160,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              localIcon,
                              color: IconColor,
                              size: IconSize,
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
                                '${language.mainWeather}',
                                style: mediumSB,
                              ),
                            ),
                            Center(
                              child: Builder(builder: (context) {
                                if (language.currentLanguage == "fa") {
                                  return Text(
                                    ' ${current_weather.tempfeelslike}°C  ${language.feelsLike} ',
                                    style: mediumSSB,
                                  );
                                } else {
                                  return Text(
                                    '${language.feelsLike} ${current_weather.tempfeelslike} °C',
                                    style: mediumSSB,
                                  );
                                }
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Directionality(
                textDirection: textdir,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text('${language.sunrise}: ${current_weather.sunrise}',
                        style: smallSB),
                    Text('${language.sunset}: ${current_weather.sunset}',
                        style: smallSB),
                  ],
                ),
              ),
              Center(
                child: Directionality(
                  textDirection: textdir,
                  child: Text(
                      '${language.lastUpdated}: ${current_weather.lastUpdatedFull}',
                      style: smallSB),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              SizedBox(
                height: 130,
                width: MediaQuery.of(context).size.width - 20,
                child: frf(
                  key: frfKey,
                ),
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
                child: Directionality(
                  textDirection: textdir,
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
                        '${language.humidity}:   ${current_weather.humidity}%',
                        style: smallSB,
                      ),
                    ],
                  ),
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
                child: Directionality(
                  textDirection: textdir,
                  child: Row(
                    // Show wind speed
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      WindIcon(
                        degree: current_weather.windDeg ?? 1,
                        color: IconColor,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        '${language.windSpeed}:   ${current_weather.windSpeed} ${language.kmh}',
                        style: smallSB,
                      ),
                    ],
                  ),
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
                child: Directionality(
                  textDirection: textdir,
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
                        '${language.pressure}: ${current_weather.pressure!} ${language.atm}',
                        style: smallSB,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 55,
              ),
              Text('${language.madeBy}', style: smallSB)
            ],
          ),
        ),
      ),
    );
  }
}
