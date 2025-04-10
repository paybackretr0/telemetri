import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'delegation_provider.dart';
import '../../widgets/custom_appbar.dart';
import '../../../utils/date_formatter.dart';
import '../../widgets/custom_form_fields.dart';

class CreateDelegationScreen extends StatefulWidget {
  const CreateDelegationScreen({super.key});

  @override
  _CreateDelegationScreenState createState() => _CreateDelegationScreenState();
}

class _CreateDelegationScreenState extends State<CreateDelegationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  DateTime? _selectedDate;
  int? _selectedDutyScheduleId;
  int? _selectedDelegateId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DelegationProvider>(context, listen: false);
      provider.getDelegableDuties();
      provider.getPotentialDelegates();
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDutyScheduleId == null) {
        CustomDialogs.showErrorSnackBar(context, 'Silakan pilih jadwal piket');
        return;
      }

      if (_selectedDelegateId == null) {
        CustomDialogs.showErrorSnackBar(context, 'Silakan pilih delegasi');
        return;
      }

      if (_selectedDate == null) {
        CustomDialogs.showErrorSnackBar(
          context,
          'Silakan pilih tanggal delegasi',
        );
        return;
      }

      final confirmed = await CustomDialogs.showConfirmationDialog(
        context: context,
        title: 'Konfirmasi Pengajuan',
        message: 'Apakah Anda yakin ingin mengajukan pertukaran piket ini?',
        confirmText: 'Ajukan',
        confirmColor: Theme.of(context).primaryColor,
        confirmIcon: Icons.send,
      );

      if (confirmed != true) return;

      try {
        final provider = Provider.of<DelegationProvider>(
          context,
          listen: false,
        );

        setState(() {});

        final result = await provider.createDelegation(
          delegateId: _selectedDelegateId!,
          dutyScheduleId: _selectedDutyScheduleId!,
          delegationDate: _selectedDate!,
          reason: _reasonController.text.trim(),
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
          CustomDialogs.showErrorSnackBar(context, 'Terjadi kesalahan: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Ajukan Pertukaran Piket',
        showBackButton: true,
        showNotification: false,
      ),
      body: Consumer<DelegationProvider>(
        builder: (context, provider, child) {
          if (provider.delegableDutiesStatus == DelegationStatus.loading ||
              provider.potentialDelegatesStatus == DelegationStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.delegableDutiesStatus == DelegationStatus.error ||
              provider.potentialDelegatesStatus == DelegationStatus.error) {
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
                    onPressed: () {
                      provider.getDelegableDuties();
                      provider.getPotentialDelegates();
                    },
                    child: const Text('Coba Lagi'),
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
                    label: 'Jadwal Piket',
                    hint: 'Pilih Jadwal Piket',
                    value: _selectedDutyScheduleId,
                    items:
                        provider.delegableDuties.map((duty) {
                          return DropdownMenuItem<int>(
                            value: duty.id,
                            child: Text(
                              '${duty.dayOfWeek} - ${duty.location} (${DateFormatter.formatTime(duty.startTime)}-${DateFormatter.formatTime(duty.endTime)})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDutyScheduleId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomDropdownField<int>(
                    label: 'Delegasikan Kepada',
                    hint: 'Pilih Delegasi',
                    value: _selectedDelegateId,
                    items:
                        provider.potentialDelegates.map((delegate) {
                          return DropdownMenuItem<int>(
                            value: delegate.id,
                            child: Text(
                              delegate.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDelegateId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomDatePickerField(
                    label: 'Tanggal Delegasi',
                    hint: 'Pilih Tanggal',
                    selectedDate: _selectedDate,
                    onTap: () => _selectDate(context),
                    dateFormatter:
                        (date) =>
                            DateFormatter.formatDateTimeIndonesia(
                              date,
                            ).split(',')[0],
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Alasan',
                    hint: 'Berikan alasan delegasi Anda',
                    controller: _reasonController,
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Alasan tidak boleh kosong';
                      }
                      if (value.length > 500) {
                        return 'Alasan tidak boleh lebih dari 500 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  CustomSubmitButton(
                    text: 'Kirim Permintaan',
                    isLoading:
                        provider.createDelegationStatus ==
                        DelegationStatus.loading,
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
}
