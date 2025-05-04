class DateFormatter {
  static final List<String> _namaBulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static String formatTimeRange(DateTime startTime, DateTime endTime) {
    try {
      String tanggal =
          '${startTime.day} ${_namaBulan[startTime.month - 1]} ${startTime.year}';

      String waktuMulai =
          '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
      String waktuSelesai =
          '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

      return '$tanggal, $waktuMulai - $waktuSelesai WIB';
    } catch (e) {
      return 'Waktu tidak valid';
    }
  }

  static String formatTime(DateTime time) {
    try {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Waktu tidak valid';
    }
  }

  static String formatDateTimeIndonesia(DateTime date) {
    try {
      String tanggal = '${date.day} ${_namaBulan[date.month - 1]} ${date.year}';

      String waktu =
          '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

      return '$tanggal, $waktu WIB';
    } catch (e) {
      return 'Tanggal tidak valid';
    }
  }

  static String formatDate(DateTime date, String format) {
    try {
      if (format == 'dd MMMM yyyy') {
        return '${date.day} ${_namaBulan[date.month - 1]} ${date.year}';
      } else if (format == 'dd/MM/yyyy') {
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      } else if (format == 'yyyy-MM-dd') {
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      } else {
        return '${date.day} ${_namaBulan[date.month - 1]} ${date.year}';
      }
    } catch (e) {
      return 'Tanggal tidak valid';
    }
  }
}
