import 'package:flutter/material.dart';

class MonitorSystemPerformanceScreen extends StatelessWidget {
  const MonitorSystemPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monitor System Performance')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Future Development:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "This screen will be developed to display real-time analytics on speed, notifications, and vehicle connectivity. "
                  "Currently, the challenges include integrating live data from Firestore, ensuring smooth UI updates, and optimizing performance for large data sets.",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
