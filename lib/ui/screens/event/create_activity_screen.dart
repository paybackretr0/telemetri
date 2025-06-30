import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'activity_provider.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_form_fields.dart';
import '../../../utils/date_formatter.dart';

class CreateActivityScreen extends StatefulWidget {
  const CreateActivityScreen({super.key});

  @override
  _CreateActivityScreenState createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  int? _selectedAttendanceTypeId;
  List<int> _selectedParticipantIds = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ActivityProvider>(context, listen: false);
      provider.getAttendanceTypes();
      provider.getUsers(); // Load users
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? _selectedStartDate ?? DateTime.now(),
      firstDate: _selectedStartDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedEndDate) {
      setState(() {
        _selectedEndDate = picked;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedStartTime) {
      setState(() {
        _selectedStartTime = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          _selectedEndTime ??
          (_selectedStartTime?.replacing(hour: _selectedStartTime!.hour + 1) ??
              TimeOfDay.now()),
    );
    if (picked != null && picked != _selectedEndTime) {
      setState(() {
        _selectedEndTime = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedStartDate == null ||
        _selectedEndDate == null ||
        _selectedStartTime == null ||
        _selectedEndTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan lengkapi tanggal dan waktu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedAttendanceTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih tipe kehadiran'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final startDateTime = DateTime(
      _selectedStartDate!.year,
      _selectedStartDate!.month,
      _selectedStartDate!.day,
      _selectedStartTime!.hour,
      _selectedStartTime!.minute,
    );

    final endDateTime = DateTime(
      _selectedEndDate!.year,
      _selectedEndDate!.month,
      _selectedEndDate!.day,
      _selectedEndTime!.hour,
      _selectedEndTime!.minute,
    );

    final provider = Provider.of<ActivityProvider>(context, listen: false);
    final success = await provider.createEvent(
      title: _titleController.text,
      description: _descriptionController.text,
      startTime: startDateTime,
      endTime: endDateTime,
      location: _locationController.text,
      attendanceTypeId: _selectedAttendanceTypeId!,
      participantIds: _selectedParticipantIds,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.successMessage),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Buat Kegiatan/Rapat',
        showBackButton: true,
        showNotification: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Judul Kegiatan/Rapat',
                hint: 'Masukkan judul kegiatan',
                controller: _titleController,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Deskripsi',
                hint: 'Masukkan deskripsi kegiatan',
                controller: _descriptionController,
                maxLines: 3,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Lokasi',
                hint: 'Masukkan lokasi kegiatan',
                controller: _locationController,
                isRequired: true,
              ),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        flex: 3,
                        child: CustomDatePickerField(
                          label: 'Tanggal Mulai',
                          hint: 'Pilih tanggal',
                          selectedDate: _selectedStartDate,
                          onTap: () => _selectStartDate(context),
                          dateFormatter:
                              (date) =>
                                  DateFormatter.formatDate(date, 'dd/MM/yyyy'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        flex: 2,
                        child: _buildTimePickerField(
                          'Waktu Mulai',
                          'Pilih waktu',
                          _selectedStartTime,
                          () => _selectStartTime(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        flex: 3,
                        child: CustomDatePickerField(
                          label: 'Tanggal Selesai',
                          hint: 'Pilih tanggal',
                          selectedDate: _selectedEndDate,
                          onTap: () => _selectEndDate(context),
                          dateFormatter:
                              (date) =>
                                  DateFormatter.formatDate(date, 'dd/MM/yyyy'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        flex: 2,
                        child: _buildTimePickerField(
                          'Waktu Selesai',
                          'Pilih waktu',
                          _selectedEndTime,
                          () => _selectEndTime(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Consumer<ActivityProvider>(
                builder: (context, provider, child) {
                  if (provider.attendanceTypesStatus == EventStatus.loading) {
                    return const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tipe Kehadiran',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Center(child: CircularProgressIndicator()),
                      ],
                    );
                  } else if (provider.attendanceTypesStatus ==
                      EventStatus.error) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tipe Kehadiran',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Error: ${provider.errorMessage}',
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => provider.getAttendanceTypes(),
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else if (provider.attendanceTypes.isEmpty) {
                    return const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tipe Kehadiran',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tidak ada tipe kehadiran tersedia',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    );
                  } else {
                    return CustomDropdownField<int>(
                      label: 'Tipe Kehadiran',
                      hint: 'Pilih tipe kehadiran',
                      value: _selectedAttendanceTypeId,
                      items:
                          provider.attendanceTypes.map((type) {
                            return DropdownMenuItem<int>(
                              value: type['id'],
                              child: Text(type['name'] ?? 'Unknown'),
                            );
                          }).toList(),
                      onChanged: (int? value) {
                        setState(() {
                          _selectedAttendanceTypeId = value;
                        });
                      },
                      isRequired: true,
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Peserta',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _showParticipantsDialog,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.people),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedParticipantIds.isEmpty
                                  ? 'Pilih Peserta (Opsional)'
                                  : '${_selectedParticipantIds.length} peserta dipilih',
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedParticipantIds.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Tip: Peserta akan menerima notifikasi tentang kegiatan ini',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add),
                              SizedBox(width: 8),
                              Text(
                                'Buat Kegiatan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePickerField(
    String label,
    String hint,
    TimeOfDay? selectedTime,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    selectedTime == null
                        ? hint
                        : '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color:
                          selectedTime == null
                              ? Colors.grey.shade500
                              : Colors.black87,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.access_time,
                  color: Theme.of(context).primaryColor,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showParticipantsDialog() {
    final provider = Provider.of<ActivityProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Pilih Peserta'),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child:
                    provider.usersStatus == EventStatus.loading
                        ? const Center(child: CircularProgressIndicator())
                        : provider.users.isEmpty
                        ? const Center(child: Text('Tidak ada user tersedia'))
                        : Column(
                          children: [
                            // Search field
                            TextField(
                              decoration: const InputDecoration(
                                hintText: 'Cari peserta...',
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                // Implement search
                                provider.getUsers(search: value);
                              },
                            ),
                            const SizedBox(height: 16),
                            // User list
                            Expanded(
                              child: ListView.builder(
                                itemCount: provider.users.length,
                                itemBuilder: (context, index) {
                                  final user = provider.users[index];
                                  final userId = user['id'];
                                  final isSelected = _selectedParticipantIds
                                      .contains(userId);

                                  return CheckboxListTile(
                                    title: Text(user['name'] ?? 'Unknown'),
                                    subtitle:
                                        user['email'] != null
                                            ? Text(user['email'])
                                            : null,
                                    value: isSelected,
                                    onChanged: (bool? value) {
                                      setDialogState(() {
                                        if (value == true) {
                                          _selectedParticipantIds.add(userId);
                                        } else {
                                          _selectedParticipantIds.remove(
                                            userId,
                                          );
                                        }
                                      });
                                      setState(() {}); // Update main screen
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Pilih (${_selectedParticipantIds.length})'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
