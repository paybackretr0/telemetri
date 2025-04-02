import 'package:flutter/material.dart';
import 'package:telemetri/ui/screens/home/home_screen.dart';
import 'package:telemetri/ui/screens/calendar/calendar_screen.dart';
import 'package:telemetri/ui/screens/attendance/scan_qr_screen.dart';
import 'package:telemetri/ui/screens/history/history_screen.dart';
import 'package:telemetri/ui/screens/profile/profile_screen.dart';
import 'package:telemetri/ui/widgets/custom_bottom_navigation.dart';
import 'package:telemetri/ui/widgets/custom_appbar.dart';

class MainContainer extends StatefulWidget {
  final int initialIndex;
  const MainContainer({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  late int _selectedIndex;

  final List<String> _pageTitles = [
    'Beranda',
    'Kalender',
    'Scan QR',
    'Riwayat Kehadiran',
    'Profil',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const CalendarScreen(),
    // ScanQR is handled separately
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // This is correct - handling ScanQR separately
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ScanQRScreen()),
      );
      return;
    }

    // Fix the screen index calculation
    int screenIndex = index;
    if (index > 2) {
      screenIndex = index - 1;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    int displayIndex = _selectedIndex;
    if (_selectedIndex > 2) {
      displayIndex = _selectedIndex - 1;
    }

    return Scaffold(
      appBar: CustomAppBar(title: _pageTitles[_selectedIndex]),
      body: IndexedStack(
        index: displayIndex < _screens.length ? displayIndex : 0,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        showLabels: false,
      ),
    );
  }
}
