// ignore_for_file: prefer_const_constructors, avoid_print, prefer_const_literals_to_create_immutables, prefer_typing_uninitialized_variables, unnecessary_brace_in_string_interps, use_build_context_synchronously, await_only_futures, invalid_use_of_protected_member, camel_case_types, unused_local_variable, curly_braces_in_flow_control_structures, unnecessary_new

import 'package:flutter/material.dart';
import 'package:weatherapp/homescreen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:weatherapp/locales.dart';
import 'package:home_widget/home_widget.dart' as home_widget;
import 'package:workmanager/workmanager.dart';
import './utils.dart';
import 'dart:io';
part 'main.g.dart';

class fileLogger {
  Directory? storage;
  File? logFile;
  String? fileName;
  fileLogger(String fname) {
    fileName = fname;
  }
  Future<void> getStorage() async {
    storage = await getExternalStorageDirectory() ?? Directory('/');
    logFile = await File('${storage!.path}/${fileName}');
    await divider;
    info("Starting Log Factory");
  }

  void divider() async {
    await logFile!.writeAsString(
        '======================================================= \n',
        mode: FileMode.append);
  }

  void info(String message) async {
    DateTime now = DateTime.now();
    await logFile!.writeAsString(
        '[ ${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}:${now.second}] INFO: ${message} \n',
        mode: FileMode.append);
  }

  void warn(String message) async {
    DateTime now = DateTime.now();
    await logFile!.writeAsString(
        '[ ${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}:${now.second}] WARN: ${message} \n',
        mode: FileMode.append);
  }

  void error(String message) async {
    DateTime now = DateTime.now();
    await logFile!.writeAsString(
        '[ ${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}:${now.second}] ERROR: ${message} \n',
        mode: FileMode.append);
  }
}

var box;
bool isThisFirstTimeUsing = true;

@HiveType(typeId: 0)
class WeatherData {
  @HiveField(0)
  String? mainIcon;
  @HiveField(1)
  String? countryname;
  @HiveField(2)
  String? temperature;
  @HiveField(3)
  String? tempfeelslike;
  @HiveField(4)
  String? humidity;
  @HiveField(5)
  String? windSpeed;
  @HiveField(6)
  String? mainWeather;
  @HiveField(7)
  String? weatherDescription;
  @HiveField(8)
  String? pressure;
  @HiveField(9)
  String? sunrise;
  @HiveField(10)
  String? sunset;
  @HiveField(11)
  String? lastUpdated;
  @HiveField(12)
  String? lastUpdatedFull;
  @HiveField(13)
  int? windDeg;
}

Future<void> initStorage() async {
  box = await Hive.openBox('settings');
  // ar wtf = Hive.box('todo_storage');
  box.put('test', 'success');
}

Future<void> getData() async {
  //countryname = await getCountrybyCity(settings[0]);
  await getWeatherData(settings[0]);
  localIcon = await chooseIcon(current_weather.mainIcon ?? 'nodata');
  if (int.parse(current_weather.lastUpdated ?? '12') > 18) {
    useNight = true;
  } else {
    useNight = false;
  }
}

Color nWhite = Color.fromRGBO(250, 236, 236, 0.898);
Color nDark = Color.fromRGBO(35, 35, 83, 0.9);
LinearGradient gar1 = LinearGradient(
    colors: [nWhite, Colors.red.withOpacity(0.7)],
    begin: Alignment.topLeft,
    end: Alignment.centerRight);
LinearGradient gar2 = LinearGradient(
    colors: [Colors.orange.withOpacity(0.7), Colors.orange.withOpacity(0.8)],
    begin: Alignment.centerLeft,
    end: Alignment.bottomRight);

