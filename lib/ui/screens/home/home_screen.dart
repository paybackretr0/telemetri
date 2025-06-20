import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:telemetri/ui/widgets/custom_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:telemetri/ui/navigations/app_routes.dart';
import 'package:telemetri/data/models/activity_model.dart';
import 'package:telemetri/data/models/history_model.dart';
import 'package:telemetri/data/environment/env_config.dart';
import 'package:telemetri/utils/platform_helper.dart';
import 'package:telemetri/utils/responsive_helper.dart';
import 'home_provider.dart';
import 'package:telemetri/utils/date_formatter.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await _homeProvider.refreshHomeData();
        },
        child: Consumer<HomeProvider>(
          builder: (context, provider, _) {
            if (PlatformHelper.isWeb) {
              return _buildWebLayout(provider);
            } else {
              return _buildMobileLayout(provider);
            }
          },
        ),
      ),
    );
  }

  Widget _buildWebLayout(HomeProvider provider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
              ),
            ),
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveHelper.getMaxContentWidth(context),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 800) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildProfileImage(provider.currentUser),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selamat Datang',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      provider.currentUser?.name ??
                                          "[Nama User]",
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Neo Telemetri Dashboard',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: _buildQuickStatCard(
                                  'Hari Ini',
                                  '${provider.todayActivities.length}',
                                  Icons.today,
                                  Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildQuickStatCard(
                                  'Riwayat',
                                  '${provider.recentHistory.length}',
                                  Icons.history,
                                  Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else {
                      return Row(
                        children: [
                          _buildProfileImage(provider.currentUser),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selamat Datang',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  provider.currentUser?.name ?? "[Nama User]",
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Neo Telemetri Dashboard',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (ResponsiveHelper.isDesktop(context)) ...[
                            _buildQuickStatCard(
                              'Hari Ini',
                              '${provider.todayActivities.length}',
                              Icons.today,
                              Colors.blue,
                            ),
                            const SizedBox(width: 16),
                            _buildQuickStatCard(
                              'Riwayat',
                              '${provider.recentHistory.length}',
                              Icons.history,
                              Colors.green,
                            ),
                          ],
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ),

          Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: ResponsiveHelper.getMaxContentWidth(context),
              ),
              padding: ResponsiveHelper.getContentPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!ResponsiveHelper.isDesktop(context))
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildQuickStatCard(
                              'Kegiatan Hari Ini',
                              '${provider.todayActivities.length}',
                              Icons.today,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildQuickStatCard(
                              'Total Riwayat',
                              '${provider.recentHistory.length}',
                              Icons.history,
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (ResponsiveHelper.isDesktop(context))
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _buildAttendanceGraph(),
                              const SizedBox(height: 24),
                              _buildTodayActivitiesSection(provider),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 1,
                          child: _buildRecentHistorySection(provider),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildAttendanceGraph(),
                        const SizedBox(height: 24),
                        _buildTodayActivitiesSection(provider),
                        const SizedBox(height: 24),
                        _buildRecentHistorySection(provider),
                      ],
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(HomeProvider provider) {
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
                            style: const TextStyle(
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
              _buildTodayActivitiesSection(provider),
              const SizedBox(height: 24),
              _buildRecentHistorySection(provider),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayActivitiesSection(HomeProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Kegiatan Hari Ini',
                style: TextStyle(
                  fontSize: PlatformHelper.isWeb ? 20 : 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  RouteNames.main,
                  arguments: {'initialIndex': 1},
                );
              },
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (provider.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (provider.todayActivities.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.event_busy, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'Tidak ada kegiatan hari ini',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              if (PlatformHelper.isWeb && ResponsiveHelper.isDesktop(context)) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 3,
                  ),
                  itemCount: provider.todayActivities.length,
                  itemBuilder: (context, index) {
                    return _buildTodayActivityCard(
                      provider.todayActivities[index],
                    );
                  },
                );
              } else {
                return Column(
                  children:
                      provider.todayActivities
                          .map((activity) => _buildTodayActivityCard(activity))
                          .toList(),
                );
              }
            },
          ),
      ],
    );
  }

  Widget _buildRecentHistorySection(HomeProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Riwayat Terbaru',
                style: TextStyle(
                  fontSize: PlatformHelper.isWeb ? 20 : 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                if (PlatformHelper.isWeb) {
                  Navigator.pushReplacementNamed(
                    context,
                    RouteNames.main,
                    arguments: {'initialIndex': 2},
                  );
                } else {
                  Navigator.pushReplacementNamed(
                    context,
                    RouteNames.main,
                    arguments: {'initialIndex': 3},
                  );
                }
              },
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (provider.isLoading && provider.recentHistory.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (provider.recentHistory.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.history_toggle_off,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'Tidak ada riwayat kehadiran',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
            ),
          )
        else
          Column(
            children:
                provider.recentHistory
                    .take(PlatformHelper.isWeb ? 5 : 3)
                    .map((history) => _buildHistoryCard(history))
                    .toList(),
          ),
      ],
    );
  }

  Widget _buildAttendanceGraph() {
    Map<int, List<History>> historyByMonth = {};
    Map<int, double> attendancePercentage = {};
    double totalPercentage = 0;
    int monthCount = 0;

    for (var history in _homeProvider.recentHistory) {
      int month = history.date.month;
      historyByMonth.putIfAbsent(month, () => []);
      historyByMonth[month]!.add(history);
    }

    historyByMonth.forEach((month, histories) {
      int totalDays = histories.length;
      int presentDays = histories.where((h) => h.status == 'hadir').length;
      double percentage = totalDays > 0 ? (presentDays / totalDays) * 100 : 0;
      attendancePercentage[month] = percentage;
      totalPercentage += percentage;
      monthCount++;
    });

    double averagePercentage =
        monthCount > 0 ? totalPercentage / monthCount : 0;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Statistik Kehadiran',
                  style: TextStyle(
                    fontSize: PlatformHelper.isWeb ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Rata-rata: ${averagePercentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
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
            height: PlatformHelper.isWeb ? 300 : 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween,
                maxY: 100,
                barGroups: List.generate(12, (index) {
                  double value = attendancePercentage[index + 1] ?? 0;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.7),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: PlatformHelper.isWeb ? 16 : 14,
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
                            style: TextStyle(
                              fontSize: PlatformHelper.isWeb ? 12 : 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF555555),
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
                            style: TextStyle(
                              fontSize: PlatformHelper.isWeb ? 12 : 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF555555),
                            ),
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.event,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.location,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                Text(
                  DateFormatter.formatTime(activity.startTime),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(dynamic user) {
    Widget defaultAvatar = CircleAvatar(
      radius: PlatformHelper.isWeb ? 40 : 30,
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Icon(
        Icons.person,
        size: PlatformHelper.isWeb ? 50 : 40,
        color: Theme.of(context).primaryColor,
      ),
    );

    if (user?.profilePicture == null || user.profilePicture.isEmpty) {
      return defaultAvatar;
    }

    final String profilePicture = user.profilePicture;
    final double radius = PlatformHelper.isWeb ? 40 : 30;

    if (profilePicture.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.network(
          profilePicture,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => defaultAvatar,
        ),
      );
    }

    final String storageUrl = EnvConfig.storageUrl;
    final String fullUrl =
        profilePicture.startsWith('/')
            ? '$storageUrl${profilePicture.substring(1)}'
            : '$storageUrl$profilePicture';

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        fullUrl,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => defaultAvatar,
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
      margin: const EdgeInsets.only(bottom: 12),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
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
                DateFormatter.formatDate(item.date, 'dd MMM yyyy'),
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
