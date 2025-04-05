import 'package:flutter/material.dart';
import 'package:telemetri/ui/widgets/custom_appbar.dart';
import 'package:telemetri/ui/widgets/custom_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Unread', 'Read'];

  // Dummy notifications data
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Presensi berhasil dicatat',
      'message': 'Kehadiran Anda pada Rapat Global OR 2 berhasil dicatat',
      'type': 'success',
      'isRead': false,
      'time': DateTime.now().subtract(const Duration(minutes: 10)),
    },
    {
      'id': '2',
      'title': 'Pengingat Kehadiran',
      'message': 'Jangan lupa untuk melakukan Piket mingguan besok yaa....',
      'type': 'reminder',
      'isRead': false,
      'time': DateTime.now().subtract(const Duration(minutes: 10)),
    },
    {
      'id': '3',
      'title': 'Perubahan Program Kerja',
      'message':
          'Ada perubahan pada proker HRD, silakan dibaca pada bagian Proker yaa....',
      'type': 'info',
      'isRead': true,
      'time': DateTime.now().subtract(const Duration(minutes: 10)),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifikasi',
        showBackButton: true,
        showNotification: false,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFilter = filter),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.1)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            filter,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildNotificationCard(notification),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    IconData getIcon() {
      switch (notification['type']) {
        case 'success':
          return Icons.check_circle;
        case 'reminder':
          return Icons.notifications_active;
        case 'info':
          return Icons.info;
        default:
          return Icons.notifications;
      }
    }

    Color getColor() {
      switch (notification['type']) {
        case 'success':
          return Colors.green;
        case 'reminder':
          return Colors.orange;
        case 'info':
          return Colors.blue;
        default:
          return Colors.grey;
      }
    }

    return CustomCard(
      child: Stack(
        children: [
          if (!notification['isRead'])
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: getColor().withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(getIcon(), color: getColor(), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Baru',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['message'],
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '10 menit yang lalu',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
