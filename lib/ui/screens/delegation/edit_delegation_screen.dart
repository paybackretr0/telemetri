import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:telemetri/data/models/delegation_model.dart';
import 'delegation_provider.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_form_fields.dart';
import '../../../utils/date_formatter.dart';

class EditDelegationScreen extends StatefulWidget {
  final Delegation delegation;

  const EditDelegationScreen({super.key, required this.delegation});

  @override
  _EditDelegationScreenState createState() => _EditDelegationScreenState();
}

class _EditDelegationScreenState extends State<EditDelegationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  int? _selectedDutyScheduleId;
  int? _selectedDelegateId;
  DateTime? _selectedDate;
  bool _isLoading = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<DelegationProvider>(context, listen: false);

    await provider.getDelegationDetail(widget.delegation.id);

    await provider.getDelegableDuties();
    await provider.getPotentialDelegates();

    if (provider.currentDelegation != null && !_isInitialized) {
      final delegation = provider.currentDelegation!;

      setState(() {
        _selectedDutyScheduleId = delegation.dutyScheduleId;
        _selectedDelegateId = delegation.delegateId;
        _selectedDate = delegation.delegationDate;
        _reasonController.text = delegation.reason;
        _isInitialized = true;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        CustomDialogs.showErrorSnackBar(
          context,
          'Silakan pilih tanggal delegasi',
        );
        return;
      }

      final provider = Provider.of<DelegationProvider>(context, listen: false);

      Map<String, dynamic> updatedData = {};

      if (_selectedDelegateId != widget.delegation.delegateId) {
        updatedData['delegate_id'] = _selectedDelegateId;
      }

      if (_selectedDutyScheduleId != widget.delegation.dutyScheduleId) {
        updatedData['duty_schedule_id'] = _selectedDutyScheduleId;
      }

      if (_selectedDate != widget.delegation.delegationDate) {
        updatedData['delegation_date'] = _selectedDate!.toIso8601String();
      }

      if (_reasonController.text != widget.delegation.reason) {
        updatedData['reason'] = _reasonController.text;
      }

      if (updatedData.isEmpty) {
        Navigator.pop(context);
        return;
      }

      final confirmed = await CustomDialogs.showConfirmationDialog(
        context: context,
        title: 'Konfirmasi Perubahan',
        message: 'Apakah Anda yakin ingin menyimpan perubahan ini?',
        confirmText: 'Simpan',
        confirmColor: Theme.of(context).primaryColor,
        confirmIcon: Icons.save,
      );

      if (confirmed != true) return;

      final success = await provider.updateDelegation(
        id: widget.delegation.id,
        delegationData: updatedData,
      );

      if (mounted) {
        if (success) {
          CustomDialogs.showSuccessSnackBar(context, provider.successMessage);
          Navigator.pop(context, true);
        } else {
          CustomDialogs.showErrorSnackBar(context, provider.errorMessage);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Edit Pertukaran Piket',
        showBackButton: true,
        showNotification: false,
      ),
      body: Consumer<DelegationProvider>(
        builder: (context, provider, child) {
          if (_isLoading ||
              provider.delegableDutiesStatus == DelegationStatus.loading ||
              provider.potentialDelegatesStatus == DelegationStatus.loading ||
              provider.delegationDetailStatus == DelegationStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.delegationDetailStatus == DelegationStatus.error ||
              provider.delegableDutiesStatus == DelegationStatus.error ||
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
                    onPressed: _loadData,
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
                    text: 'Simpan Perubahan',
                    isLoading:
                        provider.updateDelegationStatus ==
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
