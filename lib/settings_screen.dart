import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _backgroundTracking = true;
  bool _vibrationAlert = true;
  double _speedLimit = 0.0;
  String _speedUnit = "km/h";
  String _notificationSound = "Default";
  String _emergencyContact = "Not Set";

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _fetchSpeedLimit();
  }

  /// Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _backgroundTracking = prefs.getBool('backgroundTracking') ?? true;
      _vibrationAlert = prefs.getBool('vibrationAlert') ?? true;
      _speedUnit = prefs.getString('speedUnit') ?? "km/h";
      _notificationSound = prefs.getString('notificationSound') ?? "Default";
      _emergencyContact = prefs.getString('emergencyContact') ?? "Not Set";
    });
  }

  /// Fetch speed limit from Firestore
  Future<void> _fetchSpeedLimit() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('speed_limits')
          .doc('global_limit')
          .get();

      if (snapshot.exists) {
        setState(() {
          _speedLimit = (snapshot.data() as Map<String, dynamic>)['speed_limit']?.toDouble() ?? 0.0;
        });
      }
    } catch (e) {
      print("Error fetching speed limit: $e");
    }
  }

  /// Save settings to SharedPreferences
  Future<void> _saveSetting(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  /// Select notification sound
  void _selectNotificationSound() {
    List<String> sounds = ["Default", "Beep", "Siren", "Chime"];
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        children: sounds
            .map(
              (sound) => ListTile(
            title: Text(sound),
            onTap: () {
              setState(() {
                _notificationSound = sound;
              });
              _saveSetting('notificationSound', sound);
              Navigator.pop(context);
            },
          ),
        )
            .toList(),
      ),
    );
  }

  /// Set emergency contact
  void _setEmergencyContact() {
    TextEditingController controller = TextEditingController(text: _emergencyContact);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Set Emergency Contact"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(hintText: "Enter phone number"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _emergencyContact = controller.text;
              });
              _saveSetting('emergencyContact', controller.text);
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Dark Mode Toggle
          SwitchListTile(
            title: const Text("Dark Mode"),
            subtitle: const Text("Enable or disable dark theme"),
            value: _isDarkMode,
            onChanged: (bool value) {
              setState(() => _isDarkMode = value);
              _saveSetting('darkMode', value);
            },
          ),
          const Divider(),

          // Speed Limit Display (Read-Only)
          ListTile(
            title: const Text("Speed Limit (km/h)"),
            subtitle: Text(
              _speedLimit > 0 ? "${_speedLimit.toStringAsFixed(1)} km/h" : "Fetching...",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),

          // Speed Unit Toggle
          ListTile(
            title: const Text("Speed Unit"),
            subtitle: Text("Current: $_speedUnit"),
            trailing: DropdownButton<String>(
              value: _speedUnit,
              items: ["km/h", "mph"].map((unit) {
                return DropdownMenuItem<String>(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _speedUnit = value);
                  _saveSetting('speedUnit', value);
                }
              },
            ),
          ),
          const Divider(),

          // Background Tracking
          SwitchListTile(
            title: const Text("Background Tracking"),
            subtitle: const Text("Allow speed tracking in the background"),
            value: _backgroundTracking,
            onChanged: (bool value) {
              setState(() => _backgroundTracking = value);
              _saveSetting('backgroundTracking', value);
            },
          ),
          const Divider(),

          // Vibration Alert
          SwitchListTile(
            title: const Text("Vibration Alert"),
            subtitle: const Text("Vibrate when exceeding speed limit"),
            value: _vibrationAlert,
            onChanged: (bool value) {
              setState(() => _vibrationAlert = value);
              _saveSetting('vibrationAlert', value);
            },
          ),
          const Divider(),

          // Notification Sound
          ListTile(
            title: const Text("Notification Sound"),
            subtitle: Text("Current: $_notificationSound"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _selectNotificationSound,
          ),
          const Divider(),

          // Emergency Contact
          ListTile(
            title: const Text("Emergency Contact"),
            subtitle: Text(_emergencyContact),
            trailing: const Icon(Icons.edit),
            onTap: _setEmergencyContact,
          ),
        ],
      ),
    );
  }
}
