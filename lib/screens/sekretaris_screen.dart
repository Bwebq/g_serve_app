import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/animations.dart';

enum _SekretarisTab { jemaat, inventaris, wartaJadwal }

class SekretarisScreen extends StatefulWidget {
  final VoidCallback? onLogout;

  const SekretarisScreen({super.key, this.onLogout});

  @override
  State<SekretarisScreen> createState() => _SekretarisScreenState();
}

class _SekretarisScreenState extends State<SekretarisScreen> {
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

  DateTime get _now => DateTime.now();
  String get _tanggalHariIni => _fmtTanggalRaw(_now);
  String get _bulanIni => '${_bulanPanjang[_now.month - 1]} ${_now.year}';

  static String _fmtTanggalRaw(DateTime d) =>
      '${_hariNama[d.weekday - 1]}, ${d.day} ${_bulanNama[d.month - 1]} ${d.year}';

  // Active Tab state
  _SekretarisTab _activeTab = _SekretarisTab.jemaat;

  // Search & Filters state for Data Jemaat
  final TextEditingController _searchController = TextEditingController();
  String _selectedSektorFilter = 'Semua Sektor';
  String _selectedStatusFilter = 'Semua Status';

  // Search & Filters state for Inventaris
  final TextEditingController _inventarisSearchController =
      TextEditingController();
  String _selectedKondisiFilter = 'Semua Kondisi';

  // Warta & Jadwal state
  JadwalPelayanDetail? _selectedJadwal;
  bool _showWartaPratinjau = false;

  // Initial Mock Jemaat Data
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

  // Mock Inventaris Data
  final List<InventarisItem> _listInventaris = [
    InventarisItem(
      id: '1',
      kode: 'EL-001',
      namaAset: 'Yamaha MG20XU Sound System',
      lokasi: 'Ruang Control',
      jumlah: 1,
      kondisi: 'Baik',
      status: 'Tersedia',
    ),
    InventarisItem(
      id: '2',
      kode: 'EL-002',
      namaAset: 'Proyektor EPSON EB-2250U',
      lokasi: 'Gedung Utama',
      jumlah: 2,
      kondisi: 'Baik',
      status: 'Tersedia',
    ),
    InventarisItem(
      id: '3',
      kode: 'MS-001',
      namaAset: 'Organ Roland AT-800',
      lokasi: 'Panggung Utama',
      jumlah: 1,
      kondisi: 'Baik',
      status: 'Tersedia',
    ),
    InventarisItem(
      id: '4',
      kode: 'FS-001',
      namaAset: 'Kursi Futura Stainless',
      lokasi: 'Gedung Utama',
      jumlah: 150,
      kondisi: 'Baik',
      status: 'Tersedia',
    ),
    InventarisItem(
      id: '5',
      kode: 'FS-002',
      namaAset: 'Meja Altar Kayu Jati',
      lokasi: 'Panggung Utama',
      jumlah: 1,
      kondisi: 'Baik',
      status: 'Tersedia',
    ),
    InventarisItem(
      id: '6',
      kode: 'FS-003',
      namaAset: 'AC Split Daikin 2PK',
      lokasi: 'Gedung Utama',
      jumlah: 4,
      kondisi: 'Perbaikan',
      status: 'Tidak Tersedia',
    ),
    InventarisItem(
      id: '7',
      kode: 'EL-003',
      namaAset: 'Lampu Sorot LED Stage',
      lokasi: 'Panggung Utama',
      jumlah: 8,
      kondisi: 'Baik',
      status: 'Tersedia',
    ),
    InventarisItem(
      id: '8',
      kode: 'FS-004',
      namaAset: 'Generator Listrik 5000W',
      lokasi: 'Belakang Gedung',
      jumlah: 1,
      kondisi: 'Rusak',
      status: 'Tidak Tersedia',
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
      diaken: 'St. H. Manurung',
    ),
    JadwalPelayanDetail(
      id: '2',
      tglBadge: 'AGU 10',
      tglLengkap: 'Minggu, 10 Agustus 2025',
      jenisIbadah: 'Ibadah Minggu Pagi',
      temaKhotbah: '"Berjalan Bersama Tuhan"',
      bacaanAlkitab: 'Mazmur 23:1-6',
      pengkhotbah: 'Pdt. B. Siahaan',
      liturgos: 'Bapak Martua Sirait',
      songsLeader: 'Ester Simanjorang',
      multimedia: 'Grace Simanjorang',
      musisi: 'Drs. Haposan Situmorang',
      diaken: 'Ibu Rosmida Hutabarat',
    ),
  ];

