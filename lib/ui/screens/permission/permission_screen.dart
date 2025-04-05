import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'permission_provider.dart';
import '../../../data/models/permission_model.dart';
import 'permission_detail_screen.dart';
import 'create_permission_screen.dart';
import '../../widgets/custom_appbar.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  _PermissionScreenState createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabSelection);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _selectedStatus = null;
            break;
          case 1:
            _selectedStatus = 'pending';
            break;
          case 2:
            _selectedStatus = 'rejected';
            break;
          case 3:
            _selectedStatus = 'approved';
            break;
          case 4:
            _selectedStatus = 'cancelled';
            break;
        }
      });
      _loadData();
    }
  }

  void _loadData() {
    final permissionProvider = Provider.of<PermissionProvider>(
      context,
      listen: false,
    );
    permissionProvider.getMyPermissions(status: _selectedStatus);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Izin Saya',
        showBackButton: false,
        showNotification: true,
      ),
      body: Column(
        children: [
          Container(
            color: primaryColor,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              tabs: const [
                Tab(text: 'Semua'),
                Tab(text: 'Pending'),
                Tab(text: 'Ditolak'),
                Tab(text: 'Disetujui'),
                Tab(text: 'Dibatalkan'),
              ],
            ),
          ),
          Expanded(
            child: Consumer<PermissionProvider>(
              builder: (context, provider, child) {
                if (provider.myPermissionsStatus == PermissionStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (provider.myPermissionsStatus ==
                    PermissionStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                } else if (provider.myPermissions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Tidak ada data izin',
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
                      itemCount: provider.myPermissions.length,
                      itemBuilder: (context, index) {
                        final permission = provider.myPermissions[index];
                        return _buildPermissionCard(permission);
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreatePermissionScreen(),
            ),
          );

          if (result == true) {
            _loadData();
          }
        },
        tooltip: 'Buat Izin Baru',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPermissionCard(Permission permission) {
    Color statusColor;
    IconData statusIcon;

    switch (permission.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'cancelled':
        statusColor = Colors.purple;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      PermissionDetailScreen(permissionId: permission.id),
            ),
          ).then((value) {
            if (value == true) {
              _loadData();
            }
          });
        },
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
                      permission.activity?.name ??
                          'Aktivitas #${permission.activityId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          permission.status == 'pending'
                              ? 'Menunggu'
                              : permission.status == 'approved'
                              ? 'Disetujui'
                              : permission.status == 'rejected'
                              ? 'Ditolak'
                              : permission.status == 'cancelled'
                              ? 'Dibatalkan'
                              : 'Tidak Diketahui',
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                permission.reason,
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (permission.activity != null)
                    Text(
                      'Tanggal: ${_formatDate(permission.activity!.startTime.toIso8601String())}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  Text(
                    'Dibuat: ${_formatDate(permission.createdAt)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
