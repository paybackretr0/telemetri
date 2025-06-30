import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'activity_provider.dart';
import '../../../data/models/activity_model.dart';
import 'create_activity_screen.dart';
import '../../widgets/custom_appbar.dart';
import '../../../utils/date_formatter.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final activityProvider = Provider.of<ActivityProvider>(
      context,
      listen: false,
    );
    activityProvider.getMyEvents();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Kegiatan Saya',
        showBackButton: false,
        showNotification: true,
      ),
      body: Consumer<ActivityProvider>(
        builder: (context, provider, child) {
          if (provider.myEventsStatus == EventStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (provider.myEventsStatus == EventStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          } else if (provider.myEvents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada kegiatan',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          } else {
            return RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.myEvents.length,
                itemBuilder: (context, index) {
                  final activity = provider.myEvents[index];
                  return _buildActivityCard(activity);
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateActivityScreen(),
            ),
          );

          if (result == true) {
            _loadData();
          }
        },
        tooltip: 'Buat Kegiatan Baru',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildActivityCard(Activity activity) {
    final now = DateTime.now();
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (now.isBefore(activity.startTime)) {
      statusColor = Colors.blue;
      statusIcon = Icons.schedule;
      statusText = 'Akan Datang';
    } else if (now.isAfter(activity.endTime)) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Selesai';
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.play_circle;
      statusText = 'Berlangsung';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to activity detail if needed
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => ActivityDetailScreen(activityId: activity.id),
          //   ),
          // );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      activity.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                activity.description,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      DateFormatter.formatTimeRange(
                        activity.startTime,
                        activity.endTime,
                      ),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      activity.location,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.qr_code, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'QR Code: ${activity.qrCode}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
