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
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';


import 'package:provider/provider.dart';

class WeatherProvider extends ChangeNotifier {
  Map<String, dynamic>? _weatherData;
  Map<String, dynamic>? _weatherDD ;
  TextEditingController _controller = TextEditingController();
  TextEditingController get controller => _controller;
  Map<String, dynamic>? get weatherData => _weatherData;
  Map<String, dynamic>? get weatherDD => _weatherDD;
  String cityName = 'Delhi,IN';
  String get city => cityName;
  Future<void> fetchWeather(String cityName) async {
    try {
      final res = await http.get(
        Uri.parse(
            'http://api.openweathermap.org/data/2.5/forecast?q=$cityName,uk&APPID=$OpenWeatherApiKey'),
      );

      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw data['message'];
      }

      _weatherData = data;
      notifyListeners();
    } catch (e) {
      throw e.toString();
    }
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
      _currentPosition = await Geolocator.getCurrentPosition( 
        
      );
      print(_currentPosition);
      _fetchWeatherData(_currentPosition.latitude, _currentPosition.longitude);
    } catch (e) {
      // Handle location retrieval error
        _error = 'Error getting location: $e';
      
    }
  }

  Future<void> _fetchWeatherData(double lat, double lon) async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$OpenWeatherApiKey'));

      if (response.statusCode == 200) {
        
          _weatherDD = json.decode(response.body);
      
      } else {
        
          _error = 'Error fetching weather data. Status code: ${response.statusCode}';
      
      }
    } catch (e) {
      // Handle weather data retrieval error
      
        _error = 'Error fetching weather data: $e';
      
    }
  }





}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WeatherProvider()._checkLocationPermission();
  }
    // final  location = Location;

   String currentLocation = 'Loading...';




  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);

    return Consumer<WeatherProvider>(
      builder: (context, value, child) => 
        
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
                    weatherProvider.fetchWeather('Delhi, IN');
                  },
                  icon: const Icon(Icons.refresh),
                ),
              
              
                //  IconButton(
                //   padding: EdgeInsets.only(right: 10),
                //   onPressed: (){}, // Call the function here
                //   icon: Icon(Icons.refresh),
                //  ),
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
                final currentTemp = value._weatherData?['list']?[0]?['main']?['temp']?.toString() ?? 'N/A';

              
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
                                      labelText: 'city',
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
              
                                  SizedBox(height: 10,),
                                  // Text(
                                  //   // 'Current Location : $currentLocation',
                                  //   's',
                                  // style: TextStyle(
                                  //   fontSize: 20
                                  // ),
                                  // ),
                                  SizedBox(height: 10,),

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
                                                    currentTemp,
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
                                        )),
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
                                      // Your UI components here
                                    ],
                                  ),
                                ]),
                          ),
                        ));
              },
            ),
          ),
        );
      
    
  }
}

// void main() {
//   runApp(
//     ChangeNotifierProvider(
//       create: (context) => WeatherProvider(),
//       child: MaterialApp(
//         home: WeatherScreen(),
//       ),
//     ),
//   );
// }
