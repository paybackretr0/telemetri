import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:telemetri/ui/screens/delegation/delegation_detail_screen.dart';
import '../../../data/models/delegation_model.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_card.dart';
import '../../../utils/date_formatter.dart';
import 'delegation_provider.dart';
import 'create_delegation_screen.dart';
import '../../widgets/custom_form_fields.dart';

class DelegationScreen extends StatefulWidget {
  final bool showBackButton;

  const DelegationScreen({super.key, this.showBackButton = false});

  @override
  _DelegationScreenState createState() => _DelegationScreenState();
}

class _DelegationScreenState extends State<DelegationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedStatus;
  bool _showMyDelegations = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabSelection);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDelegations();
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
      _loadDelegations();
    }
  }

  void _loadDelegations() {
    final provider = Provider.of<DelegationProvider>(context, listen: false);
    provider.getMyDelegations(
      status: _selectedStatus,
      role: _showMyDelegations ? 'requester' : 'delegate',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Pergantian Piket',
        showBackButton: widget.showBackButton,
        showNotification: true,
      ),
      body: Column(
        children: [
          Container(
            color: primaryColor,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SegmentedButton<bool>(
                  style: SegmentedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    foregroundColor: Colors.white,
                    selectedForegroundColor: primaryColor,
                    selectedBackgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  segments: [
                    ButtonSegment<bool>(
                      value: true,
                      label: const Text('Permintaan Keluar'),
                      icon: Icon(
                        Icons.outgoing_mail,
                        color: _showMyDelegations ? primaryColor : Colors.white,
                      ),
                    ),
                    ButtonSegment<bool>(
                      value: false,
                      label: const Text('Permintaan Masuk'),
                      icon: Icon(
                        Icons.inbox,
                        color:
                            !_showMyDelegations ? primaryColor : Colors.white,
                      ),
                    ),
                  ],
                  selected: {_showMyDelegations},
                  onSelectionChanged: (Set<bool> selection) {
                    setState(() {
                      _showMyDelegations = selection.first;
                    });
                    _loadDelegations();
                  },
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.white, width: 3),
                    ),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.7),
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                  tabs: const [
                    Tab(text: 'Semua'),
                    Tab(text: 'Pending'),
                    Tab(text: 'Ditolak'),
                    Tab(text: 'Disetujui'),
                    Tab(text: 'Dibatalkan'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<DelegationProvider>(
              builder: (context, provider, child) {
                return _buildContent(provider);
              },
            ),
          ),
        ],
      ),
      floatingActionButton:
          _showMyDelegations
              ? FloatingActionButton(
                backgroundColor: primaryColor,
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateDelegationScreen(),
                    ),
                  );
                  if (result == true) _loadDelegations();
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: const Icon(Icons.add, color: Colors.white),
              )
              : null,
    );
  }

  Widget _buildContent(DelegationProvider provider) {
    if (provider.myDelegationsStatus == DelegationStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (provider.myDelegationsStatus == DelegationStatus.error) {
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
              onPressed: _loadDelegations,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    } else if (provider.myDelegations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Tidak ada data pergantian piket',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDelegations,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    } else {
      return RefreshIndicator(
        onRefresh: () async {
          _loadDelegations();
        },
        child: ListView.builder(
          itemCount: provider.myDelegations.length,
          itemBuilder: (context, index) {
            final delegation = provider.myDelegations[index];
            return _buildDelegationCard(delegation, provider);
          },
        ),
      );
    }
  }

  Widget _buildDelegationCard(
    Delegation delegation,
    DelegationProvider provider,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    Color statusColor;
    IconData statusIcon;

    switch (delegation.status) {
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

    return CustomCard(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2.0,
      color: isDarkMode ? theme.cardColor : Colors.white,
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => DelegationDetailScreen(
                  delegation: delegation,
                  isOutgoingRequest: _showMyDelegations,
                ),
          ),
        );
        if (result == true) _loadDelegations();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  delegation.dutySchedule != null
                      ? '${delegation.dutySchedule!.dayOfWeek} - ${delegation.dutySchedule!.location}'
                      : 'Tugas Piket #${delegation.dutyScheduleId}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _getStatusText(delegation.status),
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
          const SizedBox(height: 12),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Row(
              key: ValueKey(_showMyDelegations),
              children: [
                Icon(
                  _showMyDelegations ? Icons.outgoing_mail : Icons.inbox,
                  size: 16,
                  color: theme.hintColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _showMyDelegations
                        ? 'Didelegasikan ke: ${delegation.delegate?.name ?? 'Tidak diketahui'}'
                        : 'Dari: ${delegation.requester?.name ?? 'Tidak diketahui'}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Text(
            delegation.reason,
            style: theme.textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: theme.hintColor),
              const SizedBox(width: 8),
              Text(
                DateFormatter.formatDateTimeIndonesia(
                  delegation.delegationDate,
                ).split(',')[0],
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(width: 16),
              if (delegation.dutySchedule != null) ...[
                Icon(Icons.access_time, size: 14, color: theme.hintColor),
                const SizedBox(width: 8),
                Text(
                  DateFormatter.formatTimeRange(
                    delegation.dutySchedule!.startTime,
                    delegation.dutySchedule!.endTime,
                  ).split(',')[1].trim(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 8),
          if (delegation.status == 'pending' && !_showMyDelegations)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Setujui'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green.withOpacity(0.1),
                      foregroundColor: Colors.green,
                    ),
                    onPressed: () => _handleApprove(delegation.id, provider),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Tolak'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      foregroundColor: Colors.red,
                    ),
                    onPressed: () => _handleReject(delegation.id, provider),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Tidak Diketahui';
    }
  }

  Future<void> _handleApprove(
    int delegationId,
    DelegationProvider provider,
  ) async {
    final confirmed = await CustomDialogs.showConfirmationDialog(
      context: context,
      title: 'Konfirmasi Persetujuan',
      message: 'Apakah Anda yakin ingin menyetujui permintaan delegasi ini?',
      confirmText: 'Setujui',
      confirmColor: Colors.green,
      confirmIcon: Icons.check,
    );

    if (confirmed != true) return;

    final result = await provider.approveDelegation(delegationId);

    if (mounted) {
      if (result) {
        CustomDialogs.showSuccessSnackBar(context, provider.successMessage);
        _loadDelegations();
      } else {
        CustomDialogs.showErrorSnackBar(context, provider.errorMessage);
      }
    }
  }

  Future<void> _handleReject(
    int delegationId,
    DelegationProvider provider,
  ) async {
    final confirmed = await CustomDialogs.showConfirmationDialog(
      context: context,
      title: 'Konfirmasi Penolakan',
      message: 'Apakah Anda yakin ingin menolak permintaan delegasi ini?',
      confirmText: 'Tolak',
      confirmColor: Colors.red,
    );

    if (confirmed != true) return;

    final result = await provider.rejectDelegation(delegationId);

    if (mounted) {
      if (result) {
        CustomDialogs.showSuccessSnackBar(context, provider.successMessage);
        _loadDelegations();
      } else {
        CustomDialogs.showErrorSnackBar(context, provider.errorMessage);
      }
    }
  }
}
