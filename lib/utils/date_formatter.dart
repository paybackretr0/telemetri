import 'package:timezone/timezone.dart' as tz;

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

  static DateTime _toWIB(DateTime dateTime) {
    final jakarta = tz.getLocation('Asia/Jakarta');
    final tzDateTime = tz.TZDateTime.from(dateTime, jakarta);
    return DateTime(
      tzDateTime.year,
      tzDateTime.month,
      tzDateTime.day,
      tzDateTime.hour,
      tzDateTime.minute,
      tzDateTime.second,
    );
  }

  static String formatTimeRange(DateTime startTime, DateTime endTime) {
    try {
      final wibStartTime = _toWIB(startTime);
      final wibEndTime = _toWIB(endTime);

      String tanggal =
          '${wibStartTime.day} ${_namaBulan[wibStartTime.month - 1]} ${wibStartTime.year}';

      String waktuMulai =
          '${wibStartTime.hour.toString().padLeft(2, '0')}:${wibStartTime.minute.toString().padLeft(2, '0')}';
      String waktuSelesai =
          '${wibEndTime.hour.toString().padLeft(2, '0')}:${wibEndTime.minute.toString().padLeft(2, '0')}';

      return '$tanggal, $waktuMulai - $waktuSelesai WIB';
    } catch (e) {
      return 'Waktu tidak valid';
    }
  }

  static String formatTime(DateTime time) {
    try {
      final wibTime = _toWIB(time);

      return '${wibTime.hour.toString().padLeft(2, '0')}:${wibTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Waktu tidak valid';
    }
  }

  static String formatDateTimeIndonesia(DateTime date) {
    try {
      final wibDate = _toWIB(date);

      String tanggal = '${wibDate.day} ${_namaBulan[wibDate.month - 1]} ${wibDate.year}';

      String waktu =
          '${wibDate.hour.toString().padLeft(2, '0')}:${wibDate.minute.toString().padLeft(2, '0')}';

      return '$tanggal, $waktu WIB';
    } catch (e) {
      return 'Tanggal tidak valid';
    }
  }

  static String formatDate(DateTime date, String format) {
    try {
      final wibDate = _toWIB(date);

      if (format == 'dd MMMM yyyy') {
        return '${wibDate.day} ${_namaBulan[wibDate.month - 1]} ${wibDate.year}';
      } else if (format == 'dd/MM/yyyy') {
        return '${wibDate.day.toString().padLeft(2, '0')}/${wibDate.month.toString().padLeft(2, '0')}/${wibDate.year}';
      } else if (format == 'yyyy-MM-dd') {
        return '${wibDate.year}-${wibDate.month.toString().padLeft(2, '0')}-${wibDate.day.toString().padLeft(2, '0')}';
      } else {
        return '${wibDate.day} ${_namaBulan[wibDate.month - 1]} ${wibDate.year}';
      }
    } catch (e) {
      return 'Tanggal tidak valid';
    }
  }
}