class DateHelper {
  static const List<String> hariNamaLong = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> hariNamaShort = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  static const List<String> bulanNamaLong = [
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

  static const List<String> bulanNamaShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  /// Get current real-life DateTime
  static DateTime get now => DateTime.now();

  /// Format DateTime to full Indonesian date string:
  /// e.g. "Kamis, 24 September 2026"
  static String formatFullDate(DateTime date, {bool shortMonth = false}) {
    final hari = hariNamaLong[date.weekday - 1];
    final bulan = shortMonth
        ? bulanNamaShort[date.month - 1]
        : bulanNamaLong[date.month - 1];
    return '$hari, ${date.day} $bulan ${date.year}';
  }

  /// Format DateTime to short Indonesian date string:
  /// e.g. "Kam, 24 Sep 2026"
  static String formatShortDate(DateTime date) {
    final hari = hariNamaShort[date.weekday - 1];
    final bulan = bulanNamaShort[date.month - 1];
    return '$hari, ${date.day} $bulan ${date.year}';
  }

  /// Format Month & Year:
  /// e.g. "September 2026"
  static String formatMonthYear(DateTime date) {
    return '${bulanNamaLong[date.month - 1]} ${date.year}';
  }

  /// Format Month & Day for badge:
  /// e.g. "SEP 24"
  static String formatBadgeDate(DateTime date) {
    final bulan = bulanNamaShort[date.month - 1].toUpperCase();
    return '$bulan ${date.day}';
  }

  /// Format simple date:
  /// e.g. "24 September 2026"
  static String formatDateOnly(DateTime date, {bool shortMonth = false}) {
    final bulan = shortMonth
        ? bulanNamaShort[date.month - 1]
        : bulanNamaLong[date.month - 1];
    return '${date.day} $bulan ${date.year}';
  }

  /// Format to ISO DB date string: e.g. "2026-01-04"
  static String formatDbDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Get closest Sunday (if today is Sunday, returns today, else next Sunday)
  static DateTime getNextOrCurrentSunday({DateTime? from}) {
    final base = from ?? DateTime.now();
    int daysUntilSunday = (DateTime.sunday - base.weekday) % 7;
    return base.add(Duration(days: daysUntilSunday));
  }

  /// Get Sunday relative to current week (0 = upcoming/current Sunday, 1 = next week, -1 = last week)
  static DateTime getSunday(int weekOffset, {DateTime? from}) {
    final sunday = getNextOrCurrentSunday(from: from);
    return sunday.add(Duration(days: weekOffset * 7));
  }
}
