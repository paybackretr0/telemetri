import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:telemetri/utils/platform_helper.dart';
import 'package:telemetri/ui/screens/auth/login_provider.dart';
import 'package:telemetri/ui/screens/home/home_screen.dart';
import 'package:telemetri/ui/screens/calendar/calendar_screen.dart';
import 'package:telemetri/ui/screens/attendance/scan_qr_screen.dart';
import 'package:telemetri/ui/screens/history/history_screen.dart';
import 'package:telemetri/ui/screens/profile/profile_screen.dart';
import 'package:telemetri/ui/screens/notification/notification_screen.dart';
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
  bool _isAuthChecked = false;
  late int _bottomNavIndex;
  bool _isLoggingOut = false;

  final List<String> _pageTitles = [
    'Dashboard',
    'Kalender',
    'Scan QR',
    'Riwayat',
    'Profil',
  ];

  final List<String> _webPageTitles = [
    'Dashboard',
    'Kalender',
    'Riwayat',
    'Notifikasi',
    'Profil',
  ];

  final List<IconData> _webPageIcons = [
    Icons.dashboard,
    Icons.calendar_today,
    Icons.history,
    Icons.notifications,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _bottomNavIndex = widget.initialIndex;

    if (PlatformHelper.isWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAuthentication();
      });
    } else {
      _isAuthChecked = true;
    }
  }

  void _checkAuthentication() {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);

    if (!loginProvider.isAuthenticated) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } else {
      setState(() {
        _isAuthChecked = true;
      });
    }
  }

  final List<Widget> _mobileScreens = [
    const HomeScreen(),
    const CalendarScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  final List<Widget> _webScreens = [
    const HomeScreen(),
    const CalendarScreen(),
    const HistoryScreen(),
    const NotificationScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (PlatformHelper.isWeb) {
      setState(() {
        _selectedIndex = index;
      });
    } else {
      setState(() {
        _bottomNavIndex = index;
      });

      if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScanQRScreen()),
        );
        return;
      }

      int screenIndex;
      if (index < 2) {
        screenIndex = index;
      } else {
        screenIndex = index - 1;
      }

      setState(() {
        _selectedIndex = screenIndex;
      });
    }
  }

  Future<void> _handleLogout() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      final loginProvider = Provider.of<LoginProvider>(context, listen: false);

      await loginProvider.logout();

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saat logout: $e'),
            backgroundColor: Colors.red,
          ),
        );

        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: !_isLoggingOut,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content:
                _isLoggingOut
                    ? const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Sedang logout...'),
                      ],
                    )
                    : const Text('Apakah Anda yakin ingin keluar?'),
            actions:
                _isLoggingOut
                    ? []
                    : [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _handleLogout();
                        },
                        child: const Text('Keluar'),
                      ),
                    ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformHelper.isWeb && !_isAuthChecked) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading...'),
            ],
          ),
        ),
      );
    }

    if (PlatformHelper.isWeb) {
      return _buildWebLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildWebLayout() {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Image.asset(
                          'assets/images/neo_telemetri_logo.png',
                          height: 48,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Neo Telemetri',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Web Dashboard',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _webPageTitles.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedIndex == index;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _onItemTapped(index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Colors.white.withOpacity(0.2)
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _webPageIcons[index],
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.7),
                                    size: 22,
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    _webPageTitles[index],
                                    style: TextStyle(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.7),
                                      fontSize: 16,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Logout button dengan implementasi yang benar
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _isLoggingOut ? null : _showLogoutDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            _isLoggingOut
                                ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                )
                                : Icon(
                                  Icons.logout,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 22,
                                ),
                            const SizedBox(width: 16),
                            Text(
                              _isLoggingOut ? 'Logging out...' : 'Logout',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              color: Colors.grey.shade50,
              child: _webScreens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: CustomAppBar(title: _pageTitles[_bottomNavIndex]),
      body: IndexedStack(index: _selectedIndex, children: _mobileScreens),
      bottomNavigationBar: CustomBottomNavigation(
        selectedIndex: _bottomNavIndex,
        onItemTapped: _onItemTapped,
        showLabels: false,
      ),
    );
  }
}
