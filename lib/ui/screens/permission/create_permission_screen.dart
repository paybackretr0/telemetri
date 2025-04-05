import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'permission_provider.dart';
import '../../../data/models/activity_model.dart';
import '../../widgets/custom_appbar.dart';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchActivities();
    });
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

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih kegiatan'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        // Pastikan activityId selalu integer
        final int activityId = _selectedActivityId!;

        final provider = Provider.of<PermissionProvider>(
          context,
          listen: false,
        );

        print(
          'Submitting permission with activityId: $activityId (${activityId.runtimeType})',
        );

        final result = await provider.createPermission(
          activityId: activityId,
          reason: _reasonController.text.trim(),
          attachment: _attachmentFile,
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
      } catch (e) {
        print('Error in _submitForm: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Buat Izin Baru',
        showBackButton: true,
        showNotification:
            false, // Usually don't need notifications on form screens
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
                          // Pastikan ID activity selalu dalam bentuk integer
                          int activityId;
                          try {
                            if (activity.id is int) {
                              activityId = activity.id;
                            } else if (activity.id is String) {
                              activityId = int.parse(activity.id.toString());
                            } else {
                              activityId = 0;
                              print(
                                'Unrecognized ID type: ${activity.id.runtimeType}',
                              );
                            }
                          } catch (e) {
                            activityId = 0;
                            print(
                              'Error parsing activity ID: ${activity.id}, error: $e',
                            );
                          }
                          // Make sure we're using the correct ID type
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
                        print(
                          'Selected activity ID: $value (${value?.runtimeType})',
                        );
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
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
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
                                        color: Theme.of(context).primaryColor,
                                      ),
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
                        backgroundColor:
                            Theme.of(
                              context,
                            ).primaryColor, // Set button background to primary color
                        foregroundColor: Colors.white,
                      ),
                      onPressed:
                          provider.createPermissionStatus ==
                                  PermissionStatus.loading
                              ? null
                              : _submitForm,
                      child:
                          provider.createPermissionStatus ==
                                  PermissionStatus.loading
                              ? const CircularProgressIndicator()
                              : const Text('Kirim Izin'),
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

  // Helper untuk memformat DateTime ke format yang lebih user-friendly
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildAttachmentPreview() {
    if (_attachmentFile == null) return const SizedBox.shrink();

    final extension = _attachmentFileName?.split('.').last.toLowerCase() ?? '';

    // If image, show preview
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

    // For other files, show file name
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
