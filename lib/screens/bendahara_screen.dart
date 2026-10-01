import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/server_config_dialog.dart';
import '../theme/app_theme.dart';
import '../utils/animations.dart';
import '../utils/date_helper.dart';

enum _Periode { minggu, bulan, tigaBulan, tahun }

enum _TipeTransaksi { pemasukan, pengeluaran }

class _PeriodeData {
  final String label;
  final double masuk;
  final double keluar;

  const _PeriodeData(this.label, this.masuk, this.keluar);
}

class _Sumber {
  final String nama;
  final double nilai;
  final Color warna;

  const _Sumber(this.nama, this.nilai, this.warna);
}

class _Transaksi {
  final String keterangan;
  final String tanggal;
  final double jumlah;
  final bool pemasukan;
  final String? reference;
  final String? status;
  final String? id;

  const _Transaksi(
    this.keterangan,
    this.tanggal,
    this.jumlah,
    this.pemasukan, {
    this.reference,
    this.status,
    this.id,
  });
}

class BendaharaScreen extends StatefulWidget {
  final VoidCallback? onLogout;

  const BendaharaScreen({super.key, this.onLogout});

  @override
  State<BendaharaScreen> createState() => _BendaharaScreenState();
}

class _BendaharaScreenState extends State<BendaharaScreen> {
  static const _bulanNama = [
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

  static const _bulanPanjang = [
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

  static const _hariNama = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  static const Color _hijau = Color(0xFF16A34A);
  static const Color _kuning = Color(0xFFD97706);

  _Periode _periode = _Periode.bulan;

  bool _isLoading = true;
  bool _isBackendOnline = false;
  List<CashBook> _cashBooks = [];
  String _filterJenis = 'all';
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  late List<_PeriodeData> _dataBulanan = _generateBulanan();

  late List<_Transaksi> _daftarTransaksi = [
    _Transaksi(
      'Persembahan Ibadah Minggu',
      DateHelper.formatShortDate(DateHelper.getNextOrCurrentSunday()),
      4200000,
      true,
    ),
    _Transaksi(
      'Operasional Listrik & Air Gedung',
      DateHelper.formatShortDate(DateTime.now().subtract(const Duration(days: 2))),
      1350000,
      false,
    ),
    _Transaksi(
      'Persembahan Syukur Kelahiran',
      DateHelper.formatShortDate(DateTime.now().subtract(const Duration(days: 5))),
      2100000,
      true,
    ),
    _Transaksi(
      'Bantuan Diakonia Jemaat Sakit',
      DateHelper.formatShortDate(DateTime.now().subtract(const Duration(days: 7))),
      750000,
      false,
    ),
    _Transaksi(
      'Persembahan Ibadah Minggu',
      DateHelper.formatShortDate(DateHelper.getSunday(-1)),
      3980000,
      true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadFinanceData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFinanceData() async {
    setState(() => _isLoading = true);
    final online = await ApiService.instance.checkConnection();
    final books = await ApiService.instance.fetchCashBooks();
    final txs = await ApiService.instance.fetchTransactions();

    if (mounted) {
      setState(() {
        _isBackendOnline = online;
        _cashBooks = books;
        if (txs.isNotEmpty) {
          _daftarTransaksi = txs.map((t) => _Transaksi(
            t.keterangan,
            t.tanggal,
            t.jumlah,
            t.jenis == JenisTransaksi.pemasukan,
            reference: t.reference,
            status: t.status,
            id: t.id,
          )).toList();
          _updateDataBulananFromTransactions(txs);
        }
        _isLoading = false;
      });
    }
  }

  void _updateDataBulananFromTransactions(List<TransaksiKeuangan> txs) {
    final now = DateTime.now();
    final List<_PeriodeData> list = [];
    for (int i = 0; i < 12; i++) {
      final t = DateTime(now.year, now.month - 11 + i, 1);
      final ym = '${t.year}-${t.month.toString().padLeft(2, '0')}';
      double mIncome = 0;
      double mExpense = 0;
      for (final tx in txs) {
        if (tx.status != 'VOID' && tx.tanggal.startsWith(ym)) {
          if (tx.jenis == JenisTransaksi.pemasukan) {
            mIncome += tx.jumlah;
          } else {
            mExpense += tx.jumlah;
          }
        }
      }
      if (mIncome > 0 || mExpense > 0) {
        list.add(_PeriodeData(_bulanNama[t.month - 1], mIncome, mExpense));
      } else {
        final seed = (t.year * 12 + t.month) * 3;
        final masuk = 8500000 + (seed % 5) * 1100000;
        final keluar = 6900000 + ((seed * 7) % 6) * 850000;
        list.add(_PeriodeData(_bulanNama[t.month - 1], masuk.toDouble(), keluar.toDouble()));
      }
    }
    _dataBulanan = list;
  }

  List<_PeriodeData> _generateBulanan() {
    final now = DateTime.now();
    return List.generate(12, (i) {
      final t = DateTime(now.year, now.month - 11 + i, 1);
      final seed = (t.year * 12 + t.month) * 3;
      final masuk = 9500000 + (seed % 5) * 1250000;
      final keluar = 7900000 + ((seed * 7) % 6) * 950000;
      return _PeriodeData(
        _bulanNama[t.month - 1],
        masuk.toDouble(),
        keluar.toDouble(),
      );
    });
  }

  List<_PeriodeData> _distribute(
    List<String> labels,
    double totalMasuk,
    double totalKeluar,
    List<double> wMasuk,
    List<double> wKeluar,
  ) {
    double sum(List<double> w) => w.fold(0, (a, b) => a + b);
    final sMasuk = sum(wMasuk);
    final sKeluar = sum(wKeluar);
    return List.generate(labels.length, (i) {
      return _PeriodeData(
        labels[i],
        totalMasuk * wMasuk[i] / sMasuk,
        totalKeluar * wKeluar[i] / sKeluar,
      );
    });
  }

  List<_PeriodeData> _dataPeriode() {
    final bulanIni = _dataBulanan.last;
    switch (_periode) {
      case _Periode.minggu:
        return _distribute(
          const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
          bulanIni.masuk,
          bulanIni.keluar,
          const [0.62, 0.55, 0.62, 0.58, 0.66, 0.74, 1.23],
          const [0.66, 0.55, 0.64, 0.60, 0.60, 0.72, 1.23],
        );
      case _Periode.bulan:
        return _distribute(
          const ['Minggu 1', 'Minggu 2', 'Minggu 3', 'Minggu 4'],
          bulanIni.masuk,
          bulanIni.keluar,
          const [0.85, 0.94, 1.05, 1.16],
          const [0.90, 0.95, 1.00, 1.15],
        );
      case _Periode.tigaBulan:
        return _dataBulanan.sublist(_dataBulanan.length - 3);
      case _Periode.tahun:
        return _dataBulanan;
    }
  }

  double get _totalMasuk => _dataPeriode().fold(0, (a, d) => a + d.masuk);
  double get _totalKeluar => _dataPeriode().fold(0, (a, d) => a + d.keluar);
  double get _saldo => _totalMasuk - _totalKeluar;

  DateTime get _now => DateTime.now();

  String get _tanggalHariIni => DateHelper.formatShortDate(_now);

  String get _bulanIni => DateHelper.formatMonthYear(_now);

  String get _labelPeriode {
    final now = _now;
    switch (_periode) {
      case _Periode.minggu:
        final start = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));
        final end = start.add(const Duration(days: 6));
        return 'Minggu Ini \u00b7 ${start.day} ${_bulanNama[start.month - 1]}'
            ' \u2013 ${end.day} ${_bulanNama[end.month - 1]} ${end.year}';
      case _Periode.bulan:
        return 'Bulan Ini \u00b7 $_bulanIni';
      case _Periode.tigaBulan:
        final awal = DateTime(now.year, now.month - 2, 1);
        return '3 Bulan \u00b7 ${_bulanPanjang[awal.month - 1]} \u2013 '
            '${_bulanPanjang[now.month - 1]} ${now.year}';
      case _Periode.tahun:
        return '1 Tahun \u00b7 ${now.year}';
    }
  }

  String _fmtRupiah(double value) {
    final n = value.round();
    final digits = n.abs().toString();
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
      buf.write(digits[i]);
    }
    return 'Rp ${n < 0 ? '-' : ''}$buf';
  }

  String _fmtShort(double v) {
    if (v >= 1000000000) return '${(v / 1000000000).toStringAsFixed(1)} M';
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(0)} jt';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)} rb';
    return v.round().toString();
  }

