// ignore_for_file: unnecessary_new, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_print, unused_import, unnecessary_brace_in_string_interps, non_constant_identifier_names, unused_local_variable, unused_catch_clause, unnecessary_overrides, unnecessary_string_interpolations

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather/weather.dart';
import 'package:weather_icons/weather_icons.dart';
//import 'package:flutter_localization/flutter_localization.dart' as loc;
import 'package:weather_animation/weather_animation.dart';
import 'package:home_widget/home_widget.dart' as home_widget;
import 'package:http/http.dart';
import 'package:intl/intl.dart' as intl;
import 'dart:async';
import './main.dart';
import './utils.dart';
import './secret.dart';

final gKey = GlobalKey<_HomeScreenState>();

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
  if (box.get('firstTime') == null) {
    // todo
  } else {
    isThisFirstTimeUsing = box.get('firstTime') ;
  }
}

void loadStorageWeatherData() {
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
    logger.warn('City not found');
  } on ClientException catch (e) {
    logger.warn('Failed to fetch weather data');
    print(e);
  }

  current_weather.temperature =
      w?.temperature?.celsius?.round().toString() ?? 'No data';
  current_weather.tempfeelslike =
      w?.tempFeelsLike?.celsius?.round().toString() ?? 'No data';
  current_weather.humidity = w?.humidity?.round().toString() ?? 'No data';
  current_weather.windSpeed = ((w?.windSpeed ?? 1) * 3.6).round().toString();
  current_weather.windDeg = w?.windDegree?.round() ?? 1;
  current_weather.countryname = w?.country ?? 'No data';
  current_weather.mainWeather = w?.weatherMain ?? 'No data';
  current_weather.weatherDescription =
      w?.weatherDescription?.toString() ?? 'Error';
  current_weather.pressure = ((w?.pressure ?? 10000000) / 1000).toString();
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
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  void disconnected() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Scaffold(body: DisconnectedScreen())),
    );
  }

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
    getWeatherData(settings[0]);
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
      displacement: 15,
      backgroundColor: Colors.white,
      onRefresh: () async {
        setState(() {
          getWeatherData(settings[0]);
          getCountrybyCity(settings[0]);
          setStorage();
          Future.delayed(Duration(seconds: 2));
        });
      },
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        decoration: BoxDecoration(
          //color: Colors.transparent,
          gradient: background,
        ),
        child: SafeArea(
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
                      Builder(builder: (context) {
                        if (current_weather.mainWeather == "Drizzle") {
                          return RainVeryLight();
                        } else if (current_weather.mainWeather == "Rain") {
                          return RainLight();
                        } else if (current_weather.mainWeather ==
                            "Thunderstorm") {
                          return ThunderStorm();
                        } else if (current_weather.mainWeather == "Snow") {
                          return Snowing();
                        } else {
                          return Text('');
                        }
                      }),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              /*if (language.currentLanguage == "en") {
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
                              }*/
                              Widget h = Column(
                                children: [
                                  Container(
                                    constraints: BoxConstraints(
                                      minWidth:
                                          MediaQuery.of(context).size.width -
                                              20,
                                    ),
                                    child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            language.setEnglish();
                                          });
                                          logger.info(
                                              "Chnaging language to English");
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('EN - English',
                                            style: mediumSSB)),
                                  ),
                                  Container(
                                    constraints: BoxConstraints(
                                      minWidth:
                                          MediaQuery.of(context).size.width -
                                              20,
                                    ),
                                    child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            language.setPersian();
                                          });
                                          Navigator.of(context).pop();
                                          logger.info(
                                              "Chnaging language to Persian");
                                        },
                                        child: Text('FA - فارسی',
                                            style: mediumSSB)),
                                  ),
                                ],
                              );
                              universalPopUp(context, h);
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return SettingsPage();
                              }));
                            },
                            icon: Icon(Icons.translate_outlined,
                                color: IconColor),
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
                            onPressed: () async {
                              /*setState(() {
                                _showDialog(context);
                                getData();
                              });
          
                              if (await getCountrybyCity(settings[0])) {
                                showSnackBar('${language.cityNotFound}', context);
                              }
          
                              setState(() {});*/
                            },
                            icon:
                                Icon(Icons.settings_outlined, color: IconColor),
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
                  height: 115,
                  width: MediaQuery.of(context).size.width - 5,
                  child: frf(
                      //key: frfKey,
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
                        Builder(builder: (context) {
                          if (current_weather.pressure!.length <= 6) {
                            return Text(
                              '${language.pressure}: ${current_weather.pressure!} ${language.atm}',
                              style: smallSB,
                            );
                          } else {
                            return Text('No data', style: smallSB);
                          }
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RainLight extends StatelessWidget {
  const RainLight({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 5,
      width: MediaQuery.of(context).size.width - 5,
      child: RainWidget(
        rainConfig: RainConfig(
          widthDrop: 4,
          areaYStart: 0,
          areaXStart: 0,
          areaXEnd: MediaQuery.of(context).size.width,
          areaYEnd: MediaQuery.of(context).size.height,
          lengthDrop: 10,
          count: 10,
          isRoundedEndsDrop: true,
        ),
      ),
    );
  }
}

class RainVeryLight extends StatelessWidget {
  const RainVeryLight({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 5,
      width: MediaQuery.of(context).size.width - 5,
      child: RainWidget(
        rainConfig: RainConfig(
          widthDrop: 4,
          areaYStart: 0,
          areaXStart: 0,
          areaXEnd: MediaQuery.of(context).size.width,
          areaYEnd: MediaQuery.of(context).size.height,
          lengthDrop: 10,
          count: 20,
          isRoundedEndsDrop: true,
        ),
      ),
    );
  }
}

class ThunderStorm extends StatelessWidget {
  const ThunderStorm({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 5,
      width: MediaQuery.of(context).size.width - 5,
      child: Stack(
        children: [
          ThunderWidget(
            thunderConfig: ThunderConfig(
              flashStartMill: 5,
              flashEndMill: 1000,
              pauseStartMill: 0,
              pauseEndMill: 60,
            ),
          ),
          RainWidget(
            rainConfig: RainConfig(
              widthDrop: 2,
              areaYStart: 0,
              areaXStart: 0,
              areaXEnd: MediaQuery.of(context).size.width,
              areaYEnd: MediaQuery.of(context).size.height,
              lengthDrop: 5,
              count: 45,
              isRoundedEndsDrop: true,
            ),
          ),
        ],
      ),
    );
  }
}

class Snowing extends StatelessWidget {
  const Snowing({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 5,
      width: MediaQuery.of(context).size.width - 5,
      child: SnowWidget(
        snowConfig: SnowConfig(
          areaYStart: 0,
          areaXStart: 0,
          areaXEnd: MediaQuery.of(context).size.width,
          areaYEnd: MediaQuery.of(context).size.height,
          size: 20,
          count: 25,
          fallMinSec: 1,
          fallMaxSec: 15,
          waveMinSec: 1,
          waveMaxSec: 2,
        ),
      ),
    );
  }
}

class DisconnectedScreen extends StatelessWidget {
  const DisconnectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: Column(
        children: [
          Text('d'),
        ],
      )),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              Text('Test text'),
            ],
          ),
        ),
      ),
    );
  }
}
