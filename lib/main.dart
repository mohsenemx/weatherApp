// ignore_for_file: prefer_const_constructors, avoid_print, prefer_const_literals_to_create_immutables, prefer_typing_uninitialized_variables, unnecessary_brace_in_string_interps, use_build_context_synchronously, await_only_futures, invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:weatherapp/homescreen.dart';
import 'package:hive_flutter/hive_flutter.dart';

import './utils.dart';

var box;
Future<void> initStorage() async {
  box = await Hive.openBox('settings');
  // ar wtf = Hive.box('todo_storage');
  box.put('test', 'success');
}

Future<void> getData() async {
  //countryname = await getCountrybyCity(settings[0]);
  await getWeatherData(settings[0]);
  mainIcon = await chooseIcon(mainWeather!);
  if (int.parse(nowHour!) > 18) {
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

LinearGradient gar3 = LinearGradient(colors: [
  Color.fromARGB(255, 18, 0, 83).withOpacity(0.87),
  Color.fromARGB(255, 8, 0, 83).withOpacity(0.8),
], begin: Alignment.topLeft, end: Alignment.center);
LinearGradient gar4 = LinearGradient(
  colors: [
    Color.fromRGBO(19, 19, 71, 0.861),
    Color.fromARGB(255, 1, 36, 88).withOpacity(0.86),
    Color.fromARGB(133, 14, 0, 78).withOpacity(0.82),
  ],
  begin: Alignment.center,
  end: Alignment.bottomRight,
);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await initStorage();
  loadStorage();
  await getData();
  await getCountrybyCity(settings[0]);
  await getNext5Hours(settings[0]);
  scheduledCall();
  runApp(MainApp());
}

Future<void> scheduledCall() async {
  gKey.currentState?.setState(() {});
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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

                    setState(() {
                      getData();
                      settings[0] = (userData != '') ? userData : "No city set";
                    });
                    setStorage();
                    await scheduledCall();
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: gKey,
      body: HomeScreen(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Padding(
          padding: const EdgeInsets.only(left: 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${countryname}, ',
                style: mediumSB,
              ),
              Text(settings[0], style: mediumSB),
            ],
          ),
        ),
        forceMaterialTransparency: true,
        actions: [
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
            icon: Icon(Icons.search, color: IconColor),
          ),
        ],
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
    );
  }
}

final myController = TextEditingController();
late String userData;