  // Counters for Jemaat
  int get _aktifCount => _listJemaat.where((j) => j.status == 'Aktif').length;
  int get _pindahCount => _listJemaat.where((j) => j.status == 'Pindah').length;
  int get _meninggalCount =>
      _listJemaat.where((j) => j.status == 'Meninggal').length;
  int get _totalCount => _listJemaat.length;

  // Counters for Inventaris
  int get _baikCount =>
      _listInventaris.where((i) => i.kondisi == 'Baik').length;
  int get _perbaikanCount =>
      _listInventaris.where((i) => i.kondisi == 'Perbaikan').length;
  int get _rusakCount =>
      _listInventaris.where((i) => i.kondisi == 'Rusak').length;

  // Filtered Jemaat
  List<JemaatMember> get _filteredJemaat {
    return _listJemaat.where((j) {
      final query = _searchController.text.trim().toLowerCase();
      final matchQuery =
          query.isEmpty ||
          j.namaLengkap.toLowerCase().contains(query) ||
          j.noRegister.toLowerCase().contains(query);
      final matchSektor =
          _selectedSektorFilter == 'Semua Sektor' ||
          j.sektor == _selectedSektorFilter;
      final matchStatus =
          _selectedStatusFilter == 'Semua Status' ||
          j.status == _selectedStatusFilter;
      return matchQuery && matchSektor && matchStatus;
    }).toList();
  }

