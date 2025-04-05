import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:telemetri/ui/widgets/custom_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Hadir', 'Izin', 'Alfa'];

  final List<Map<String, dynamic>> _attendanceHistory = [
    {
      'id': '1',
      'title': 'Piket Minggu 1',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'checkIn': '08:00',
      'checkOut': '17:00',
      'status': 'Hadir',
    },
    {
      'id': '2',
      'title': 'Rapat Global OR',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'checkIn': '09:30',
      'status': 'Hadir',
    },
    {
      'id': '3',
      'title': 'Rapat Divisi',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'checkIn': '13:00',
      'status': 'Izin',
    },
    {
      'id': '4',
      'title': 'Rapat Departemen',
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'checkIn': '10:00',
      'status': 'Alfa',
    },
    {
      'id': '5',
      'title': 'Workshop Flutter',
      'date': DateTime.now().subtract(const Duration(days: 10)),
      'checkIn': '09:00',
      'checkOut': '16:00',
      'status': 'Hadir',
    },
  ];

  List<Map<String, dynamic>> get filteredHistory {
    if (_selectedFilter == 'Semua') {
      return _attendanceHistory;
    } else {
      return _attendanceHistory
          .where((item) => item['status'] == _selectedFilter)
          .toList();
    }
  }

  String _getCounterLabel() {
    switch (_selectedFilter) {
      case 'Izin':
        return 'Izin';
      case 'Alfa':
        return 'Alfa';
      case 'Hadir':
        return 'Hadir';
      default:
        return 'Kehadiran';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
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

                    // Definisi warna berdasarkan status
                    Color tabColor = Theme.of(context).primaryColor;
                    if (filter == 'Hadir') {
                      tabColor = Colors.green;
                    } else if (filter == 'Izin') {
                      tabColor = Colors.orange;
                    } else if (filter == 'Alfa') {
                      tabColor = Colors.red;
                    }

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? tabColor.withOpacity(0.1)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border:
                                isSelected
                                    ? Border.all(color: tabColor, width: 1.5)
                                    : null,
                          ),
                          child: Column(
                            children: [
                              Text(
                                filter,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                  color:
                                      isSelected
                                          ? tabColor
                                          : Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (isSelected)
                                Container(
                                  height: 3,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: tabColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.list_alt, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '${filteredHistory.length} ${_getCounterLabel()}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child:
                filteredHistory.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history_toggle_off,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada riwayat $_selectedFilter',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: filteredHistory.length,
                      itemBuilder: (context, index) {
                        final item = filteredHistory[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildHistoryCard(item),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    Color statusColor;
    IconData statusIcon;

    switch (item['status']) {
      case 'Hadir':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Izin':
        statusColor = Colors.orange;
        statusIcon = Icons.assignment_late;
        break;
      default:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
    }

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      item['status'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(item['date']),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                'Masuk: ${item['checkIn']}',
                style: const TextStyle(fontSize: 14),
              ),
              if (item.containsKey('checkOut') && item['checkOut'] != null) ...[
                const SizedBox(width: 12),
                Text(
                  'Keluar: ${item['checkOut']}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
