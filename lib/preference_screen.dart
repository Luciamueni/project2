import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceScreen extends StatefulWidget {
  final String userId;

  const PreferenceScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _PreferenceScreenState createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  // Preference state variables with default values
  bool _darkMode = true;
  bool _notifications = true;
  bool _locationTracking = true;
  double _routePreference = 1.0; // 0: Fastest, 1: Most efficient, 2: Scenic

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Load preferences from local storage
  Future<void> _loadPreferences() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      await _loadFromLocalStorage();
    } catch (e) {
      print('Error loading preferences: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Save preferences to local storage
  Future<void> _saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('darkMode', _darkMode);
      await prefs.setBool('notifications', _notifications);
      await prefs.setBool('locationTracking', _locationTracking);
      await prefs.setDouble('routePreference', _routePreference);

      // Show a brief save indication
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Preferences updated"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Error saving to local storage: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error updating preferences"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Load preferences from local storage
  Future<void> _loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _darkMode = prefs.getBool('darkMode') ?? true;
          _notifications = prefs.getBool('notifications') ?? true;
          _locationTracking = prefs.getBool('locationTracking') ?? true;
          _routePreference = prefs.getDouble('routePreference') ?? 1.0;
        });
      }
    } catch (e) {
      print('Error loading from local storage: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          "Navigation Preferences",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 18 : 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A2980),
              Color(0xFF26D0CE),
            ],
          ),
        ),
        child: _isLoading
            ? Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        )
            : SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Title
                  Text(
                    "Display Settings",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),

                  // Dark Mode Toggle
                  _buildPreferenceToggle(
                    "Dark Mode",
                    "Enable dark mode for navigation",
                    Icons.dark_mode,
                    _darkMode,
                        (value) {
                      if (value != null) {
                        setState(() {
                          _darkMode = value;
                        });
                        _saveToLocalStorage();
                      }
                    },
                    isSmallScreen,
                  ),

                  SizedBox(height: isSmallScreen ? 16 : 20),
                  Text(
                    "Navigation Settings",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),

                  // Route Preference Slider
                  _buildGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.route,
                              color: Colors.white,
                              size: isSmallScreen ? 20 : 24,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Route Preference",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Fastest",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: _routePreference == 0
                                    ? Colors.white
                                    : Colors.white70,
                                fontWeight: _routePreference == 0
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            Text(
                              "Efficient",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: _routePreference == 1
                                    ? Colors.white
                                    : Colors.white70,
                                fontWeight: _routePreference == 1
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            Text(
                              "Scenic",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: _routePreference == 2
                                    ? Colors.white
                                    : Colors.white70,
                                fontWeight: _routePreference == 2
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white.withOpacity(0.3),
                            thumbColor: Colors.white,
                            overlayColor: Colors.white.withOpacity(0.3),
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: _routePreference,
                            min: 0.0,
                            max: 2.0,
                            divisions: 2,
                            onChanged: (value) {
                              setState(() {
                                _routePreference = value;
                              });
                              _saveToLocalStorage();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 16 : 20),
                  Text(
                    "Privacy Settings",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),

                  // Location Tracking
                  _buildPreferenceToggle(
                    "Location Tracking",
                    "Allow app to track your location",
                    Icons.location_on,
                    _locationTracking,
                        (value) {
                      if (value != null) {
                        setState(() {
                          _locationTracking = value;
                        });
                        _saveToLocalStorage();
                      }
                    },
                    isSmallScreen,
                  ),

                  SizedBox(height: isSmallScreen ? 10 : 12),

                  // Notifications
                  _buildPreferenceToggle(
                    "Notifications",
                    "Receive navigation alerts",
                    Icons.notifications,
                    _notifications,
                        (value) {
                      if (value != null) {
                        setState(() {
                          _notifications = value;
                        });
                        _saveToLocalStorage();
                      }
                    },
                    isSmallScreen,
                  ),

                  SizedBox(height: isSmallScreen ? 24 : 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build preference toggle items
  Widget _buildPreferenceToggle(
      String title,
      String subtitle,
      IconData icon,
      bool value,
      Function(bool?) onChanged,
      bool isSmallScreen,
      ) {
    return _buildGlassCard(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
            child: Icon(
              icon,
              size: isSmallScreen ? 20 : 24,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: Colors.white.withOpacity(0.5),
            inactiveThumbColor: Colors.white.withOpacity(0.8),
            inactiveTrackColor: Colors.white.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  // Helper method to create a glass-like card with backdrop filter
  Widget _buildGlassCard({required Widget child}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}