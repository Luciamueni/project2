import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ConnectionScreen extends StatefulWidget {
  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final FlutterBluePlus flutterBlue = FlutterBluePlus(); // No .instance
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? connectedDevice;
  bool isConnecting = false;
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    scanForDevices();
  }

  /// Scan for Bluetooth devices
  void scanForDevices() async {
    if (isScanning) return;

    setState(() {
      devicesList.clear();
      isScanning = true;
    });

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (!devicesList.any((d) => d.id == r.device.id)) {
          setState(() {
            devicesList.add(r.device);
          });
        }
      }
    });

    await Future.delayed(const Duration(seconds: 5));
    await FlutterBluePlus.stopScan();

    setState(() {
      isScanning = false;
    });
  }

  /// Connect to a selected Bluetooth device
  void connectToDevice(BluetoothDevice device) async {
    setState(() {
      isConnecting = true;
    });

    try {
      await device.connect(); // Using direct connection method
      setState(() {
        connectedDevice = device;
        isConnecting = false;
      });
    } catch (error) {
      print("Connection failed: $error");
      setState(() {
        isConnecting = false;
      });
    }
  }

  /// Disconnect from the currently connected device
  void disconnectDevice() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      setState(() {
        connectedDevice = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vehicle Connection"),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Connection status card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            connectedDevice != null ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                            color: connectedDevice != null ? Colors.indigo : Colors.grey,
                            size: 28,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Connection Status",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: connectedDevice != null ? Colors.green.shade50 : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: connectedDevice != null ? Colors.green.shade200 : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              connectedDevice != null ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: connectedDevice != null ? Colors.green : Colors.grey,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                connectedDevice != null
                                    ? "Connected to ${connectedDevice!.name.isNotEmpty ? connectedDevice!.name : 'Unknown Device'}"
                                    : "Not Connected",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: connectedDevice != null ? Colors.green.shade700 : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: Icon(
                            connectedDevice == null
                                ? isScanning ? Icons.search : Icons.bluetooth_searching
                                : Icons.bluetooth_disabled,
                            color: Colors.white,
                          ),
                          label: Text(
                            connectedDevice == null
                                ? isScanning ? "Scanning..." : "Scan for Vehicles"
                                : "Disconnect",
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: connectedDevice == null ? Colors.indigo : Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          onPressed: connectedDevice == null
                              ? (isScanning ? null : scanForDevices)
                              : disconnectDevice,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Available devices section
              Text(
                "Available Devices",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade800,
                ),
              ),
              SizedBox(height: 8),

              isScanning
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: Colors.indigo),
                      SizedBox(height: 16),
                      Text(
                        "Scanning for nearby devices...",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              )
                  : devicesList.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.bluetooth_disabled, color: Colors.grey.shade400, size: 48),
                      SizedBox(height: 16),
                      Text(
                        "No devices found",
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Try scanning again or check your Bluetooth settings",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              )
                  : Expanded(
                child: ListView.builder(
                  itemCount: devicesList.length,
                  itemBuilder: (context, index) {
                    final device = devicesList[index];
                    final isConnectedDevice = connectedDevice != null && connectedDevice!.id == device.id;

                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isConnectedDevice ? Colors.indigo.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isConnectedDevice ? Colors.indigo.shade200 : Colors.grey.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: isConnectedDevice ? Colors.indigo.shade100 : Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.bluetooth,
                                color: isConnectedDevice ? Colors.indigo : Colors.grey.shade600,
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    device.name.isNotEmpty ? device.name : "Unknown Device",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    device.id.toString(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            isConnectedDevice
                                ? Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "Connected",
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                                : ElevatedButton(
                              onPressed: isConnecting ? null : () => connectToDevice(device),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                              child: Text(isConnecting ? "Connecting..." : "Connect"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}