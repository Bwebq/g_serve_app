import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/animations.dart';
import '../utils/date_helper.dart';

enum _MultimediaTab { absensiJadwal, timMultimedia, inventaris, wartaLiturgi }

class MultimediaScreen extends StatefulWidget {
  final VoidCallback? onLogout;

  const MultimediaScreen({super.key, this.onLogout});

  @override
  State<MultimediaScreen> createState() => _MultimediaScreenState();
}

class _MultimediaScreenState extends State<MultimediaScreen> {
  _MultimediaTab _activeTab = _MultimediaTab.absensiJadwal;
  String _searchQuery = '';
  String _selectedKondisiFilter = 'Semua Kondisi';

  // Backend Sync State
  bool _isLoadingBackend = false;
  bool _isBackendConnected = false;

  // ---------------------------------------------------------------------------
  // JADWAL & ABSENSI MULTIMEDIA DATA (With Check-in & Substitution)
  // ---------------------------------------------------------------------------
  late List<MultimediaSchedule> _listSchedules;

  @override
  void initState() {
    super.initState();
    _loadFromBackend();
    final sun0 = DateHelper.getNextOrCurrentSunday();
    final sun1 = DateHelper.getSunday(1);

    _listSchedules = [
      MultimediaSchedule(
        id: 'SCH-MM-01',
        serviceDate: DateHelper.formatFullDate(sun0),
        serviceType: 'Ibadah Minggu Pagi (09:00 WIB)',
        theme: '"Kasih Kristus Yang Menguatkan"',
        officers: [
          MultimediaDutyOfficer(
            id: 'OFF-01',
            serviceId: 'SCH-MM-01',
            dutyTitle: 'Operator PPT Layar 1 (EasyWorship)',
            officerName: 'Ruli Manurung',
            attendanceStatus: 'PRESENT',
            attendanceTime: '08:15 WIB',
          ),
          MultimediaDutyOfficer(
            id: 'OFF-02',
            serviceId: 'SCH-MM-01',
            dutyTitle: 'Operator Layar 2 & OBS Live Streaming',
            officerName: 'Andre Siregar',
            attendanceStatus: 'SCHEDULED',
          ),
          MultimediaDutyOfficer(
            id: 'OFF-03',
            serviceId: 'SCH-MM-01',
            dutyTitle: 'Sound Engineering & Audio Mixer',
            officerName: 'Daniel Sitorus',
            attendanceStatus: 'REPLACED',
            replacementOfficerName: 'Gita Nababan',
            replacementReason: 'Sakit demam & istirahat di rumah',
            replacedAt: '29 Sep 2026, 18:30 WIB',
          ),
          MultimediaDutyOfficer(
            id: 'OFF-04',
            serviceId: 'SCH-MM-01',
            dutyTitle: 'Kameramen & Switcher Video',
            officerName: 'Samuel Hutapea',
            attendanceStatus: 'SCHEDULED',
          ),
        ],
      ),
      MultimediaSchedule(
        id: 'SCH-MM-02',
        serviceDate: DateHelper.formatFullDate(sun1),
        serviceType: 'Ibadah Minggu Pagi (09:00 WIB)',
        theme: '"Hidup Dalam Terang Firman"',
        officers: [
          MultimediaDutyOfficer(
            id: 'OFF-05',
            serviceId: 'SCH-MM-02',
            dutyTitle: 'Operator PPT Layar 1 (EasyWorship)',
            officerName: 'Gita Nababan',
            attendanceStatus: 'SCHEDULED',
          ),
          MultimediaDutyOfficer(
            id: 'OFF-06',
            serviceId: 'SCH-MM-02',
            dutyTitle: 'Operator Layar 2 & OBS Live Streaming',
            officerName: 'Ruli Manurung',
            attendanceStatus: 'SCHEDULED',
          ),
          MultimediaDutyOfficer(
            id: 'OFF-07',
            serviceId: 'SCH-MM-02',
            dutyTitle: 'Sound Engineering & Audio Mixer',
            officerName: 'Andre Siregar',
            attendanceStatus: 'SCHEDULED',
          ),
        ],
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // TIM MULTIMEDIA DATA
  // ---------------------------------------------------------------------------
  final List<MinistryMember> _listMembers = [
    MinistryMember(
      id: 'MM-001',
      division: 'multimedia',
      name: 'Ruli Manurung',
      roleTitle: 'Koordinator & Operator PPT',
      phone: '0821-9876-5432',
      notes: 'Penanggung Jawab Teknis Multimedia',
      isActive: true,
    ),
    MinistryMember(
      id: 'MM-002',
      division: 'multimedia',
      name: 'Andre Siregar',
      roleTitle: 'Streaming & OBS Specialist',
      phone: '0812-4455-6677',
      notes: 'Teknisi Siaran Langsung YouTube',
      isActive: true,
    ),
    MinistryMember(
      id: 'MM-003',
      division: 'multimedia',
      name: 'Daniel Sitorus',
      roleTitle: 'Sound Engineer & Audio',
      phone: '0857-3322-1144',
      notes: 'Operator Mixer Audio Behringer',
      isActive: true,
    ),
    MinistryMember(
      id: 'MM-004',
      division: 'multimedia',
      name: 'Gita Nababan',
      roleTitle: 'Kameramen & Visual Support',
      phone: '0813-8899-0011',
      notes: 'Operator Kamera Panggung',
      isActive: true,
    ),
    MinistryMember(
      id: 'MM-005',
      division: 'multimedia',
      name: 'Samuel Hutapea',
      roleTitle: 'Switcher & Lighting',
      phone: '0822-7766-5544',
      notes: 'Operator ATEM Mini Video Switcher',
      isActive: true,
    ),
  ];

  // ---------------------------------------------------------------------------
  // INVENTARIS MULTIMEDIA (Scoped strictly to Multimedia)
  // ---------------------------------------------------------------------------
  final List<InventarisItem> _listInventaris = [
    InventarisItem(
      id: 'AST-MM01',
      kode: 'MM-001',
      namaAset: 'Kamera Mirrorless Sony Alpha A6400 (Kit Lens)',
      lokasi: 'Balkon Multimedia Lantai 2',
      jumlah: 2,
      kondisi: 'Baik',
      status: 'Tersedia',
      division: 'multimedia',
      category: 'Kamera & Video',
    ),
    InventarisItem(
      id: 'AST-MM02',
      kode: 'MM-002',
      namaAset: 'PC Streaming Core i7 RTX 4060 32GB RAM',
      lokasi: 'Ruang Kontrol Multimedia',
      jumlah: 1,
      kondisi: 'Baik',
      status: 'Tersedia',
      division: 'multimedia',
      category: 'Komputer & Server',
    ),
    InventarisItem(
      id: 'AST-MM03',
      kode: 'MM-003',
      namaAset: 'Proyektor Epson EB-2250U 5000 Lumens',
      lokasi: 'Plafon Tengah & Panggung Gereja',
      jumlah: 2,
      kondisi: 'Baik',
      status: 'Tersedia',
      division: 'multimedia',
      category: 'Proyektor & Layar',
    ),
    InventarisItem(
      id: 'AST-MM04',
      kode: 'MM-004',
      namaAset: 'Video Switcher Blackmagic ATEM Mini Pro',
      lokasi: 'Ruang Kontrol Multimedia',
      jumlah: 1,
      kondisi: 'Baik',
      status: 'Tersedia',
      division: 'multimedia',
      category: 'Video Switcher',
    ),
    InventarisItem(
      id: 'AST-MM05',
      kode: 'MM-005',
      namaAset: 'Kabel HDMI Fiber Optic 30 Meter 4K',
      lokasi: 'Saluran Kabel Plafon',
      jumlah: 3,
      kondisi: 'Baik',
      status: 'Tersedia',
      division: 'multimedia',
      category: 'Kabel & Aksesoris',
    ),
    InventarisItem(
      id: 'AST-MM06',
      kode: 'MM-006',
      namaAset: 'Capture Card Elgato Cam Link 4K',
      lokasi: 'Ruang Kontrol Multimedia',
      jumlah: 2,
      kondisi: 'Perbaikan',
      status: 'Tersedia',
      division: 'multimedia',
      category: 'Aksesoris Video',
    ),
    InventarisItem(
      id: 'AST-MM07',
      kode: 'MM-007',
      namaAset: 'Splitter HDMI 1x4 4K Powered',
      lokasi: 'Rak Server Multimedia',
      jumlah: 2,
      kondisi: 'Baik',
      status: 'Tersedia',
      division: 'multimedia',
      category: 'Distribusi Video',
    ),
  ];

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
                    _buildTabSwitcher(),
                    const SizedBox(height: 16),
                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 150),
                      child: _buildActiveTabContent(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _activeTab == _MultimediaTab.timMultimedia
          ? ScaleOnTap(
              child: FloatingActionButton.extended(
                onPressed: _showTambahMemberDialog,
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                icon: const Icon(Icons.person_add, size: 20),
                label: const Text(
                  'Tambah Anggota MM',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                elevation: 3,
              ),
            )
          : _activeTab == _MultimediaTab.inventaris
              ? ScaleOnTap(
                  child: FloatingActionButton.extended(
                    onPressed: _showTambahInventarisDialog,
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text(
                      'Tambah Aset MM',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    elevation: 3,
                  ),
                )
              : null,
    );
  }

  Widget _buildRoleBannerBar() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0284C7),
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.tv, color: Colors.white, size: 14),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              'Anda masuk sebagai Divisi Multimedia — Absensi Petugas, Livestreaming & Inventaris IT',
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
            backgroundColor: Color(0xFF0284C7),
            child: Text(
              'R',
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
                  'Ruli Manurung',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  'Koordinator Divisi Multimedia & IT',
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
              color: const Color(0xFF0284C7).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.connected_tv, size: 13, color: Color(0xFF0284C7)),
                SizedBox(width: 4),
                Text(
                  'Multimedia',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadFromBackend() async {
    setState(() => _isLoadingBackend = true);
    try {
      final members = await ApiService.instance.fetchMinistryMembers(division: 'multimedia');
      if (members.isNotEmpty && mounted) {
        setState(() {
          _listMembers.clear();
          _listMembers.addAll(members);
          _isBackendConnected = true;
        });
      }
      final assets = await ApiService.instance.fetchAssets(division: 'multimedia');
      if (assets.isNotEmpty && mounted) {
        setState(() {
          _listInventaris.clear();
          _listInventaris.addAll(assets);
          _isBackendConnected = true;
        });
      }
    } catch (e) {
      debugPrint('[MultimediaScreen] Sync error: $e');
    } finally {
      if (mounted) setState(() => _isLoadingBackend = false);
    }
  }

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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.connected_tv_outlined, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'G-SERVE Mobile',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Divisi Multimedia',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                  const SizedBox(width: 6),
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
        ],
      ),
      actions: [
        IconButton(
          onPressed: _isLoadingBackend ? null : _loadFromBackend,
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
          onPressed: () {
            if (widget.onLogout != null) {
              widget.onLogout!();
            } else {
              Navigator.pop(context);
            }
          },
          tooltip: 'Keluar',
          icon: const Icon(Icons.logout, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeaderHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0369A1), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.broadcast_on_personal, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Sistem Pelayanan Multimedia',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Absensi petugas ibadah, pengelolaan live streaming, pergantian pelayan, dan inventaris perangkat digital.',
            style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatChip(
                icon: Icons.check_circle_outline,
                label: 'Absensi Terintegrasi',
              ),
              _buildStatChip(
                icon: Icons.videocam_outlined,
                label: '${_listInventaris.length} Aset Digital',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _tabButton(
              title: 'Absensi MM',
              icon: Icons.assignment_turned_in_outlined,
              isActive: _activeTab == _MultimediaTab.absensiJadwal,
              onTap: () => setState(() => _activeTab = _MultimediaTab.absensiJadwal),
            ),
          ),
          Expanded(
            child: _tabButton(
              title: 'Tim MM',
              icon: Icons.people_outline,
              isActive: _activeTab == _MultimediaTab.timMultimedia,
              onTap: () => setState(() => _activeTab = _MultimediaTab.timMultimedia),
            ),
          ),
          Expanded(
            child: _tabButton(
              title: 'Inventaris',
              icon: Icons.video_camera_back_outlined,
              isActive: _activeTab == _MultimediaTab.inventaris,
              onTap: () => setState(() => _activeTab = _MultimediaTab.inventaris),
            ),
          ),
          Expanded(
            child: _tabButton(
              title: 'Warta',
              icon: Icons.book_outlined,
              isActive: _activeTab == _MultimediaTab.wartaLiturgi,
              onTap: () => setState(() => _activeTab = _MultimediaTab.wartaLiturgi),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required String title,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0284C7) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? Colors.white : AppTheme.textGrey,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? Colors.white : AppTheme.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(BuildContext context) {
    switch (_activeTab) {
      case _MultimediaTab.absensiJadwal:
        return _buildAbsensiJadwalContent(context);
      case _MultimediaTab.timMultimedia:
        return _buildTimMultimediaContent(context);
      case _MultimediaTab.inventaris:
        return _buildInventarisContent(context);
      case _MultimediaTab.wartaLiturgi:
        return _buildWartaLiturgiContent(context);
    }
  }

  // ---------------------------------------------------------------------------
  // TAB 1: ABSENSI & JADWAL MULTIMEDIA (Check-in & Substitution)
  // ---------------------------------------------------------------------------
  Widget _buildAbsensiJadwalContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Absensi & Petugas Ibadah',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            Text(
              'Realtime GKPI',
              style: TextStyle(
                fontSize: 11.5,
                color: Color(0xFF0284C7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Lakukan check-in kehadiran atau ajukan pergantian pelayan jika berhalangan.',
          style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
        ),
        const SizedBox(height: 14),
        ..._listSchedules.map((schedule) => _buildScheduleCard(context, schedule)),
      ],
    );
  }

  Widget _buildScheduleCard(BuildContext context, MultimediaSchedule schedule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.borderGrey),
        ),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      schedule.serviceType,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0369A1),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    schedule.serviceDate,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                schedule.theme,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 14),
              const Divider(color: AppTheme.borderGrey, height: 1),
              const SizedBox(height: 12),
              const Text(
                'PETUGAS MULTIMEDIA BERTUGAS:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textGrey,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              ...schedule.officers.map((officer) => _buildOfficerRow(context, officer)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfficerRow(BuildContext context, MultimediaDutyOfficer officer) {
    Color statusBg;
    Color statusText;
    String statusLabel;
    IconData statusIcon;

    if (officer.attendanceStatus == 'PRESENT') {
      statusBg = const Color(0xFFDCFCE7);
      statusText = const Color(0xFF15803D);
      statusLabel = 'HADIR';
      statusIcon = Icons.check_circle;
    } else if (officer.attendanceStatus == 'REPLACED') {
      statusBg = const Color(0xFFFEF3C7);
      statusText = const Color(0xFFB45309);
      statusLabel = 'DIGANTIKAN';
      statusIcon = Icons.swap_horiz;
    } else {
      statusBg = const Color(0xFFE0F2FE);
      statusText = const Color(0xFF0369A1);
      statusLabel = 'TERJADWAL';
      statusIcon = Icons.schedule;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: officer.attendanceStatus == 'PRESENT'
              ? const Color(0xFF86EFAC)
              : AppTheme.borderGrey,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      officer.dutyTitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0369A1),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      officer.officerName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: statusText),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: statusText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (officer.attendanceStatus == 'REPLACED' &&
              officer.replacementOfficerName != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 14, color: Color(0xFFB45309)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Digantikan oleh: ${officer.replacementOfficerName} • Alasan: "${officer.replacementReason ?? '-'}"',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF92400E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 6,
            children: [
              // Button: Toggle Check-in (Hadir)
              OutlinedButton.icon(
                onPressed: () => _toggleCheckIn(officer),
                icon: Icon(
                  officer.attendanceStatus == 'PRESENT'
                      ? Icons.cancel_outlined
                      : Icons.check_circle_outline,
                  size: 14,
                ),
                label: Text(
                  officer.attendanceStatus == 'PRESENT' ? 'Batalkan Hadir' : 'Check-In Hadir',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: officer.attendanceStatus == 'PRESENT'
                      ? AppTheme.textGrey
                      : const Color(0xFF15803D),
                  side: BorderSide(
                    color: officer.attendanceStatus == 'PRESENT'
                        ? AppTheme.borderGrey
                        : const Color(0xFF86EFAC),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              // Button: Ganti Petugas / Substitusi
              ElevatedButton.icon(
                onPressed: () => _showSubstitusiDialog(officer),
                icon: const Icon(Icons.swap_horiz, size: 14),
                label: const Text(
                  'Ganti Petugas',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleCheckIn(MultimediaDutyOfficer officer) {
    setState(() {
      if (officer.attendanceStatus == 'PRESENT') {
        officer.attendanceStatus = 'SCHEDULED';
        officer.attendanceTime = null;
      } else {
        officer.attendanceStatus = 'PRESENT';
        final now = DateTime.now();
        officer.attendanceTime =
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB';
      }
    });

    ApiService.instance.checkInOfficer(officer.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          officer.attendanceStatus == 'PRESENT'
              ? 'Check-in berhasil: ${officer.officerName} telah hadir!'
              : 'Status kehadiran ${officer.officerName} diubah ke Terjadwal.',
        ),
        backgroundColor: officer.attendanceStatus == 'PRESENT'
            ? const Color(0xFF15803D)
            : AppTheme.primaryBlue,
      ),
    );
  }

  void _showSubstitusiDialog(MultimediaDutyOfficer officer) {
    final nameCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.swap_horiz, color: Color(0xFF0284C7)),
            SizedBox(width: 8),
            Text('Pergantian Petugas MM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tugas: ${officer.dutyTitle}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0369A1)),
              ),
              Text(
                'Petugas Awal: ${officer.officerName}',
                style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Petugas Pengganti',
                  hintText: 'Contoh: Gita Nababan',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(
                  labelText: 'Alasan Pergantian',
                  hintText: 'Contoh: Sakit flu, dinas luar kota, izin keluarga',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty || reasonCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama pengganti & alasan wajib diisi!')),
                );
                return;
              }

              setState(() {
                officer.attendanceStatus = 'REPLACED';
                officer.replacementOfficerName = nameCtrl.text.trim();
                officer.replacementReason = reasonCtrl.text.trim();
                officer.replacedAt = DateHelper.formatFullDate(DateTime.now());
              });

              ApiService.instance.substituteOfficer(
                officer.id,
                nameCtrl.text.trim(),
                reasonCtrl.text.trim(),
              );

              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Pergantian dicatat: ${officer.officerName} digantikan oleh ${nameCtrl.text.trim()}',
                  ),
                  backgroundColor: const Color(0xFFB45309),
                ),
              );
            },
            child: const Text('Simpan Pergantian', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: TIM MULTIMEDIA & IT
  // ---------------------------------------------------------------------------
  Widget _buildTimMultimediaContent(BuildContext context) {
    final filtered = _listMembers.where((m) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return m.name.toLowerCase().contains(q) ||
          m.roleTitle.toLowerCase().contains(q) ||
          m.phone.contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchField('Cari personil multimedia...'),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Personil Tim Multimedia (${filtered.length})',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const Text(
              'Divisi Multimedia GKPI',
              style: TextStyle(
                fontSize: 11.5,
                color: Color(0xFF0284C7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (filtered.isEmpty)
          _buildEmptyState('Tidak ada personil yang cocok.')
        else
          ...filtered.map((member) => _buildMemberCard(context, member)),
      ],
    );
  }

  Widget _buildMemberCard(BuildContext context, MinistryMember member) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppTheme.borderGrey),
        ),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF0284C7).withValues(alpha: 0.15),
                child: const Icon(
                  Icons.videocam,
                  color: Color(0xFF0284C7),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            member.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: member.isActive
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            member.isActive ? 'Aktif' : 'Nonaktif',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: member.isActive
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.roleTitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0369A1),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 13, color: AppTheme.textGrey),
                        const SizedBox(width: 4),
                        Text(
                          member.phone,
                          style: const TextStyle(fontSize: 11.5, color: AppTheme.textGrey),
                        ),
                      ],
                    ),
                    if (member.notes != null && member.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        member.notes!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textGrey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18, color: AppTheme.textGrey),
                onSelected: (val) {
                  if (val == 'edit') {
                    _showEditMemberDialog(member);
                  } else if (val == 'hapus') {
                    _confirmDeleteMember(member);
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit Data', style: TextStyle(fontSize: 13)),
                  ),
                  const PopupMenuItem(
                    value: 'hapus',
                    child: Text(
                      'Hapus',
                      style: TextStyle(fontSize: 13, color: AppTheme.buttonRed),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: INVENTARIS MULTIMEDIA (Scoped strictly to Multimedia)
  // ---------------------------------------------------------------------------
  Widget _buildInventarisContent(BuildContext context) {
    final filtered = _listInventaris.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.namaAset.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.kode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.lokasi.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesKondisi = _selectedKondisiFilter == 'Semua Kondisi' ||
          item.kondisi == _selectedKondisiFilter;
      return matchesSearch && matchesKondisi;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchField('Cari aset multimedia, kamera, proyektor...'),
        const SizedBox(height: 10),
        _buildKondisiFilterRow(),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aset Multimedia & IT (${filtered.length})',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const Text(
              'Khusus Divisi Multimedia',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF0284C7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (filtered.isEmpty)
          _buildEmptyState('Tidak ada aset multimedia yang cocok.')
        else
          ...filtered.map((item) => _buildInventarisCard(context, item)),
      ],
    );
  }

  Widget _buildKondisiFilterRow() {
    final list = ['Semua Kondisi', 'Baik', 'Perbaikan', 'Rusak'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: list.map((k) {
          final sel = _selectedKondisiFilter == k;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(k),
              selected: sel,
              onSelected: (val) {
                if (val) setState(() => _selectedKondisiFilter = k);
              },
              labelStyle: TextStyle(
                fontSize: 11.5,
                fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                color: sel ? Colors.white : AppTheme.textDark,
              ),
              selectedColor: const Color(0xFF0284C7),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: sel ? const Color(0xFF0284C7) : AppTheme.borderGrey,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInventarisCard(BuildContext context, InventarisItem item) {
    Color badgeColor;
    Color badgeText;
    if (item.kondisi == 'Baik') {
      badgeColor = const Color(0xFFDCFCE7);
      badgeText = const Color(0xFF15803D);
    } else if (item.kondisi == 'Perbaikan') {
      badgeColor = const Color(0xFFFEF3C7);
      badgeText = const Color(0xFFB45309);
    } else {
      badgeColor = const Color(0xFFFEE2E2);
      badgeText = const Color(0xFFB91C1C);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppTheme.borderGrey),
        ),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.kode,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0369A1),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.kondisi,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: badgeText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.namaAset,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textGrey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.lokasi,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundGrey,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${item.jumlah} Unit',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(color: AppTheme.borderGrey, height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showEditInventarisDialog(item),
                    icon: const Icon(Icons.edit_outlined, size: 15),
                    label: const Text('Edit', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF0369A1),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _confirmDeleteInventaris(item),
                    icon: const Icon(Icons.delete_outline, size: 15),
                    label: const Text('Hapus', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.buttonRed,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 4: WARTA & LITURGI
  // ---------------------------------------------------------------------------
  Widget _buildWartaLiturgiContent(BuildContext context) {
    final sun0 = DateHelper.getNextOrCurrentSunday();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Warta & Materi Digital',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Materi slide PPT ibadah minggu, naskah warta, dan link live streaming YouTube.',
          style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppTheme.borderGrey),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.slideshow, color: Color(0xFF0284C7), size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Slide EasyWorship & PPT Minggu Ini',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                          ),
                          Text(
                            DateHelper.formatFullDate(sun0),
                            style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(color: AppTheme.borderGrey, height: 1),
                const SizedBox(height: 12),
                const Text(
                  'LINK STREAMING RESMI GKPI CIMAHI:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textGrey),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.play_circle_fill, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'https://youtube.com/@gkpijemaatcimahi/live',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue),
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
    );
  }

  Widget _buildSearchField(String hint) {
    return TextField(
      onChanged: (val) => setState(() => _searchQuery = val),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textGrey),
        prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.textGrey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
          borderSide: const BorderSide(color: Color(0xFF0284C7)),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 10),
          Text(
            msg,
            style: const TextStyle(fontSize: 13, color: AppTheme.textGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DIALOGS: TAMBAH / EDIT MEMBER MULTIMEDIA
  // ---------------------------------------------------------------------------
  void _showTambahMemberDialog() {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController(text: 'Operator PPT / EasyWorship');
    final phoneCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tambah Anggota Multimedia', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: roleCtrl,
                decoration: const InputDecoration(labelText: 'Peran Teknis (PPT / OBS / Sound)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Nomor WhatsApp / HP'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(labelText: 'Catatan Penugasan'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              final newMember = MinistryMember(
                id: 'MM-${DateTime.now().millisecondsSinceEpoch}',
                division: 'multimedia',
                name: nameCtrl.text.trim(),
                roleTitle: roleCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                notes: notesCtrl.text.trim(),
                isActive: true,
              );
              setState(() {
                _listMembers.add(newMember);
              });
              ApiService.instance.createMinistryMember(newMember.toJson());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Personil multimedia berhasil ditambahkan!')),
              );
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditMemberDialog(MinistryMember member) {
    final nameCtrl = TextEditingController(text: member.name);
    final roleCtrl = TextEditingController(text: member.roleTitle);
    final phoneCtrl = TextEditingController(text: member.phone);
    final notesCtrl = TextEditingController(text: member.notes ?? '');
    bool isActive = member.isActive;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Personil Multimedia', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: roleCtrl,
                  decoration: const InputDecoration(labelText: 'Peran Teknis'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Nomor WhatsApp'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'Catatan'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Status Aktif Pelayanan', style: TextStyle(fontSize: 13)),
                  value: isActive,
                  activeThumbColor: const Color(0xFF0284C7),
                  onChanged: (val) => setDState(() => isActive = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
              onPressed: () {
                final updated = MinistryMember(
                  id: member.id,
                  division: 'multimedia',
                  name: nameCtrl.text.trim(),
                  roleTitle: roleCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  notes: notesCtrl.text.trim(),
                  isActive: isActive,
                );
                setState(() {
                  final idx = _listMembers.indexWhere((m) => m.id == member.id);
                  if (idx != -1) {
                    _listMembers[idx] = updated;
                  }
                });
                ApiService.instance.updateMinistryMember(member.id, updated.toJson());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data personil berhasil diperbarui!')),
                );
              },
              child: const Text('Perbarui', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteMember(MinistryMember member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Personil?'),
        content: Text('Hapus "${member.name}" dari daftar personil multimedia?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.buttonRed),
            onPressed: () {
              final memberId = member.id;
              setState(() {
                _listMembers.removeWhere((m) => m.id == memberId);
              });
              ApiService.instance.deleteMinistryMember(memberId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Personil telah dihapus.')),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DIALOGS: TAMBAH / EDIT INVENTARIS MULTIMEDIA
  // ---------------------------------------------------------------------------
  void _showTambahInventarisDialog() {
    final kodeCtrl = TextEditingController(text: 'MM-00${_listInventaris.length + 1}');
    final namaCtrl = TextEditingController();
    final lokasiCtrl = TextEditingController(text: 'Ruang Kontrol Multimedia');
    final jumlahCtrl = TextEditingController(text: '1');
    String kondisi = 'Baik';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Tambah Aset Multimedia', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: kodeCtrl,
                  decoration: const InputDecoration(labelText: 'Kode Aset'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: namaCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Perangkat Multimedia'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: lokasiCtrl,
                  decoration: const InputDecoration(labelText: 'Lokasi Penyimpanan / Pasang'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: jumlahCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Jumlah Unit'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: kondisi,
                  decoration: const InputDecoration(labelText: 'Kondisi'),
                  items: ['Baik', 'Perbaikan', 'Rusak']
                      .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                      .toList(),
                  onChanged: (val) => setDState(() => kondisi = val ?? 'Baik'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
              onPressed: () {
                if (namaCtrl.text.trim().isEmpty) return;
                final jml = int.tryParse(jumlahCtrl.text.trim()) ?? 1;
                final newItem = InventarisItem(
                  id: 'AST-${DateTime.now().millisecondsSinceEpoch}',
                  kode: kodeCtrl.text.trim(),
                  namaAset: namaCtrl.text.trim(),
                  lokasi: lokasiCtrl.text.trim(),
                  jumlah: jml,
                  kondisi: kondisi,
                  status: 'Tersedia',
                  division: 'multimedia',
                );
                setState(() {
                  _listInventaris.add(newItem);
                });
                ApiService.instance.createAsset(newItem.toJson());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Aset multimedia berhasil ditambahkan!')),
                );
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditInventarisDialog(InventarisItem item) {
    final namaCtrl = TextEditingController(text: item.namaAset);
    final lokasiCtrl = TextEditingController(text: item.lokasi);
    final jumlahCtrl = TextEditingController(text: item.jumlah.toString());
    String kondisi = item.kondisi;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Aset ${item.kode}', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Perangkat'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: lokasiCtrl,
                  decoration: const InputDecoration(labelText: 'Lokasi'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: jumlahCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Jumlah Unit'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: kondisi,
                  decoration: const InputDecoration(labelText: 'Kondisi'),
                  items: ['Baik', 'Perbaikan', 'Rusak']
                      .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                      .toList(),
                  onChanged: (val) => setDState(() => kondisi = val ?? 'Baik'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
              onPressed: () {
                final jml = int.tryParse(jumlahCtrl.text.trim()) ?? item.jumlah;
                final updated = InventarisItem(
                  id: item.id,
                  kode: item.kode,
                  namaAset: namaCtrl.text.trim(),
                  lokasi: lokasiCtrl.text.trim(),
                  jumlah: jml,
                  kondisi: kondisi,
                  status: item.status,
                  division: 'multimedia',
                  category: item.category,
                );
                setState(() {
                  final idx = _listInventaris.indexWhere((i) => i.id == item.id);
                  if (idx != -1) {
                    _listInventaris[idx] = updated;
                  }
                });
                ApiService.instance.updateAsset(item.id, updated.toJson());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Aset multimedia berhasil diperbarui!')),
                );
              },
              child: const Text('Perbarui', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteInventaris(InventarisItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Aset Multimedia?'),
        content: Text('Hapus aset "${item.namaAset}" (${item.kode})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.buttonRed),
            onPressed: () {
              final assetId = item.id;
              setState(() {
                _listInventaris.removeWhere((i) => i.id == assetId);
              });
              ApiService.instance.deleteAsset(assetId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Aset multimedia telah dihapus.')),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
