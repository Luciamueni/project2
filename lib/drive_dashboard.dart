import 'package:flutter/material.dart';
import 'speed_control.dart';
import 'connection_screen.dart';
import 'settings_screen.dart';
import 'signin_screen.dart';
import 'preference_screen.dart'; // Import the preference screen
import 'dart:ui';

class DriveDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsiveness
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
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
        child: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom App Bar with Sign Out (removed user icon)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12.0 : 16.0,
                    vertical: isSmallScreen ? 12.0 : 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Drive Dashboard',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 20 : 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Welcome back',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => SignInScreen()),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 8 : 12,
                              vertical: isSmallScreen ? 6 : 8
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.logout,
                                color: Colors.white,
                                size: isSmallScreen ? 16 : 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Sign Out',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: isSmallScreen ? 12 : 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Title for dashboard options
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      isSmallScreen ? 16 : 20,
                      isSmallScreen ? 16 : 20,
                      isSmallScreen ? 16 : 20,
                      isSmallScreen ? 12 : 15
                  ),
                  child: Text(
                    'Dashboard Options',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Dashboard Tiles
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12.0 : 16.0),
                  child: GridView.count(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    childAspectRatio: isSmallScreen ? 1.0 : 1.1,
                    crossAxisSpacing: isSmallScreen ? 12 : 16,
                    mainAxisSpacing: isSmallScreen ? 12 : 16,
                    children: [
                      _buildDashboardTile(
                        context,
                        title: "Speed Control",
                        icon: Icons.speed,
                        destination: SpeedControlScreen(),
                        isSmallScreen: isSmallScreen,
                      ),
                      _buildDashboardTile(
                        context,
                        title: "Vehicle Connection",
                        icon: Icons.car_repair,
                        destination: ConnectionScreen(),
                        isSmallScreen: isSmallScreen,
                      ),
                      _buildDashboardTile(
                        context,
                        title: "Settings",
                        icon: Icons.settings,
                        destination: SettingsScreen(),
                        isSmallScreen: isSmallScreen,
                      ),
                      _buildDashboardTile(
                        context,
                        title: "Preferences",
                        icon: Icons.tune,
                        destination: const PreferenceScreen(userId: '',), // Link to preference screen
                        isSmallScreen: isSmallScreen,
                      ),
                    ],
                  ),
                ),

                // Additional content section
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      isSmallScreen ? 16 : 20,
                      isSmallScreen ? 24 : 30,
                      isSmallScreen ? 16 : 20,
                      isSmallScreen ? 12 : 15
                  ),
                  child: Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Recent activity cards
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12.0 : 16.0),
                  child: Column(
                    children: [
                      _buildActivityCard(
                        "Today's Drive",
                        "45 minutes • 28 km",
                        Icons.timeline,
                        isSmallScreen: isSmallScreen,
                      ),
                      _buildActivityCard(
                        "Speed Alert",
                        "Exceeded limit by 10 km/h",
                        Icons.warning_amber,
                        isSmallScreen: isSmallScreen,
                      ),
                      _buildActivityCard(
                        "Vehicle Status",
                        "All systems normal",
                        Icons.check_circle,
                        isSmallScreen: isSmallScreen,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isSmallScreen ? 80 : 100), // Space at the bottom for navigation bar
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(isSmallScreen),
    );
  }

  Widget _buildBottomNavBar(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 12 : 20),
      height: isSmallScreen ? 60 : 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white.withOpacity(0.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, true, isSmallScreen),
                _buildNavItem(Icons.analytics, false, isSmallScreen),
                _buildNavItem(Icons.notifications, false, isSmallScreen),
                _buildNavItem(Icons.settings, false, isSmallScreen),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive, bool isSmallScreen) {
    return Container(
      decoration: isActive
          ? BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      )
          : null,
      padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 6 : 8
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: isSmallScreen ? 24 : 28,
      ),
    );
  }

  Widget _buildActivityCard(String title, String subtitle, IconData icon, {required bool isSmallScreen}) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
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
                SizedBox(width: isSmallScreen ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
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
                Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: isSmallScreen ? 20 : 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardTile(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Widget destination,
        required bool isSmallScreen,
      }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  child: Icon(
                    icon,
                    size: isSmallScreen ? 30 : 36,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
