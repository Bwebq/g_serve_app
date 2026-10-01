import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/animations.dart';
import '../utils/date_helper.dart';

enum _DiakenTab { jemaat, wartaJadwal }

class DiakenScreen extends StatefulWidget {
  final VoidCallback? onLogout;

  const DiakenScreen({super.key, this.onLogout});

  @override
  State<DiakenScreen> createState() => _DiakenScreenState();
}

class _DiakenScreenState extends State<DiakenScreen> {
  static const List<String> _bulanNama = DateHelper.bulanNamaShort;

  DateTime get _now => DateTime.now();
  String get _tanggalHariIni => DateHelper.formatShortDate(_now);

  // Navigation tab state
  _DiakenTab _activeTab = _DiakenTab.jemaat;

  // Backend Sync State
  bool _isLoadingBackend = false;
  bool _isBackendConnected = false;

  @override
  void initState() {
    super.initState();
    _loadDataFromBackend();
  }

  Future<void> _loadDataFromBackend() async {
    setState(() => _isLoadingBackend = true);
    try {
      final members = await ApiService.instance.fetchMembers();
      if (members.isNotEmpty && mounted) {
        setState(() {
          _listJemaat.clear();
          _listJemaat.addAll(members);
          _isBackendConnected = true;
        });
      }
    } catch (e) {
      debugPrint('[DiakenScreen] Sync error: $e');
    } finally {
      if (mounted) setState(() => _isLoadingBackend = false);
    }
  }

  // Search & Filter state for Data Jemaat
  final TextEditingController _searchController = TextEditingController();
  String _selectedSektorFilter = 'Semua Sektor';
  String _selectedStatusFilter = 'Semua Status';

  // Warta & Jadwal state
  JadwalPelayanDetail? _selectedJadwal;
  bool _showWartaPratinjau = false;

  // View Mode: 'jemaat' (Daftar Individu) vs 'keluarga' (Kartu Keluarga Digital)
  String _viewModeJemaat = 'jemaat';

  // Initial Mock Jemaat Data with Family Classification (GKPI Cimahi)
  final List<JemaatMember> _listJemaat = [
    JemaatMember(
      id: '1',
      noRegister: 'GKPI-001',
      namaLengkap: 'Bapak Martua Sirait',
      sektor: 'Sektor 1',
      status: 'Aktif',
      tglLahir: '14 Mar 1965',
      isBaptis: true,
      isSidi: true,
      isNikah: true,
      noKk: 'KK-001',
      namaKeluarga: 'Keluarga Bpk. Martua Sirait / Br. Hutabarat',
      hubunganKeluarga: 'Kepala Keluarga',
      isKepalaKeluarga: true,
      telepon: '0813-4455-6677',
      alamat: 'Jl. Kolonel Masturi No. 88, Cimahi',
      pekerjaan: 'Wiraswasta',
      jenisKelamin: 'L',
    ),
    JemaatMember(
      id: '2',
      noRegister: 'GKPI-002',
      namaLengkap: 'Ibu Rosmida Hutabarat',
      sektor: 'Sektor 1',
      status: 'Aktif',
      tglLahir: '22 Jul 1968',
      isBaptis: true,
      isSidi: true,
      isNikah: true,
      noKk: 'KK-001',
      namaKeluarga: 'Keluarga Bpk. Martua Sirait / Br. Hutabarat',
      hubunganKeluarga: 'Istri',
      isKepalaKeluarga: false,
      telepon: '0813-4455-6678',
      alamat: 'Jl. Kolonel Masturi No. 88, Cimahi',
      pekerjaan: 'PNS',
      jenisKelamin: 'P',
    ),
    JemaatMember(
      id: '8',
      noRegister: 'GKPI-008',
      namaLengkap: 'Ruli Manurung',
      sektor: 'Sektor 1',
      status: 'Aktif',
      tglLahir: '25 Des 1995',
      isBaptis: true,
      isSidi: true,
      isNikah: false,
      noKk: 'KK-001',
      namaKeluarga: 'Keluarga Bpk. Martua Sirait / Br. Hutabarat',
      hubunganKeluarga: 'Anak',
      isKepalaKeluarga: false,
      telepon: '0821-9876-5432',
      alamat: 'Jl. Kolonel Masturi No. 88, Cimahi',
      pekerjaan: 'IT Specialist',
      jenisKelamin: 'L',
    ),
    JemaatMember(
      id: '3',
      noRegister: 'GKPI-003',
      namaLengkap: 'Pdt. Saut Nainggolan',
      sektor: 'Sektor 2',
      status: 'Aktif',
      tglLahir: '05 Nov 1972',
      isBaptis: true,
      isSidi: true,
      isNikah: true,
      noKk: 'KK-002',
      namaKeluarga: 'Keluarga Pdt. Saut Nainggolan / Br. Simbolon',
      hubunganKeluarga: 'Kepala Keluarga',
      isKepalaKeluarga: true,
      telepon: '0812-1122-3344',
      alamat: 'Jl. Ibu Sangki No. 1, Cimahi',
      pekerjaan: 'Pendeta Resort',
      jenisKelamin: 'L',
    ),
    JemaatMember(
      id: '7',
      noRegister: 'GKPI-007',
      namaLengkap: 'Ev. Tiur Simbolon',
      sektor: 'Sektor 2',
      status: 'Aktif',
      tglLahir: '10 Feb 1980',
      isBaptis: true,
      isSidi: true,
      isNikah: true,
      noKk: 'KK-002',
      namaKeluarga: 'Keluarga Pdt. Saut Nainggolan / Br. Simbolon',
      hubunganKeluarga: 'Istri',
      isKepalaKeluarga: false,
      telepon: '0812-1122-3355',
      alamat: 'Jl. Ibu Sangki No. 1, Cimahi',
      pekerjaan: 'Guru Agama',
      jenisKelamin: 'P',
    ),
    JemaatMember(
      id: '11',
      noRegister: 'GKPI-011',
      namaLengkap: 'Samuel Nainggolan',
      sektor: 'Sektor 2',
      status: 'Aktif',
      tglLahir: '04 Mei 2002',
      isBaptis: true,
      isSidi: true,
      isNikah: false,
      noKk: 'KK-002',
      namaKeluarga: 'Keluarga Pdt. Saut Nainggolan / Br. Simbolon',
      hubunganKeluarga: 'Anak',
      isKepalaKeluarga: false,
      telepon: '0812-1122-3366',
      alamat: 'Jl. Ibu Sangki No. 1, Cimahi',
      pekerjaan: 'Mahasiswa',
      jenisKelamin: 'L',
    ),
    JemaatMember(
      id: '4',
      noRegister: 'GKPI-004',
      namaLengkap: 'Ester Simanjorang',
      sektor: 'Sektor 5',
      status: 'Aktif',
      tglLahir: '18 Agu 1998',
      isBaptis: true,
      isSidi: true,
      isNikah: false,
      noKk: 'KK-003',
      namaKeluarga: 'Keluarga Ester Simanjorang',
      hubunganKeluarga: 'Kepala Keluarga',
      isKepalaKeluarga: true,
      telepon: '0895-3344-5566',
      alamat: 'Jl. Amir Machmud No. 102, Cimahi',
      pekerjaan: 'Karyawan Swasta',
      jenisKelamin: 'P',
    ),
    JemaatMember(
      id: '12',
      noRegister: 'GKPI-012',
      namaLengkap: 'Grace Simanjorang',
      sektor: 'Sektor 5',
      status: 'Aktif',
      tglLahir: '19 Nov 2004',
      isBaptis: true,
      isSidi: true,
      isNikah: false,
      noKk: 'KK-003',
      namaKeluarga: 'Keluarga Ester Simanjorang',
      hubunganKeluarga: 'Anak',
      isKepalaKeluarga: false,
      telepon: '0895-3344-5577',
      alamat: 'Jl. Amir Machmud No. 102, Cimahi',
      pekerjaan: 'Pelajar',
      jenisKelamin: 'P',
    ),
    JemaatMember(
      id: '5',
      noRegister: 'GKPI-005',
      namaLengkap: 'St. H. Manurung',
      sektor: 'Sektor 3',
      status: 'Pindah',
      tglLahir: '12 Mei 1960',
      isBaptis: true,
      isSidi: true,
      isNikah: true,
      noKk: 'KK-004',
      namaKeluarga: 'Keluarga St. H. Manurung',
      hubunganKeluarga: 'Kepala Keluarga',
      isKepalaKeluarga: true,
      telepon: '0813-9988-7766',
      alamat: 'Jl. Cisangkan No. 15, Cimahi',
      pekerjaan: 'Pensiunan',
      jenisKelamin: 'L',
    ),
    JemaatMember(
      id: '9',
      noRegister: 'GKPI-009',
      namaLengkap: 'Marlina Tampubolon',
      sektor: 'Sektor 3',
      status: 'Aktif',
      tglLahir: '14 Sep 1992',
      isBaptis: true,
      isSidi: true,
      isNikah: true,
      noKk: 'KK-004',
      namaKeluarga: 'Keluarga St. H. Manurung',
      hubunganKeluarga: 'Istri',
      isKepalaKeluarga: false,
      telepon: '0812-7788-9900',
      alamat: 'Jl. Cisangkan No. 15, Cimahi',
      pekerjaan: 'Wirausaha',
      jenisKelamin: 'P',
    ),
    JemaatMember(
      id: '6',
      noRegister: 'GKPI-006',
      namaLengkap: 'Alm. O. Nainggolan',
      sektor: 'Sektor 4',
      status: 'Meninggal',
      tglLahir: '01 Jan 1945',
      isBaptis: true,
      isSidi: true,
      isNikah: true,
      noKk: 'KK-005',
      namaKeluarga: 'Keluarga Situmorang / Nainggolan',
      hubunganKeluarga: 'Kepala Keluarga',
      isKepalaKeluarga: true,
      telepon: '-',
      alamat: 'Jl. Mahar Martanegara No. 45, Cimahi',
      pekerjaan: '-',
      jenisKelamin: 'L',
    ),
    JemaatMember(
      id: '10',
      noRegister: 'GKPI-010',
      namaLengkap: 'Drs. Haposan Situmorang',
      sektor: 'Sektor 4',
      status: 'Aktif',
      tglLahir: '08 Mar 1967',
      isBaptis: true,
      isSidi: true,
      isNikah: true,
      noKk: 'KK-005',
      namaKeluarga: 'Keluarga Situmorang / Nainggolan',
      hubunganKeluarga: 'Famili / Lainnya',
      isKepalaKeluarga: false,
      telepon: '0813-1645-6835',
      alamat: 'Jl. Mahar Martanegara No. 45, Cimahi',
      pekerjaan: 'Akuntan',
      jenisKelamin: 'L',
    ),
  ];

