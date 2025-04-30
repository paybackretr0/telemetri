import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'permission_provider.dart';
import '../../../data/models/permission_model.dart';
import '../../../data/models/activity_model.dart';
import '../../widgets/custom_appbar.dart';
import '../../../utils/date_formatter.dart';
import '../../widgets/custom_form_fields.dart';

class EditPermissionScreen extends StatefulWidget {
  final Permission permission;

  const EditPermissionScreen({super.key, required this.permission});

  @override
  _EditPermissionScreenState createState() => _EditPermissionScreenState();
}

class _EditPermissionScreenState extends State<EditPermissionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _reasonController;

  int? _selectedActivityId;
  File? _attachmentFile;
  String? _attachmentFileName;
  bool _attachmentChanged = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController(text: widget.permission.reason);
    _selectedActivityId = widget.permission.activityId;

    if (widget.permission.attachment != null) {
      _attachmentFileName = widget.permission.attachment!.split('/').last;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchActivities();
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _fetchActivities() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    await Provider.of<PermissionProvider>(
      context,
      listen: false,
    ).getActivities();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickAttachment() async {
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
                    setState(() {
                      _attachmentFile = File(pickedFile.path);
                      _attachmentFileName = pickedFile.path.split('/').last;
                      _attachmentChanged = true;
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
                  if (pickedFile != null && mounted) {
                    setState(() {
                      _attachmentFile = File(pickedFile.path);
                      _attachmentFileName = pickedFile.path.split('/').last;
                      _attachmentChanged = true;
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
                  if (result != null && mounted) {
                    setState(() {
                      _attachmentFile = File(result.files.single.path!);
                      _attachmentFileName = result.files.single.name;
                      _attachmentChanged = true;
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
        CustomDialogs.showErrorSnackBar(context, 'Silakan pilih kegiatan');
        return;
      }

      final provider = Provider.of<PermissionProvider>(context, listen: false);

      final reasonChanged =
          _reasonController.text.trim() != widget.permission.reason;
      final activityChanged =
          _selectedActivityId != widget.permission.activityId;

      if (reasonChanged || activityChanged || _attachmentChanged) {
        final confirmed = await CustomDialogs.showConfirmationDialog(
          context: context,
          title: 'Konfirmasi Perubahan',
          message: 'Apakah Anda yakin ingin menyimpan perubahan ini?',
          confirmText: 'Simpan',
          confirmColor: Theme.of(context).primaryColor,
          confirmIcon: Icons.save,
        );

        if (confirmed != true) return;

        final result = await provider.updatePermission(
          id: widget.permission.id,
          activityId: activityChanged ? _selectedActivityId : null,
          reason: reasonChanged ? _reasonController.text.trim() : null,
          attachment: _attachmentChanged ? _attachmentFile : null,
        );

        if (mounted) {
          if (result) {
            CustomDialogs.showSuccessSnackBar(context, provider.successMessage);
            Navigator.pop(context, true);
          } else {
            CustomDialogs.showErrorSnackBar(context, provider.errorMessage);
          }
        }
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Edit Izin',
        showBackButton: true,
        showNotification: false,
      ),
      body: Consumer<PermissionProvider>(
        builder: (context, provider, child) {
          final List<Activity> activities = provider.activities;
          final bool isActivitiesLoading =
              provider.activitiesStatus == PermissionStatus.loading;

          if (isActivitiesLoading) {
            return const Center(child: CircularProgressIndicator());
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
                        activities
                            .where(
                              (activity) =>
                                  activity.startTime.isAfter(DateTime.now()),
                            )
                            .map((activity) {
                              return DropdownMenuItem<int>(
                                value: activity.id,
                                child: Text(
                                  '${activity.title} (${DateFormatter.formatDateTimeIndonesia(activity.startTime)})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            })
                            .toList(),
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
                        (_attachmentFile != null || _attachmentFileName != null)
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
                    text: 'Simpan Perubahan',
                    isLoading:
                        provider.updatePermissionStatus ==
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

  Widget _buildAttachmentPreview() {
    final extension = _attachmentFileName?.split('.').last.toLowerCase() ?? '';

    if (_attachmentFile != null && ['jpg', 'jpeg', 'png'].contains(extension)) {
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
                if (mounted) {
                  setState(() {
                    _attachmentFile = null;
                    _attachmentFileName = null;
                    _attachmentChanged = true;
                  });
                }
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
                    : ['jpg', 'jpeg', 'png'].contains(extension)
                    ? Icons.image
                    : Icons.insert_drive_file,
                size: 32,
                color:
                    extension == 'pdf'
                        ? Colors.red
                        : ['jpg', 'jpeg', 'png'].contains(extension)
                        ? Colors.blue
                        : Colors.grey,
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
              if (mounted) {
                setState(() {
                  _attachmentFile = null;
                  _attachmentFileName = null;
                  _attachmentChanged = true;
                });
              }
            },
          ),
        ),
      ],
    );
  }
}
