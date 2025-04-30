import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:telemetri/ui/widgets/custom_appbar.dart';
import 'package:telemetri/ui/widgets/custom_form_fields.dart';
import 'package:telemetri/ui/screens/profile/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nimController = TextEditingController();
  final _jurusanController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<ProfileProvider>(context, listen: false);
    if (provider.user != null) {
      _nameController.text = provider.user!.name;
      _phoneController.text = provider.user!.phoneNumber ?? '';
      _nimController.text = provider.user!.nim ?? '';
      _jurusanController.text = provider.user!.jurusan ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nimController.dispose();
    _jurusanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomAppBar(title: 'Edit Profil', showBackButton: true),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(provider, theme),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          'Informasi Pribadi',
                          Icons.person_outline,
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _nameController,
                          label: 'Nama Lengkap',
                          hint: 'Masukkan nama lengkap',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _phoneController,
                          label: 'Nomor Telepon',
                          hint: 'Masukkan nomor telepon',
                        ),
                        const SizedBox(height: 16),

                        _buildSectionHeader(
                          'Informasi Akademik',
                          Icons.school_outlined,
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _nimController,
                          label: 'NIM',
                          hint: 'Masukkan NIM',
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _jurusanController,
                          label: 'Jurusan',
                          hint: 'Masukkan jurusan',
                        ),
                        const SizedBox(height: 32),

                        if (provider.error != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red.shade700,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    provider.error!,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        CustomSubmitButton(
                          text: 'Simpan Perubahan',
                          onPressed: () => _updateProfile(provider),
                          isLoading: provider.isUpdating,
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(ProfileProvider provider, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.7)],
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child:
                    provider.selectedImage != null
                        ? ClipOval(
                          child: Image.file(
                            provider.selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                        : provider.user?.profilePicture != null
                        ? ClipOval(
                          child: Image.network(
                            getProfilePictureUrl(
                              provider.user!.profilePicture!,
                            ),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                size: 80,
                                color: Colors.white,
                              );
                            },
                          ),
                        )
                        : const Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.white,
                        ),
              ),
              Material(
                elevation: 4,
                shape: const CircleBorder(),
                clipBehavior: Clip.hardEdge,
                color: theme.colorScheme.secondary,
                child: InkWell(
                  onTap: () => provider.pickImage(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Ubah Foto Profil',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  void _updateProfile(ProfileProvider provider) async {
    if (_formKey.currentState!.validate()) {
      final success = await provider.updateProfile(
        name: _nameController.text,
        phoneNumber: _phoneController.text,
        nim: _nimController.text,
        jurusan: _jurusanController.text,
      );

      if (success && mounted) {
        CustomDialogs.showSuccessSnackBar(
          context,
          'Profil berhasil diperbarui',
        );
        Navigator.pop(context);
      } else if (mounted) {
        CustomDialogs.showErrorSnackBar(
          context,
          provider.error ?? 'Gagal memperbarui profil',
        );
      }
    }
  }
}
