import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weatherApp/bloc/weather_bloc_bloc.dart';
import 'package:weatherApp/screens/home_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;
void main() {
  runApp(const MainApp());
}


class MainApp extends StatelessWidget {
  const MainApp({super.key});

 @override
  Widget build(BuildContext context) {
    return MaterialApp(
			debugShowCheckedModeBanner: false,
      home: FutureBuilder(
				future: _getGeoLocationPosition(),
        builder: (context, snap) {
					if(snap.hasData) {
						return BlocProvider<WeatherBlocBloc>(
							create: (context) => WeatherBlocBloc()..add(
								FetchWeather(snap.data as Position)
							),
							child: const HomeScreen(),
						);
					} else {
            developer.log(snap.data.toString());
						return const Scaffold(
							body: Center(
								child: CircularProgressIndicator(),
							),
						);
					}
        }
      )
    );
  }
}

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      print('Location permissions are permanently denied, we cannot request permissions.');
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position location = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    developer.log(location.toString());
    if(location.longitude > 0 ) return location;
    return Position(longitude: 461716.36390889, latitude: 5099841.8884004, accuracy: 0, altitude: 0, altitudeAccuracy: 0, heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0, timestamp: DateTime.now());
  }
