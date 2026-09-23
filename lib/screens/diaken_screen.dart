import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/animations.dart';

enum _DiakenTab { jemaat, wartaJadwal }

class DiakenScreen extends StatefulWidget {
  final VoidCallback? onLogout;

  const DiakenScreen({super.key, this.onLogout});

  @override
  State<DiakenScreen> createState() => _DiakenScreenState();
}

class _DiakenScreenState extends State<DiakenScreen> {
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

  static const _hariNama = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  DateTime get _now => DateTime.now();
  String get _tanggalHariIni => _fmtTanggalRaw(_now);

  static String _fmtTanggalRaw(DateTime d) =>
      '${_hariNama[d.weekday - 1]}, ${d.day} ${_bulanNama[d.month - 1]} ${d.year}';

  // Navigation tab state
  _DiakenTab _activeTab = _DiakenTab.jemaat;

  // Search & Filter state for Data Jemaat
  final TextEditingController _searchController = TextEditingController();
  String _selectedSektorFilter = 'Semua Sektor';
  String _selectedStatusFilter = 'Semua Status';

  // Initial Mock Jemaat Data (12 Jemaat)
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
    ),
  ];

  // Mock Jadwal Pelayan data
  final List<JadwalPelayanDetail> _listJadwalPelayan = [
    JadwalPelayanDetail(
      id: '1',
      tglBadge: 'AGU 3',
      tglLengkap: 'Minggu, 3 Agustus 2025',
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
      tglBadge: 'AGU 10',
      tglLengkap: 'Minggu, 10 Agustus 2025',
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
      tglBadge: 'AGU 17',
      tglLengkap: 'Minggu, 17 Agustus 2025',
      jenisIbadah: 'Ibadah Kemerdekaan RI',
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

  // Counts
  int get _countTotal => _listJemaat.length;
  int get _countAktif => _listJemaat.where((j) => j.status == 'Aktif').length;
  int get _countPindah => _listJemaat.where((j) => j.status == 'Pindah').length;
  int get _countMeninggal =>
      _listJemaat.where((j) => j.status == 'Meninggal').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: FloatingActionButton(
        onPressed: _showHelpDialog,
        backgroundColor: const Color(0xFF1E293B),
        mini: true,
        tooltip: 'Bantuan Divisi Diaken',
        child: const Icon(Icons.help_outline, color: Colors.white, size: 20),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top Amber Role Alert Banner
            _buildTopBanner(),

            // Main Content Body with Sidebar & Body Area
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 900;
                  if (isDesktop) {
                    return Row(
                      children: [
                        _buildSidebar(isDesktop: true),
                        Expanded(
                          child: Column(
                            children: [
                              _buildTopBarHeader(isDesktop: true),
                              Expanded(child: _buildMainContentArea()),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Scaffold(
                      appBar: AppBar(
                        backgroundColor: AppTheme.primaryBlue,
                        title: Row(
                          children: [
                            const Icon(Icons.group_work_outlined, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _activeTab == _DiakenTab.jemaat
                                  ? 'Data Jemaat'
                                  : 'Warta & Jadwal',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      drawer: Drawer(child: _buildSidebar(isDesktop: false)),
                      body: Column(
                        children: [
                          _buildTopBarHeader(isDesktop: false),
                          Expanded(child: _buildMainContentArea()),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TOP AMBER NOTICE BANNER
  // ---------------------------------------------------------------------------
  Widget _buildTopBanner() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF59E0B), // Vibrant Orange / Amber
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'Anda masuk sebagai Divisi Diaken \u2014 akses dibatasi sesuai peran',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TOP NAVBAR HEADER
  // ---------------------------------------------------------------------------
  Widget _buildTopBarHeader({required bool isDesktop}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Screen Title & Date Subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _activeTab == _DiakenTab.jemaat
                    ? 'Data Jemaat'
                    : 'Warta & Jadwal',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),

          // Date & User Profile Pill
          Row(
            children: [
              if (isDesktop) ...[
                Text(
                  _tanggalHariIni,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppTheme.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 20),
              ],

              // User Info Avatar
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'B',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (isDesktop)
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bapak Martua Sirait',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          'Divisi Diaken',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LEFT SIDEBAR NAVIGATION
  // ---------------------------------------------------------------------------
  Widget _buildSidebar({required bool isDesktop}) {
    return Container(
      width: 250,
      color: const Color(0xFF0F294A), // Deep Navy Blue
      child: Column(
        children: [
          // Sidebar Header Brand
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.church,
                      color: AppTheme.primaryBlue,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'G-SERVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'GKPI Cimahi',
                        style: TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // PERAN Active Badge Card (Orange Amber Gradient)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Text(
                    'PERAN',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Divisi Diaken',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Navigation Menu Options
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildSidebarMenuItem(
                  tab: _DiakenTab.jemaat,
                  icon: Icons.group_outlined,
                  label: 'Data Jemaat',
                ),
                const SizedBox(height: 6),
                _buildSidebarMenuItem(
                  tab: _DiakenTab.wartaJadwal,
                  icon: Icons.menu_book_outlined,
                  label: 'Warta & Jadwal',
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white12, height: 1),

          // Sidebar Bottom Profile & Logout Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'B',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bapak Martua Sirait',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Divisi Diaken',
                        style: TextStyle(color: Colors.white54, fontSize: 10.5),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white70,
                    size: 18,
                  ),
                  tooltip: 'Keluar Peran',
                  onPressed: widget.onLogout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarMenuItem({
    required _DiakenTab tab,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _activeTab == tab;

    return BouncyPress(
      onTap: () {
        setState(() {
          _activeTab = tab;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E6091) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MAIN CONTENT ROUTER
  // ---------------------------------------------------------------------------
  Widget _buildMainContentArea() {
    return AnimatedSwitcherSlide(
      child: _activeTab == _DiakenTab.jemaat
          ? _buildDataJemaatView()
          : _buildWartaJadwalView(),
    );
  }

  // ---------------------------------------------------------------------------
  // DATA JEMAAT VIEW
  // ---------------------------------------------------------------------------
  Widget _buildDataJemaatView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Subtitle + Top Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data Jemaat',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_countAktif aktif dari $_countTotal jemaat terdaftar',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ],
              ),

              // Action Buttons: Import Excel & + Tambah Jemaat
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _showImportExcelDialog,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.textDark,
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.file_upload_outlined, size: 18),
                    label: const Text(
                      'Import Excel',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showTambahJemaatDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E6091),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      'Tambah Jemaat',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 3 Metric Summary Cards Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 700;
              return Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                children: [
                  Expanded(
                    flex: isWide ? 1 : 0,
                    child: _buildMetricCard(
                      icon: Icons.person_outline,
                      count: _countAktif.toString(),
                      label: 'Aktif',
                      bgColor: const Color(0xFFECFDF5),
                      borderColor: const Color(0xFFA7F3D0),
                      iconBgColor: const Color(0xFFD1FAE5),
                      textColor: const Color(0xFF059669),
                    ),
                  ),
                  SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 12),
                  Expanded(
                    flex: isWide ? 1 : 0,
                    child: _buildMetricCard(
                      icon: Icons.person_remove_outlined,
                      count: _countPindah.toString(),
                      label: 'Pindah',
                      bgColor: const Color(0xFFFEF3C7),
                      borderColor: const Color(0xFFFDE68A),
                      iconBgColor: const Color(0xFFFDE68A),
                      textColor: const Color(0xFFD97706),
                    ),
                  ),
                  SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 12),
                  Expanded(
                    flex: isWide ? 1 : 0,
                    child: _buildMetricCard(
                      icon: Icons.person_off_outlined,
                      count: _countMeninggal.toString(),
                      label: 'Meninggal',
                      bgColor: const Color(0xFFF1F5F9),
                      borderColor: const Color(0xFFCBD5E1),
                      iconBgColor: const Color(0xFFE2E8F0),
                      textColor: const Color(0xFF475569),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          // Search & Filters Box Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 750;
                return Flex(
                  direction: isWide ? Axis.horizontal : Axis.vertical,
                  children: [
                    // Search text field
                    Expanded(
                      flex: isWide ? 2 : 0,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Cari nama atau no. register...',
                          prefixIcon: Icon(Icons.search, size: 20),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          isDense: true,
                          fillColor: Color(0xFFF8FAFC),
                        ),
                      ),
                    ),
                    SizedBox(width: isWide ? 12 : 0, height: isWide ? 0 : 10),

                    // Dropdown Sektor
                    Expanded(
                      flex: isWide ? 1 : 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSektorFilter,
                            isExpanded: true,
                            items:
                                [
                                  'Semua Sektor',
                                  'Sektor 1',
                                  'Sektor 2',
                                  'Sektor 3',
                                  'Sektor 4',
                                  'Sektor 5',
                                ].map((s) {
                                  return DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      s,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedSektorFilter = val);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isWide ? 12 : 0, height: isWide ? 0 : 10),

                    // Dropdown Status
                    Expanded(
                      flex: isWide ? 1 : 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStatusFilter,
                            isExpanded: true,
                            items:
                                [
                                  'Semua Status',
                                  'Aktif',
                                  'Pindah',
                                  'Meninggal',
                                ].map((st) {
                                  return DropdownMenuItem(
                                    value: st,
                                    child: Text(
                                      st,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedStatusFilter = val);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Jemaat Table Container
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFFF8FAFC),
                ),
                dataRowMinHeight: 58,
                dataRowMaxHeight: 58,
                horizontalMargin: 20,
                columnSpacing: 24,
                columns: const [
                  DataColumn(
                    label: Text(
                      'NO. REGISTER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'NAMA LENGKAP',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'SEKTOR',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'STATUS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'TGL. LAHIR',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'SAKRAMEN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'AKSI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ),
                ],
                rows: _filteredJemaatList.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(
                        InkWell(
                          onTap: () => _showDetailJemaatDialog(item),
                          child: Text(
                            item.noRegister,
                            style: const TextStyle(
                              color: Color(0xFF1E6091),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          item.namaLengkap,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          item.sektor,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ),
                      DataCell(_buildStatusBadge(item.status)),
                      DataCell(
                        Text(
                          item.tglLahir,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ),
                      DataCell(
                        Wrap(
                          spacing: 6,
                          children: [
                            if (item.isBaptis) _buildSakramenBadge('✓ Baptis'),
                            if (item.isSidi) _buildSakramenBadge('✓ Sidi'),
                            if (item.isNikah) _buildSakramenBadge('✓ Nikah'),
                          ],
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.visibility_outlined,
                                size: 18,
                                color: Color(0xFF1E6091),
                              ),
                              tooltip: 'Detail Jemaat',
                              onPressed: () => _showDetailJemaatDialog(item),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: Color(0xFFD97706),
                              ),
                              tooltip: 'Edit Data',
                              onPressed: () => _showEditJemaatDialog(item),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Colors.redAccent,
                              ),
                              tooltip: 'Hapus Data',
                              onPressed: () => _showDeleteJemaatDialog(item),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // METRIC SUMMARY CARD BUILDER
  // ---------------------------------------------------------------------------
  Widget _buildMetricCard({
    required IconData icon,
    required String count,
    required String label,
    required Color bgColor,
    required Color borderColor,
    required Color iconBgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: textColor, size: 22),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: textColor.withValues(alpha: 0.8),
                ),
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
  // WARTA & JADWAL VIEW (FOR DIAKEN)
  // ---------------------------------------------------------------------------
  Widget _buildWartaJadwalView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Warta & Jadwal Ibadah',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Jadwal penugasan pelayan & informasi warta jemaat',
            style: TextStyle(fontSize: 13, color: AppTheme.textGrey),
          ),
          const SizedBox(height: 20),

          // Schedule List Cards
          ..._listJadwalPelayan.map((j) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          j.tglBadge,
                          style: const TextStyle(
                            color: Color(0xFFD97706),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          j.jenisIbadah,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      Text(
                        j.tglLengkap,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tema: ${j.temaKhotbah}',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Bacaan Alkitab: ${j.bacaanAlkitab}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppTheme.textGrey,
                    ),
                  ),
                  const Divider(height: 24),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _buildDutyChip('Pengkhotbah', j.pengkhotbah),
                      _buildDutyChip('Liturgos', j.liturgos),
                      _buildDutyChip('Diaken', j.diaken, isHighlight: true),
                      _buildDutyChip('Musisi', j.musisi),
                      _buildDutyChip('Song Leader', j.songsLeader),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDutyChip(String role, String name, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHighlight
              ? const Color(0xFFFDE68A)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: AppTheme.textDark),
          children: [
            TextSpan(
              text: '$role: ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isHighlight
                    ? const Color(0xFFD97706)
                    : AppTheme.textGrey,
              ),
            ),
            TextSpan(
              text: name,
              style: TextStyle(
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
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
                      setState(() {
                        _listJemaat.insert(
                          0,
                          JemaatMember(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            noRegister: noRegCtrl.text.trim(),
                            namaLengkap: namaCtrl.text.trim(),
                            sektor: sektorVal,
                            status: statusVal,
                            tglLahir: tglCtrl.text.trim(),
                            isBaptis: baptisVal,
                            isSidi: sidiVal,
                            isNikah: nikahVal,
                          ),
                        );
                      });
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
                      setState(() {
                        final index = _listJemaat.indexWhere(
                          (j) => j.id == item.id,
                        );
                        if (index != -1) {
                          _listJemaat[index] = JemaatMember(
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
                        }
                      });
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
              Text(
                item.namaLengkap,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('No. Register', item.noRegister),
              _buildDetailRow('Sektor', item.sektor),
              _buildDetailRow('Status Keanggotaan', item.status),
              _buildDetailRow('Tanggal Lahir', item.tglLahir),
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
            ],
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12.5, color: AppTheme.textGrey),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteJemaatDialog(JemaatMember item) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus data ${item.namaLengkap} (${item.noRegister})?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                setState(() {
                  _listJemaat.removeWhere((j) => j.id == item.id);
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Data ${item.namaLengkap} telah dihapus'),
                  ),
                );
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
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
}
