import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/animations.dart';
import '../utils/date_helper.dart';

enum _PemusikTab { timPemusik, inventaris, wartaJadwal }

class PemusikScreen extends StatefulWidget {
  final VoidCallback? onLogout;

  const PemusikScreen({super.key, this.onLogout});

  @override
  State<PemusikScreen> createState() => _PemusikScreenState();
}

class _PemusikScreenState extends State<PemusikScreen> {
  _PemusikTab _activeTab = _PemusikTab.timPemusik;
  String _searchQuery = '';
  String _selectedKondisiFilter = 'Semua Kondisi';

  // Backend Sync State
  bool _isLoadingBackend = false;
  bool _isBackendConnected = false;

  @override
  void initState() {
    super.initState();
    _loadFromBackend();
  }

  Future<void> _loadFromBackend() async {
    setState(() => _isLoadingBackend = true);
    try {
      final members = await ApiService.instance.fetchMinistryMembers(division: 'musik');
      if (members.isNotEmpty && mounted) {
        setState(() {
          _listMembers.clear();
          _listMembers.addAll(members);
          _isBackendConnected = true;
        });
      }
      final assets = await ApiService.instance.fetchAssets(division: 'musik');
      if (assets.isNotEmpty && mounted) {
        setState(() {
          _listInventaris.clear();
          _listInventaris.addAll(assets);
          _isBackendConnected = true;
        });
      }
    } catch (e) {
      debugPrint('[PemusikScreen] Sync error: $e');
    } finally {
      if (mounted) setState(() => _isLoadingBackend = false);
    }
  }

  // ---------------------------------------------------------------------------
  // TIM PEMUSIK DATA (Divisi Pemusik & Koor GKPI Cimahi)
  // ---------------------------------------------------------------------------
  final List<MinistryMember> _listMembers = [
    MinistryMember(
      id: 'MUS-001',
      division: 'pemusik',
      name: 'Jonatan Purba',
      roleTitle: 'Pianist / Keyboard Utama',
      phone: '0857-1122-3344',
      notes: 'Koordinator Pelayanan Musik GKPI',
      isActive: true,
    ),
    MinistryMember(
      id: 'MUS-002',
      division: 'pemusik',
      name: 'Ester Simanjorang',
      roleTitle: 'Song Leader / Vokalis',
      phone: '0895-3344-5566',
      notes: 'Pemandu Lagu Ibadah Minggu',
      isActive: true,
    ),
    MinistryMember(
      id: 'MUS-003',
      division: 'pemusik',
      name: 'Marlina Tampubolon',
      roleTitle: 'Song Leader / Vokalis',
      phone: '0812-7788-9900',
      notes: 'Pelayan Song Leader',
      isActive: true,
    ),
    MinistryMember(
      id: 'MUS-004',
      division: 'pemusik',
      name: 'David Hutapea',
      roleTitle: 'Gitaris Akustik & Elektrik',
      phone: '0813-5566-7788',
      notes: 'Pemusik Ibadah Pagi & Pemuda',
      isActive: true,
    ),
    MinistryMember(
      id: 'MUS-005',
      division: 'pemusik',
      name: 'Samuel Panjaitan',
      roleTitle: 'Bassist',
      phone: '0852-6677-8899',
      notes: 'Pemusik Ibadah Minggu',
      isActive: true,
    ),
    MinistryMember(
      id: 'MUS-006',
      division: 'pemusik',
      name: 'Kevin Sihombing',
      roleTitle: 'Drummer / Perkusi',
      phone: '0878-1122-3344',
      notes: 'Pemusik Drum Ibadah',
      isActive: true,
    ),
    MinistryMember(
      id: 'MUS-007',
      division: 'pemusik',
      name: 'Daniel Simatupang',
      roleTitle: 'Keyboardist Cadangan',
      phone: '0812-3344-9988',
      notes: 'Pelayan Cadangan',
      isActive: false,
    ),
  ];

