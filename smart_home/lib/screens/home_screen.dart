import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_home/screens/control_panel.dart';
import 'package:smart_home/screens/logs_screen.dart';
import 'package:smart_home/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ControlPanel(),
    const LogsScreen(),
    const SettingsScreen(),
  ];

// ... (کلاس بدون تغییر)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Home Control'),
        centerTitle: true,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home_2), // آیکون جدید
            activeIcon: Icon(Iconsax.home_25), // آیکون فعال
            label: 'Control',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.document_text), // آیکون جدید
            activeIcon: Icon(Iconsax.document_text5),
            label: 'Logs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.setting_2), // آیکون جدید
            activeIcon: Icon(Iconsax.setting_25),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}