  // Filtered Inventaris
  List<InventarisItem> get _filteredInventaris {
    return _listInventaris.where((item) {
      final query = _inventarisSearchController.text.trim().toLowerCase();
      final matchQuery =
          query.isEmpty ||
          item.kode.toLowerCase().contains(query) ||
          item.namaAset.toLowerCase().contains(query);
      final matchKondisi =
          _selectedKondisiFilter == 'Semua Kondisi' ||
          item.kondisi == _selectedKondisiFilter;
      return matchQuery && matchKondisi;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _inventarisSearchController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // MODAL: Tambah Jemaat
  // ─────────────────────────────────────────────────────────────────────────────
  void _openTambahJemaatModal() {
    final namaController = TextEditingController();
    final noRegController = TextEditingController(
      text: 'GKPI-0${(_listJemaat.length + 1).toString().padLeft(2, '0')}',
    );
    DateTime selectedTglLahir = DateTime(1995, 3, 15);

    String fmtTglLahir(DateTime d) {
      const bulanShort = [
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
      return '${d.day} ${bulanShort[d.month - 1]} ${d.year}';
    }

    final tglLahirController = TextEditingController(
      text: fmtTglLahir(selectedTglLahir),
    );
    String sektorDipilih = 'Sektor 1';
    String statusDipilih = 'Aktif';
    bool baptis = true, sidi = true, nikah = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickTglLahir() async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedTglLahir,
                firstDate: DateTime(1930),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppTheme.primaryBlue,
                        onPrimary: Colors.white,
                        onSurface: AppTheme.textDark,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setModalState(() {
                  selectedTglLahir = picked;
                  tglLahirController.text = fmtTglLahir(picked);
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppTheme.borderGrey,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tambah Data Jemaat Baru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: noRegController,
                      decoration: _fieldDecoration('No. Register'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: namaController,
                      decoration: _fieldDecoration(
                        'Nama Lengkap',
                      ).copyWith(hintText: 'Contoh: St. B. Simanjuntak'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: sektorDipilih,
                            decoration: _fieldDecoration('Sektor'),
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
                                        child: Text(
                                          s,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (val) {
                              if (val != null)
                                setModalState(() => sektorDipilih = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: statusDipilih,
                            decoration: _fieldDecoration('Status'),
                            items: ['Aktif', 'Pindah', 'Meninggal']
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      s,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null)
                                setModalState(() => statusDipilih = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Tanggal Lahir Date Picker
                    InkWell(
                      onTap: pickTglLahir,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
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
                              Icons.cake_outlined,
                              size: 20,
                              color: AppTheme.primaryBlue,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tanggal Lahir',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textGrey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  tglLahirController.text,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.calendar_month,
                              size: 18,
                              color: AppTheme.textGrey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'STATUS SAKRAMEN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textGrey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        FilterChip(
                          label: const Text(
                            'Baptis',
                            style: TextStyle(fontSize: 12),
                          ),
                          selected: baptis,
                          selectedColor: const Color(0xFFE0F2FE),
                          onSelected: (val) =>
                              setModalState(() => baptis = val),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text(
                            'Sidi',
                            style: TextStyle(fontSize: 12),
                          ),
                          selected: sidi,
                          selectedColor: const Color(0xFFE0F2FE),
                          onSelected: (val) => setModalState(() => sidi = val),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text(
                            'Nikah',
                            style: TextStyle(fontSize: 12),
                          ),
                          selected: nikah,
                          selectedColor: const Color(0xFFE0F2FE),
                          onSelected: (val) => setModalState(() => nikah = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final nama = namaController.text.trim();
                          final noReg = noRegController.text.trim();
                          if (nama.isNotEmpty) {
                            setState(() {
                              _listJemaat.insert(
                                0,
                                JemaatMember(
                                  id: DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                                  noRegister: noReg,
                                  namaLengkap: nama,
                                  sektor: sektorDipilih,
                                  status: statusDipilih,
                                  tglLahir: tglLahirController.text.trim(),
                                  isBaptis: baptis,
                                  isSidi: sidi,
                                  isNikah: nikah,
                                ),
                              );
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Data Jemaat berhasil ditambahkan!',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Harap isi nama lengkap jemaat.'),
                                backgroundColor: AppTheme.buttonRed,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                        ),
                        icon: const Icon(Icons.check_circle_outline, size: 20),
                        label: const Text(
                          'Simpan Data Jemaat',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // MODAL: Tambah Aset
  // ─────────────────────────────────────────────────────────────────────────────
  void _openTambahAsetModal() {
    final kodeController = TextEditingController();
    final namaController = TextEditingController();
    final jumlahController = TextEditingController(text: '1');
    final lokasiController = TextEditingController();
    String kondisiDipilih = 'Baik';
    String statusDipilih = 'Tersedia';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppTheme.borderGrey,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tambah Aset Baru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: _buildFormField(
                            controller: kodeController,
                            label: 'Kode',
                            hint: 'EL-001',
                            icon: Icons.qr_code_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: _buildFormField(
                            controller: namaController,
                            label: 'Nama Aset',
                            hint: 'Cth: Sound System JBL',
                            icon: Icons.inventory_2_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: kondisiDipilih,
                            decoration: _fieldDecoration('Kondisi'),
                            items: ['Baik', 'Perbaikan', 'Rusak']
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      s,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null)
                                setModalState(() => kondisiDipilih = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: statusDipilih,
                            decoration: _fieldDecoration('Status'),
                            items: ['Tersedia', 'Tidak Tersedia']
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      s,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null)
                                setModalState(() => statusDipilih = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFormField(
                            controller: jumlahController,
                            label: 'Jumlah',
                            hint: '1',
                            icon: Icons.format_list_numbered_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: _buildFormField(
                            controller: lokasiController,
                            label: 'Lokasi',
                            hint: 'Cth: Gedung Utama',
                            icon: Icons.location_on_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final kode = kodeController.text.trim();
                          final nama = namaController.text.trim();
                          final jumlah =
                              int.tryParse(jumlahController.text.trim()) ?? 0;
                          final lokasi = lokasiController.text.trim();
                          if (kode.isEmpty ||
                              nama.isEmpty ||
                              lokasi.isEmpty ||
                              jumlah <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Isi kode, nama, jumlah, dan lokasi aset.',
                                ),
                                backgroundColor: AppTheme.buttonRed,
                              ),
                            );
                            return;
                          }
                          setState(() {
                            _listInventaris.insert(
                              0,
                              InventarisItem(
                                id: DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                                kode: kode,
                                namaAset: nama,
                                lokasi: lokasi,
                                jumlah: jumlah,
                                kondisi: kondisiDipilih,
                                status: statusDipilih,
                              ),
                            );
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Aset berhasil ditambahkan!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                        ),
                        icon: const Icon(Icons.check_circle_outline, size: 20),
                        label: const Text(
                          'Simpan Aset',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // MODAL: Tambah Jadwal Pelayan
  // ─────────────────────────────────────────────────────────────────────────────
  void _openTambahJadwalPelayanModal() {
    DateTime selectedDate = DateTime.now();

    String fmtTglLengkap(DateTime d) {
      const hari = [
        'Minggu',
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
      ];
      const bulan = [
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
      final h = d.weekday == 7 ? hari[0] : hari[d.weekday];
      return '$h, ${d.day} ${bulan[d.month - 1]} ${d.year}';
    }

    String fmtTglBadge(DateTime d) {
      const bulanShort = [
        'JAN',
        'FEB',
        'MAR',
        'APR',
        'MEI',
        'JUN',
        'JUL',
        'AGU',
        'SEP',
        'OKT',
        'NOV',
        'DES',
      ];
      return '${bulanShort[d.month - 1]} ${d.day}';
    }

    final tglLengkapController = TextEditingController(
      text: fmtTglLengkap(selectedDate),
    );
    final tglBadgeController = TextEditingController(
      text: fmtTglBadge(selectedDate),
    );
    final temaController = TextEditingController();
    final bacaanController = TextEditingController();
    String jenisIbadah = 'Ibadah Minggu Pagi';
    String pengkhotbah = '';
    String liturgos = '';
    String songsLeader = '';
    String multimedia = '';
    String musisi = '';
    String diaken = '';

    final namaList = _listJemaat.map((j) => j.namaLengkap).toList();
    namaList.insert(0, '— Pilih —');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickDate() async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2024),
                lastDate: DateTime(2030),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppTheme.primaryBlue,
                        onPrimary: Colors.white,
                        onSurface: AppTheme.textDark,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setModalState(() {
                  selectedDate = picked;
                  tglLengkapController.text = fmtTglLengkap(picked);
                  tglBadgeController.text = fmtTglBadge(picked);
                });
              }
            }

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Grab Bar & Title Header
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppTheme.borderGrey,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.calendar_month_outlined,
                              color: AppTheme.primaryBlue,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tambah Jadwal Pelayan',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Atur tanggal, tema, & petugas ibadah',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.close,
                              color: AppTheme.textGrey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // SECTION 1: TANGGAL & IBADAH
                      const Text(
                        'INFORMASI IBADAH',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Tanggal & Badge row
                      Row(
                        children: [
                          // Clickable Calendar Date Picker for Tanggal Lengkap
                          Expanded(
                            flex: 3,
                            child: InkWell(
                              onTap: pickDate,
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.backgroundGrey,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppTheme.borderGrey,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 18,
                                      color: AppTheme.primaryBlue,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Tanggal Lengkap',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: AppTheme.textGrey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            tglLengkapController.text,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textDark,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Auto Badge Preview
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppTheme.primaryBlue.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Badge Tanggal',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.primaryBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.auto_awesome,
                                        size: 14,
                                        color: AppTheme.primaryBlue,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        tglBadgeController.text,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Jenis Ibadah Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: jenisIbadah,
                        isExpanded: true,
                        decoration: _fieldDecoration('Jenis Ibadah'),
                        items:
                            [
                                  'Ibadah Minggu Pagi',
                                  'Ibadah Minggu Sore',
                                  'Ibadah Keluarga',
                                  'Ibadah Pemuda',
                                ]
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      s,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          if (val != null)
                            setModalState(() => jenisIbadah = val);
                        },
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: temaController,
                        decoration: _fieldDecoration('Tema Khotbah').copyWith(
                          hintText: 'Cth: "Kasih Kristus Yang Menguatkan"',
                          prefixIcon: const Icon(
                            Icons.church_outlined,
                            size: 20,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: bacaanController,
                        decoration: _fieldDecoration('Bacaan Alkitab').copyWith(
                          hintText: 'Cth: Yohanes 15:9-17',
                          prefixIcon: const Icon(
                            Icons.menu_book_outlined,
                            size: 20,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // SECTION 2: PETUGAS PELAYAN IBADAH
                      const Text(
                        'PETUGAS PELAYAN IBADAH',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Grid Pair 1: Pengkhotbah & Liturgos
                      Row(
                        children: [
                          Expanded(
                            child: _buildPelayanDropdown(
                              'Pengkhotbah',
                              pengkhotbah,
                              namaList,
                              (val) =>
                                  setModalState(() => pengkhotbah = val ?? ''),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildPelayanDropdown(
                              'Liturgos',
                              liturgos,
                              namaList,
                              (val) =>
                                  setModalState(() => liturgos = val ?? ''),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Grid Pair 2: Songs Leader & Multimedia
                      Row(
                        children: [
                          Expanded(
                            child: _buildPelayanDropdown(
                              'Songs Leader',
                              songsLeader,
                              namaList,
                              (val) =>
                                  setModalState(() => songsLeader = val ?? ''),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildPelayanDropdown(
                              'Multimedia',
                              multimedia,
                              namaList,
                              (val) =>
                                  setModalState(() => multimedia = val ?? ''),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Grid Pair 3: Musisi & Diaken
                      Row(
                        children: [
                          Expanded(
                            child: _buildPelayanDropdown(
                              'Musisi',
                              musisi,
                              namaList,
                              (val) => setModalState(() => musisi = val ?? ''),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildPelayanDropdown(
                              'Diaken',
                              diaken,
                              namaList,
                              (val) => setModalState(() => diaken = val ?? ''),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final badge = tglBadgeController.text.trim();
                            final tgl = tglLengkapController.text.trim();
                            if (badge.isEmpty || tgl.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Pilih tanggal ibadah.'),
                                  backgroundColor: AppTheme.buttonRed,
                                ),
                              );
                              return;
                            }
                            final newJadwal = JadwalPelayanDetail(
                              id: DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                              tglBadge: badge,
                              tglLengkap: tgl,
                              jenisIbadah: jenisIbadah,
                              temaKhotbah: temaController.text.trim().isEmpty
                                  ? '—'
                                  : temaController.text.trim(),
                              bacaanAlkitab:
                                  bacaanController.text.trim().isEmpty
                                  ? '—'
                                  : bacaanController.text.trim(),
                              pengkhotbah: pengkhotbah.isEmpty
                                  ? '—'
                                  : pengkhotbah,
                              liturgos: liturgos.isEmpty ? '—' : liturgos,
                              songsLeader: songsLeader.isEmpty
                                  ? '—'
                                  : songsLeader,
                              multimedia: multimedia.isEmpty ? '—' : multimedia,
                              musisi: musisi.isEmpty ? '—' : musisi,
                              diaken: diaken.isEmpty ? '—' : diaken,
                            );
                            setState(() {
                              _listJadwalPelayan.add(newJadwal);
                              _selectedJadwal = newJadwal;
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Jadwal pelayan berhasil disimpan!',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 2,
                          ),
                          icon: const Icon(
                            Icons.check_circle_outline,
                            size: 20,
                          ),
                          label: const Text(
                            'Simpan Jadwal',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPelayanDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: value.isEmpty
          ? items.first
          : (items.contains(value) ? value : items.first),
      isDense: true,
      isExpanded: true,
      decoration: _fieldDecoration(label).copyWith(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 12,
        ),
      ),
      items: items
          .map(
            (s) => DropdownMenuItem(
              value: s,
              child: Text(
                s,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12.5),
              ),
            ),
          )
          .toList(),
      onChanged: (val) {
        if (val != null && val != '— Pilih —') {
          onChanged(val);
        } else {
          onChanged('');
        }
      },
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: _fieldDecoration(label).copyWith(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textGrey, fontSize: 12.5),
        prefixIcon: Icon(icon, size: 20, color: AppTheme.textGrey),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // BUILD MAIN SCRIPTHOLDER
  // ─────────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: _buildAppBar(context),
      body: SafeArea(
        top: false,
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
              const SizedBox(height: 16),

              FadeSlideAnimation(
                delay: const Duration(milliseconds: 120),
                child: _buildSegmentedTabSelector(),
              ),
              const SizedBox(height: 16),

              if (_activeTab == _SekretarisTab.jemaat) ...[
                FadeSlideAnimation(
                  delay: const Duration(milliseconds: 200),
                  child: _buildJemaatContent(context),
                ),
              ] else if (_activeTab == _SekretarisTab.inventaris) ...[
                FadeSlideAnimation(
                  delay: const Duration(milliseconds: 200),
                  child: _buildInventarisContent(context),
                ),
              ] else ...[
                FadeSlideAnimation(
                  delay: const Duration(milliseconds: 200),
                  child: _buildWartaJadwalContent(context),
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: ScaleOnTap(
        child: FloatingActionButton.extended(
          onPressed: () {
            if (_activeTab == _SekretarisTab.jemaat) {
              _openTambahJemaatModal();
            } else if (_activeTab == _SekretarisTab.inventaris) {
              _openTambahAsetModal();
            } else {
              _openTambahJadwalPelayanModal();
            }
          },
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add, size: 22),
          label: Text(
            _activeTab == _SekretarisTab.jemaat
                ? 'Tambah Jemaat'
                : (_activeTab == _SekretarisTab.inventaris
                      ? 'Tambah Aset'
                      : 'Tambah Jadwal'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 3,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // APP BAR
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
                  'G-SERVE Sekretariat',
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
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
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
  // HERO BANNER CARD (Identical style to BendaharaScreen's _buildHeader)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildHeaderHeroCard() {
    IconData heroIcon;
    String heroTitle;
    String heroSubtitle;
    String heroBadge;

    if (_activeTab == _SekretarisTab.jemaat) {
      heroIcon = Icons.badge_outlined;
      heroTitle = 'Sekretariat Jemaat';
      heroSubtitle =
          'Kam, ${_now.day} ${_bulanNama[_now.month - 1]} ${_now.year}';
      heroBadge = '$_totalCount Jemaat';
    } else if (_activeTab == _SekretarisTab.inventaris) {
      heroIcon = Icons.inventory_2_outlined;
      heroTitle = 'Inventaris & Aset';
      heroSubtitle = 'Ringkasan sarana & prasarana · $_bulanIni';
      heroBadge = '${_listInventaris.length} Aset';
    } else {
      heroIcon = Icons.article_outlined;
      heroTitle = 'Warta & Jadwal';
      heroSubtitle = 'Jadwal pelayan & warta ibadah · $_bulanIni';
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
  // SEGMENTED TAB SELECTOR (Matching BendaharaScreen's _buildPeriodSelector)
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
            _SekretarisTab.jemaat,
            Icons.people_alt_outlined,
            'Data Jemaat',
          ),
          _buildSegmentedTabItem(
            _SekretarisTab.inventaris,
            Icons.inventory_2_outlined,
            'Inventaris',
          ),
          _buildSegmentedTabItem(
            _SekretarisTab.wartaJadwal,
            Icons.article_outlined,
            'Warta & Jadwal',
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabItem(
    _SekretarisTab tab,
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
    final filtered = _filteredJemaat;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Excel Action row
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
                    '$_aktifCount aktif dari $_totalCount jemaat terdaftar',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Import data jemaat dari Excel akan segera tersedia.',
                  ),
                ),
              ),
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
        const SizedBox(height: 16),

        // 3 Stat Cards in Bendahara style
        Row(
          children: [
            Expanded(
              child: _buildRefinedStatCard(
                title: 'Aktif',
                value: '$_aktifCount',
                icon: Icons.check_circle_outline,
                iconBgColor: const Color(0xFFDCFCE7),
                iconColor: const Color(0xFF166534),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildRefinedStatCard(
                title: 'Pindah',
                value: '$_pindahCount',
                icon: Icons.swap_horiz_outlined,
                iconBgColor: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFF92400E),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildRefinedStatCard(
                title: 'Meninggal',
                value: '$_meninggalCount',
                icon: Icons.sentiment_dissatisfied_outlined,
                iconBgColor: const Color(0xFFF3F4F6),
                iconColor: const Color(0xFF374151),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Search & Filter Box
        Container(
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
          padding: const EdgeInsets.all(14.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (val) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Cari nama atau no. register...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.textGrey,
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: AppTheme.backgroundGrey,
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
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedSektorFilter,
                      decoration: _filterDropdownDecoration(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textDark,
                      ),
                      items:
                          [
                                'Semua Sektor',
                                'Sektor 1',
                                'Sektor 2',
                                'Sektor 3',
                                'Sektor 4',
                                'Sektor 5',
                              ]
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    s,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (val) {
                        if (val != null)
                          setState(() => _selectedSektorFilter = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedStatusFilter,
                      decoration: _filterDropdownDecoration(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textDark,
                      ),
                      items: ['Semua Status', 'Aktif', 'Pindah', 'Meninggal']
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s, overflow: TextOverflow.ellipsis),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null)
                          setState(() => _selectedStatusFilter = val);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Member Cards List
        if (filtered.isEmpty)
          _buildEmptySlot(
            icon: Icons.people_outline,
            text: 'Data jemaat tidak ditemukan.',
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildJemaatCard(filtered[index]),
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // TAB 2 CONTENT: INVENTARIS
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildInventarisContent(BuildContext context) {
    final filtered = _filteredInventaris;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Description
        const Text(
          'Inventaris & Aset',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Manajemen sarana & prasarana GKPI Cimahi',
          style: TextStyle(fontSize: 13, color: AppTheme.textGrey),
        ),
        const SizedBox(height: 16),

        // 3 Stat Cards for Inventaris
        Row(
          children: [
            Expanded(
              child: _buildRefinedStatCard(
                title: 'Kondisi Baik',
                value: '$_baikCount',
                icon: Icons.check_circle_outline,
                iconBgColor: const Color(0xFFDCFCE7),
                iconColor: const Color(0xFF166534),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildRefinedStatCard(
                title: 'Perbaikan',
                value: '$_perbaikanCount',
                icon: Icons.build_circle_outlined,
                iconBgColor: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFF92400E),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildRefinedStatCard(
                title: 'Rusak',
                value: '$_rusakCount',
                icon: Icons.cancel_outlined,
                iconBgColor: const Color(0xFFFEE2E2),
                iconColor: const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Search & Filter Box
        Container(
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
          padding: const EdgeInsets.all(14.0),
          child: Column(
            children: [
              TextField(
                controller: _inventarisSearchController,
                onChanged: (val) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Cari kode barang atau nama aset...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.textGrey,
                    size: 20,
                  ),
                  suffixIcon: _inventarisSearchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _inventarisSearchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: AppTheme.backgroundGrey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _selectedKondisiFilter,
                decoration: _filterDropdownDecoration().copyWith(
                  prefixIcon: const Icon(
                    Icons.filter_list_outlined,
                    size: 18,
                    color: AppTheme.textGrey,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppTheme.textDark,
                ),
                items: ['Semua Kondisi', 'Baik', 'Perbaikan', 'Rusak']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedKondisiFilter = val);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Items count info
        Text(
          'Menampilkan ${filtered.length} dari ${_listInventaris.length} aset',
          style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
        ),
        const SizedBox(height: 12),

        // Items List
        if (filtered.isEmpty)
          _buildEmptySlot(
            icon: Icons.inventory_2_outlined,
            text: 'Tidak ada aset yang sesuai filter.',
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (_, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = filtered[index];
              return _buildInventarisCard(item, index);
            },
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // TAB 3 CONTENT: WARTA & JADWAL
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildWartaJadwalContent(BuildContext context) {
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

        // Action Buttons row
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
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
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
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
                  horizontal: 14,
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
              label: const Text('Cetak', style: TextStyle(fontSize: 12.5)),
            ),
          ],
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
          _buildEmptySlot(
            icon: Icons.calendar_month_outlined,
            text: 'Belum ada jadwal pelayan. Klik "+ Tambah Jadwal".',
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

  // ─────────────────────────────────────────────────────────────────────────────
  // REFINED STAT CARD (Matching BendaharaScreen's _buildStatCard)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildRefinedStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textGrey,
              fontWeight: FontWeight.w500,
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

  InputDecoration _filterDropdownDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.borderGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.borderGrey),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // INVENTARIS ITEM CARD
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildInventarisCard(InventarisItem item, int index) {
    Color kondisiColor, kondisiBg;
    IconData kondisiIcon;
    if (item.kondisi == 'Baik') {
      kondisiColor = const Color(0xFF166534);
      kondisiBg = const Color(0xFFDCFCE7);
      kondisiIcon = Icons.check_circle_outline;
    } else if (item.kondisi == 'Perbaikan') {
      kondisiColor = const Color(0xFF92400E);
      kondisiBg = const Color(0xFFFEF3C7);
      kondisiIcon = Icons.build_circle_outlined;
    } else {
      kondisiColor = const Color(0xFF991B1B);
      kondisiBg = const Color(0xFFFEE2E2);
      kondisiIcon = Icons.cancel_outlined;
    }

    final isAvailable = item.status == 'Tersedia';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: Kode badge + Kondisi badge + Delete
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.kode,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: kondisiBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(kondisiIcon, size: 12, color: kondisiColor),
                    const SizedBox(width: 3),
                    Text(
                      item.kondisi == 'Baik' ? '✓ Baik' : item.kondisi,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: kondisiColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Status chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? const Color(0xFFE0F2FE)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.status,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: isAvailable
                        ? AppTheme.primaryBlue
                        : const Color(0xFF6B7280),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(
                    () => _listInventaris.removeWhere((x) => x.id == item.id),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item.namaAset} dihapus.'),
                      backgroundColor: AppTheme.buttonRed,
                    ),
                  );
                },
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: AppTheme.textGrey,
                ),
                visualDensity: VisualDensity.compact,
                tooltip: 'Hapus aset',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.namaAset,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppTheme.textGrey,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  item.lokasi,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textGrey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.format_list_numbered_outlined,
                size: 14,
                color: AppTheme.textGrey,
              ),
              const SizedBox(width: 4),
              Text(
                '${item.jumlah} Unit',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // JADWAL BADGE CARD
  // ─────────────────────────────────────────────────────────────────────────────
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
                    setState(() {
                      if (_selectedJadwal?.id == jadwal.id)
                        _selectedJadwal = null;
                      _listJadwalPelayan.removeWhere((x) => x.id == jadwal.id);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Jadwal ${jadwal.tglBadge} dihapus.'),
                        backgroundColor: AppTheme.buttonRed,
                      ),
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

  // ─────────────────────────────────────────────────────────────────────────────
  // DETAIL JADWAL CARD
  // ─────────────────────────────────────────────────────────────────────────────
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

  Widget _buildEmptySlot({required IconData icon, required String text}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.textGrey, size: 26),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textGrey, fontSize: 12.5),
          ),
        ],
      ),
    );
  }

  Widget _buildJemaatCard(JemaatMember member) {
    Color statusColor, statusBg;
    if (member.status == 'Aktif') {
      statusColor = const Color(0xFF166534);
      statusBg = const Color(0xFFDCFCE7);
    } else if (member.status == 'Pindah') {
      statusColor = const Color(0xFF92400E);
      statusBg = const Color(0xFFFEF3C7);
    } else {
      statusColor = const Color(0xFF374151);
      statusBg = const Color(0xFFF3F4F6);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                member.noRegister,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  member.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            member.namaLengkap,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.grid_view_outlined,
                size: 14,
                color: AppTheme.textGrey,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  member.sektor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.cake_outlined,
                size: 14,
                color: AppTheme.textGrey,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  member.tglLahir,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textGrey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppTheme.borderGrey, height: 1),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (member.isBaptis) _buildSakramenBadge('✓ Baptis'),
              if (member.isSidi) _buildSakramenBadge('✓ Sidi'),
              if (member.isNikah) _buildSakramenBadge('✓ Nikah'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSakramenBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryBlue,
        ),
      ),
    );
  }
}
