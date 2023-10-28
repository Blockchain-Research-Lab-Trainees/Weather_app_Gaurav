import 'package:gaurav_app/secrets.dart';
import 'package:location_geocoder/location_geocoder.dart';
import 'package:flutter/material.dart';
 
 import 'package:flutter/services.dart';
 import 'package:gaurav_app/weather_screen.dart';
 



import 'dart:convert';

void main() {
  
  final jsonData = json.decode('http://api.openweathermap.org/data/2.5/forecast?q=London,uk&APPID=${secrets().OpenWeatherApiKey2}');

  // Specify current location coordinates (latitude and longitude)
  final myLatitude = 9.9312;
  final myLongitude = 76.2673;

  // Extract the weather data from current location
  final myLocationData = jsonData['list'].firstWhere((item) {
    final coordinates = item['coord'];
    return coordinates['lat'] == myLatitude && coordinates['lon'] == myLongitude;
  }, orElse: () => null);

  if (myLocationData != null) {
    // You can access the weather data for your current location from myLocationData
    final temperature = myLocationData['main']['temp'];
    final description = myLocationData['weather'][0]['description'];
    final cityName = jsonData['city']['name'];
    print('Weather at $cityName - Temperature: $temperature°C, Description: $description');
  } else {
    print('Weather data for your current location not found in the JSON.');
  }
}
