// ignore_for_file: camel_case_types

class currentLang {
  String helloText = "";
  String byeText = "";
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
  void setEnglish() {
    englishLang f = englishLang();
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
  }
  void setPersian() {
    persianLang f = persianLang();
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
  String feelsLike = "Feel like";
  String humidity = "Humidity";
  String windSpeed = "Wind speed";
  String pressure = "Pressure";
  String madeBy = "Made by MohsenEMX";
}


class persianLang {
  String helloText = "سلام";
  String byeText = "خدانگه دار";

  String cityNotFound = "شهر پیدا نشد";
  String setCityName = "اسم شهر را انتخاب کنید";
  String sunset = "غروب";
  String sunrise = "طلوع";
  String lastUpdated = "آخرین بروزرسانی";
  String feelsLike = "حس میشود";
  String humidity = "رطوبت";
  String windSpeed = "سرعت باد";
  String pressure = "فشار هوا";
  String madeBy = "ساخته شده توسط محسن";
}
