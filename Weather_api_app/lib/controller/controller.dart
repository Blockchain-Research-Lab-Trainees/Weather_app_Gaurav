import 'package:gaurav_app/secrets.dart';
import 'package:location_geocoder/location_geocoder.dart';
import 'package:flutter/material.dart';
 
 import 'package:flutter/services.dart';
 import 'package:gaurav_app/weather_screen.dart';
 

// getUserLocation() async {//call this async method from whereever you need
    
//       LocationData myLocation;
//       String error;
//       Location location = new Location();
//       try {
//         myLocation = await location.getLocation();
//       } on PlatformException catch (e) {
//         if (e.code == 'PERMISSION_DENIED') {
//           error = 'please grant permission';
//           print(error);
//         }
//         if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
//           error = 'permission denied- please enable it from app settings';
//           print(error);
//         }
//         myLocation = null;
//       }
//       currentLocation = myLocation;
//       final coordinates = new Coordinates(
//           myLocation.latitude, myLocation.longitude);
//       var addresses = await Geocoder.local.findAddressesFromCoordinates(
//           coordinates);
//       var first = addresses.first;
//       print(' ${first.locality}, ${first.adminArea},${first.subLocality}, ${first.subAdminArea},${first.addressLine}, ${first.featureName},${first.thoroughfare}, ${first.subThoroughfare}');
//       return first;
//     }

// const _apiKey = 'openWeatherApiKey';
//         final LocatitonGeocoder geocoder = LocatitonGeocoder(_apiKey);
//         final address =  geocoder
//             .findAddressesFromCoordinates(Coordinates(9.9312, 76.2673));
//         print(address.first.addressLine);


import 'dart:convert';

void main() {
  // Replace with your actual JSON data
  final jsonData = json.decode('http://api.openweathermap.org/data/2.5/forecast?q=London,uk&APPID=$OpenWeatherApiKey2');

  // Specify your current location coordinates (latitude and longitude)
  final myLatitude = 9.9312;
  final myLongitude = 76.2673;

  // Extract the weather data for your current location
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
