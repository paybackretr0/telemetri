import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:telemetri/ui/widgets/custom_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:telemetri/ui/navigations/app_routes.dart';
import 'package:telemetri/data/models/activity_model.dart';
import 'package:telemetri/data/environment/env_config.dart';
import 'home_provider.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeProvider _homeProvider;

  @override
  void initState() {
    super.initState();
    _homeProvider = Provider.of<HomeProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeProvider.refreshHomeData();
    });
  }

  Widget _buildAttendanceGraph() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Statistik Kehadiran',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Rata-rata: 87%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween,
                maxY: 100,
                barGroups: List.generate(12, (index) {
                  final data = [85, 90, 75, 95, 80, 88, 92, 78, 83, 89, 91, 87];
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data[index].toDouble(),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF214DD0), Color(0xFF4E8FF3)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 14,
                        borderRadius: BorderRadius.circular(8),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 100,
                          color: Colors.grey.withOpacity(0.08),
                        ),
                      ),
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const titles = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'Mei',
                          'Jun',
                          'Jul',
                          'Agu',
                          'Sep',
                          'Okt',
                          'Nov',
                          'Des',
                        ];
                        return SideTitleWidget(
                          meta: meta,
                          space: 4,
                          angle: 0.3,
                          child: Text(
                            titles[value.toInt()],
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF555555),
                            ),
                          ),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value % 25 != 0) return const SizedBox();
                        return SideTitleWidget(
                          meta: meta,
                          space: 8,
                          child: Text(
                            '${value.toInt()}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF555555),
                            ),
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine:
                      (value) => FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1.2,
                        dashArray: [4, 4],
                      ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipPadding: const EdgeInsets.all(10),
                    tooltipMargin: 8,
                    tooltipRoundedRadius: 10,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.round()}%',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayActivityCard(Activity activity) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activity.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Lokasi: ${activity.location}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Waktu: ${DateFormat('HH:mm').format(activity.startTime)}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceStatusCard(Map<String, dynamic> status) {
    final statusDate = DateTime.parse(status['date']);
    final statusColor =
        status['status'] == 'Hadir'
            ? Colors.green
            : status['status'] == 'Izin'
            ? Colors.orange
            : Colors.red;

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    status['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status['status'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(statusDate),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              'Lokasi: ${status['location']}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Waktu: ${DateFormat('HH:mm').format(statusDate)}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(dynamic user) {
    if (user?.profilePicture == null || user.profilePicture.isEmpty) {
      return CircleAvatar(
        radius: 30,
        backgroundImage: AssetImage('assets/images/default_profile.png'),
      );
    }

    final String profilePicture = user.profilePicture;

    if (profilePicture.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.network(
          profilePicture,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/images/default_profile.png'),
            );
          },
        ),
      );
    }

    final String storageUrl = EnvConfig.storageUrl;

    final String fullUrl =
        profilePicture.startsWith('/')
            ? '$storageUrl${profilePicture.substring(1)}'
            : '$storageUrl$profilePicture';

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Image.network(
        fullUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('assets/images/default_profile.png'),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await _homeProvider.refreshHomeData();
        },
        child: Consumer<HomeProvider>(
          builder: (context, provider, _) {
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      CustomCard(
                        child: Row(
                          children: [
                            _buildProfileImage(provider.currentUser),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Halo, ${provider.currentUser?.name ?? "[Nama User]"}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildAttendanceGraph(),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kegiatan Hari Ini',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                RouteNames.main,
                                arguments: {'initialIndex': 1},
                              );
                            },
                            child: Text(
                              'Lihat Semua',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      provider.isLoading
                          ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 24.0,
                              ),
                              child: CircularProgressIndicator(),
                            ),
                          )
                          : provider.todayActivities.isEmpty
                          ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.0),
                              child: Text(
                                'Tidak ada kegiatan hari ini',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                provider.todayActivities
                                    .map(
                                      (activity) =>
                                          _buildTodayActivityCard(activity),
                                    )
                                    .toList(),
                          ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Riwayat Kehadiran',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                RouteNames.main,
                                arguments: {'initialIndex': 3},
                              );
                            },
                            child: Text(
                              'Lihat Semua',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Column(
                        children:
                            attendanceStatus
                                .map(
                                  (status) =>
                                      _buildAttendanceStatusCard(status),
                                )
                                .toList(),
                      ),

                      const SizedBox(height: 24),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

final List<Map<String, dynamic>> attendanceStatus = [
  {
    'date': DateTime.now().toString(),
    'status': 'Hadir',
    'title': 'Rapat Koordinasi',
    'location': 'Ruang Meeting Utama',
  },
  {
    'date': DateTime.now().subtract(const Duration(days: 1)).toString(),
    'status': 'Izin',
    'title': 'Workshop Flutter',
    'location': 'Aula Gedung B',
  },
];
