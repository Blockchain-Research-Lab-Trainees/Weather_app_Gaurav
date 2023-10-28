import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gaurav_app/additional_info_item.dart';
import 'package:gaurav_app/geolocation.dart';
import 'package:gaurav_app/hourly_forecast_items.dart';
import 'package:gaurav_app/weather.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:gaurav_app/secrets.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shake/shake.dart';


class WeatherProvider extends ChangeNotifier {  // it is use to maanage & and notify changes to weather data
  Map<String, dynamic>? _weatherData;   // this  is a map that store data  receive from api
  Map<String, dynamic>? _weatherDD;    // store location data
  TextEditingController _controller = TextEditingController();
  TextEditingController get controller => _controller;   // to access controoller
  Map<String, dynamic>? get weatherData => _weatherData;
  Map<String, dynamic>? get weatherDD => _weatherDD;
  String cityName = 'Ghaziabad, IN';
  String get city => cityName;

  Future<void> fetchWeather(String cityName) async {
    try {
      final res = await http.get(
        Uri.parse(
            'http://api.openweathermap.org/data/2.5/forecast?q=$cityName,uk&APPID=${secrets().OpenWeatherApiKey2}'),
      );

      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {   // if response status code is 200 it indicate success
        throw data['message'];
      }

      _weatherData = data;
      notifyListeners();
    } catch (e) {
      throw e.toString();
    }

    

// Create a ShakeDetector instance
    // final ShakeDetector detector = ShakeDetector.waitForStart(
    //   onPhoneShake: () {
    //     // Refresh weather data when the phone is shaken
    //     fetchWeather(cityName);
    //     print('shaken');
    //   },
    // );
    // detector.startListening();

    // WeatherProvider() {
    //   // Start listening for shake events
    //   detector.startListening();
    // }
  }

  weatherLocation _location = weatherLocation();

  late Position _currentPosition;
  // Map<String, dynamic> _weatherData = {};
  String _error = '';

  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      // Handle case when user denies location permission