  // ---------------------------------------------------------------------------
  // INVENTARIS PEMUSIK (Scoped to Division Pemusik)
  // ---------------------------------------------------------------------------
  final List<InventarisItem> _listInventaris = [
    InventarisItem(
      id: 'AST-M01',
      kode: 'MUS-001',
      namaAset: 'Keyboard Yamaha Montage 8',
      lokasi: 'Panggung Utama Gereja',
      jumlah: 1,
      kondisi: 'Baik',
      status: 'Tersedia',
      division: 'pemusik',
      category: 'Keyboard & Synth',
    ),
    InventarisItem(
      id: 'AST-M02',
      kode: 'MUS-002',
      namaAset: 'Gitar Akustik Fender CD-60S',
      lokasi: 'Ruang Musik Panggung',
      jumlah: 1,
      kondisi: 'Baik',
      status: 'Tersedia',
      division: 'pemusik',
      category: 'Gitar',
    ),
    InventarisItem(
      id: 'AST-M03',
      kode: 'MUS-003',
      namaAset: 'Bass Elektrik Cort Action PJ',
      lokasi: 'Ruang Musik Panggung',
      jumlah: 1,
      kondisi: 'Baik',
      status: 'Tersedia',
      division: 'pemusik',
      category: 'Bass',
    ),
    InventarisItem(
      id: 'AST-M04',
      kode: 'MUS-004',
      namaAset: 'Amplifier Roland KC-550 Keyboard',
      lokasi: 'Panggung Utama',
      jumlah: 2,
      kondisi: 'Baik',
      status: 'Tersedia',
      division: 'pemusik',
      category: 'Amplifier',
    ),
    InventarisItem(
      id: 'AST-M05',
      kode: 'MUS-005',
      namaAset: 'Mic Wireless Shure GLXD4 (Set 2 Mic)',
      lokasi: 'Lemari Audio Pemusik',
      jumlah: 2,
      kondisi: 'Baik',
      status: 'Tersedia',
      division: 'pemusik',
      category: 'Microphone',
    ),
    InventarisItem(
      id: 'AST-M06',
      kode: 'MUS-006',
      namaAset: 'Drum Elektrik Roland TD-17KVX',
      lokasi: 'Panggung Utama Gereja',
      jumlah: 1,
      kondisi: 'Baik',
      status: 'Tersedia',
      division: 'pemusik',
      category: 'Drum & Perkusi',
    ),
    InventarisItem(
      id: 'AST-M07',
      kode: 'MUS-007',
      namaAset: 'Kabel Jack Canare 5m Gold Plated',
      lokasi: 'Lemari Audio Pemusik',
      jumlah: 6,
      kondisi: 'Perbaikan',
      status: 'Tersedia',
      division: 'pemusik',
      category: 'Aksesoris & Kabel',
    ),
    InventarisItem(
      id: 'AST-M08',
      kode: 'MUS-008',
      namaAset: 'Stand Keyboard Besi Dobel Hercules',
      lokasi: 'Panggung Utama',
      jumlah: 2,
      kondisi: 'Baik',
      status: 'Tersedia',
      division: 'pemusik',
      category: 'Stand & Mount',
    ),
  ];

