import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'permission_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import '../../../data/models/permission_model.dart';
import 'edit_permission_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/activity_model.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_form_fields.dart';
import '../../../data/environment/env_config.dart';
import '../../../utils/date_formatter.dart';

class PermissionDetailScreen extends StatefulWidget {
  final int permissionId;

  const PermissionDetailScreen({super.key, required this.permissionId});

  @override
  _PermissionDetailScreenState createState() => _PermissionDetailScreenState();
}

class _PermissionDetailScreenState extends State<PermissionDetailScreen> {
  late PermissionProvider _permissionProvider;

  @override
  void initState() {
    super.initState();
    _permissionProvider = Provider.of<PermissionProvider>(
      context,
      listen: false,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await _permissionProvider.getPermissionDetail(widget.permissionId);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Detail Izin',
        showBackButton: true,
        showNotification: true,
      ),
      body: Consumer<PermissionProvider>(
        builder: (context, provider, child) {
          if (provider.permissionDetailStatus == PermissionStatus.loading) {
            return Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          } else if (provider.permissionDetailStatus ==
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          } else if (provider.currentPermission == null) {
            return const Center(child: Text('Data izin tidak ditemukan'));
          } else {
            final permission = provider.currentPermission!;
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusCard(permission, primaryColor),
                        const SizedBox(height: 16),
                        if (permission.activity != null)
                          _buildActivityCard(
                            permission.activity!,
                            primaryColor,
                          ),
                        const SizedBox(height: 16),
                        _buildDetailCard(permission, primaryColor),
                        const SizedBox(height: 16),
                        if (permission.attachment != null)
                          _buildAttachmentCard(
                            permission.attachment!,
                            primaryColor,
                          ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
                if (permission.status == 'pending' ||
                    permission.status == 'approved')
                  _buildActionButtons(permission, primaryColor),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildActionButtons(Permission permission, Color primaryColor) {
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
          if (permission.status == 'pending') ...[
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text('Edit Izin'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              EditPermissionScreen(permission: permission),
                    ),
                  );

                  if (result == true) {
                    _loadData();
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.cancel, color: Colors.white),
              label: const Text('Batalkan Izin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                _showDeleteConfirmation(permission);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Activity activity, Color primaryColor) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Informasi Kegiatan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            Divider(),
            const SizedBox(height: 8),
            _buildInfoRow('Nama Kegiatan', activity.name),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Waktu',
              DateFormatter.formatTimeRange(
                activity.startTime,
                activity.endTime,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Lokasi', activity.location),
            const SizedBox(height: 8),
            _buildInfoRow('Deskripsi', activity.description),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(Permission permission, Color primaryColor) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Detail Izin',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            Divider(),
            const SizedBox(height: 8),
            _buildInfoRow('Pengaju', permission.user?.name ?? '-'),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Tanggal Pengajuan',
              DateFormatter.formatDateTimeIndonesia(
                DateTime.parse(permission.createdAt),
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Alasan', permission.reason, isMultiLine: true),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(Permission permission, Color primaryColor) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (permission.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = 'Menunggu Persetujuan';
        break;
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Disetujui';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Ditolak';
        break;
      case 'cancelled':
        statusColor = Colors.purple;
        statusIcon = Icons.cancel;
        statusText = 'Dibatalkan';
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = 'Unknown';
    }

    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 48),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  if (permission.approvedAt != null)
                    Text(
                      'Diproses pada: ${DateFormatter.formatDateTimeIndonesia(DateTime.parse(permission.approvedAt!))}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  if (permission.approver != null)
                    Text(
                      'Oleh: ${permission.approver!.name}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentCard(String attachment, Color primaryColor) {
    String fileName = attachment.split('/').last;
    final extension = fileName.split('.').last.toLowerCase();
    final isImage = ['jpg', 'jpeg', 'png', 'gif'].contains(extension);
    final isPdf = extension == 'pdf';

    String displayName =
        isImage
            ? 'Lampiran Izin.$extension'
            : extension == 'pdf'
            ? 'Lampiran Izin.pdf'
            : 'Lampiran Izin';

    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_file, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Lampiran',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                _getFileIcon(fileName),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    displayName,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                if (!isImage)
                  IconButton(
                    icon: Icon(
                      isPdf ? Icons.picture_as_pdf : Icons.open_in_new,
                      color: isPdf ? Colors.red : primaryColor,
                    ),
                    onPressed: () {
                      _openAttachment(attachment);
                    },
                  ),
              ],
            ),
            if (isImage) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  _showFullScreenImage(attachment);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    children: [
                      CachedNetworkImage(
                        imageUrl: _getAttachmentUrl(attachment),
                        placeholder:
                            (context, url) => Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      color: primaryColor,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Memuat gambar...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        errorWidget: (context, url, error) {
                          return Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 48,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Gagal memuat gambar',
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  error.toString(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.red[300],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                        fit: BoxFit.contain,
                        memCacheHeight: 500,
                        memCacheWidth: 500,
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Ketuk untuk memperbesar',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(String attachment) {
    final url = _getAttachmentUrl(attachment);

    showDialog(
      context: context,
      builder:
          (BuildContext context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.zero,
            child: Stack(
              children: [
                InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4,
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.contain,
                    placeholder:
                        (context, url) => Container(
                          color: Colors.black45,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.black87,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.white,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Tidak dapat memuat gambar',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _openAttachment(String attachmentPath) async {
    final url = _getAttachmentUrl(attachmentPath);
    final extension = attachmentPath.split('.').last.toLowerCase();
    final isPdf = extension == 'pdf';

    try {
      final Uri uri = Uri.parse(url);

      if (isPdf) {
        if (await canLaunch(uri.toString())) {
          await launch(
            uri.toString(),
            forceSafariVC: false,
            forceWebView: false,
            headers: <String, String>{'header_key': 'header_value'},
          );
        } else {
          _showPdfOptions(uri.toString());
        }
      } else if (await canLaunch(uri.toString())) {
        await launch(uri.toString(), forceSafariVC: false, forceWebView: false);
      } else {
        if (mounted) {
          CustomDialogs.showErrorSnackBar(
            context,
            'Tidak dapat membuka lampiran',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        CustomDialogs.showErrorSnackBar(context, 'Error: $e');
      }
    }
  }

  void _showPdfOptions(String url) {
    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Buka PDF'),
            content: const Text(
              'Tidak ditemukan aplikasi untuk membuka file PDF. Pilih opsi berikut:',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  launch(url, forceSafariVC: true, forceWebView: true);
                },
                child: const Text('Buka di Browser'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Clipboard.setData(ClipboardData(text: url)).then((_) {
                    if (mounted) {
                      CustomDialogs.showSuccessSnackBar(
                        context,
                        'Link disalin ke clipboard',
                      );
                    }
                  });
                },
                child: const Text('Salin Link'),
              ),
            ],
          ),
    );
  }

  String _getAttachmentUrl(String attachmentPath) {
    if (attachmentPath.startsWith('/')) {
      attachmentPath = attachmentPath.substring(1);
    }

    String baseUrl = EnvConfig.storageUrl;
    if (!baseUrl.endsWith('/')) {
      baseUrl += '/';
    }

    final url = baseUrl + attachmentPath;
    return url;
  }

  Widget _buildInfoRow(String label, String value, {bool isMultiLine = false}) {
    final primaryColor = Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: primaryColor.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
          textAlign: isMultiLine ? TextAlign.justify : TextAlign.start,
        ),
      ],
    );
  }

  void _showDeleteConfirmation(Permission permission) {
    final primaryColor = Theme.of(context).primaryColor;
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Konfirmasi Pembatalan',
              style: TextStyle(color: primaryColor),
            ),
            content: const Text(
              'Apakah Anda yakin ingin membatalkan izin ini?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Tidak'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  Navigator.pop(context);

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder:
                        (context) =>
                            const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    final result = await _permissionProvider.cancelPermission(
                      permission.id,
                    );

                    navigator.pop();

                    if (mounted) {
                      if (result) {
                        CustomDialogs.showSuccessSnackBar(
                          context,
                          'Izin berhasil dibatalkan',
                        );
                        navigator.pop(true);
                      } else {
                        CustomDialogs.showErrorSnackBar(
                          context,
                          'Gagal membatalkan izin',
                        );
                      }
                    }
                  } catch (e) {
                    navigator.pop();
                    if (mounted) {
                      CustomDialogs.showErrorSnackBar(
                        context,
                        'Terjadi kesalahan: ${e.toString()}',
                      );
                    }
                  }
                },
                child: const Text('Ya'),
              ),
            ],
          ),
    );
  }

  Widget _getFileIcon(String fileName) {
    IconData iconData;
    Color iconColor;
    final primaryColor = Theme.of(context).primaryColor;

    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        iconData = Icons.picture_as_pdf;
        iconColor = Colors.red;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
        iconData = Icons.image;
        iconColor = primaryColor;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = primaryColor;
    }

    return Icon(iconData, color: iconColor, size: 32);
  }
}
