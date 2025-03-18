import 'package:flutter/material.dart';
import 'admin_screens/dashboard.dart';
import 'admin_screens/update_speed_limit.dart';
import 'admin_screens/manage_users.dart';
import 'admin_screens/monitor_performance.dart';
import 'admin_screens/security_updates.dart';
import 'signin_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4D7DF9),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4D7DF9),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const AdminHomePage(),
    );
  }
}

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  bool _isRailExtended = true;

  final List<Widget> _screens = [
    const AdminDashboard(),
    const UpdateSpeedLimitScreen(),
    const ManageUserAccountsScreen(),
    const MonitorSystemPerformanceScreen(),
    const ImplementSecurityUpdatesScreen(),
  ];

  final List<Map<String, dynamic>> _destinations = [
    {
      'icon': Icons.dashboard_rounded,
      'label': 'Dashboard',
    },
    {
      'icon': Icons.speed_rounded,
      'label': 'Speed Limits',
    },
    {
      'icon': Icons.people_alt_rounded,
      'label': 'User Accounts',
    },
    {
      'icon': Icons.insights_rounded,
      'label': 'Performance',
    },
    {
      'icon': Icons.shield_rounded,
      'label': 'Security',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  void _signOut(BuildContext context) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SignInScreen()),
              );
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 800 && screenWidth <= 1200;
    final isMobile = screenWidth <= 800;

    // Automatically adjust rail extension based on screen size
    if (isDesktop && !_isRailExtended) {
      setState(() => _isRailExtended = true);
    } else if (isMobile && _isRailExtended) {
      setState(() => _isRailExtended = false);
    }

    return Scaffold(
      appBar: isMobile
          ? AppBar(
        title: Text(_destinations[_selectedIndex]['label']),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: "Sign Out",
            onPressed: () => _signOut(context),
          ),
          const SizedBox(width: 8),
        ],
      )
          : null,
      drawer: isMobile
          ? Drawer(
        child: SafeArea(
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Admin Panel',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _destinations.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(_destinations[index]['icon']),
                      title: Text(_destinations[index]['label']),
                      selected: _selectedIndex == index,
                      onTap: () {
                        _onItemTapped(index);
                        Navigator.pop(context); // Close drawer
                      },
                    );
                  },
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text('Sign Out'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  _signOut(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            NavigationRail(
              extended: _isRailExtended,
              minExtendedWidth: 220,
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              labelType: NavigationRailLabelType.none,
              leading: isTablet
                  ? IconButton(
                icon: Icon(_isRailExtended ? Icons.menu_open_rounded : Icons.menu_rounded),
                onPressed: () {
                  setState(() {
                    _isRailExtended = !_isRailExtended;
                  });
                },
              )
                  : Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  children: [
                    if (_isRailExtended)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.admin_panel_settings_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Admin Panel',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.admin_panel_settings_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),
              destinations: _destinations.map((destination) {
                return NavigationRailDestination(
                  icon: Icon(destination['icon']),
                  label: Text(destination['label']),
                );
              }).toList(),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _signOut(context),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _isRailExtended
                            ? Row(
                          children: [
                            const Icon(Icons.logout_rounded),
                            const SizedBox(width: 12),
                            Text(
                              'Sign Out',
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        )
                            : const Tooltip(
                          message: "Sign Out",
                          child: Icon(Icons.logout_rounded),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: _screens,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}