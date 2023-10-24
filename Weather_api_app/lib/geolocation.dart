
import 'package:flutter/material.dart';
import 'package:gaurav_app/weather_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

const String openWeatherApiKey = '8049eac8c49885f052b0a530d4315c33'; // Replace with your API key

// void main() {
//   runApp(MaterialApp(home: WeatherApp()));
// }

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  late Position _currentPosition;
  Map<String, dynamic> _weatherData = {};
  String _error = '';
  bool _isLoading = true;
  WeatherProvider _provider  = WeatherProvider();
  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      // Handle case when user denies location permission
      setState(() {
        _error = 'Location permission denied.';
      });
    }
  
  }

  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      _fetchWeatherData(_currentPosition.latitude, _currentPosition.longitude);
    } catch (e) {
      // Handle location retrieval error
      setState(() {
        _error = 'Error getting location: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWeatherData(double lat, double lon) async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$openWeatherApiKey'));

      if (response.statusCode == 200) {
        setState(() {
          _weatherData = json.decode(response.body);
          _isLoading =false;
        });
      } else {
        setState(() {
          _error = 'Error fetching weather data. Status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle weather data retrieval error
      setState(() {
        _error = 'Error fetching weather data: $e';
        _isLoading = false;
      });
    }
    finally{
      _provider.cityName = _weatherData['name'];
      print(_provider.cityName);
      _provider.fetchWeather(_provider.cityName);
      _provider.notifyListeners();
    }
  }

  @override
  Widget build(BuildContext context) {
    return 
    
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
             if (_isLoading)
          CircularProgressIndicator()

          else Column(
            children:[

            Text('Current Location: ${_weatherData['name'] ?? "N/A"}'),
            Text('Temperature: ${(_weatherData['main']['temp'] - 273.15).toStringAsFixed(2)}°C'),
            Text('Weather: ${_weatherData['weather'][0]['main'] ?? "N/A"}'),
            if (_error.isNotEmpty) Text('Error: $_error', style: TextStyle(color: Colors.red)),
            ]
          )
          ],
        );
    
    
  }
}
