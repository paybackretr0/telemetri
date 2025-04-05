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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih kegiatan'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final provider = Provider.of<PermissionProvider>(context, listen: false);

      final reasonChanged =
          _reasonController.text.trim() != widget.permission.reason;
      final activityChanged =
          _selectedActivityId != widget.permission.activityId;

      if (reasonChanged || activityChanged || _attachmentChanged) {
        final result = await provider.updatePermission(
          id: widget.permission.id,
          activityId: activityChanged ? _selectedActivityId : null,
          reason: reasonChanged ? _reasonController.text.trim() : null,
          attachment: _attachmentChanged ? _attachmentFile : null,
        );

        if (result) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(provider.successMessage)));
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
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
                  const Text(
                    'Kegiatan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Pilih Kegiatan',
                    ),
                    value: _selectedActivityId,
                    items:
                        activities.map((activity) {
                          return DropdownMenuItem<int>(
                            value: activity.id,
                            child: Text(
                              '${activity.title} (${DateFormatter.formatDateTimeIndonesia(activity.startTime)})',
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
                  const Text(
                    'Alasan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _reasonController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Berikan alasan izin Anda',
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Alasan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Lampiran (Opsional)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickAttachment,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child:
                          (_attachmentFile != null ||
                                  _attachmentFileName != null)
                              ? _buildAttachmentPreview()
                              : const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.upload_file,
                                      size: 32,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Tap untuk memilih file',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed:
                          provider.updatePermissionStatus ==
                                  PermissionStatus.loading
                              ? null
                              : _submitForm,
                      child:
                          provider.updatePermissionStatus ==
                                  PermissionStatus.loading
                              ? const CircularProgressIndicator()
                              : const Text('Simpan Perubahan'),
                    ),
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
