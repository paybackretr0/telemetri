import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:telemetri/ui/widgets/custom_appbar.dart';
import 'package:telemetri/ui/widgets/custom_card.dart';
import 'package:telemetri/ui/widgets/custom_form_fields.dart';
import '../../../utils/date_formatter.dart';
import 'notification_provider.dart';
import '../../../data/models/notification_model.dart' as model;
import '../../navigations/app_routes.dart';
import '../permission/permission_screen.dart';
import '../delegation/delegation_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Unread', 'Read'];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      provider.loadNotifications(refresh: true);
      provider.getUnreadCount();

      _scrollController.addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
          provider.loadMore();
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildDismissibleNotificationItem(
    BuildContext context,
    model.Notification notification,
    int index,
  ) {
    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await CustomDialogs.showConfirmationDialog(
          context: context,
          title: 'Hapus Notifikasi',
          message: 'Apakah Anda yakin ingin menghapus notifikasi ini?',
          confirmText: 'Hapus',
          cancelText: 'Batal',
          confirmColor: Colors.red,
          confirmIcon: Icons.delete,
          cancelIcon: Icons.close,
        );
      },
      onDismissed: (direction) {
        Provider.of<NotificationProvider>(
          context,
          listen: false,
        ).deleteNotification(notification.id).then((success) {
          if (success) {
            CustomDialogs.showSuccessSnackBar(
              context,
              'Notifikasi berhasil dihapus',
            );
          } else {
            CustomDialogs.showErrorSnackBar(
              context,
              'Gagal menghapus notifikasi',
            );
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () => _markAsRead(context, notification),
          child: _buildNotificationCard(notification),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifikasi',
        showBackButton: true,
        showNotification: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () => _markAllAsRead(context),
            tooltip: 'Tandai semua sebagai dibaca',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _deleteAllNotifications(context),
            tooltip: 'Hapus semua notifikasi',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: Consumer<NotificationProvider>(
              builder: (context, provider, child) {
                if (provider.status == NotificationStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (provider.status == NotificationStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text('Error: ${provider.errorMessage}'),
                        const SizedBox(height: 16),
                        CustomSubmitButton(
                          text: 'Coba Lagi',
                          isLoading: false,
                          onPressed:
                              () => provider.loadNotifications(refresh: true),
                        ),
                      ],
                    ),
                  );
                } else if (provider.notifications.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text('Tidak ada notifikasi'),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadNotifications(refresh: true),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        provider.notifications.length +
                        (provider.hasMoreData ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.notifications.length) {
                        return provider.isLoadingMore
                            ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                            : const SizedBox.shrink();
                      }

                      final notification = provider.notifications[index];
                      return _buildDismissibleNotificationItem(
                        context,
                        notification,
                        index,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
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
                  onTap: () {
                    setState(() => _selectedFilter = filter);
                    Provider.of<NotificationProvider>(
                      context,
                      listen: false,
                    ).filterByReadStatus(filter);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Theme.of(context).primaryColor.withOpacity(0.1)
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
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildNotificationCard(model.Notification notification) {
    IconData getIcon() {
      switch (notification.type) {
        case 'success':
          return Icons.check_circle;
        case 'reminder':
          return Icons.notifications_active;
        case 'info':
          return Icons.info;
        case 'warning':
          return Icons.warning_amber;
        case 'error':
          return Icons.error;
        default:
          return Icons.notifications;
      }
    }

    Color getColor() {
      switch (notification.type) {
        case 'success':
          return Colors.green;
        case 'reminder':
          return Colors.orange;
        case 'info':
          return Colors.blue;
        case 'warning':
          return Colors.amber;
        case 'error':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    String formatDateTime(DateTime dateTime) {
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return DateFormatter.formatDateTimeIndonesia(dateTime);
      } else if (difference.inHours > 0) {
        return '${difference.inHours} jam yang lalu';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} menit yang lalu';
      } else {
        return 'Baru saja';
      }
    }

    return CustomCard(
      child: Stack(
        children: [
          if (!notification.isRead)
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
                            notification.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
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
                      notification.message,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDateTime(notification.createdAt),
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

  void _markAsRead(BuildContext context, model.Notification notification) {
    if (!notification.isRead) {
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).markAsRead(notification.id);
    }

    switch (notification.type) {
      case 'attendance':
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.main,
          (route) => false,
          arguments: {'initialIndex': 3},
        );
        break;
      case 'program':
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.main,
          (route) => false,
          arguments: {'initialIndex': 1},
        );
        break;
      case 'permission':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PermissionScreen()),
        );
        break;
      case 'delegation':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DelegationScreen()),
        );
        break;
      default:
        break;
    }
  }

  void _markAllAsRead(BuildContext context) {
    CustomDialogs.showConfirmationDialog(
      context: context,
      title: 'Tandai Semua Sebagai Dibaca',
      message:
          'Apakah Anda yakin ingin menandai semua notifikasi sebagai dibaca?',
      confirmText: 'Ya',
      cancelText: 'Batal',
      confirmColor: Theme.of(context).primaryColor,
      confirmIcon: Icons.done_all,
      cancelIcon: Icons.close,
    ).then((confirmed) {
      if (confirmed == true) {
        Provider.of<NotificationProvider>(
          context,
          listen: false,
        ).markAllAsRead().then((success) {
          if (success) {
            CustomDialogs.showSuccessSnackBar(
              context,
              'Semua notifikasi telah ditandai sebagai dibaca',
            );
          } else {
            CustomDialogs.showErrorSnackBar(
              context,
              'Gagal menandai notifikasi sebagai dibaca',
            );
          }
        });
      }
    });
  }

  void _deleteAllNotifications(BuildContext context) {
    CustomDialogs.showConfirmationDialog(
      context: context,
      title: 'Hapus Semua Notifikasi',
      message: 'Apakah Anda yakin ingin menghapus semua notifikasi?',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      confirmColor: Colors.red,
      confirmIcon: Icons.delete_forever,
      cancelIcon: Icons.close,
    ).then((confirmed) {
      if (confirmed == true) {
        Provider.of<NotificationProvider>(
          context,
          listen: false,
        ).deleteAllNotifications().then((success) {
          if (success) {
            CustomDialogs.showSuccessSnackBar(
              context,
              'Semua notifikasi berhasil dihapus',
            );
          } else {
            CustomDialogs.showErrorSnackBar(
              context,
              'Gagal menghapus semua notifikasi',
            );
          }
        });
      }
    });
  }
}
