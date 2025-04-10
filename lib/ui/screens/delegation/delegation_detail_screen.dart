import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/delegation_model.dart';
import '../../../utils/date_formatter.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_card.dart';
import 'delegation_provider.dart';
import 'edit_delegation_screen.dart';
import '../../widgets/custom_form_fields.dart';

class DelegationDetailScreen extends StatelessWidget {
  final Delegation delegation;
  final bool isOutgoingRequest;

  const DelegationDetailScreen({
    super.key,
    required this.delegation,
    required this.isOutgoingRequest,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DelegationProvider>(context, listen: false);
    final theme = Theme.of(context);

    final bool isFutureDate = delegation.delegationDate.isAfter(DateTime.now());

    return Scaffold(
      appBar: CustomAppBar(title: 'Detail Permohonan', showBackButton: true),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[100]),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: _buildStatusBadge(delegation.status),
                    ),
                    const SizedBox(height: 24),

                    _buildInfoSection(
                      'Informasi Jadwal',
                      Icons.schedule,
                      theme.primaryColor,
                      [
                        _buildDetailItem(
                          'Jadwal Piket',
                          delegation.dutySchedule != null
                              ? '${delegation.dutySchedule!.dayOfWeek} - ${delegation.dutySchedule!.location}'
                              : 'Tugas Piket #${delegation.dutyScheduleId}',
                          Icons.calendar_today,
                        ),
                        if (delegation.dutySchedule != null)
                          _buildDetailItem(
                            'Waktu Piket',
                            DateFormatter.formatTimeRange(
                              delegation.dutySchedule!.startTime,
                              delegation.dutySchedule!.endTime,
                            ).split(',')[1].trim(),
                            Icons.access_time,
                          ),
                        _buildDetailItem(
                          'Tanggal Delegasi',
                          DateFormatter.formatDateTimeIndonesia(
                            delegation.delegationDate,
                          ).split(',')[0],
                          Icons.event,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    _buildInfoSection(
                      'Informasi Delegasi',
                      Icons.swap_horiz,
                      Colors.blue,
                      [
                        _buildDetailItem(
                          'Pemohon',
                          delegation.requester?.name ?? 'Tidak diketahui',
                          Icons.person_outline,
                        ),
                        _buildDetailItem(
                          'Delegasi Kepada',
                          delegation.delegate?.name ?? 'Tidak diketahui',
                          Icons.person,
                        ),
                        _buildDetailItem(
                          'Alasan',
                          delegation.reason,
                          Icons.description,
                        ),
                      ],
                    ),

                    if (delegation.approver != null ||
                        delegation.approvedAt != null)
                      Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildInfoSection(
                            'Informasi Persetujuan',
                            Icons.verified_user,
                            Colors.green,
                            [
                              if (delegation.approver != null)
                                _buildDetailItem(
                                  'Disetujui Oleh',
                                  delegation.approver!.name,
                                  Icons.verified_user,
                                ),
                              if (delegation.approvedAt != null)
                                _buildDetailItem(
                                  'Disetujui Pada',
                                  DateFormatter.formatDateTimeIndonesia(
                                    delegation.approvedAt!,
                                  ),
                                  Icons.update,
                                ),
                            ],
                          ),
                        ],
                      ),

                    const SizedBox(height: 16),
                    _buildInfoSection(
                      'Informasi Tambahan',
                      Icons.info_outline,
                      Colors.grey[700]!,
                      [
                        _buildDetailItem(
                          'Dibuat Pada',
                          DateFormatter.formatDateTimeIndonesia(
                            DateTime.parse(delegation.createdAt),
                          ),
                          Icons.history,
                        ),
                        _buildDetailItem(
                          'Diperbarui Pada',
                          DateFormatter.formatDateTimeIndonesia(
                            DateTime.parse(delegation.updatedAt),
                          ),
                          Icons.update,
                        ),
                      ],
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            if (delegation.status == 'pending' ||
                (delegation.status == 'approved' &&
                    isFutureDate &&
                    isOutgoingRequest))
              _buildActionButtons(context, delegation.id, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    int delegationId,
    DelegationProvider provider,
  ) {
    final bool isApproved = delegation.status == 'approved';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: Icon(
                isOutgoingRequest ? Icons.edit : Icons.check,
                color: Colors.white,
              ),
              label: Text(
                isOutgoingRequest ? 'Edit' : 'Setujui',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isOutgoingRequest ? Colors.blue : Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
                disabledBackgroundColor: Colors.green,
                disabledForegroundColor: Colors.white,
              ),
              onPressed:
                  (isApproved && !isOutgoingRequest)
                      ? null
                      : () {
                        if (isOutgoingRequest) {
                          _handleEdit(context, delegationId, provider);
                        } else {
                          _handleApprove(context, delegationId, provider);
                        }
                      },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              icon: Icon(
                isOutgoingRequest ? Icons.cancel : Icons.close,
                color: Colors.white,
              ),
              label: Text(
                isOutgoingRequest ? 'Batalkan' : 'Tolak',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
              ),
              onPressed: () {
                if (isOutgoingRequest) {
                  _handleCancel(context, delegationId, provider);
                } else {
                  _handleReject(context, delegationId, provider);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    String text;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending;
        text = 'Menunggu';
        break;
      case 'approved':
        color = Colors.green;
        icon = Icons.check_circle;
        text = 'Disetujui';
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        text = 'Ditolak';
        break;
      case 'cancelled':
        color = Colors.purple;
        icon = Icons.cancel;
        text = 'Dibatalkan';
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
        text = 'Tidak Diketahui';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    String title,
    IconData titleIcon,
    Color iconColor,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Row(
            children: [
              Icon(titleIcon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
            ],
          ),
        ),
        CustomCard(
          elevation: 2,
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: Colors.grey[800]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleEdit(
    BuildContext context,
    int delegationId,
    DelegationProvider provider,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDelegationScreen(delegation: delegation),
      ),
    );

    if (result == true) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _handleCancel(
    BuildContext context,
    int delegationId,
    DelegationProvider provider,
  ) async {
    final confirmed = await CustomDialogs.showConfirmationDialog(
      context: context,
      title: 'Konfirmasi Pembatalan',
      message: 'Apakah Anda yakin ingin membatalkan delegasi ini?',
      confirmText: 'Batalkan',
      confirmColor: Colors.red,
      confirmIcon: Icons.cancel,
    );

    if (confirmed != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final result = await provider.cancelDelegation(delegationId);

    if (context.mounted) Navigator.pop(context);

    if (result) {
      if (context.mounted) {
        Navigator.pop(context, true);
        CustomDialogs.showSuccessSnackBar(context, provider.successMessage);
      }
    } else {
      if (context.mounted) {
        CustomDialogs.showErrorSnackBar(context, provider.errorMessage);
      }
    }
  }

  Future<void> _handleApprove(
    BuildContext context,
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final result = await provider.approveDelegation(delegationId);

    if (context.mounted) Navigator.pop(context);

    if (result) {
      if (context.mounted) {
        Navigator.pop(context, true);
        CustomDialogs.showSuccessSnackBar(context, provider.successMessage);
      }
    } else {
      if (context.mounted) {
        CustomDialogs.showErrorSnackBar(context, provider.errorMessage);
      }
    }
  }

  Future<void> _handleReject(
    BuildContext context,
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final result = await provider.rejectDelegation(delegationId);

    if (context.mounted) Navigator.pop(context);

    if (result) {
      if (context.mounted) {
        Navigator.pop(context, true);
        CustomDialogs.showSuccessSnackBar(context, provider.successMessage);
      }
    } else {
      if (context.mounted) {
        CustomDialogs.showErrorSnackBar(context, provider.errorMessage);
      }
    }
  }
}
