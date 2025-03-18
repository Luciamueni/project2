import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';

class SpeedControlScreen extends StatefulWidget {
  @override
  _SpeedControlScreenState createState() => _SpeedControlScreenState();
}

class _SpeedControlScreenState extends State<SpeedControlScreen> {
  double _speedMS = 0.0; // Speed in meters per second
  double _speedKMH = 0.0; // Speed in km/h
  double _speedLimitMS = 10.0; // Default speed limit (m/s)
  double _speedLimitKMH = 36.0; // Default speed limit (km/h)
  late Stream<Position> _positionStream;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    fetchSpeedLimit(); // Fetch speed limit from Firestore
    _checkLocationPermission(); // Check and request location permission
  }

  /// Check and request location permission
  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location services are disabled. Please enable them to track speed.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      setState(() {
        _permissionGranted = false;
      });
      return;
    }

    // Check permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Request permission
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permission denied
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied. Unable to track speed.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        setState(() {
          _permissionGranted = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permission permanently denied
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied. Please enable them in app settings.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 5),
          ),
        );
      }
      setState(() {
        _permissionGranted = false;
      });
      return;
    }

    // Permission granted, start tracking
    setState(() {
      _permissionGranted = true;
    });
    startSpeedTracking();
  }

  /// Fetch speed limit from Firestore (Collection: `speed_limits`, Document: `current`)
  Future<void> fetchSpeedLimit() async {
    try {
      var doc = await FirebaseFirestore.instance.collection('speed_limits').doc('current').get();
      if (doc.exists) {
        setState(() {
          _speedLimitMS = doc['speed_limit'].toDouble(); // Speed limit in m/s
          _speedLimitKMH = _speedLimitMS * 1; // Convert to km/h
        });
      }
    } catch (e) {
      print("Error fetching speed limit: $e");
    }
  }

  /// Start tracking GPS speed
  void startSpeedTracking() {
    if (!_permissionGranted) return;

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 1),
    );

    _positionStream.listen((Position position) {
      double newSpeedMS = position.speed; // Speed in meters per second
      double newSpeedKMH = newSpeedMS * 3.6; // Convert to km/h

      setState(() {
        _speedMS = newSpeedMS;
        _speedKMH = newSpeedKMH;
      });

      // Check if speed exceeds limit
      if (_speedKMH > _speedLimitKMH) {
        showSpeedAlert();
        playSpeedAlertSound();
      }
    }, onError: (error) {
      print("Error getting position: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error tracking location: $error"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  /// Show a snackbar warning when speed exceeds the limit
  void showSpeedAlert() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("⚠️ Slow down! Speed limit exceeded: ${_speedKMH.toStringAsFixed(2)} km/h"),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(10),
      ),
    );
  }

  /// Play sound alert when speed exceeds the limit
  Future<void> playSpeedAlertSound() async {
    await _audioPlayer.play(AssetSource('alert.mp3')); // Ensure the file is inside `assets/sounds/`
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Dispose audio player
    super.dispose();
  }

  // Helper method to determine speed indicator color
  Color _getSpeedColor() {
    if (_speedKMH > _speedLimitKMH) {
      return Colors.red;
    } else if (_speedKMH > _speedLimitKMH * 0.8) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  // Helper method to show permission state
  Widget _buildPermissionStatus() {
    if (!_permissionGranted) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.location_disabled, color: Colors.red, size: 36),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "LOCATION PERMISSION REQUIRED",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "This app needs location permission to track your speed",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _checkLocationPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("GRANT"),
            ),
          ],
        ),
      );
    }
    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Speed Monitor"),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade100, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Permission status
                _buildPermissionStatus(),

                // Speed gauge
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "CURRENT SPEED",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _permissionGranted ? _speedKMH.toStringAsFixed(1) : "0.0",
                                style: TextStyle(
                                  fontSize: 72,
                                  fontWeight: FontWeight.bold,
                                  color: _permissionGranted ? _getSpeedColor() : Colors.grey,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Text(
                                  " km/h",
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _permissionGranted ? "${_speedMS.toStringAsFixed(1)} m/s" : "0.0 m/s",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Speed limit card
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.speed_outlined,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "SPEED LIMIT",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _speedLimitKMH.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
                                      child: Text(
                                        "km/h",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Status indicator - only show if permission granted
                _permissionGranted ? Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _speedKMH > _speedLimitKMH ? Colors.red.shade50 : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _speedKMH > _speedLimitKMH ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                            color: _speedKMH > _speedLimitKMH ? Colors.red : Colors.green,
                            size: 24,
                          ),
                          SizedBox(width: 10),
                          Text(
                            _speedKMH > _speedLimitKMH ? "SPEED LIMIT EXCEEDED" : "WITHIN SPEED LIMIT",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _speedKMH > _speedLimitKMH ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ) : SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}