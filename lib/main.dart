import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'neu_circle.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _fetchPermissionStatus();
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() {
          _hasPermission = (status == PermissionStatus.granted);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.brown[600],
        body: Builder(
          builder: (context) {
            if (_hasPermission) {
              return _buildCompass();
            } else {
              return _buildPermissionSheet();
            }
          },
        ),
      ),
    );
  }

  //compass
  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        // error
        if (snapshot.hasError) {
          return Text('Error reading heading: ${snapshot.error}');
        }
        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        double? direction = snapshot.data!.heading;

        //doesn't support
        if (direction == null) {
          return const Center(
            child: Text("Device does not have sensors"),
          );
        }

        //compass
        return NeuCircle(
          child: Transform.rotate(
            angle: (direction * (pi / 180) * -1),
            child: Image.asset(
              'assets/compass.png',
              color: Colors.white,
              fit: BoxFit.fill,
            ),
          ),
        );
      },
    );
  }

  //Permission
  Widget _buildPermissionSheet() {
    return Center(
      child: ElevatedButton(
        child: const Text("Request Permission"),
        onPressed: () {
          Permission.locationWhenInUse.request().then((ignored) {
            _fetchPermissionStatus();
          });
        },
      ),
    );
  }
}
