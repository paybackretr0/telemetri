import 'package:flutter/material.dart';
import 'package:telemetri/ui/screens/delegation/delegation_screen.dart';
import 'package:telemetri/ui/widgets/custom_card.dart';
import 'package:provider/provider.dart';
import 'package:telemetri/ui/screens/profile/profile_provider.dart';
import 'package:telemetri/ui/navigations/app_routes.dart';
import 'package:telemetri/ui/screens/permission/permission_screen.dart';
import 'package:telemetri/ui/screens/faq/faq_screen.dart';
import 'package:telemetri/ui/screens/about/about_screen.dart';
import 'package:telemetri/utils/date_formatter.dart';
import '../../../data/environment/env_config.dart';
import '../../widgets/custom_form_fields.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).getProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${provider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.getProfile(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.getProfile();
            },
            color: Theme.of(context).primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(context, provider),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            context,
                            'Pengajuan Izin',
                            Icons.assignment_late_rounded,
                            Colors.orange,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const PermissionScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            context,
                            'Tukar Piket',
                            Icons.swap_horiz_rounded,
                            Colors.green,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const DelegationScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildSectionTitle(context, 'Informasi Pengurus'),
                  ),
                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CustomCard(
                      child: Column(
                        children: [
                          _buildInfoItem(
                            context,
                            'Email',
                            provider.user?.email ?? '-',
                            Icons.email,
                          ),
                          Divider(color: Colors.grey.shade200, thickness: 1),
                          _buildInfoItem(
                            context,
                            'No. Telepon',
                            provider.user?.phoneNumber ?? '-',
                            Icons.phone,
                          ),
                          Divider(color: Colors.grey.shade200, thickness: 1),
                          _buildInfoItem(
                            context,
                            'NIM',
                            provider.user?.nim ?? '-',
                            Icons.badge,
                          ),
                          Divider(color: Colors.grey.shade200, thickness: 1),
                          _buildInfoItem(
                            context,
                            'Jurusan',
                            provider.user?.jurusan ?? '-',
                            Icons.school,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildSectionTitle(context, 'Informasi Organisasi'),
                  ),
                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CustomCard(
                      child: Column(
                        children: [
                          _buildInfoItem(
                            context,
                            'Jabatan',
                            provider.user?.jabatan ?? '-',
                            Icons.work,
                          ),
                          Divider(color: Colors.grey.shade200, thickness: 1),
                          _buildInfoItem(
                            context,
                            'Divisi',
                            provider.user?.divisi ?? '-',
                            Icons.group,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildSectionTitle(context, 'Jadwal Piket'),
                  ),
                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CustomCard(
                      child: Column(
                        children:
                            provider.user?.dutySchedules != null &&
                                    provider.user!.dutySchedules!.isNotEmpty
                                ? provider.user!.dutySchedules!.map((schedule) {
                                  final timeRange =
                                      DateFormatter.formatTimeRange(
                                        schedule.startTime,
                                        schedule.endTime,
                                      );

                                  return Column(
                                    children: [
                                      _buildScheduleItem(
                                        context,
                                        schedule.dayOfWeek,
                                        timeRange,
                                        schedule.location,
                                      ),
                                      if (schedule !=
                                          provider.user!.dutySchedules!.last)
                                        Divider(
                                          color: Colors.grey.shade200,
                                          thickness: 1,
                                        ),
                                    ],
                                  );
                                }).toList()
                                : [
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        'Tidak ada jadwal piket',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildSectionTitle(context, 'Informasi'),
                  ),
                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildInfoCard(context, 'FAQ', Icons.help_outline, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FaqScreen(),
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          context,
                          'Tentang Aplikasi',
                          Icons.info_outline,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AboutScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildLogoutButton(context),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(
    BuildContext context,
    String day,
    String time, [
    String? location,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  day,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          if (location != null && location.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 52),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      location,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return CustomCard(
      onTap: onTap,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(child: Icon(icon, color: color, size: 28)),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
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
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipOval(child: _buildProfileImage(provider)),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    RouteNames.editProfile,
                  ).then((_) => setState(() {}));
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 18,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            provider.user?.name ?? 'Nama Pengguna',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            provider.user?.nomorSeri ?? 'SN. A13',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            provider.user?.subDivisi ?? 'Mobile Programming',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(ProfileProvider provider) {
    if (provider.user?.profilePicture == null ||
        provider.user!.profilePicture!.isEmpty) {
      return const Icon(Icons.person, size: 80, color: Colors.white);
    }

    final String profilePicture = provider.user!.profilePicture!;

    if (profilePicture.startsWith('http')) {
      return Image.network(
        profilePicture,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading network image: $error');
          return const Icon(Icons.person, size: 80, color: Colors.white);
        },
      );
    }
    final String storageUrl = EnvConfig.storageUrl;

    final String fullUrl =
        profilePicture.startsWith('/')
            ? '$storageUrl${profilePicture.substring(1)}'
            : '$storageUrl$profilePicture';

    print('Constructed URL: $fullUrl');

    return Image.network(
      fullUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('Error loading network image: $error');
        return const Icon(Icons.person, size: 80, color: Colors.white);
      },
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return CustomCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: Theme.of(context).primaryColor,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
              ),
              child: Icon(
                Icons.chevron_right,
                color: Colors.grey.shade600,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: CustomSubmitButton(
        text: 'Keluar',
        isLoading: profileProvider.isLoading,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        onPressed: () {
          CustomDialogs.showConfirmationDialog(
            context: context,
            title: 'Konfirmasi',
            message: 'Apakah Anda yakin ingin keluar?',
            confirmText: 'Keluar',
            cancelText: 'Batal',
            confirmColor: Colors.red,
            confirmIcon: Icons.logout,
            cancelIcon: Icons.close,
          ).then((confirmed) async {
            if (confirmed == true) {
              final success = await profileProvider.logout();

              if (context.mounted && success) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(RouteNames.login, (route) => false);
              } else if (context.mounted && !success) {
                CustomDialogs.showErrorSnackBar(
                  context,
                  profileProvider.error ?? 'Gagal keluar dari aplikasi',
                );
              }
            }
          });
        },
      ),
    );
  }
}

String getProfilePictureUrl(String? profilePicture) {
  if (profilePicture == null || profilePicture.isEmpty) {
    return '';
  }

  if (profilePicture.startsWith('http')) {
    return profilePicture;
  }

  try {
    String baseUrl = EnvConfig.storageUrl;
    if (!baseUrl.endsWith('/')) {
      baseUrl += '/';
    }
    return '$baseUrl$profilePicture';
  } catch (e) {
    return '';
  }
}
