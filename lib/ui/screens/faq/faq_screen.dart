import 'package:flutter/material.dart';
import 'package:telemetri/ui/widgets/custom_appbar.dart';
import 'package:telemetri/ui/widgets/custom_card.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = [
    'Umum',
    'Absensi',
    'Izin',
    'Kegiatan',
    'Akun',
  ];

  final Map<String, bool> _expandedItems = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Frequently Asked Questions',
        showBackButton: true,
        showNotification: false,
      ),
      body: Column(
        children: [
          _buildHeader(primaryColor),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: primaryColor,
              labelColor: primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: _categories.map((category) => Tab(text: category)).toList(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              tabAlignment: TabAlignment.center,
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGeneralFaqList(primaryColor),
                _buildAttendanceFaqList(primaryColor),
                _buildPermissionFaqList(primaryColor),
                _buildActivityFaqList(primaryColor),
                _buildAccountFaqList(primaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temukan jawaban dari pertanyaan yang sering diajukan',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.question_answer_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem({
    required Color primaryColor,
    required String question,
    required String answer,
    Widget? customAnswer,
    String? id,
  }) {
    final itemId = id ?? question;

    _expandedItems.putIfAbsent(itemId, () => false);

    return CustomCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      elevation: 1,
      onTap: () {
        setState(() {
          _expandedItems[itemId] = !_expandedItems[itemId]!;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(
                _expandedItems[itemId]!
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: primaryColor,
              ),
            ],
          ),
          if (_expandedItems[itemId]!)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 16),
                customAnswer ??
                    Text(
                      answer,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildGeneralFaqList(Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFaqItem(
          primaryColor: primaryColor,
          question: 'Apa itu Aplikasi TeleMetri?',
          answer:
              'Aplikasi Telemetri adalah aplikasi absensi dan manajemen kegiatan UKM Neo Telemetri. Aplikasi ini memudahkan anggota untuk melakukan absensi kegiatan, mengajukan izin, dan mengakses informasi kegiatan UKM.',
        ),
        _buildFaqItem(
          primaryColor: primaryColor,
          question: 'Apa saja fitur utama aplikasi ini?',
          answer:
              'Fitur utama aplikasi meliputi: Absensi dengan QR Code, Pengajuan Izin, Kalendar Kegiatan, Riwayat Kehadiran, Notifikasi Kegiatan, dan Manajemen Profil.',
        ),
        _buildFaqItem(
          primaryColor: primaryColor,
          question: 'Siapa yang dapat menggunakan aplikasi ini?',
          answer:
              'Aplikasi ini diperuntukkan bagi anggota UKM Neo Telemetri yang telah terdaftar dalam database organisasi.',
        ),
        _buildFaqItem(
          primaryColor: primaryColor,
          question:
              'Bagaimana cara mendapatkan bantuan jika mengalami kendala?',
          answer:
              'Anda dapat menghubungi admin UKM melalui fitur hubungi kami di menu profil atau mengirimkan email ke support@neotelemetri.com.',
        ),
        _buildFaqItem(
          primaryColor: primaryColor,
          question: 'Apakah aplikasi ini tersedia untuk iOS dan Android?',
          answer:
              'Ya, aplikasi Telemetri tersedia untuk perangkat iOS dan Android. Anda dapat mengunduhnya melalui App Store atau Google Play Store.',
        ),
      ],
    );
  }

  Widget _buildAttendanceFaqList(Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFaqItem(
          primaryColor: primaryColor,
          question: 'Bagaimana cara melakukan absensi?',
          answer:
              'Untuk melakukan absensi, buka aplikasi dan tekan tombol "Scan QR" pada menu navigasi. Kemudian arahkan kamera ke QR Code yang tersedia di lokasi kegiatan. Sistem akan secara otomatis mencatat kehadiran Anda.',
          customAnswer: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Untuk melakukan absensi, ikuti langkah-langkah berikut:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              _buildNumberedStep(
                1,
                'Buka aplikasi dan tekan tombol "Scan QR" pada menu navigasi',
                primaryColor,
              ),
              _buildNumberedStep(
                2,
                'Arahkan kamera ke QR Code yang tersedia di lokasi kegiatan',
                primaryColor,
              ),
              _buildNumberedStep(
                3,
                'Tunggu hingga proses pemindaian selesai',
                primaryColor,
              ),
              _buildNumberedStep(
                4,
                'Sistem akan otomatis mencatat kehadiran Anda',
                primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                'Pastikan Anda berada dalam jangkauan lokasi yang ditentukan saat melakukan absensi.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        _buildFaqItem(
          primaryColor: primaryColor,
          question:
              'Apa yang harus dilakukan jika QR Code tidak dapat dipindai?',
          answer:
              'Jika QR Code tidak dapat dipindai, pastikan pencahayaan cukup dan kamera Anda bersih. Anda juga dapat mencoba memperbarui aplikasi atau menghubungi admin kegiatan untuk bantuan.',
        ),
        _buildFaqItem(
          primaryColor: primaryColor,
          question: 'Bagaimana cara melihat riwayat kehadiran saya?',
          answer:
              'Untuk melihat riwayat kehadiran, buka menu "Riwayat Kehadiran" pada bagian bawah navigasi. Di sana Anda dapat melihat daftar kehadiran Anda beserta statusnya.',
        ),
        _buildFaqItem(
          primaryColor: primaryColor,
          question: 'Apa batas waktu untuk melakukan absensi?',
          answer:
              'Batas waktu absensi ditentukan oleh admin untuk setiap kegiatan. Umumnya, Anda dapat melakukan absensi 15 menit sebelum hingga 15 menit setelah waktu yang ditentukan. Detail waktu absensi dapat dilihat di informasi kegiatan.',
        ),
        _buildFaqItem(
          primaryColor: primaryColor,
          question: 'Apa yang dimaksud dengan absensi geolokasi?',
          answer:
              'Absensi geolokasi menggunakan GPS untuk memverifikasi lokasi Anda saat melakukan absensi. Fitur ini memastikan bahwa Anda benar-benar berada di lokasi kegiatan saat melakukan absensi.',
        ),
      ],
    );
  }

  Widget _buildPermissionFaqList(Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFaqItem(
          primaryColor: primaryColor,
          question: 'Bagaimana cara mengajukan izin tidak hadir?',
          answer:
              'Untuk mengajukan izin, buka menu Kegiatan, pilih kegiatan yang ingin diajukan izin, lalu pilih opsi "Ajukan Izin". Isi formulir dengan alasan dan lampirkan dokumen pendukung jika diperlukan.',
        ),
        _buildFaqItem(
          primaryColor: primaryColor,
          question: 'Berapa lama proses persetujuan izin?',
          answer:
              'Umumnya proses persetujuan izin membutuhkan waktu 1-2 hari kerja. Anda akan menerima notifikasi saat status izin Anda diperbarui.',
        ),
        _buildFaqItem(
          primaryColor: primaryColor,
          question:
              'Dokumen apa saja yang perlu dilampirkan saat mengajukan izin?',
          answer:
              'Dokumen yang perlu dilampirkan bergantung pada jenis izin. Untuk izin sakit, lampirkan surat keterangan dokter. Untuk izin keperluan akademik, lampirkan surat atau bukti kegiatan. Format yang diterima adalah JPG, PNG, atau PDF.',
        ),
        _buildFaqItem(
          primaryColor: primaryColor,
          question: 'Bagaimana cara membatalkan pengajuan izin?',
          answer:
              'Untuk membatalkan pengajuan izin, buka menu "Riwayat Izin", pilih izin yang ingin dibatalkan, lalu tekan tombol "Batalkan". Pembatalan hanya dapat dilakukan jika status izin masih "Menunggu Persetujuan".',
        ),
        _buildFaqItem(
          primaryColor: primaryColor,
          question: 'Apa saja status pengajuan izin yang ada?',
          answer:
              'Terdapat 3 status pengajuan izin: "Menunggu Persetujuan" (izin sedang diproses), "Disetujui" (izin diterima), dan "Ditolak" (izin tidak diterima).',
        ),
      ],
    );
  }

  Widget _buildActivityFaqList(Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFaqItem(
          primaryColor: primaryColor,
          question: 'Bagaimana cara melihat jadwal kegiatan?',
          answer:
              'Anda dapat melihat jadwal kegiatan melalui menu "Kalender" di bagian navigasi bawah. Kalender menampilkan semua kegiatan yang akan datang dengan kode warna untuk jenis kegiatan yang berbeda.',
        ),
        _buildFaqItem(
          primaryColor: primaryColor,
          question: 'Apakah saya akan mendapatkan pengingat kegiatan?',
          answer:
              'Ya, sistem akan mengirimkan notifikasi pengingat 1 hari dan 1 jam sebelum kegiatan dimulai. Anda dapat mengatur preferensi notifikasi di menu Pengaturan.',
        ),
        _buildFaqItem(
          primaryColor: primaryColor,
          question:
              'Bagaimana cara menyinkronkan kegiatan dengan Google Calendar?',
          answer:
              'Untuk menyinkronkan dengan Google Calendar, buka menu Profil > Pengaturan > Integrasi Kalender. Klik "Hubungkan dengan Google Calendar" dan ikuti langkah-langkah autentikasi.',
        ),
        _buildFaqItem(
          primaryColor: primaryColor,
          question: 'Apa saja jenis kegiatan yang ada di UKM?',
          answer:
              'Jenis kegiatan di UKM meliputi: Rapat Rutin, Piket Harian, Workshop, Seminar, Kelas Pelatihan, dan Event Khusus. Setiap jenis kegiatan memiliki ketentuan absensi yang berbeda.',
        ),
        _buildFaqItem(
          primaryColor: primaryColor,
          question:
              'Bagaimana cara mendapatkan informasi detail lokasi kegiatan?',
          answer:
              'Detail lokasi kegiatan dapat dilihat pada halaman informasi kegiatan. Aplikasi juga menyediakan fitur peta untuk membantu Anda menemukan lokasi dengan mudah.',
        ),
      ],
    );
  }

  Widget _buildAccountFaqList(Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFaqItem(
          primaryColor: primaryColor,
          question: 'Bagaimana cara mengubah informasi profil?',
          answer:
              'Untuk mengubah informasi profil, buka menu "Profil" di navigasi bawah, lalu tap pada opsi "Edit Profil". Anda dapat mengubah foto profil, nomor telepon, dan informasi lainnya.',
        ),
        _buildFaqItem(
          primaryColor: primaryColor,
          question: 'Cara mengubah password akun?',
          answer:
              'Untuk mengubah password, buka menu Profil > Pengaturan > Keamanan > Ubah Password. Masukkan password lama Anda diikuti password baru, lalu konfirmasi perubahan.',
        ),
        _buildFaqItem(
          primaryColor: primaryColor,
          question: 'Apa yang harus dilakukan jika lupa password?',
          answer:
              'Jika lupa password, tap opsi "Lupa Password" pada halaman login. Masukkan email terdaftar Anda, dan sistem akan mengirimkan tautan reset password ke email tersebut.',
        ),
        _buildFaqItem(
          primaryColor: primaryColor,
          question: 'Bagaimana cara logout dari aplikasi?',
          answer:
              'Untuk logout, buka menu Profil dan scroll ke bawah hingga menemukan tombol "Logout". Tap tombol tersebut dan konfirmasi tindakan Anda.',
        ),
        _buildFaqItem(
          primaryColor: primaryColor,
          question: 'Apakah data saya aman di aplikasi ini?',
          answer:
              'Ya, aplikasi kami mengutamakan keamanan data pengguna. Kami menggunakan enkripsi untuk melindungi data pribadi dan tidak membagikan informasi Anda kepada pihak ketiga tanpa persetujuan.',
        ),
      ],
    );
  }

  Widget _buildNumberedStep(int number, String text, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
