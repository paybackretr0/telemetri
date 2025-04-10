import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'permission_provider.dart';
import '../../../data/models/activity_model.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_form_fields.dart';

class CreatePermissionScreen extends StatefulWidget {
  const CreatePermissionScreen({super.key});

  @override
  _CreatePermissionScreenState createState() => _CreatePermissionScreenState();
}

class _CreatePermissionScreenState extends State<CreatePermissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  int? _selectedActivityId;
  File? _attachmentFile;
  String? _attachmentFileName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchActivities();
    });
  }

  Future<void> _fetchActivities() async {
    if (!mounted) return;

    setState(() {});

    await Provider.of<PermissionProvider>(
      context,
      listen: false,
    ).getActivities();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment() async {
    if (!mounted) return;

    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null && mounted) {
                    // Check if still mounted
                    setState(() {
                      _attachmentFile = File(pickedFile.path);
                      _attachmentFileName = pickedFile.path.split('/').last;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _attachmentFile = File(pickedFile.path);
                      _attachmentFileName = pickedFile.path.split('/').last;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_copy),
                title: const Text('Dokumen'),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                  );
                  if (result != null) {
                    setState(() {
                      _attachmentFile = File(result.files.single.path!);
                      _attachmentFileName = result.files.single.name;
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedActivityId == null) {
        CustomDialogs.showErrorSnackBar(context, 'Silakan pilih kegiatannya');
        return;
      }

      final confirmed = await CustomDialogs.showConfirmationDialog(
        context: context,
        title: 'Konfirmasi Pengajuan Izin',
        message: 'Apakah Anda yakin ingin mengajukan izin ini?',
        confirmText: 'Ajukan',
        confirmColor: Theme.of(context).primaryColor,
        confirmIcon: Icons.send,
      );

      if (confirmed != true) return;

      try {
        final int activityId = _selectedActivityId!;

        final provider = Provider.of<PermissionProvider>(
          context,
          listen: false,
        );

        final result = await provider.createPermission(
          activityId: activityId,
          reason: _reasonController.text.trim(),
          attachment: _attachmentFile,
        );

        if (mounted) {
          if (result) {
            CustomDialogs.showSuccessSnackBar(context, provider.successMessage);
            Navigator.pop(context, true);
          } else {
            CustomDialogs.showErrorSnackBar(context, provider.errorMessage);
          }
        }
      } catch (e) {
        if (mounted) {
          CustomDialogs.showErrorSnackBar(context, 'Gagal membuat izin');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Buat Izin Baru',
        showBackButton: true,
        showNotification: false,
      ),
      body: Consumer<PermissionProvider>(
        builder: (context, provider, child) {
          final List<Activity> activities = provider.activities;
          final bool isActivitiesLoading =
              provider.activitiesStatus == PermissionStatus.loading;
          final bool isActivitiesError =
              provider.activitiesStatus == PermissionStatus.error;

          if (isActivitiesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (isActivitiesError) {
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
                    onPressed: _fetchActivities,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (activities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Tidak ada kegiatan yang tersedia',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchActivities,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomDropdownField<int>(
                    label: 'Kegiatan',
                    hint: 'Pilih Kegiatan',
                    value: _selectedActivityId,
                    items:
                        activities.map((activity) {
                          int activityId;
                          try {
                            activityId = activity.id;
                          } catch (e) {
                            activityId = 0;
                          }
                          return DropdownMenuItem<int>(
                            value: activityId,
                            child: Text(
                              '${activity.title} (${_formatDateTime(activity.startTime)})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedActivityId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Alasan',
                    hint: 'Berikan alasan izin Anda',
                    controller: _reasonController,
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Alasan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomAttachmentField(
                    label: 'Lampiran (Opsional)',
                    onTap: _pickAttachment,
                    child:
                        _attachmentFile != null
                            ? _buildAttachmentPreview()
                            : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.upload_file,
                                    size: 32,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap untuk memilih file',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  ),
                  const SizedBox(height: 24),

                  CustomSubmitButton(
                    text: 'Kirim Izin',
                    isLoading:
                        provider.createPermissionStatus ==
                        PermissionStatus.loading,
                    onPressed: _submitForm,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildAttachmentPreview() {
    if (_attachmentFile == null) return const SizedBox.shrink();

    final extension = _attachmentFileName?.split('.').last.toLowerCase() ?? '';

    if (['jpg', 'jpeg', 'png'].contains(extension)) {
      return Stack(
        children: [
          Center(
            child: Image.file(_attachmentFile!, height: 100, fit: BoxFit.cover),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                setState(() {
                  _attachmentFile = null;
                  _attachmentFileName = null;
                });
              },
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                extension == 'pdf'
                    ? Icons.picture_as_pdf
                    : Icons.insert_drive_file,
                size: 32,
                color: extension == 'pdf' ? Colors.red : Colors.blue,
              ),
              const SizedBox(height: 8),
              Text(
                _attachmentFileName ?? 'File',
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () {
              setState(() {
                _attachmentFile = null;
                _attachmentFileName = null;
              });
            },
          ),
        ),
      ],
    );
  }
}
