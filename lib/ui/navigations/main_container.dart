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
  const MainContainer({super.key, this.initialIndex = 0});

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
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ScanQRScreen()),
      );
      return;
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