      _error = 'Location permission denied.';
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition();
      print(_currentPosition);
      _fetchWeatherData(_currentPosition.latitude, _currentPosition.longitude);
    } catch (e) {
      // Handle location retrieval error
      _error = 'Error getting location: $e';
    }
  }

  Future<void> _fetchWeatherData(double lat, double lon) async {   //it give me or fetch current weather locathion using lon &lat
    try {
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=${secrets().OpenWeatherApiKey2}'));

      if (response.statusCode == 200) {
        _weatherDD = json.decode(response.body);
// Notify listeners after updating the data
      notifyListeners();   // after error or data updates it notify widgets to change change data

      } else {
        _error =
            'Error fetching weather data. Status code: ${response.statusCode}';

            notifyListeners();
      }
    } catch (e) {
      // Handle weather data retrieval error

      _error = 'Error fetching weather data: $e';
      notifyListeners();


    }
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {

    double scrollPosition = 0.0;
    

@override
  void initState() {
    super.initState();
     WeatherProvider()._checkLocationPermission();
    WeatherProvider()._checkLocationPermission();
    accelerometerEvents.listen((AccelerometerEvent event) {
      double sensitivity = 2.0;
      setState(() {
        scrollPosition += event.y * sensitivity;
        if (scrollPosition < 0) {
          scrollPosition = 0;
        } else if (scrollPosition > 1.0) {
          scrollPosition = 1.0;
        }
      });
    });
  }

  @override
  void dispose() {   //it remove created object permanently from widgrt tree 
    super.dispose();
    accelerometerEvents.drain();
  }

  
  // @override


  String currentLocation = 'Loading...';

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final H =MediaQuery.sizeOf(context).height;
    final W = MediaQuery.sizeOf(context).width;



    

    return WillPopScope(
        onWillPop: () async {
          return await showExitConfirmationDialog(context);
    
        },
    
    child :Consumer<WeatherProvider>(      // fetch data from proviser and changes or rebuild on change value in provider
      builder: (context, value, child) => 
        
          
          // Image.asset(
          //   'assets/images/back.jpg',
          //   fit: BoxFit.cover,
          //   width: double.infinity,
          //   height: double.infinity,
          // ),
          
          
          
          
          Scaffold(
          appBar: AppBar(
            title: const Text(
              "Weather App",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                padding: EdgeInsets.only(right: 20),
                onPressed: () {
                  weatherProvider.fetchWeather('Ghaziabad, IN');
                },
                icon: const Icon(Icons.refresh),
              ),
      
            ],
          ),
          body: FutureBuilder(
            future: weatherProvider.fetchWeather(value.cityName),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }
      
              final data = weatherProvider.weatherData;
      
              if (data == null) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                );
              }
              currentLocation = value.cityName;
      
              //  final data = snapshot.data;
              final currentTemp =
                  value._weatherData?['list']?[0]?['main']?['temp']?.toString() ??
                      'N/A';
      
              final currentWeatherData = data['list'][0];
              // final currentTemp = value._weatherData!['list'][0]['main']['temp'].toString();
              final currentSky = currentWeatherData['weather'][0]['main'];
              final currentPressure = currentWeatherData['main']['pressure'];
              final currentWindSpeed = currentWeatherData['wind']['speed'];
              final currentHumidity = currentWeatherData['main']['humidity'];
      
              return Consumer<WeatherProvider>(
                  builder: (context, value, child) => SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                
                                TextFormField(
                                  style: TextStyle(color: Colors.black),
                                  // validator: _validateEmail,
                                  // autovalidateMode:
                                  //     AutovalidateMode.onUserInteraction,
                                  controller: value.controller,
      
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.deepPurpleAccent),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.deepPurpleAccent),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    labelText: 'City',
                                    contentPadding: EdgeInsets.all(8.0),
                                    labelStyle: TextStyle(
                                      color: Colors.red,
                                    ),
                                    suffixIconConstraints: BoxConstraints(
                                      minWidth: 5,
                                    ),
                                    suffix: TextButton(
                                      onPressed: () {
                                        value.cityName =
                                            value.controller.text.toString();
                                        value.fetchWeather(value.cityName);
                                      },
                                      child: Text(
                                        'Search',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                    fillColor: Colors.grey[200],
                                    filled: true,
                                  ),
                                ),
      
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Search Location : $currentLocation',
                                  
                                style: TextStyle(
                                  fontSize: 20
                                ),
                                ),
      
                                SizedBox(
                                  height: 10,
                                ),
      
                                 WeatherApp(),
      
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: Card(
                                    
                                      elevation: 12,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16.0)),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 10,
                                            sigmaY: 10,
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  '$currentTemp K' ,
                                                  style: TextStyle(
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                Icon(
                                                  currentSky == 'Clouds' ||
                                                          currentSky == 'Rain'
                                                      ? Icons.cloud
                                                      : Icons.sunny,
                                                  size: 68,
                                                ),
                                                Text(
                                                  currentSky,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Weather Forecast',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                SizedBox(
                                  height: 125,
                                  child: ListView.builder(
                                      itemCount: 6,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        final hourlyForecast =
                                            data['list'][index + 1];
                                        final time = DateTime.parse(
                                            hourlyForecast['dt_txt']);
      
                                        return HourlyForecast(
                                          temperature: hourlyForecast['main']
                                                  ['temp']
                                              .toString(),
                                          time: DateFormat('j').format(time),
                                          icons: data['list'][index + 1]
                                                              ['weather'][0]
                                                          ['main'] ==
                                                      'Clouds' ||
                                                  data['list'][index + 1]
                                                              ['weather'][0]
                                                          ['main'] ==
                                                      'Rain'
                                              ? Icons.cloud
                                              : Icons.sunny,
                                        );
                                      }),
                                ),
                                SizedBox(height: 20),
                                const Text(
                                  'Aditional Information',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    AdditionalInfo(
                                      icon: Icons.water_drop,
                                      label: 'Humidity',
                                      value: currentHumidity.toString(),
                                    ),
                                    AdditionalInfo(
                                       icon: Icons.air,
                                      label: 'wind Speed',
                                      value: currentWindSpeed.toString(),
                                    ),
                                    AdditionalInfo(
                                       icon: Icons.beach_access,
                                      label: 'Pressure',
                                      value: currentPressure.toString(),
                                    ),
                                  
                                  ],
                                ),
                              ]),
                        ),
                      ));
            },
          ),
        ),
        
      ),
    );
    
  }
}






Future<bool> showExitConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Do you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Yes'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
















