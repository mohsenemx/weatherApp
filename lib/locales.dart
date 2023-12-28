// ignore_for_file: camel_case_types
import 'homescreen.dart';
import 'utils.dart';

class currentLang {
  String helloText = "";
  String byeText = "";
  String mainWeather = "";
  List<String> futureMainWeathers = [];
  String currentLanguage = "en";
  String cityNotFound = "City not found";
  String setCityName = "Set city name";
  String sunset = "Sunset";
  String sunrise = "Sunrise";
  String lastUpdated = "Last updated";
  String feelsLike = "Feel like";
  String humidity = "Humidity";
  String windSpeed = "Wind speed";
  String pressure = "Pressure";
  String madeBy = "Made by MohsenEMX";
  String kmh = "km/h";
  String atm = "atm";
  String firstTime =
      "Hi there, we noticed it's your first time using the app! \n Before we get started, you need to set a city to begin with.";
  String go = "Go";
  void setEnglish() {
    englishLang f = englishLang();
    mainWeather = current_weather.mainWeather!;
    currentLanguage = "en";
    helloText = f.helloText;
    byeText = f.byeText;
    cityNotFound = f.cityNotFound;
    setCityName = f.setCityName;
    sunset = f.sunset;
    sunrise = f.sunrise;
    lastUpdated = f.lastUpdated;
    feelsLike = f.feelsLike;
    humidity = f.humidity;
    windSpeed = f.windSpeed;
    pressure = f.pressure;
    madeBy = f.madeBy;
    kmh = f.kmh;
    atm = f.atm;
    firstTime = f.firstTime;
    go = f.go;
  }

  void setPersian() {
    persianLang f = persianLang();
    translateWeather(current_weather.mainWeather);
    currentLanguage = "fa";
    helloText = f.helloText;
    byeText = f.byeText;
    cityNotFound = f.cityNotFound;
    setCityName = f.setCityName;
    sunset = f.sunset;
    sunrise = f.sunrise;
    lastUpdated = f.lastUpdated;
    feelsLike = f.feelsLike;
    humidity = f.humidity;
    windSpeed = f.windSpeed;
    pressure = f.pressure;
    madeBy = f.madeBy;
    kmh = f.kmh;
    atm = f.atm;
    firstTime = f.firstTime;
    go = f.go;
  }

  // only for persian
  void translateWeather(String? weather) {
    if (weather == "Clear") {
      mainWeather = "صاف";
    } else if (weather == "Rain") {
      mainWeather = "بارانی";
    } else if (weather == "Clouds") {
      mainWeather = "ابری";
    } else if (weather == "Thunderstorm") {
      mainWeather = "طوفانی";
    } else if (weather == "Snow") {
      mainWeather = "برفی";
    } else if (weather == "Drizzle") {
      mainWeather = "باران سبک";
    } else if (weather == "Mist" || weather == "Fog") {
      mainWeather = "مه";
    } else {
      mainWeather = "صاف";
    }
  }

  String translateWeatherReturn(String? weather, String lang) {
    if (lang == "en") {
      return weather!;
    } else {
      if (weather == "Clear") {
        return "صاف";
      } else if (weather == "Rain") {
        return "بارانی";
      } else if (weather == "Clouds") {
        return "ابری";
      } else if (weather == "Thunderstorm") {
        return "طوفانی";
      } else if (weather == "Snow") {
        return "برفی";
      } else if (weather == "Drizzle") {
        return "باران سبک";
      } else if (weather == "Mist" || weather == "Fog") {
        return "مه";
      } else {
        return "صاف";
      }
    }
  }

  void translateWeathersLoop(List<HourlyForecastClass> f) {
    for (int i = 0; i < 10; i++) {
      String a = "";
      String weather = f[i].mainWeather!;
      if (currentLanguage == "fa") {
        if (weather == "Clear") {
          a = "صاف";
        } else if (weather == "Rain") {
          a = "بارانی";
        } else if (weather == "Clouds") {
          a = "ابری";
        } else if (weather == "Thunderstorm") {
          a = "طوفانی";
        } else if (weather == "Snow") {
          a = "برفی";
        } else if (weather == "Drizzle") {
          a = "باران سبک";
        } else if (weather == "Mist" || weather == "Fog") {
          a = "مه";
        } else {
          a = "صاف";
        }
      } else {
        a = weather;
      }
      futureMainWeathers.add(a);
    }
  }
}

class englishLang {
  String helloText = "Hi";
  String byeText = "Bye";

  String cityNotFound = "City not found";
  String setCityName = "Set city name";
  String sunset = "Sunset";
  String sunrise = "Sunrise";
  String lastUpdated = "Last updated";
  String feelsLike = "Feels like";
  String humidity = "Humidity";
  String windSpeed = "Wind speed";
  String pressure = "Pressure";
  String madeBy = "Made by MohsenEMX";
  String kmh = "km/h";
  String atm = "atm";
  String firstTime =
      "Hi there, we noticed it's your first time using the app! \n Before we get started, you need to set a city to begin with.";
  String go = "Go";
}

class persianLang {
  String helloText = "سلام";
  String byeText = "خدانگه دار";

  String cityNotFound = "شهر پیدا نشد";
  String setCityName = "اسم شهر را انتخاب کنید";
  String sunset = "غروب";
  String sunrise = "طلوع";
  String lastUpdated = "آخرین بروزرسانی";
  String feelsLike = "دما قابل حس";
  String humidity = "رطوبت";
  String windSpeed = "سرعت باد";
  String pressure = "فشار هوا";
  String madeBy = "ساخته شده توسط محسن";
  String kmh = "کیلومتر بر ساعت";
  String atm = "اتمسفر";
  String firstTime =
      "سلام! به نظر میرسه که اولین باره که این برنامه رو نصب کردی! \n قبل از اینکه شروع کنیم، باید یک شهر انتخاب کنی. اسم شهر باید اینگلیسی باشه.";
  String go = "برو بریم";
}
