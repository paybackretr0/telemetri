import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:telemetri/ui/widgets/custom_card.dart';
import 'package:telemetri/data/models/history_model.dart';
import 'history_provider.dart';
import 'package:telemetri/utils/date_formatter.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<String> _filters = ['Semua', 'Hadir', 'Izin', 'Alfa'];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<HistoryProvider>(context, listen: false);
      provider.getHistory(refresh: true);

      _scrollController.addListener(_scrollListener);
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = Provider.of<HistoryProvider>(context, listen: false);
      provider.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  String _getCounterLabel(String filter) {
    switch (filter) {
      case 'izin':
        return 'izin';
      case 'alfa':
        return 'alfa';
      case 'hadir':
        return 'hadir';
      default:
        return 'Kehadiran';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<HistoryProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 4,
                ),
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
                        final isSelected = provider.selectedFilter == filter;

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
                              provider.setFilter(filter);
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
                                        ? Border.all(
                                          color: tabColor,
                                          width: 1.5,
                                        )
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.list_alt,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${provider.filteredHistory.length} ${_getCounterLabel(provider.selectedFilter)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child:
                    provider.isLoading && provider.historyItems.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : provider.error != null &&
                            provider.historyItems.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                provider.error!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed:
                                    () => provider.getHistory(refresh: true),
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        )
                        : provider.filteredHistory.isEmpty
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
                                'Tidak ada riwayat ${provider.selectedFilter}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                        : RefreshIndicator(
                          onRefresh: () => provider.getHistory(refresh: true),
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount:
                                provider.filteredHistory.length +
                                (provider.hasMoreData ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= provider.filteredHistory.length) {
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  alignment: Alignment.center,
                                  child: const CircularProgressIndicator(),
                                );
                              }

                              final item = provider.filteredHistory[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildHistoryCard(item),
                              );
                            },
                          ),
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(History item) {
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.help_outline;

    switch (item.status) {
      case 'hadir':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'izin':
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
                  item.title,
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
                      item.status,
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
                DateFormatter.formatDate(item.date, 'dd MMMM yyyy'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Masuk: ${item.checkInTime != null ? DateFormatter.formatTime(DateTime.parse(item.checkInTime!)) : "-"}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              if (item.checkOutTime != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time_filled,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Keluar: ${DateFormatter.formatTime(DateTime.parse(item.checkOutTime!))}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.category, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                item.activityType,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