LinearGradient gar3 = LinearGradient(
  colors: [
    Color.fromRGBO(99, 89, 133, 1),
    Color.fromRGBO(68, 60, 104, 1),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
LinearGradient gar4 = LinearGradient(
  colors: [
    Color.fromRGBO(57, 48, 83, 1),
    Color.fromRGBO(24, 18, 43, 1),
  ],
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
);
fileLogger logger = fileLogger('last.txt');
currentLang language = currentLang();
Future<void> backgroundCallback(Uri? uri) async {
  updateAppWidget();
}

Future<void> updateAppWidget() async {
  await getWeatherData(settings[0]);
  await home_widget.HomeWidget.saveWidgetData<String>(
      '_mainWeather', '${current_weather.mainWeather}');
  await home_widget.HomeWidget.saveWidgetData<String>(
      '_mainTemp', '${current_weather.temperature} °C');
  await home_widget.HomeWidget.saveWidgetData('_feelsLike',
      'Feels like ${current_weather.tempfeelslike ?? 'No data'} °C');
  await home_widget.HomeWidget.updateWidget(
      name: 'HomeScreenWidgetProvider', iOSName: 'HomeScreenWidgetProvider');
}

@pragma("vm:entry-point")
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) {
    final now = DateTime.now();
    getWeatherData(settings[0]);
    return Future.wait<bool?>([
      home_widget.HomeWidget.saveWidgetData<String>(
          '_mainWeather', '${current_weather.mainWeather}'),
      home_widget.HomeWidget.saveWidgetData<String>(
          '_mainTemp', '${current_weather.temperature} °C'),
      home_widget.HomeWidget.saveWidgetData('_feelsLike',
          'Feels like ${current_weather.tempfeelslike ?? 'No data'} °C'),
      home_widget.HomeWidget.updateWidget(
        name: 'HomeScreenWidgetProvider',
        iOSName: 'HomeScreenWidgetProvider',
      ),
    ]).then((value) {
      return !value.contains(false);
    });
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await logger.getStorage();
  // initialize background worker
  Workmanager().initialize(callbackDispatcher);
  // choose a location to store data and logs
  final appDocumentsDir = await getExternalStorageDirectory();
  final appDocs = await getApplicationDocumentsDirectory();
  String path = appDocumentsDir?.path ?? appDocs.path;
  // initialize the local storage
  Hive
    ..init(path)
    ..registerAdapter<WeatherData>(WeatherDataAdapter());

  logger.info('Loading storage');
  // load the data from local storage
  await initStorage();
  
  loadStorage();
  logger.info('Fetching data from api');
  // define 3 required functions as variables

  // register home widget's background worker
  home_widget.HomeWidget.registerBackgroundCallback(backgroundCallback);
  // isn't required but it's prefered to be called before actual loading of GUI
  language.setEnglish();
  logger.info('Loading GUI');
  // finally runn the actual flutter app
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      var getDataD = getData();
      var cbc = getCountrybyCity(settings[0]);
      var next5 = getNext5Hours(settings[0]);
      // execute the functions one by one on seperate cores/threads
      final value = await Future.wait([getDataD, cbc, next5]);
    }
  } on SocketException catch (_) {
    //loadStorageWeatherData();
    gKey.currentState?.disconnected();
  }
  runApp(MainApp());
  
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      /*localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      //locale: Locale('fa'),
      supportedLocales: const [
        Locale('fa'),
        Locale('en'),
      ],*/

      title: "Weather App",
      home: HomeWidget(),
    );
  }
}

GlobalKey<FirstTimeState> hfs = GlobalKey();

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  @override
  void initState() {
    super.initState();
    updateAppWidget();
    home_widget.HomeWidget.widgetClicked.listen((Uri? uri) {
      updateAppWidget();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final List<Locale> systemLocales =
          View.of(context).platformDispatcher.locales;
      String devLang = systemLocales[0].toLanguageTag().substring(0, 2);
      if (devLang == "fa") {
        language.setPersian();
        textdir = TextDirection.rtl;
      } else {
        language.setEnglish();
      }
      if (isThisFirstTimeUsing) {
        return FirstTime(
          key: hfs,
        );
      } else
        return Scaffold(
          body: HomeScreen(
            key: gKey,
          ),
          //backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            forceMaterialTransparency: true,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: false,
          drawer: Drawer(
            child: DrawerButton(onPressed: () {}),
          ),
        );
    });
  }
}

class FirstTime extends StatefulWidget {
  const FirstTime({super.key});

  @override
  State<FirstTime> createState() => FirstTimeState();
}

class FirstTimeState extends State<FirstTime> {
  TextEditingController cName = TextEditingController();
  void isWrongCity() {
    showSnackBar('City not found', context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    if (language.currentLanguage == "en") {
                      setState(() {
                        language.setPersian();
                        language.translateWeathersLoop(futureForeCast);
                        textdir = TextDirection.rtl;
                      });
                    } else if (language.currentLanguage == "fa") {
                      setState(() {
                        language.setEnglish();
                        language.translateWeathersLoop(futureForeCast);
                        textdir = TextDirection.ltr;
                      });
                    }
                  },
                  icon: Icon(Icons.translate_outlined, color: IconColor),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Directionality(
                    textDirection: textdir,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        language.firstTime,
                        style: smallSB,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: cName,
                    autofocus: true,
                    style: mediumSSB,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: language.setCityName,
                      labelText: language.setCityName,
                      labelStyle: smallSB,
                      alignLabelWithHint: true,
                      //helperText: language.setCityName,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        gapPadding: 1,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () async {
                    String udat = cName.text;

                    if (!(await getCountrybyCity(cName.text))) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: new Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                new CircularProgressIndicator(),
                                new Text("Loading"),
                              ],
                            ),
                          );
                        },
                      );
                      new Future.delayed(new Duration(seconds: 3), () {
                        Navigator.pop(context); //pop dialog
                      });
                      setState(() {
                        sleep(Duration(seconds: 2));
                        logger.info('Fetching new data from api');
                        isThisFirstTimeUsing = false;
                        getData();
                        getNext5Hours(cName.text);
                        settings[0] =
                            (cName.text != '') ? cName.text : "No city set";
                        setStorage();
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Scaffold(body: HomeScreen())),
                        );
                      });
                    }
                  },
                  child: Text(language.go, style: mediumSSB),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
