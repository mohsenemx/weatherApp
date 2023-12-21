// ignore_for_file: prefer_const_constructors, avoid_print, prefer_const_literals_to_create_immutables, prefer_typing_uninitialized_variables, unnecessary_brace_in_string_interps, use_build_context_synchronously, await_only_futures, invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:weatherapp/homescreen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import './utils.dart';
part 'main.g.dart';

var box;

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
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentsDir = await getApplicationDocumentsDirectory();
  String path = appDocumentsDir.path;

  Hive
    ..init(path)
    ..registerAdapter<WeatherData>(WeatherDataAdapter());
  //Hive.registerAdapter(WeatherDataAdapter());
  //Hive.init(path).registerAdapter(WeatherDataAdapter());

  await initStorage();
  loadStorage();
  await getData();
  await getCountrybyCity(settings[0]); // call to determine the geo location
  await getNext5Hours(settings[0]);
  runApp(MainApp());
}

Future<void> scheduledCall(void d) async {
  gKey.currentState?.setState(() {
    d;
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Weather App",
      home: HomeWidget(),
    );
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: gKey,
      body: HomeScreen(),
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
       
    );
  }
}