  // ---------------------------------------------------------------------------
  // JADWAL PELAYAN IBADAH
  // ---------------------------------------------------------------------------
  List<JadwalPelayanDetail> get _listJadwalPelayan {
    final sun0 = DateHelper.getNextOrCurrentSunday();
    final sun1 = DateHelper.getSunday(1);
    return [
      JadwalPelayanDetail(
        id: 'JDW-001',
        tglBadge: DateHelper.formatBadgeDate(sun0),
        tglLengkap: DateHelper.formatFullDate(sun0),
        jenisIbadah: 'Ibadah Minggu Pagi',
        temaKhotbah: '"Kasih Kristus Yang Menguatkan"',
        bacaanAlkitab: 'Yohanes 15:9-17',
        pengkhotbah: 'Pdt. Saut Nainggolan',
        liturgos: 'Ev. Tiur Simbolon',
        songsLeader: 'Marlina Tampubolon, Ester Simanjorang',
        multimedia: 'Ruli Manurung (PPT) & Andre Siregar (OBS)',
        musisi: 'Jonatan Purba (Keyboard), David Hutapea (Gitar), Samuel Panjaitan (Bass)',
        diaken: 'Bapak Martua Sirait, Drs. Haposan Situmorang',
      ),
      JadwalPelayanDetail(
        id: 'JDW-002',
        tglBadge: DateHelper.formatBadgeDate(sun1),
        tglLengkap: DateHelper.formatFullDate(sun1),
        jenisIbadah: 'Ibadah Minggu Pagi',
        temaKhotbah: '"Hidup Dalam Terang Firman"',
        bacaanAlkitab: 'Mazmur 119:105-112',
        pengkhotbah: 'Pdt. B. Siahaan',
        liturgos: 'Ev. Tiur Simbolon',
        songsLeader: 'Marlina Tampubolon',
        multimedia: 'Ruli Manurung',
        musisi: 'Jonatan Purba (Keyboard), Kevin Sihombing (Drum)',
        diaken: 'St. H. Manurung',
      ),
    ];
  }

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
      floatingActionButton: _activeTab == _PemusikTab.timPemusik
          ? ScaleOnTap(
              child: FloatingActionButton.extended(
                onPressed: _showTambahMemberDialog,
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                icon: const Icon(Icons.person_add, size: 20),
                label: const Text(
                  'Tambah Musisi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                elevation: 3,
              ),
            )
          : _activeTab == _PemusikTab.inventaris
              ? ScaleOnTap(
                  child: FloatingActionButton.extended(
                    onPressed: _showTambahInventarisDialog,
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text(
                      'Tambah Aset Musik',
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
      color: const Color(0xFF8B5CF6),
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.music_note, color: Colors.white, size: 14),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              'Anda masuk sebagai Divisi Pemusik — Pengelolaan Musisi, Song Leader & Aset Musik',
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
            backgroundColor: Color(0xFF8B5CF6),
            child: Text(
              'J',
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
                  'Jonatan Purba',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  'Koordinator Divisi Pemusik & Koor',
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
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.piano, size: 13, color: Color(0xFF8B5CF6)),
                SizedBox(width: 4),
                Text(
                  'Pemusik',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
            child: const Icon(Icons.music_note, color: Colors.white, size: 24),
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
                    'Divisi Pemusik',
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
          colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
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
                child: const Icon(Icons.queue_music, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Pelayanan Musik & Pujian',
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
            'Kelola penugasan musisi, song leader, serta ketersediaan instrumen & audio worship GKPI Cimahi.',
            style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatChip(
                icon: Icons.people_outline,
                label: '${_listMembers.where((m) => m.isActive).length} Musisi Aktif',
              ),
              _buildStatChip(
                icon: Icons.speaker,
                label: '${_listInventaris.length} Aset Musik',
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
              title: 'Tim Pemusik',
              icon: Icons.people_alt_outlined,
              isActive: _activeTab == _PemusikTab.timPemusik,
              onTap: () => setState(() => _activeTab = _PemusikTab.timPemusik),
            ),
          ),
          Expanded(
            child: _tabButton(
              title: 'Inventaris',
              icon: Icons.piano,
              isActive: _activeTab == _PemusikTab.inventaris,
              onTap: () => setState(() => _activeTab = _PemusikTab.inventaris),
            ),
          ),
          Expanded(
            child: _tabButton(
              title: 'Jadwal & Warta',
              icon: Icons.calendar_today_outlined,
              isActive: _activeTab == _PemusikTab.wartaJadwal,
              onTap: () => setState(() => _activeTab = _PemusikTab.wartaJadwal),
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
          color: isActive ? const Color(0xFF8B5CF6) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isActive ? Colors.white : AppTheme.textGrey,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
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
      case _PemusikTab.timPemusik:
        return _buildTimPemusikContent(context);
      case _PemusikTab.inventaris:
        return _buildInventarisContent(context);
      case _PemusikTab.wartaJadwal:
        return _buildWartaJadwalContent(context);
    }
  }

  // ---------------------------------------------------------------------------
  // TAB 1: TIM PEMUSIK & SONG LEADER
  // ---------------------------------------------------------------------------
  Widget _buildTimPemusikContent(BuildContext context) {
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
        _buildSearchField('Cari nama musisi / instrumen...'),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daftar Pelayan Musik (${filtered.length})',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            Text(
              'GKPI Cimahi',
              style: TextStyle(
                fontSize: 11.5,
                color: const Color(0xFF8B5CF6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (filtered.isEmpty)
          _buildEmptyState('Tidak ada pelayan musik yang cocok.')
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
                backgroundColor: member.isActive
                    ? const Color(0xFF8B5CF6).withValues(alpha: 0.15)
                    : Colors.grey.withValues(alpha: 0.15),
                child: Icon(
                  Icons.music_note,
                  color: member.isActive ? const Color(0xFF8B5CF6) : Colors.grey,
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
                        color: Color(0xFF6D28D9),
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
  // TAB 2: INVENTARIS PEMUSIK (Scoped strictly to Pemusik)
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
        _buildSearchField('Cari aset instrumen, kode, lokasi...'),
        const SizedBox(height: 10),
        _buildKondisiFilterRow(),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aset Musik & Audio (${filtered.length})',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const Text(
              'Khusus Divisi Pemusik',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF8B5CF6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (filtered.isEmpty)
          _buildEmptyState('Tidak ada aset instrumen yang cocok.')
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
              selectedColor: const Color(0xFF8B5CF6),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: sel ? const Color(0xFF8B5CF6) : AppTheme.borderGrey,
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
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.kode,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6D28D9),
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
                      foregroundColor: const Color(0xFF6D28D9),
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
  // TAB 3: WARTA & JADWAL IBADAH
  // ---------------------------------------------------------------------------
  Widget _buildWartaJadwalContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jadwal Pelayanan Ibadah GKPI',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Informasi tema khotbah, firman, song leader & musisi yang bertugas.',
          style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
        ),
        const SizedBox(height: 12),
        ..._listJadwalPelayan.map((j) => _buildJadwalCard(context, j)),
      ],
    );
  }

  Widget _buildJadwalCard(BuildContext context, JadwalPelayanDetail j) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      j.tglBadge,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6D28D9),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      j.tglLengkap,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                j.temaKhotbah,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.book_outlined, size: 14, color: AppTheme.primaryBlue),
                  const SizedBox(width: 5),
                  Text(
                    j.bacaanAlkitab,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: AppTheme.borderGrey, height: 1),
              const SizedBox(height: 12),
              _dutyRow('Pengkhotbah', j.pengkhotbah),
              const SizedBox(height: 6),
              _dutyRow('Liturgos', j.liturgos),
              const SizedBox(height: 6),
              _dutyRow('Song Leader', j.songsLeader, isHighlight: true),
              const SizedBox(height: 6),
              _dutyRow('Musisi', j.musisi, isHighlight: true),
              const SizedBox(height: 6),
              _dutyRow('Multimedia', j.multimedia),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dutyRow(String role, String name, {bool isHighlight = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            role,
            style: TextStyle(
              fontSize: 11.5,
              color: isHighlight ? const Color(0xFF6D28D9) : AppTheme.textGrey,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
        const Text(': ', style: TextStyle(fontSize: 11.5, color: AppTheme.textGrey)),
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 12,
              color: isHighlight ? const Color(0xFF4C1D95) : AppTheme.textDark,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
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
          borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
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
  // DIALOGS: TAMBAH / EDIT MEMBER MUSIK
  // ---------------------------------------------------------------------------
  void _showTambahMemberDialog() {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController(text: 'Pianist / Keyboard');
    final phoneCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tambah Pelayan Musik', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama Lengkap Musisi'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: roleCtrl,
                decoration: const InputDecoration(labelText: 'Peran / Alat Musik (e.g. Bassist, Song Leader)'),
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
                decoration: const InputDecoration(labelText: 'Catatan Pelayanan'),
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
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6)),
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              final newMember = MinistryMember(
                id: 'MUS-${DateTime.now().millisecondsSinceEpoch}',
                division: 'pemusik',
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
                const SnackBar(content: Text('Anggota musisi berhasil ditambahkan!')),
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
          title: const Text('Edit Data Musisi', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  decoration: const InputDecoration(labelText: 'Peran / Instrumen'),
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
                  activeThumbColor: const Color(0xFF8B5CF6),
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
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6)),
              onPressed: () {
                final updated = MinistryMember(
                  id: member.id,
                  division: 'pemusik',
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
                  const SnackBar(content: Text('Data musisi berhasil diperbarui!')),
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
        title: const Text('Hapus Musisi?'),
        content: Text('Hapus "${member.name}" dari daftar pelayan musik?'),
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
                const SnackBar(content: Text('Musisi telah dihapus.')),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DIALOGS: TAMBAH / EDIT INVENTARIS PEMUSIK
  // ---------------------------------------------------------------------------
  void _showTambahInventarisDialog() {
    final kodeCtrl = TextEditingController(text: 'MUS-00${_listInventaris.length + 1}');
    final namaCtrl = TextEditingController();
    final lokasiCtrl = TextEditingController(text: 'Ruang Musik Panggung');
    final jumlahCtrl = TextEditingController(text: '1');
    String kondisi = 'Baik';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Tambah Aset Musik', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  decoration: const InputDecoration(labelText: 'Nama Instrumen / Alat Musik'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: lokasiCtrl,
                  decoration: const InputDecoration(labelText: 'Lokasi Penyimpanan'),
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
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6)),
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
                  division: 'pemusik',
                );
                setState(() {
                  _listInventaris.add(newItem);
                });
                ApiService.instance.createAsset(newItem.toJson());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Aset musik berhasil ditambahkan!')),
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
                  decoration: const InputDecoration(labelText: 'Nama Instrumen'),
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
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6)),
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
                  division: 'pemusik',
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
                  const SnackBar(content: Text('Aset musik berhasil diperbarui!')),
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
        title: const Text('Hapus Aset Musik?'),
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
                const SnackBar(content: Text('Aset musik telah dihapus.')),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