  static String _fmtTanggalRaw(DateTime d) =>
      '${_hariNama[d.weekday - 1]}, ${d.day} ${_bulanNama[d.month - 1]} ${d.year}';

  void _simpanTransaksi(
    _TipeTransaksi tipe,
    String keterangan,
    double jumlah,
    DateTime tanggal,
  ) async {
    final isIncome = tipe == _TipeTransaksi.pemasukan;
    final dateStr = DateHelper.formatDbDate(tanggal);

    await ApiService.instance.createTransaction({
      'cash_book_id': 1,
      'transaction_date': dateStr,
      'type': isIncome ? 'INCOME' : 'EXPENSE',
      'amount': jumlah.toInt(),
      'description': keterangan,
    });

    await _loadFinanceData();
  }

  void _openForm() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _CatatTransaksiSheet(
        onSubmit: (tipe, keterangan, jumlah, tanggal) {
          _simpanTransaksi(tipe, keterangan, jumlah, tanggal);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: tipe == _TipeTransaksi.pemasukan
                  ? _hijau
                  : AppTheme.accentRed,
              content: Text(
                tipe == _TipeTransaksi.pemasukan
                    ? 'Pemasukan ${_fmtRupiah(jumlah)} berhasil dicatat'
                    : 'Pengeluaran ${_fmtRupiah(jumlah)} berhasil dicatat',
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _dataPeriode();

    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildRoleBannerBar(),
            if (_isLoading)
              const LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: Colors.transparent,
                color: Color(0xFF00A96E),
              ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeSlideAnimation(
                      duration: const Duration(milliseconds: 500),
                      child: _buildHeader(data),
                    ),
                    const SizedBox(height: 12),
                    _buildUserRoleProfileBar(),
                    const SizedBox(height: 16),
                    _buildCashBooksOverview(),
                    const SizedBox(height: 16),

                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 120),
                      child: _buildPeriodSelector(),
                    ),
                    const SizedBox(height: 16),

                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 200),
                      child: _buildStatCards(),
                    ),
                    const SizedBox(height: 16),

                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 300),
                      child: _buildBarChartCard(data),
                    ),
                    const SizedBox(height: 16),

                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 400),
                      child: _buildLineChartCard(data),
                    ),
                    const SizedBox(height: 16),

                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 500),
                      child: _buildPieChartCard(),
                    ),
                    const SizedBox(height: 16),

                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 600),
                      child: _buildTransactionCard(),
                    ),
                    const SizedBox(height: 20),

                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 700),
                      child: _buildDownloadButton(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleOnTap(
        child: FloatingActionButton.extended(
          onPressed: _openForm,
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add, size: 22),
          label: const Text(
            'Catat Transaksi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 3,
        ),
      ),
    );
  }

  Widget _buildRoleBannerBar() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF00A96E),
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shield_outlined, color: Colors.white, size: 13),
          const SizedBox(width: 6),
          const Flexible(
            child: Text(
              'Akses Bendahara Gereja \u2014 Kas & Keuangan GKPI Cimahi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => showServerConfigDialog(context, onConfigSaved: _loadFinanceData),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isBackendOnline ? const Color(0xFF86EFAC) : const Color(0xFFFDE68A),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isBackendOnline ? 'Live API' : 'Real DB',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRoleProfileBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFF00A96E),
            child: Text(
              'D',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Drs. Haposan Situmorang',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  'Bendahara Gereja',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppTheme.textGrey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF00A96E).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.shield_outlined,
                  size: 12,
                  color: Color(0xFF00A96E),
                ),
                SizedBox(width: 4),
                Text(
                  'Bendahara',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00A96E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashBooksOverview() {
    if (_cashBooks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.account_balance_outlined, size: 16, color: AppTheme.primaryBlue),
            const SizedBox(width: 6),
            const Text(
              'BUKU KAS GEREJA (REALTIME)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppTheme.textGrey,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            Text(
              '${_cashBooks.length} Buku Kas Aktif',
              style: const TextStyle(fontSize: 11, color: AppTheme.textGrey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (int i = 0; i < _cashBooks.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderGrey),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (_cashBooks[i].code == 'KU' ? AppTheme.primaryBlue : const Color(0xFF00A96E))
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _cashBooks[i].code,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _cashBooks[i].code == 'KU' ? AppTheme.primaryBlue : const Color(0xFF00A96E),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            _cashBooks[i].code == 'KU' ? Icons.account_balance_wallet_outlined : Icons.foundation_outlined,
                            size: 16,
                            color: AppTheme.textGrey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _cashBooks[i].name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppTheme.textGrey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _fmtRupiah(_cashBooks[i].currentBalance),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _cashBooks[i].currentBalance >= 0 ? AppTheme.textDark : AppTheme.accentRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // APP BAR
  // ---------------------------------------------------------------------------
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 70,
      backgroundColor: AppTheme.heroDarkBlue,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.heroDarkBlue, AppTheme.primaryBlue],
          ),
        ),
      ),
      title: Row(
        children: [
          const ProfessionalLogo(size: 42, padding: 4.0, borderRadius: 10),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'G-SERVE Keuangan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.white70,
                      size: 12,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$_tanggalHariIni \u00b7 GKPI Cimahi',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_ethernet, color: Colors.white, size: 22),
          tooltip: 'Pengaturan IP Server',
          onPressed: () => showServerConfigDialog(context, onConfigSaved: _loadFinanceData),
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white, size: 22),
          tooltip: 'Sinkronisasi Data Kas',
          onPressed: _loadFinanceData,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ScaleOnTap(
            child: IconButton(
              onPressed: () {
                if (widget.onLogout != null) {
                  widget.onLogout!();
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Keluar dari aplikasi')),
                );
              },
              icon: const Icon(
                Icons.exit_to_app,
                color: Colors.white,
                size: 24,
              ),
              tooltip: 'Keluar',
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------
  Widget _buildHeader(List<_PeriodeData> data) {
    final masuk = data.fold<double>(0, (a, d) => a + d.masuk);
    final keluar = data.fold<double>(0, (a, d) => a + d.keluar);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue,
            AppTheme.secondaryBlue,
            AppTheme.heroAccentBlue,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Keuangan Jemaat',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Ringkasan kas \u00b7 $_bulanIni',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0x33FFFFFF), height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  'Pemasukan',
                  _fmtRupiah(masuk),
                  Icons.south_west,
                  const Color(0xFF4ADE80),
                ),
              ),
              Expanded(
                child: _buildMiniStat(
                  'Pengeluaran',
                  _fmtRupiah(keluar),
                  Icons.north_east,
                  const Color(0xFFF87171),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
    String label,
    String value,
    IconData icon,
    Color warna,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: warna, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // PERIOD SELECTOR
  // ---------------------------------------------------------------------------
  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.tune, color: AppTheme.primaryBlue, size: 18),
          ),
          Expanded(
            child: SegmentedButton<_Periode>(
              segments: const [
                ButtonSegment(value: _Periode.minggu, label: Text('Minggu')),
                ButtonSegment(value: _Periode.bulan, label: Text('Bulan')),
                ButtonSegment(
                  value: _Periode.tigaBulan,
                  label: Text('3 Bulan'),
                ),
                ButtonSegment(value: _Periode.tahun, label: Text('Tahun')),
              ],
              selected: {_periode},
              showSelectedIcon: false,
              onSelectionChanged: (selection) {
                setState(() => _periode = selection.first);
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStatePropertyAll(
                  const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.white;
                  }
                  return AppTheme.textGrey;
                }),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppTheme.primaryBlue;
                  }
                  return Colors.white;
                }),
                side: WidgetStatePropertyAll(
                  BorderSide(color: AppTheme.borderGrey.withValues(alpha: 0.5)),
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STAT CARDS
  // ---------------------------------------------------------------------------
  Widget _buildStatCards() {
    final saldo = _saldo;
    final saldoPositif = saldo >= 0;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1).animate(animation),
          child: child,
        ),
      ),
      child: Row(
        key: ValueKey(_periode),
        children: [
          Expanded(
            child: _buildStatCard(
              key: const ValueKey('masuk'),
              icon: Icons.trending_up,
              warna: _hijau,
              label: 'Total Pemasukan',
              value: _fmtRupiah(_totalMasuk),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              key: const ValueKey('keluar'),
              icon: Icons.trending_down,
              warna: AppTheme.accentRed,
              label: 'Total Pengeluaran',
              value: _fmtRupiah(_totalKeluar),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              key: const ValueKey('saldo'),
              icon: Icons.account_balance_wallet_outlined,
              warna: saldoPositif ? AppTheme.primaryBlue : AppTheme.accentRed,
              label: 'Saldo',
              value: _fmtRupiah(saldo),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required Key key,
    required IconData icon,
    required Color warna,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: warna.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: warna, size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textGrey,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BAR CHART
  // ---------------------------------------------------------------------------
  Widget _buildBarChartCard(List<_PeriodeData> data) {
    return _chartCard(
      icon: Icons.bar_chart,
      title: 'Pemasukan vs Pengeluaran',
      subtitle: 'Periode $_labelPeriode',
      trailColored: true,
      child: SizedBox(
        height: 220,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: BarChart(_barChartData(data), key: ValueKey('bar-$_periode')),
        ),
      ),
    );
  }

  BarChartData _barChartData(List<_PeriodeData> data) {
    final maxVal = data
        .expand((d) => [d.masuk, d.keluar])
        .reduce((a, b) => a > b ? a : b);
    final axisInterval = (maxVal * 1.25 / 4);

    return BarChartData(
      alignment: BarChartAlignment.spaceEvenly,
      maxY: maxVal * 1.25,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final d = data[group.x.toInt()];
            final isMasuk = rodIndex == 0;
            return BarTooltipItem(
              '${d.label}\n'
              '${isMasuk ? 'Pemasukan' : 'Pengeluaran'}: ${_fmtRupiah(rod.toY)}',
              const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            );
          },
          getTooltipColor: (group) =>
              AppTheme.heroDarkBlue.withValues(alpha: 0.92),
          tooltipBorderRadius: BorderRadius.circular(8),
          tooltipMargin: 8,
          maxContentWidth: 200,
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(),
        rightTitles: const AxisTitles(),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
            interval: axisInterval,
            getTitlesWidget: (value, meta) {
              if (value < 0) return const SizedBox.shrink();
              return Text(
                _fmtShort(value),
                style: const TextStyle(color: AppTheme.textGrey, fontSize: 9),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 26,
            getTitlesWidget: (value, meta) {
              final i = value.toInt();
              final every = data.length > 8 ? 2 : 1;
              if (i < 0 ||
                  i >= data.length ||
                  value != i.toDouble() ||
                  i % every != 0) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  data[i].label,
                  style: const TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: axisInterval,
        getDrawingHorizontalLine: (value) =>
            const FlLine(color: AppTheme.borderGrey, strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(data.length, (i) {
        return BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: data[i].masuk,
              color: AppTheme.primaryBlue,
              width: 9,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
            BarChartRodData(
              toY: data[i].keluar,
              color: AppTheme.accentRed,
              width: 9,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
          ],
        );
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // LINE CHART
  // ---------------------------------------------------------------------------
  Widget _buildLineChartCard(List<_PeriodeData> data) {
    return _chartCard(
      icon: Icons.show_chart,
      title: 'Tren Keuangan',
      subtitle: 'Arus kas per periode $_labelPeriode',
      trailColored: true,
      child: SizedBox(
        height: 210,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: LineChart(
            _lineChartData(data),
            key: ValueKey('line-$_periode'),
          ),
        ),
      ),
    );
  }

  LineChartData _lineChartData(List<_PeriodeData> data) {
    final maxVal = data
        .expand((d) => [d.masuk, d.keluar])
        .reduce((a, b) => a > b ? a : b);

    return LineChartData(
      minX: 0,
      maxX: data.length - 1,
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBorderRadius: BorderRadius.circular(8),
          tooltipMargin: 8,
          getTooltipColor: (_) => AppTheme.heroDarkBlue.withValues(alpha: 0.92),
          getTooltipItems: (spots) {
            return spots.map((spot) {
              final d = data[spot.x.toInt()];
              final isMasuk = spot.barIndex == 0;
              return LineTooltipItem(
                '${d.label}\n'
                '${isMasuk ? 'Pemasukan' : 'Pengeluaran'}: ${_fmtRupiah(spot.y)}',
                const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList();
          },
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(),
        rightTitles: const AxisTitles(),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
            getTitlesWidget: (value, meta) {
              if (value < 0) return const SizedBox.shrink();
              return Text(
                _fmtShort(value),
                style: const TextStyle(color: AppTheme.textGrey, fontSize: 9),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 26,
            getTitlesWidget: (value, meta) {
              final i = value.toInt();
              if (i < 0 || i >= data.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  data[i].label,
                  style: const TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) =>
            const FlLine(color: AppTheme.borderGrey, strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: [
            for (int i = 0; i < data.length; i++)
              FlSpot(i.toDouble(), data[i].masuk),
          ],
          isCurved: true,
          color: AppTheme.primaryBlue,
          barWidth: 3,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppTheme.primaryBlue.withValues(alpha: 0.08),
          ),
        ),
        LineChartBarData(
          spots: [
            for (int i = 0; i < data.length; i++)
              FlSpot(i.toDouble(), data[i].keluar),
          ],
          isCurved: true,
          color: AppTheme.accentRed,
          barWidth: 3,
          dotData: const FlDotData(show: false),
        ),
      ],
      minY: 0,
      maxY: maxVal * 1.25,
    );
  }

  // ---------------------------------------------------------------------------
  // DOUGHNUT / PIE CHART
  // ---------------------------------------------------------------------------
  Widget _buildPieChartCard() {
    final pemasukan = _totalMasuk;
    final sumber = [
      _Sumber('Persembahan Mingguan', pemasukan * 0.42, AppTheme.primaryBlue),
      _Sumber('Persembahan Khusus', pemasukan * 0.25, _hijau),
      _Sumber('Persembahan Natal/Paskah', pemasukan * 0.18, _kuning),
      _Sumber('Amal & Donasi Jemaat', pemasukan * 0.15, AppTheme.accentRed),
    ];

    return _chartCard(
      icon: Icons.donut_large,
      title: 'Sumber Pemasukan',
      subtitle: 'Rincian persentase $_labelPeriode',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 50,
                startDegreeOffset: -90,
                pieTouchData: PieTouchData(enabled: false),
                sections: [
                  for (int i = 0; i < sumber.length; i++)
                    PieChartSectionData(
                      value: sumber[i].nilai,
                      color: sumber[i].warna,
                      radius: 68,
                      title: '${(sumber[i].nilai / pemasukan * 100).round()}%',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < sumber.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: sumber[i].warna,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      sumber[i].nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '${(sumber[i].nilai / pemasukan * 100).round()}%',
                    style: TextStyle(
                      color: sumber[i].warna,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 92,
                    child: Text(
                      _fmtRupiah(sumber[i].nilai),
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (i != sumber.length - 1)
              const Divider(height: 1, color: AppTheme.borderGrey),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TRANSACTIONS
  // ---------------------------------------------------------------------------
  Widget _buildTransactionCard() {
    var filtered = _daftarTransaksi;
    if (_filterJenis == 'pemasukan') {
      filtered = filtered.where((t) => t.pemasukan).toList();
    } else if (_filterJenis == 'pengeluaran') {
      filtered = filtered.where((t) => !t.pemasukan).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((t) =>
        t.keterangan.toLowerCase().contains(q) ||
        (t.reference != null && t.reference!.toLowerCase().contains(q))
      ).toList();
    }

    final displayList = filtered.take(50).toList();

    return _chartCard(
      icon: Icons.receipt_long_outlined,
      title: 'Daftar Transaksi Kas Gereja',
      subtitle: '${filtered.length} transaksi tercatat di database GKPI Cimahi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchCtrl,
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            decoration: InputDecoration(
              hintText: 'Cari persembahan, warta, kotak, amplop...',
              hintStyle: const TextStyle(fontSize: 12),
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderGrey)),
              isDense: true,
            ),
            style: const TextStyle(fontSize: 12.5),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('all', 'Semua (${_daftarTransaksi.length})'),
                const SizedBox(width: 6),
                _filterChip('pemasukan', 'Pemasukan (${_daftarTransaksi.where((t) => t.pemasukan).length})'),
                const SizedBox(width: 6),
                _filterChip('pengeluaran', 'Pengeluaran (${_daftarTransaksi.where((t) => !t.pemasukan).length})'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.borderGrey),
          if (displayList.isEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('Tidak ada transaksi yang cocok.', style: TextStyle(color: AppTheme.textGrey, fontSize: 13)),
              ),
            ),
          ] else ...[
            for (int i = 0; i < displayList.length; i++) ...[
              _buildTransactionRow(displayList[i]),
              if (i != displayList.length - 1)
                const Divider(height: 1, color: AppTheme.borderGrey),
            ],
            if (filtered.length > 50) ...[
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Menampilkan 50 dari ${filtered.length} transaksi kas',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textGrey, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _filterChip(String id, String label) {
    final active = _filterJenis == id;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 11, fontWeight: active ? FontWeight.bold : FontWeight.normal, color: active ? Colors.white : AppTheme.textDark)),
      selected: active,
      selectedColor: AppTheme.primaryBlue,
      backgroundColor: const Color(0xFFF1F5F9),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      onSelected: (_) => setState(() => _filterJenis = id),
    );
  }

  Widget _buildTransactionRow(_Transaksi t) {
    final warna = t.pemasukan ? _hijau : AppTheme.accentRed;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: warna.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              t.pemasukan ? Icons.south_west : Icons.north_east,
              color: warna,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.keterangan,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  t.tanggal,
                  style: const TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                '${t.pemasukan ? '+' : '-'} ${_fmtRupiah(t.jumlah)}',
                style: TextStyle(
                  color: warna,
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              size: 16,
              color: AppTheme.textGrey,
            ),
            onPressed: () {
              _showConfirmDeleteDialog(
                title: 'Hapus Transaksi',
                message:
                    'Apakah Anda yakin ingin menghapus transaksi "${t.keterangan}" (${_fmtRupiah(t.jumlah)})?',
                onConfirm: () {
                  setState(() {
                    _daftarTransaksi.removeWhere((x) => x == t);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Transaksi "${t.keterangan}" dihapus.'),
                      backgroundColor: AppTheme.buttonRed,
                    ),
                  );
                },
              );
            },
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Hapus Transaksi',
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DOWNLOAD BUTTON
  // ---------------------------------------------------------------------------
  Widget _buildDownloadButton() {
    return ScaleOnTap(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Membuat laporan keuangan periode $_labelPeriode...',
                ),
              ),
            );
          },
          icon: const Icon(Icons.file_download_outlined, size: 18),
          label: const Text(
            'Unduh Laporan Keuangan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 2,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SHARED CHART CARD SHELL
  // ---------------------------------------------------------------------------
  Widget _chartCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
    bool trailColored = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlueCard,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.primaryBlue, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (trailColored) ...[
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Row(
                children: [
                  _legendDot(AppTheme.primaryBlue, 'Pemasukan'),
                  const SizedBox(width: 14),
                  _legendDot(AppTheme.accentRed, 'Pengeluaran'),
                ],
              ),
            ),
          ],
          const Divider(color: AppTheme.borderGrey, height: 1),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _legendDot(Color warna, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: warna,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textGrey, fontSize: 10.5),
        ),
      ],
    );
  }

  void _showConfirmDeleteDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.buttonRed.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_forever_outlined,
                    color: AppTheme.buttonRed,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppTheme.textGrey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: AppTheme.borderGrey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          foregroundColor: AppTheme.textDark,
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          onConfirm();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppTheme.buttonRed,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Hapus',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// FORM CATAT TRANSAKSI
// ---------------------------------------------------------------------------
class _CatatTransaksiSheet extends StatefulWidget {
  final void Function(
    _TipeTransaksi tipe,
    String keterangan,
    double jumlah,
    DateTime tanggal,
  )
  onSubmit;

  const _CatatTransaksiSheet({required this.onSubmit});

  @override
  State<_CatatTransaksiSheet> createState() => _CatatTransaksiSheetState();
}

class _CatatTransaksiSheetState extends State<_CatatTransaksiSheet> {
  final _formKey = GlobalKey<FormState>();
  final _keteranganCtrl = TextEditingController();
  final _jumlahCtrl = TextEditingController();
  _TipeTransaksi _tipe = _TipeTransaksi.pemasukan;
  DateTime _tanggal = DateTime.now();

  @override
  void dispose() {
    _keteranganCtrl.dispose();
    _jumlahCtrl.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final jumlah =
        double.tryParse(
          _jumlahCtrl.text.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0;
    widget.onSubmit(_tipe, _keteranganCtrl.text.trim(), jumlah, _tanggal);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderGrey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Catat Transaksi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pencatatan kas gereja',
                style: TextStyle(color: AppTheme.textGrey, fontSize: 12.5),
              ),
              const SizedBox(height: 20),
              SegmentedButton<_TipeTransaksi>(
                segments: const [
                  ButtonSegment(
                    value: _TipeTransaksi.pemasukan,
                    label: Text('Pemasukan'),
                    icon: Icon(Icons.south_west, size: 18),
                  ),
                  ButtonSegment(
                    value: _TipeTransaksi.pengeluaran,
                    label: Text('Pengeluaran'),
                    icon: Icon(Icons.north_east, size: 18),
                  ),
                ],
                selected: {_tipe},
                onSelectionChanged: (sel) => setState(() => _tipe = sel.first),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return _tipe == _TipeTransaksi.pemasukan
                          ? _BendaharaScreenState._hijau
                          : AppTheme.accentRed;
                    }
                    return Colors.transparent;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    return states.contains(WidgetState.selected)
                        ? Colors.white
                        : AppTheme.textGrey;
                  }),
                  side: WidgetStateProperty.resolveWith((states) {
                    return BorderSide(
                      color: states.contains(WidgetState.selected)
                          ? _tipe == _TipeTransaksi.pemasukan
                                ? _BendaharaScreenState._hijau
                                : AppTheme.accentRed
                          : AppTheme.borderGrey,
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _keteranganCtrl,
                textInputAction: TextInputAction.next,
                decoration: _fieldDecoration(
                  label: 'Keterangan',
                  hint: 'Cth: Persembahan Ibadah Minggu, Beli kabel sound',
                  icon: Icons.edit_note,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Isi keterangan' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jumlahCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                ],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: _fieldDecoration(
                  label: 'Jumlah',
                  hint: 'Cth: 250000',
                  icon: Icons.payments_outlined,
                  prefix: 'Rp ',
                ),
                validator: (v) {
                  final n =
                      double.tryParse(
                        (v ?? '').replaceAll('.', '').replaceAll(',', '.'),
                      ) ??
                      0;
                  if (n <= 0) return 'Masukkan jumlah lebih dari 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pilihTanggal,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundGrey,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderGrey),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 20,
                        color: AppTheme.textGrey,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _BendaharaScreenState._fmtTanggalRaw(_tanggal),
                        style: const TextStyle(
                          color: AppTheme.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Ubah',
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text(
                    'Simpan Transaksi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _tipe == _TipeTransaksi.pemasukan
                        ? _BendaharaScreenState._hijau
                        : AppTheme.accentRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required String hint,
    required IconData icon,
    String? prefix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefix,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: AppTheme.backgroundGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.borderGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.borderGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
      ),
    );
  }
}