  // Dynamic Family Classification getter
  List<KeluargaJemaat> get _listKeluarga {
    final Map<String, List<JemaatMember>> map = {};
    for (final j in _listJemaat) {
      final kk = j.noKk ?? 'KK-001';
      map.putIfAbsent(kk, () => []).add(j);
    }
    return map.entries.map((e) {
      final head = e.value.firstWhere(
        (m) => m.isKepalaKeluarga || m.hubunganKeluarga == 'Kepala Keluarga',
        orElse: () => e.value.first,
      );
      return KeluargaJemaat(
        id: e.key,
        noKk: e.key,
        namaKeluarga: head.namaKeluarga ?? 'Keluarga ${head.namaLengkap}',
        sektor: head.sektor,
        kepalaKeluarga: head.namaLengkap,
        alamat: head.alamat ?? 'Cimahi',
        telepon: head.telepon ?? '0812-xxxx-xxxx',
        jumlahAnggota: e.value.length,
        anggota: e.value,
      );
    }).toList();
  }

  // Dynamic Jadwal Pelayan data based on real-time DateTime
  List<JadwalPelayanDetail> get _listJadwalPelayan {
    final sun0 = DateHelper.getNextOrCurrentSunday();
    final sun1 = DateHelper.getSunday(1);
    final sun2 = DateHelper.getSunday(2);
    return [
      JadwalPelayanDetail(
        id: '1',
        tglBadge: DateHelper.formatBadgeDate(sun0),
        tglLengkap: DateHelper.formatFullDate(sun0),
        jenisIbadah: 'Ibadah Minggu Pagi',
        temaKhotbah: '"Kasih Kristus Yang Menguatkan"',
        bacaanAlkitab: 'Yohanes 15:9-17',
        pengkhotbah: 'Pdt. Saut Nainggolan',
        liturgos: 'Ev. Tiur Simbolon',
        songsLeader: 'Marlina Tampubolon',
        multimedia: 'Samuel Nainggolan',
        musisi: 'Ruli Manurung',
        diaken: 'Bapak Martua Sirait',
      ),
      JadwalPelayanDetail(
        id: '2',
        tglBadge: DateHelper.formatBadgeDate(sun1),
        tglLengkap: DateHelper.formatFullDate(sun1),
        jenisIbadah: 'Ibadah Minggu Pagi',
        temaKhotbah: '"Hiduplah Dalam Terang Terbuka"',
        bacaanAlkitab: 'Efesus 5:8-14',
        pengkhotbah: 'St. H. Manurung',
        liturgos: 'Ev. Tiur Simbolon',
        songsLeader: 'Ester Simanjorang',
        multimedia: 'Samuel Nainggolan',
        musisi: 'Ruli Manurung',
        diaken: 'Ibu Rosmida Hutabarat',
      ),
      JadwalPelayanDetail(
        id: '3',
        tglBadge: DateHelper.formatBadgeDate(sun2),
        tglLengkap: DateHelper.formatFullDate(sun2),
        jenisIbadah: 'Ibadah Ucapan Syukur',
        temaKhotbah: '"Merdeka Untuk Melayani"',
        bacaanAlkitab: 'Galasia 5:13-15',
        pengkhotbah: 'Pdt. Saut Nainggolan',
        liturgos: 'Drs. Haposan Situmorang',
        songsLeader: 'Marlina Tampubolon',
        multimedia: 'Samuel Nainggolan',
        musisi: 'Ruli Manurung',
        diaken: 'Bapak Martua Sirait',
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filtered List Jemaat getter
  List<JemaatMember> get _filteredJemaatList {
    return _listJemaat.where((item) {
      final q = _searchController.text.toLowerCase().trim();
      final matchQuery =
          q.isEmpty ||
          item.namaLengkap.toLowerCase().contains(q) ||
          item.noRegister.toLowerCase().contains(q);
      final matchSektor =
          _selectedSektorFilter == 'Semua Sektor' ||
          item.sektor == _selectedSektorFilter;
      final matchStatus =
          _selectedStatusFilter == 'Semua Status' ||
          item.status == _selectedStatusFilter;
      return matchQuery && matchSektor && matchStatus;
    }).toList();
  }

  // Filtered List Kartu Keluarga getter
  List<KeluargaJemaat> get _filteredKeluargaList {
    return _listKeluarga.where((kk) {
      final q = _searchController.text.toLowerCase().trim();
      final matchQuery = q.isEmpty ||
          kk.namaKeluarga.toLowerCase().contains(q) ||
          kk.noKk.toLowerCase().contains(q) ||
          kk.kepalaKeluarga.toLowerCase().contains(q) ||
          kk.anggota.any((m) => m.namaLengkap.toLowerCase().contains(q));
      final matchSektor = _selectedSektorFilter == 'Semua Sektor' ||
          kk.sektor == _selectedSektorFilter;
      return matchQuery && matchSektor;
    }).toList();
  }

  // Counts
  int get _countTotal => _listJemaat.length;
  int get _countAktif => _listJemaat.where((j) => j.status == 'Aktif').length;
  int get _countPindah => _listJemaat.where((j) => j.status == 'Pindah').length;
  int get _countMeninggal =>
      _listJemaat.where((j) => j.status == 'Meninggal').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: _buildAppBar(context),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildRoleBannerBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeSlideAnimation(
                      duration: const Duration(milliseconds: 500),
                      child: _buildHeaderHeroCard(),
                    ),
                    const SizedBox(height: 12),
                    _buildUserRoleProfileBar(),
                    const SizedBox(height: 16),

                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 120),
                      child: _buildSegmentedTabSelector(),
                    ),
                    const SizedBox(height: 16),

                    if (_activeTab == _DiakenTab.jemaat) ...[
                      FadeSlideAnimation(
                        delay: const Duration(milliseconds: 200),
                        child: _buildJemaatContent(context),
                      ),
                    ] else ...[
                      FadeSlideAnimation(
                        delay: const Duration(milliseconds: 200),
                        child: _buildWartaJadwalView(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleOnTap(
        child: FloatingActionButton.extended(
          onPressed: () {
            if (_activeTab == _DiakenTab.jemaat) {
              _showTambahJemaatDialog();
            } else {
              _showTambahJadwalDialog();
            }
          },
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add, size: 22),
          label: Text(
            _activeTab == _DiakenTab.jemaat
                ? 'Tambah Jemaat'
                : 'Tambah Jadwal',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 3,
        ),
      ),
    );
  }

  Widget _buildRoleBannerBar() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF59E0B), // Diaken Orange hint
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.shield_outlined, color: Colors.white, size: 13),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              'Anda masuk sebagai Divisi Diaken — akses dibatasi sesuai peran',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
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
            backgroundColor: Color(0xFFF59E0B),
            child: Text(
              'B',
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
                  'Bapak Martua Sirait',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  'Divisi Diaken',
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
              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.shield_outlined,
                  size: 12,
                  color: Color(0xFFF59E0B),
                ),
                SizedBox(width: 4),
                Text(
                  'Diaken',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // APP BAR (Matching Sekretaris & Bendahara Screen)
  // ─────────────────────────────────────────────────────────────────────────────
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
                  'G-SERVE Diaken',
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
                      '$_tanggalHariIni · GKPI Cimahi',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isBackendConnected
                            ? const Color(0xFF4ADE80)
                            : Colors.amberAccent,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isBackendConnected ? 'Live' : 'Offline',
                      style: TextStyle(
                        color: _isBackendConnected
                            ? const Color(0xFF86EFAC)
                            : Colors.amberAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
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
          onPressed: _isLoadingBackend ? null : _loadDataFromBackend,
          icon: _isLoadingBackend
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  Icons.sync,
                  color: _isBackendConnected
                      ? const Color(0xFF4ADE80)
                      : Colors.white70,
                  size: 22,
                ),
          tooltip: _isBackendConnected
              ? 'Backend Terhubung (Klik untuk sinkronkan)'
              : 'Sinkronkan dengan Backend',
        ),
        IconButton(
          onPressed: _showHelpDialog,
          icon: const Icon(Icons.help_outline, color: Colors.white, size: 22),
          tooltip: 'Bantuan Diaken',
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

  // ─────────────────────────────────────────────────────────────────────────────
  // HERO BANNER CARD (Identical style to Sekretaris & Bendahara Screen)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildHeaderHeroCard() {
    IconData heroIcon;
    String heroTitle;
    String heroSubtitle;
    String heroBadge;

    if (_activeTab == _DiakenTab.jemaat) {
      heroIcon = Icons.group_work_outlined;
      heroTitle = 'Divisi Diaken';
      heroSubtitle = 'Kam, ${_now.day} ${_bulanNama[_now.month - 1]} ${_now.year}';
      heroBadge = '$_countTotal Jemaat';
    } else {
      heroIcon = Icons.menu_book_outlined;
      heroTitle = 'Warta & Jadwal';
      heroSubtitle = 'Jadwal pelayan & warta ibadah';
      heroBadge = '${_listJadwalPelayan.length} Jadwal';
    }

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
      child: Row(
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
            child: Icon(heroIcon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  heroTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  heroSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              heroBadge,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SEGMENTED TAB SELECTOR
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildSegmentedTabSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildSegmentedTabItem(
            _DiakenTab.jemaat,
            Icons.people_alt_outlined,
            'Data Jemaat',
          ),
          _buildSegmentedTabItem(
            _DiakenTab.wartaJadwal,
            Icons.article_outlined,
            'Warta & Jadwal',
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabItem(
    _DiakenTab tab,
    IconData icon,
    String label,
  ) {
    final isSelected = _activeTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppTheme.textGrey,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppTheme.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // TAB 1 CONTENT: DATA JEMAAT
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildJemaatContent(BuildContext context) {
    final filtered = _filteredJemaatList;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title & Excel Action row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data Jemaat',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$_countAktif aktif dari $_countTotal jemaat terdaftar',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: _showImportExcelDialog,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textDark,
                side: const BorderSide(color: AppTheme.borderGrey),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.white,
              ),
              icon: const Icon(
                Icons.upload_file_outlined,
                size: 16,
                color: AppTheme.textGrey,
              ),
              label: const Text('Import Excel', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // View Mode Switcher: Daftar Individu vs Kartu Keluarga Digital
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderGrey),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _viewModeJemaat = 'jemaat'),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _viewModeJemaat == 'jemaat'
                          ? AppTheme.primaryBlue
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 15,
                          color: _viewModeJemaat == 'jemaat'
                              ? Colors.white
                              : AppTheme.textDark,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Daftar Jemaat (${_listJemaat.length})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _viewModeJemaat == 'jemaat'
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: _viewModeJemaat == 'jemaat'
                                  ? Colors.white
                                  : AppTheme.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _viewModeJemaat = 'keluarga'),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _viewModeJemaat == 'keluarga'
                          ? AppTheme.primaryBlue
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.family_restroom,
                          size: 15,
                          color: _viewModeJemaat == 'keluarga'
                              ? Colors.white
                              : AppTheme.textDark,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Kartu Keluarga (${_listKeluarga.length})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _viewModeJemaat == 'keluarga'
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: _viewModeJemaat == 'keluarga'
                                  ? Colors.white
                                  : AppTheme.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 3 Stat Cards in Bendahara / Sekretaris style
        if (_viewModeJemaat == 'keluarga')
          Row(
            children: [
              Expanded(
                child: _buildRefinedStatCard(
                  title: 'Total KK',
                  value: '${_listKeluarga.length}',
                  icon: Icons.family_restroom,
                  iconBgColor: const Color(0xFFEFF6FF),
                  iconColor: const Color(0xFF1D4ED8),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildRefinedStatCard(
                  title: 'Total Jiwa',
                  value: '$_countTotal',
                  icon: Icons.people_alt_outlined,
                  iconBgColor: const Color(0xFFDCFCE7),
                  iconColor: const Color(0xFF166534),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildRefinedStatCard(
                  title: 'Sektor',
                  value: '5 Sektor',
                  icon: Icons.grid_view,
                  iconBgColor: const Color(0xFFFEF3C7),
                  iconColor: const Color(0xFF92400E),
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: _buildRefinedStatCard(
                  title: 'Aktif',
                  value: '$_countAktif',
                  icon: Icons.check_circle_outline,
                  iconBgColor: const Color(0xFFDCFCE7),
                  iconColor: const Color(0xFF166534),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildRefinedStatCard(
                  title: 'Pindah',
                  value: '$_countPindah',
                  icon: Icons.swap_horiz,
                  iconBgColor: const Color(0xFFFEF3C7),
                  iconColor: const Color(0xFF92400E),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildRefinedStatCard(
                  title: 'Meninggal',
                  value: '$_countMeninggal',
                  icon: Icons.sentiment_dissatisfied_outlined,
                  iconBgColor: const Color(0xFFF1F5F9),
                  iconColor: const Color(0xFF475569),
                ),
              ),
            ],
          ),
        const SizedBox(height: 16),

        // Search & Filters Box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderGrey),
          ),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Cari nama atau no. register...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  fillColor: AppTheme.backgroundGrey,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundGrey,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.borderGrey),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSektorFilter,
                          isExpanded: true,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textDark),
                          items: [
                            'Semua Sektor',
                            'Sektor 1',
                            'Sektor 2',
                            'Sektor 3',
                            'Sektor 4',
                            'Sektor 5',
                          ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedSektorFilter = val);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundGrey,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.borderGrey),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedStatusFilter,
                          isExpanded: true,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textDark),
                          items: [
                            'Semua Status',
                            'Aktif',
                            'Pindah',
                            'Meninggal',
                          ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedStatusFilter = val);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // List Content: Kartu Keluarga vs Daftar Jemaat Mobile Cards
        if (_viewModeJemaat == 'keluarga')
          _buildKartuKeluargaView()
        else if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            child: const Column(
              children: [
                Icon(Icons.search_off, size: 48, color: AppTheme.textGrey),
                SizedBox(height: 12),
                Text(
                  'Tidak ada data jemaat yang ditemukan',
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
                ),
              ],
            ),
          )
        else
          ...filtered.map((item) => _buildJemaatMobileCard(item)),
      ],
    );
  }

  Widget _buildRefinedStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.textGrey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DIGITAL KARTU KELUARGA (KK) COMPONENTS
  // ---------------------------------------------------------------------------
  Widget _buildKartuKeluargaView() {
    final list = _filteredKeluargaList;
    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: const Column(
          children: [
            Icon(Icons.family_restroom, size: 48, color: AppTheme.textGrey),
            SizedBox(height: 12),
            Text(
              'Tidak ada data Kartu Keluarga ditemukan',
              style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
            ),
          ],
        ),
      );
    }
    return Column(
      children: list.map((kk) => _buildKeluargaCard(kk)).toList(),
    );
  }

  Widget _buildKeluargaCard(KeluargaJemaat kk) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: No KK badge + Sektor + Detail KK Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.assignment_ind, size: 13, color: AppTheme.primaryBlue),
                        const SizedBox(width: 4),
                        Text(
                          kk.noKk,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundGrey,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderGrey),
                    ),
                    child: Text(
                      kk.sektor,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _showDetailKeluargaDialog(kk),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.lightBlueCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.visibility_outlined, size: 14, color: AppTheme.primaryBlue),
                      SizedBox(width: 4),
                      Text(
                        'Detail KK',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Nama Keluarga
          Text(
            kk.namaKeluarga,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),

          // Kepala Keluarga
          Row(
            children: [
              const Icon(Icons.workspace_premium, size: 15, color: Color(0xFFD97706)),
              const SizedBox(width: 6),
              const Text(
                'Kepala: ',
                style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
              ),
              Expanded(
                child: Text(
                  kk.kepalaKeluarga,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${kk.jumlahAnggota} Jiwa',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF166534),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Alamat
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 15, color: AppTheme.textGrey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  kk.alamat,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Anggota Keluarga List Preview
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.backgroundGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Anggota Keluarga:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textGrey,
                  ),
                ),
                const SizedBox(height: 6),
                ...kk.anggota.map((m) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: Row(
                    children: [
                      Icon(
                        m.jenisKelamin == 'P' ? Icons.female : Icons.male,
                        size: 14,
                        color: AppTheme.textGrey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          m.namaLengkap,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      _buildHubunganBadge(m.hubunganKeluarga, m.isKepalaKeluarga),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailKeluargaDialog(KeluargaJemaat kk) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.family_restroom, color: AppTheme.primaryBlue, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kk.namaKeluarga,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${kk.noKk} • ${kk.sektor}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Kepala Keluarga', kk.kepalaKeluarga),
                  _buildDetailRow('Alamat', kk.alamat),
                  _buildDetailRow('No. Telepon', kk.telepon),
                  _buildDetailRow('Jumlah Anggota', '${kk.jumlahAnggota} Jiwa'),
                  const SizedBox(height: 14),
                  const Text(
                    'Daftar Anggota Keluarga Terdaftar:',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...kk.anggota.map((m) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundGrey,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.borderGrey),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                m.namaLengkap,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildHubunganBadge(m.hubunganKeluarga, m.isKepalaKeluarga),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 10,
                          runSpacing: 4,
                          children: [
                            Text(
                              'Reg: ${m.noRegister}',
                              style: const TextStyle(fontSize: 11, color: AppTheme.primaryBlue),
                            ),
                            Text(
                              'Lahir: ${m.tglLahir}',
                              style: const TextStyle(fontSize: 11, color: AppTheme.textGrey),
                            ),
                            if (m.pekerjaan != null && m.pekerjaan != '-')
                              Text(
                                'Profesi: ${m.pekerjaan}',
                                style: const TextStyle(fontSize: 11, color: AppTheme.textGrey),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          children: [
                            if (m.isBaptis) _buildSakramenBadge('✓ Baptis'),
                            if (m.isSidi) _buildSakramenBadge('✓ Sidi'),
                            if (m.isNikah) _buildSakramenBadge('✓ Nikah'),
                          ],
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHubunganBadge(String? hubungan, bool isHead) {
    final h = hubungan ?? (isHead ? 'Kepala Keluarga' : 'Anggota');
    Color bg;
    Color fg;
    IconData icon;

    switch (h) {
      case 'Kepala Keluarga':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        icon = Icons.workspace_premium;
        break;
      case 'Istri':
        bg = const Color(0xFFFCE7F3);
        fg = const Color(0xFFBE185D);
        icon = Icons.favorite_rounded;
        break;
      case 'Anak':
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0369A1);
        icon = Icons.person_outline;
        break;
      default:
        bg = const Color(0xFFF3E8FF);
        fg = const Color(0xFF7E22CE);
        icon = Icons.people_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 4),
          Text(
            h,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
          ),
        ],
      ),
    );
  }

  Widget _buildJemaatMobileCard(JemaatMember item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Register No & Status Badge & KK Identifier
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    item.noRegister,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  if (item.noKk != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.noKk!,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              _buildStatusBadge(item.status),
            ],
          ),
          const SizedBox(height: 8),

          // Nama Lengkap + Hubungan Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  item.namaLengkap,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _buildHubunganBadge(item.hubunganKeluarga, item.isKepalaKeluarga),
            ],
          ),
          const SizedBox(height: 8),

          // Sektor & Tgl Lahir
          Row(
            children: [
              const Icon(Icons.grid_view, size: 14, color: AppTheme.textGrey),
              const SizedBox(width: 4),
              Text(
                item.sektor,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.cake_outlined, size: 14, color: AppTheme.textGrey),
              const SizedBox(width: 4),
              Text(
                item.tglLahir,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Sakramen Badges & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (item.isBaptis) _buildSakramenBadge('✓ Baptis'),
                    if (item.isSidi) _buildSakramenBadge('✓ Sidi'),
                    if (item.isNikah) _buildSakramenBadge('✓ Nikah'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined, size: 18, color: AppTheme.primaryBlue),
                    onPressed: () => _showDetailJemaatDialog(item),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFFD97706)),
                    onPressed: () => _showEditJemaatDialog(item),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.buttonRed),
                    onPressed: () => _showDeleteJemaatDialog(item),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    if (status == 'Aktif') {
      bg = const Color(0xFFDCFCE7);
      text = const Color(0xFF166534);
    } else if (status == 'Pindah') {
      bg = const Color(0xFFFEF3C7);
      text = const Color(0xFF92400E);
    } else {
      bg = const Color(0xFFF1F5F9);
      text = const Color(0xFF475569);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: text,
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSakramenBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF1D4ED8),
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WARTA & JADWAL VIEW (MATCHING SEKRETARIS SCREEN)
  // ---------------------------------------------------------------------------
  Widget _buildWartaJadwalView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Description
        const Text(
          'Warta & Jadwal',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Jadwal pelayan ibadah & warta jemaat',
          style: TextStyle(fontSize: 13, color: AppTheme.textGrey),
        ),
        const SizedBox(height: 16),

        // Action Buttons row (Tambah Warta, Pratinjau Warta, Cetak)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: _openTambahWartaModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.post_add_outlined, size: 16),
                label: const Text(
                  'Tambah Warta',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () =>
                    setState(() => _showWartaPratinjau = !_showWartaPratinjau),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _showWartaPratinjau
                      ? AppTheme.primaryBlue
                      : AppTheme.textDark,
                  side: BorderSide(
                    color: _showWartaPratinjau
                        ? AppTheme.primaryBlue
                        : AppTheme.borderGrey,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: _showWartaPratinjau
                      ? AppTheme.lightBlueCard
                      : Colors.white,
                ),
                icon: Icon(
                  _showWartaPratinjau
                      ? Icons.visibility
                      : Icons.visibility_outlined,
                  size: 16,
                ),
                label: Text(
                  _showWartaPratinjau ? 'Sembunyikan' : 'Pratinjau Warta',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur cetak/export akan segera tersedia.'),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textDark,
                  side: const BorderSide(color: AppTheme.borderGrey),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.white,
                ),
                icon: const Icon(
                  Icons.print_outlined,
                  size: 16,
                  color: AppTheme.textGrey,
                ),
                label: const Text('Cetak', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Pratinjau Warta Jemaat (shown when toggled)
        if (_showWartaPratinjau) ...[
          _buildWartaPratinjauCard(),
          const SizedBox(height: 20),
        ],

        // Daftar Jadwal Section
        Row(
          children: [
            const Text(
              'DAFTAR JADWAL',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: AppTheme.primaryBlue,
              ),
            ),
            const Spacer(),
            Text(
              '${_listJadwalPelayan.length} jadwal',
              style: const TextStyle(fontSize: 11.5, color: AppTheme.textGrey),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (_listJadwalPelayan.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderGrey),
            ),
            child: Column(
              children: const [
                Icon(Icons.calendar_month_outlined, size: 40, color: AppTheme.textGrey),
                SizedBox(height: 8),
                Text(
                  'Belum ada jadwal pelayan. Klik "+ Tambah Jadwal".',
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _listJadwalPelayan.length,
            separatorBuilder: (_, i) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final jadwal = _listJadwalPelayan[index];
              final isSelected = _selectedJadwal?.id == jadwal.id;
              return _buildJadwalBadgeCard(jadwal, isSelected);
            },
          ),

        // Detail Jadwal Terpilih
        if (_selectedJadwal != null) ...[
          const SizedBox(height: 20),
          _buildDetailJadwalCard(_selectedJadwal!),
        ],
      ],
    );
  }

  Widget _buildJadwalBadgeCard(JadwalPelayanDetail jadwal, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedJadwal = isSelected ? null : jadwal),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : AppTheme.borderGrey,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    jadwal.tglBadge.split(' ').first,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white70 : AppTheme.textGrey,
                    ),
                  ),
                  Text(
                    jadwal.tglBadge.split(' ').last,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    jadwal.jenisIbadah,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    jadwal.tglLengkap,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white70 : AppTheme.textGrey,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    jadwal.pengkhotbah,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isSelected ? Colors.white60 : AppTheme.textGrey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Icon(
                  isSelected
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: isSelected ? Colors.white : AppTheme.textGrey,
                  size: 20,
                ),
                const SizedBox(height: 4),
                IconButton(
                  onPressed: () {
                    _showConfirmDeleteDialog(
                      title: 'Hapus Jadwal',
                      message:
                          'Apakah Anda yakin ingin menghapus jadwal "${jadwal.jenisIbadah}" (${jadwal.tglBadge})?',
                      onConfirm: () {
                        setState(() {
                          if (_selectedJadwal?.id == jadwal.id) {
                            _selectedJadwal = null;
                          }
                          _listJadwalPelayan.removeWhere((x) => x.id == jadwal.id);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Jadwal ${jadwal.tglBadge} dihapus.'),
                            backgroundColor: AppTheme.buttonRed,
                          ),
                        );
                      },
                    );
                  },
                  icon: Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: isSelected ? Colors.white60 : AppTheme.textGrey,
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailJadwalCard(JadwalPelayanDetail jadwal) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primaryBlue, AppTheme.secondaryBlue],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jadwal.jenisIbadah,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        jadwal.tglLengkap,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur edit jadwal akan segera tersedia.'),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Edit', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailInfoRow(
                        Icons.church_outlined,
                        'Tema Khotbah',
                        jadwal.temaKhotbah,
                      ),
                      const SizedBox(height: 8),
                      _buildDetailInfoRow(
                        Icons.menu_book_outlined,
                        'Bacaan Alkitab',
                        jadwal.bacaanAlkitab,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'PELAYAN IBADAH',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textGrey,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2.8,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _buildPelayanChip(
                      Icons.mic_outlined,
                      'Pengkhotbah',
                      jadwal.pengkhotbah,
                    ),
                    _buildPelayanChip(
                      Icons.book_outlined,
                      'Liturgos',
                      jadwal.liturgos,
                    ),
                    _buildPelayanChip(
                      Icons.music_note_outlined,
                      'Songs Leader',
                      jadwal.songsLeader,
                    ),
                    _buildPelayanChip(
                      Icons.tv_outlined,
                      'Multimedia',
                      jadwal.multimedia,
                    ),
                    _buildPelayanChip(
                      Icons.piano_outlined,
                      'Musisi',
                      jadwal.musisi,
                    ),
                    _buildPelayanChip(
                      Icons.volunteer_activism_outlined,
                      'Diaken',
                      jadwal.diaken,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryBlue),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPelayanChip(IconData icon, String peran, String nama) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryBlue),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  peran,
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: AppTheme.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  nama,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWartaPratinjauCard() {
    final jadwal =
        _selectedJadwal ??
        (_listJadwalPelayan.isNotEmpty ? _listJadwalPelayan.first : null);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4A017), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4A017).withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF1A3A6B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Column(
              children: [
                const Text(
                  'GEREJA KRISTEN PROTESTAN INDONESIA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
                const Text(
                  'GKPI CIMAHI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Container(height: 1, color: Colors.white24),
                const SizedBox(height: 4),
                const Text(
                  'WARTA JEMAAT',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (jadwal != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFBFD0FF)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'JADWAL IBADAH MINGGU INI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text(
                              'Tanggal:',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textGrey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              jadwal.tglLengkap,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text(
                              'Tema:',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textGrey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                jadwal.temaKhotbah,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text(
                              'Bacaan:',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textGrey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              jadwal.bacaanAlkitab,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'PELAYAN IBADAH',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildWartaPelayanRow('Pengkhotbah', jadwal.pengkhotbah),
                  _buildWartaPelayanRow('Liturgos', jadwal.liturgos),
                  _buildWartaPelayanRow('Songs Leader', jadwal.songsLeader),
                  _buildWartaPelayanRow('Multimedia', jadwal.multimedia),
                  _buildWartaPelayanRow('Musisi', jadwal.musisi),
                  _buildWartaPelayanRow('Diaken', jadwal.diaken),
                ] else ...[
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Pilih jadwal untuk pratinjau warta',
                        style: TextStyle(color: AppTheme.textGrey),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Container(height: 1, color: AppTheme.borderGrey),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    '"Kiranya Allah, sumber pengharapan, memenuhi kamu dengan segala sukacita dan damai sejahtera." — Roma 15:13',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.textGrey,
                      fontStyle: FontStyle.italic,
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

  Widget _buildWartaPelayanRow(String peran, String nama) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              peran,
              style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
            ),
          ),
          const Text(': ', style: TextStyle(color: AppTheme.textGrey)),
          Expanded(
            child: Text(
              nama,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INTERACTIVE DIALOGS FOR DATA JEMAAT
  // ---------------------------------------------------------------------------
  void _showTambahJemaatDialog() {
    final formKey = GlobalKey<FormState>();
    final noRegCtrl = TextEditingController(
      text: 'GKPI-0${_listJemaat.length + 1}',
    );
    final namaCtrl = TextEditingController();
    final tglCtrl = TextEditingController();
    String sektorVal = 'Sektor 1';
    String statusVal = 'Aktif';
    bool baptisVal = true;
    bool sidiVal = true;
    bool nikahVal = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              title: const Row(
                children: [
                  Icon(Icons.person_add_alt_1, color: Color(0xFF1E6091)),
                  SizedBox(width: 10),
                  Text(
                    'Tambah Data Jemaat Baru',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 440,
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NO. REGISTER',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textGrey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: noRegCtrl,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 14),

                        const Text(
                          'NAMA LENGKAP',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textGrey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: namaCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Contoh: Bapak Saut Manurung',
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'SEKTOR',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    initialValue: sektorVal,
                                    items:
                                        [
                                              'Sektor 1',
                                              'Sektor 2',
                                              'Sektor 3',
                                              'Sektor 4',
                                              'Sektor 5',
                                            ]
                                            .map(
                                              (s) => DropdownMenuItem(
                                                value: s,
                                                child: Text(s),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (v) =>
                                        setModalState(() => sektorVal = v!),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'STATUS',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    initialValue: statusVal,
                                    items: ['Aktif', 'Pindah', 'Meninggal']
                                        .map(
                                          (s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(s),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) =>
                                        setModalState(() => statusVal = v!),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        const Text(
                          'TANGGAL LAHIR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textGrey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: tglCtrl,
                          decoration: const InputDecoration(
                            hintText: 'e.g. 15 Mei 1985',
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          'STATUS SAKRAMEN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textGrey,
                          ),
                        ),
                        CheckboxListTile(
                          dense: true,
                          title: const Text('Telah Dibaptis'),
                          value: baptisVal,
                          onChanged: (v) =>
                              setModalState(() => baptisVal = v ?? true),
                        ),
                        CheckboxListTile(
                          dense: true,
                          title: const Text('Telah Sidi'),
                          value: sidiVal,
                          onChanged: (v) =>
                              setModalState(() => sidiVal = v ?? true),
                        ),
                        CheckboxListTile(
                          dense: true,
                          title: const Text('Telah Menikah'),
                          value: nikahVal,
                          onChanged: (v) =>
                              setModalState(() => nikahVal = v ?? false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E6091),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final newMember = JemaatMember(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        noRegister: noRegCtrl.text.trim(),
                        namaLengkap: namaCtrl.text.trim(),
                        sektor: sektorVal,
                        status: statusVal,
                        tglLahir: tglCtrl.text.trim(),
                        isBaptis: baptisVal,
                        isSidi: sidiVal,
                        isNikah: nikahVal,
                      );
                      setState(() {
                        _listJemaat.insert(0, newMember);
                      });
                      ApiService.instance.createMember(newMember.toJson());
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Berhasil menambahkan ${namaCtrl.text.trim()}',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text('Simpan Jemaat'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditJemaatDialog(JemaatMember item) {
    final formKey = GlobalKey<FormState>();
    final noRegCtrl = TextEditingController(text: item.noRegister);
    final namaCtrl = TextEditingController(text: item.namaLengkap);
    final tglCtrl = TextEditingController(text: item.tglLahir);
    String sektorVal = item.sektor;
    String statusVal = item.status;
    bool baptisVal = item.isBaptis;
    bool sidiVal = item.isSidi;
    bool nikahVal = item.isNikah;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              title: Row(
                children: [
                  const Icon(Icons.edit_note, color: Color(0xFFD97706)),
                  const SizedBox(width: 10),
                  Text(
                    'Edit Data ${item.namaLengkap}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 440,
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NO. REGISTER',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textGrey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: noRegCtrl,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 14),

                        const Text(
                          'NAMA LENGKAP',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textGrey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: namaCtrl,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'SEKTOR',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    initialValue: sektorVal,
                                    items:
                                        [
                                              'Sektor 1',
                                              'Sektor 2',
                                              'Sektor 3',
                                              'Sektor 4',
                                              'Sektor 5',
                                            ]
                                            .map(
                                              (s) => DropdownMenuItem(
                                                value: s,
                                                child: Text(s),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (v) =>
                                        setModalState(() => sektorVal = v!),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'STATUS',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    initialValue: statusVal,
                                    items: ['Aktif', 'Pindah', 'Meninggal']
                                        .map(
                                          (s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(s),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) =>
                                        setModalState(() => statusVal = v!),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        const Text(
                          'TANGGAL LAHIR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textGrey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: tglCtrl,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          'STATUS SAKRAMEN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textGrey,
                          ),
                        ),
                        CheckboxListTile(
                          dense: true,
                          title: const Text('Telah Dibaptis'),
                          value: baptisVal,
                          onChanged: (v) =>
                              setModalState(() => baptisVal = v ?? true),
                        ),
                        CheckboxListTile(
                          dense: true,
                          title: const Text('Telah Sidi'),
                          value: sidiVal,
                          onChanged: (v) =>
                              setModalState(() => sidiVal = v ?? true),
                        ),
                        CheckboxListTile(
                          dense: true,
                          title: const Text('Telah Menikah'),
                          value: nikahVal,
                          onChanged: (v) =>
                              setModalState(() => nikahVal = v ?? false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final updated = JemaatMember(
                        id: item.id,
                        noRegister: noRegCtrl.text.trim(),
                        namaLengkap: namaCtrl.text.trim(),
                        sektor: sektorVal,
                        status: statusVal,
                        tglLahir: tglCtrl.text.trim(),
                        isBaptis: baptisVal,
                        isSidi: sidiVal,
                        isNikah: nikahVal,
                      );
                      setState(() {
                        final index = _listJemaat.indexWhere(
                          (j) => j.id == item.id,
                        );
                        if (index != -1) {
                          _listJemaat[index] = updated;
                        }
                      });
                      ApiService.instance.updateMember(item.id, updated.toJson());
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Perubahan data ${namaCtrl.text.trim()} disimpan',
                          ),
                          backgroundColor: Colors.blueAccent,
                        ),
                      );
                    }
                  },
                  child: const Text('Simpan Perubahan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDetailJemaatDialog(JemaatMember item) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Row(
            children: [
              const Icon(Icons.badge_outlined, color: Color(0xFF1E6091)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.namaLengkap,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('No. Register', item.noRegister),
                  if (item.noKk != null) _buildDetailRow('No. KK', item.noKk!),
                  _buildDetailRow('Hubungan Keluarga', item.hubunganKeluarga),
                  if (item.namaKeluarga != null)
                    _buildDetailRow('Nama Keluarga', item.namaKeluarga!),
                  _buildDetailRow('Sektor', item.sektor),
                  _buildDetailRow('Status Keanggotaan', item.status),
                  _buildDetailRow('Tanggal Lahir', item.tglLahir),
                  if (item.pekerjaan != null && item.pekerjaan != '-')
                    _buildDetailRow('Pekerjaan', item.pekerjaan!),
                  if (item.telepon != null && item.telepon != '-')
                    _buildDetailRow('No. Telepon', item.telepon!),
                  if (item.alamat != null)
                    _buildDetailRow('Alamat', item.alamat!),
                  const SizedBox(height: 12),
                  const Text(
                    'Sakramen Gerejawi:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textGrey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (item.isBaptis) _buildSakramenBadge('✓ Baptis'),
                      if (item.isSidi) _buildSakramenBadge('✓ Sidi'),
                      if (item.isNikah) _buildSakramenBadge('✓ Nikah'),
                    ],
                  ),
                  // Household members sharing same KK
                  if (item.noKk != null &&
                      _listJemaat.any((j) => j.noKk == item.noKk && j.id != item.id)) ...[
                    const SizedBox(height: 14),
                    const Divider(),
                    const SizedBox(height: 6),
                    Text(
                      'Anggota Serumah (${item.noKk}):',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._listJemaat
                        .where((j) => j.noKk == item.noKk && j.id != item.id)
                        .map((other) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3.0),
                              child: Row(
                                children: [
                                  Icon(
                                    other.jenisKelamin == 'P' ? Icons.female : Icons.male,
                                    size: 14,
                                    color: AppTheme.textGrey,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      other.namaLengkap,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                  ),
                                  _buildHubunganBadge(
                                    other.hubunganKeluarga,
                                    other.isKepalaKeluarga,
                                  ),
                                ],
                              ),
                            )),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12.5, color: AppTheme.textGrey),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteJemaatDialog(JemaatMember item) {
    _showConfirmDeleteDialog(
      title: 'Hapus Data Jemaat',
      message:
          'Apakah Anda yakin ingin menghapus data ${item.namaLengkap} (${item.noRegister})?',
      onConfirm: () {
        final memberId = item.id;
        setState(() {
          _listJemaat.removeWhere((j) => j.id == memberId);
        });
        ApiService.instance.deleteMember(memberId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data ${item.namaLengkap} telah dihapus'),
            backgroundColor: AppTheme.buttonRed,
          ),
        );
      },
    );
  }

  void _showImportExcelDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Row(
            children: [
              Icon(Icons.file_upload_outlined, color: Color(0xFF1E6091)),
              SizedBox(width: 10),
              Text(
                'Import Data Jemaat via Excel',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFCBD5E1),
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 40,
                      color: Color(0xFF1E6091),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Pilih atau tarik file Excel (.xlsx / .csv) ke sini',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Format kolom: NoRegister, Nama, Sektor, Status, TglLahir',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E6091),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('File Excel berhasil di-import (Simulasi)'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Unggah & Import'),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFFF59E0B)),
              SizedBox(width: 8),
              Text('Panduan Peran Diaken'),
            ],
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Peran Diaken dikhususkan untuk mengelola data jemaat gereja.',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                SizedBox(height: 10),
                Text('Fitur Utama Divisi Diaken:'),
                SizedBox(height: 6),
                Text('• Pengelolaan Data Jemaat (Tambah, Edit, Detail, Hapus)'),
                Text('• Import Data Jemaat dari Excel (.xlsx)'),
                Text('• Filter menurut Sektor & Status Keanggotaan'),
                Text('• Pantau Penugasan Diaken di Warta & Jadwal Ibadah'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Mengerti'),
            ),
          ],
        );
      },
    );
  }

  void _showTambahJadwalDialog() {
    _openTambahWartaModal();
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

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
      filled: true,
      fillColor: AppTheme.backgroundGrey,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.borderGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.borderGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
      ),
    );
  }

  void _openTambahWartaModal() {
    final edisiController = TextEditingController(
      text: 'Warta Minggu, ${_now.day + 7} ${_bulanNama[_now.month - 1]} ${_now.year}',
    );
    final tglController = TextEditingController(
      text: 'Minggu, ${_now.day + 7} ${_bulanNama[_now.month - 1]} ${_now.year}',
    );
    final tglBadgeController = TextEditingController(
      text: 'AGU ${_now.day + 7}',
    );
    String jenisIbadah = 'Ibadah Minggu Pagi';
    final temaController = TextEditingController();
    final bacaanController = TextEditingController();
    final pengkhotbahController = TextEditingController(text: 'Pdt. Saut Nainggolan');
    final liturgosController = TextEditingController(text: 'Ev. Tiur Simbolon');
    final songsLeaderController = TextEditingController(text: 'Marlina Tampubolon');
    final multimediaController = TextEditingController(text: 'Ruli Manurung');
    final musisiController = TextEditingController(text: 'Jonatan Purba');
    final diakenController = TextEditingController(text: 'Bapak Martua Sirait');
    final isiWartaController = TextEditingController(
      text: 'Informasi dan warta pelayanan jemaat GKPI Cimahi.',
    );

    bool isFileUploaded = false;
    String fileName = 'Document_Warta_${_now.day + 7}_${_now.month}.pdf';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.borderGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.post_add_outlined, color: AppTheme.primaryBlue, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Tambah Warta Jemaat',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppTheme.textGrey),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppTheme.borderGrey),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: edisiController,
                            decoration: _fieldDecoration('Edisi / Judul Warta').copyWith(
                              hintText: 'e.g. Warta Minggu 17 Agustus 2025',
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: tglBadgeController,
                                  decoration: _fieldDecoration('Badge Tgl').copyWith(
                                    hintText: 'e.g. AGU 17',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: tglController,
                                  decoration: _fieldDecoration('Tanggal Lengkap').copyWith(
                                    hintText: 'e.g. Minggu, 17 Agustus 2025',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            initialValue: jenisIbadah,
                            decoration: _fieldDecoration('Jenis Ibadah'),
                            items: [
                              'Ibadah Minggu Pagi',
                              'Ibadah Minggu Sore',
                              'Ibadah Sekolah Minggu',
                              'Ibadah Pemuda',
                            ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() => jenisIbadah = val);
                              }
                            },
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: temaController,
                            decoration: _fieldDecoration('Tema Khotbah').copyWith(
                              hintText: 'e.g. "Kasih Kristus Yang Menguatkan"',
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: bacaanController,
                            decoration: _fieldDecoration('Bacaan Alkitab').copyWith(
                              hintText: 'e.g. Yohanes 15:9-17',
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: pengkhotbahController,
                                  decoration: _fieldDecoration('Pengkhotbah'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: liturgosController,
                                  decoration: _fieldDecoration('Liturgos'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: songsLeaderController,
                                  decoration: _fieldDecoration('Songs Leader'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: multimediaController,
                                  decoration: _fieldDecoration('Multimedia'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: musisiController,
                                  decoration: _fieldDecoration('Musisi'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: diakenController,
                                  decoration: _fieldDecoration('Diaken'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: isiWartaController,
                            maxLines: 3,
                            decoration: _fieldDecoration('Ringkasan / Isi Warta').copyWith(
                              hintText: 'Tuliskan pengumuman atau catatan warta jemaat...',
                            ),
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            'LAMPIRAN FILE WARTA',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textGrey,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () {
                              setModalState(() {
                                isFileUploaded = !isFileUploaded;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isFileUploaded
                                    ? const Color(0xFFDCFCE7)
                                    : AppTheme.backgroundGrey,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isFileUploaded
                                      ? const Color(0xFF166534)
                                      : AppTheme.borderGrey,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isFileUploaded
                                        ? Icons.check_circle_outline
                                        : Icons.upload_file_outlined,
                                    color: isFileUploaded
                                        ? const Color(0xFF166534)
                                        : AppTheme.primaryBlue,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isFileUploaded
                                              ? 'File Warta Diterima: $fileName'
                                              : 'Upload Dokumen Warta (.pdf / .docx)',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.bold,
                                            color: isFileUploaded
                                                ? const Color(0xFF166534)
                                                : AppTheme.textDark,
                                          ),
                                        ),
                                        Text(
                                          isFileUploaded
                                              ? 'Klik untuk mengganti file'
                                              : 'Pilih file warta jemaat dari perangkat Anda',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isFileUploaded
                                                ? const Color(0xFF166534).withValues(alpha: 0.8)
                                                : AppTheme.textGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: AppTheme.borderGrey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final newJadwal = JadwalPelayanDetail(
                                id: 'JDW-00${_listJadwalPelayan.length + 1}',
                                tglBadge: tglBadgeController.text.trim().isNotEmpty
                                    ? tglBadgeController.text.trim()
                                    : DateHelper.formatBadgeDate(DateHelper.getNextOrCurrentSunday()),
                                tglLengkap: tglController.text.trim().isNotEmpty
                                    ? tglController.text.trim()
                                    : DateHelper.formatFullDate(DateHelper.getNextOrCurrentSunday()),
                                jenisIbadah: jenisIbadah,
                                temaKhotbah: temaController.text.trim().isNotEmpty
                                    ? '"${temaController.text.trim()}"'
                                    : '"Hidup Dalam Terang Firman"',
                                bacaanAlkitab: bacaanController.text.trim().isNotEmpty
                                    ? bacaanController.text.trim()
                                    : 'Mazmur 119:105-112',
                                pengkhotbah: pengkhotbahController.text.trim(),
                                liturgos: liturgosController.text.trim(),
                                songsLeader: songsLeaderController.text.trim(),
                                multimedia: multimediaController.text.trim(),
                                musisi: musisiController.text.trim(),
                                diaken: diakenController.text.trim(),
                              );
                              setState(() {
                                _listJadwalPelayan.insert(0, newJadwal);
                                _selectedJadwal = newJadwal;
                                _showWartaPratinjau = true;
                              });
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Warta "${edisiController.text.trim()}" berhasil ditambahkan!',
                                  ),
                                  backgroundColor: const Color(0xFF166534),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Simpan Warta',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
