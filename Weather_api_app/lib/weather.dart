import 'dart:convert';
import 'package:http/http.dart' as http ;
import 'package:geolocator/geolocator.dart';
import 'secrets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gaurav_app/secrets.dart';


class weatherLocation{
late Position _currentPosition;
  Map<String, dynamic> _weatherData = {};
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
        desiredAccuracy: LocationAccuracy.best,
      );
      _fetchWeatherData(_currentPosition.latitude, _currentPosition.longitude);
    } catch (e) {
      // Handle location retrieval error
        _error = 'Error getting location: $e';
      
    }
  }

  Future<void> _fetchWeatherData(double lat, double lon) async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=${secrets().OpenWeatherApiKey2}'));

      if (response.statusCode == 200) {
        
          _weatherData = json.decode(response.body);
      
      } else {
        
          _error = 'Error fetching weather data. Status code: ${response.statusCode}';
      
      }
    } catch (e) {
      // Handle weather data retrieval error
      
        _error = 'Error fetching weather data: $e';
      
    }
  }


}