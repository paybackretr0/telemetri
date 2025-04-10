import 'package:flutter/material.dart';
import 'package:telemetri/ui/widgets/custom_appbar.dart';
import 'package:telemetri/ui/widgets/custom_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Tentang Aplikasi',
        showBackButton: true,
        showNotification: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(primaryColor, size),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAboutSection(primaryColor),
                  const SizedBox(height: 20),
                  _buildTeamSection(primaryColor),
                  const SizedBox(height: 20),
                  _buildContactSection(primaryColor, context),
                  const SizedBox(height: 20),
                  _buildVersionInfo(primaryColor),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color primaryColor, Size size) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
        ),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            height: 120,
            width: 120,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/neo_telemetri_logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // App name
          const Text(
            'Neo Telemetri',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'IT for The Future',
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(Color primaryColor) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'Tentang Neo Telemetri',
            Icons.info_outline,
            primaryColor,
          ),
          const SizedBox(height: 12),
          const Text(
            'Neo Telemetri adalah Unit Kegiatan Mahasiswa di bidang teknologi informasi yang berfokus pada pengembangan keterampilan mahasiswa dalam berbagai aspek IT seperti pemrograman, desain, jaringan, dan teknologi terkini.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'UKM Neo Telemetri didirikan pada tahun 2005 dan telah menghasilkan banyak prestasi serta alumni yang berkiprah di industri teknologi nasional maupun internasional.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection(Color primaryColor) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSectionTitle(
            'Pengembang',
            Icons.person_2_outlined,
            primaryColor,
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _TeamMemberCard(
                name: 'Khalied Nauly Maturino',
                role: 'All Role',
                photoUrl: 'assets/images/h.JPG',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(Color primaryColor, BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'Hubungi Kami',
            Icons.contact_mail_outlined,
            primaryColor,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.email_outlined,
            title: 'Email',
            detail: 'neotelemetri.unand@gmail.com',
            onTap:
                () =>
                    _launchUrl('mailto:neotelemetri.unand@gmail.com', context),
          ),
          _buildContactItem(
            icon: Icons.language_outlined,
            title: 'Website',
            detail: 'www.neotelemetri.id',
            onTap: () => _launchUrl('https://www.neotelemetri.id', context),
          ),
          _buildContactItem(
            icon: Icons.location_on_outlined,
            title: 'Alamat',
            detail: 'Gedung PKM Lantai 2, Universitas Andalas',
            onTap:
                () => _launchUrl(
                  'https://maps.app.goo.gl/dAwmPBim7xZgPM8o8',
                  context,
                ),
          ),
          _buildSocialMediaLinks(primaryColor, context),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String detail,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  detail,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaLinks(Color primaryColor, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Media Sosial:',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildSocialButton(
              icon: FontAwesomeIcons.facebook,
              color: const Color(0xFF1877F2),
              onTap:
                  () =>
                      _launchUrl('https://facebook.com/neotelemetri', context),
            ),
            _buildSocialButton(
              icon: FontAwesomeIcons.instagram,
              color: const Color(0xFFE1306C),
              onTap:
                  () =>
                      _launchUrl('https://instagram.com/neotelemetri', context),
            ),
            _buildSocialButton(
              icon: FontAwesomeIcons.xTwitter,
              color: const Color.fromARGB(255, 0, 0, 0),
              onTap: () => _launchUrl('https://x.com/neotelemetri', context),
            ),
            _buildSocialButton(
              icon: FontAwesomeIcons.youtube,
              color: const Color(0xFFFF0000),
              onTap:
                  () => _launchUrl(
                    'https://www.youtube.com/neotelemetri',
                    context,
                  ),
            ),
            _buildSocialButton(
              icon: FontAwesomeIcons.linkedin,
              color: const Color(0xFF0A66C2),
              onTap:
                  () => _launchUrl(
                    'https://linkedin.com/company/neotelemetri',
                    context,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildVersionInfo(Color primaryColor) {
    return Center(
      child: Column(
        children: [
          Text(
            'Versi 1.0.0',
            style: TextStyle(
              fontSize: 14,
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '© 2025 retr0X - All Rights Reserved',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color primaryColor) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url, BuildContext context) async {
    try {
      await launch(url);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak dapat membuka $url'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _TeamMemberCard extends StatelessWidget {
  final String name;
  final String role;
  final String? photoUrl;

  const _TeamMemberCard({
    required this.name,
    required this.role,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[200],
            backgroundImage:
                photoUrl != null
                    ? photoUrl!.startsWith('http')
                        ? NetworkImage(photoUrl!)
                        : AssetImage(photoUrl!) as ImageProvider
                    : null,
            child:
                photoUrl == null
                    ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    )
                    : null,
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            role,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
